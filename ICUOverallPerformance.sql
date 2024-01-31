
SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SET @SRU = (SELECT
 			 	SUM(TempoPermanencia) / COUNT(CASE WHEN H1.End IS NOT NULL AND Death = 0 THEN 1 END) AS SRU
     	 	FROM (
             	SELECT *, ROUND(TIMESTAMPDIFF(second, Start, End) / 86400, 2) AS TempoPermanencia
             	FROM (
                 	SELECT * FROM NewCHospitalizationSet
                 	WHERE ((End >= @StartDate) AND Start <= @EndDate) AND End <= @EndDate
             	) AS subquery
     	 	) AS H1);

SET @mortalidade_observada = (SELECT
                    			  (COUNT(CASE WHEN H1.Death = 1 AND
                                    			  H1.End IS NOT NULL AND
                                    			  H1.End >= @StartDate AND
                                    			  H1.END <= @EndDate THEN 1 END) / COUNT(*)) * 100 AS MortalidadeObservada
                			  FROM (
                    			  SELECT * FROM NewCHospitalizationSet
                             	WHERE ((End >= @StartDate) AND Start <= @EndDate) AND End <= @EndDate
                			  ) AS H1);

SET @AVGSAPS3 = (SELECT avg(valor) AS Media
  			  FROM (
     			  SELECT
         			  CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CM.Value, '"value":', -1), '}', 1) AS DECIMAL) AS valor
     			  FROM (
         			  SELECT H.CPatientId, MAX(Timestamp) AS MaxTimestamp
         			  FROM (
             			  SELECT * FROM NewCHospitalizationSet
                     	WHERE ((End >= @StartDate) AND Start <= @EndDate) AND End <= @EndDate
         			  ) AS H
         			  JOIN CMeasurementSet AS CM ON H.CPatientId = CM.CPatientId
         			  WHERE CM.Timestamp BETWEEN H.Start AND H.End
         			  AND CM.Type = 4 AND CM.SubType = 1
         			  GROUP BY CPatientId
     			  ) AS LastAppearances
     			  JOIN CMeasurementSet AS CM ON LastAppearances.CPatientId = CM.CPatientId
     			  WHERE CM.Timestamp = LastAppearances.MaxTimestamp
  			  ) AS Subquery);

SET @mortaidade_esperada_geral = ( ((EXP(-32.6659 + LOG(@AVGSAPS3 + 20.5958) * 7.3068)) / (1 + (EXP(-32.6659 + LOG(@AVGSAPS3 + 20.5958) * 7.3068)))) * 100 );

SELECT ROUND((@mortalidade_observada / @mortaidade_esperada_geral) / @SRU, 2) AS ICUEfficiency,
     	ROUND(@mortalidade_observada / @mortaidade_esperada_geral, 2) AS SMR_geral,
     	@SRU AS SRU;