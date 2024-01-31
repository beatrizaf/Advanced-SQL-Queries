SET @StartDate = '2022-10-03 00:00:00.000';
SET @EndDate = '2023-12-31 23:59:59.000';

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

SET @mortaidade_esperada_la = ( ((EXP(-64.599 + LOG(@AVGSAPS3 + 71.0599) * 13.2322)) / (1 + (EXP(-64.599 + LOG(@AVGSAPS3 + 71.0599) * 13.2322)))) * 100 );

SET @mortaidade_esperada_geral = ( ((EXP(-32.6659 + LOG(@AVGSAPS3 + 20.5958) * 7.3068)) / (1 + (EXP(-32.6659 + LOG(@AVGSAPS3 + 20.5958) * 7.3068)))) * 100 );

SELECT ROUND(@mortalidade_observada / @mortaidade_esperada_geral, 1) AS SMR_geral,
	 ROUND(@mortalidade_observada / @mortaidade_esperada_la, 1) AS SMR_LA,
	 ROUND(@mortalidade_observada, 1) AS MortalidadeObservada,
	 ROUND(@mortaidade_esperada_geral, 1) AS MortalidadeEsperadaGeral,
	 ROUND(@mortaidade_esperada_la, 1) AS MortalidadeEsperadaLA,
	 round(@AVGSAPS3, 1) AS Saps3Medio;