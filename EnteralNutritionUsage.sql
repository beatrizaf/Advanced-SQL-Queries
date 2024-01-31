SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SET @TotalPatients = (SELECT COUNT(*) FROM NewCHospitalizationSet
              		   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SET @utilizouInfusao = (SELECT COUNT(DISTINCT CI.CPatientId, NumHosp)
          				 FROM (
                        	SELECT CPatientId, Start, End, ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
               		 	FROM NewCHospitalizationSet
               		 	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
         				 ) AS H
         				 JOIN CInfusionSet AS CI ON (H.CPatientId = CI.CPatientId)
         				 WHERE ((EndDate BETWEEN Start AND End) OR (End IS NULL AND EndDate >= Start))
    			     	);

SET @NaoUtilizouInfusao = (@TotalPatients - @utilizouInfusao);

SET @UtilizouNutrição = (SELECT COUNT(DISTINCT CI.CPatientId, NumHosp)
       				  FROM (
       				       SELECT CPatientId, Start, End, ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
               		  	FROM NewCHospitalizationSet
               		  	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
       				  ) AS H
       				  JOIN CInfusionSet AS CI ON (H.CPatientId = CI.CPatientId)
         				  WHERE ((EndDate BETWEEN Start AND End) OR (End IS NULL AND EndDate >= Start))
       				  AND (CI.DrugCode = '0' OR CI.DrugCode = '406')
       				  );

SET @NaoUtilizouNutrição = (@TotalPatients - @UtilizouNutrição - @NaoUtilizouInfusao);

SELECT @UtilizouNutrição AS Used,
  	 ROUND((@UtilizouNutrição / @TotalPatients) * 100, 2) AS Percent_Used,
  	 FLOOR(@NaoUtilizouNutrição) AS DidntUse,
  	 ROUND((@NaoUtilizouNutrição / @TotalPatients) * 100,2) AS Percent_DidntUse,
  	 FLOOR(@NaoUtilizouInfusao) AS HasntInfusion,
  	 ROUND((@NaoUtilizouInfusao / @TotalPatients) * 100, 2)AS Percent_HasntInfusion;