SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT Date, avg(valor) AS Media,
  	avg(valor) + (stddev(valor)/2) AS "+DP",
  	avg(valor) - (stddev(valor)/2) AS "-DP"
FROM (
   SELECT DATE(MaxTimestamp) AS Date,
   	CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CM.Value, '"value":', -1), '}', 1) AS DECIMAL) AS valor
   FROM (
   	SELECT H.CPatientId, MAX(Timestamp) AS MaxTimestamp
   	FROM (
       	SELECT * FROM NewCHospitalizationSet
       	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
   	) AS H
   	JOIN CMeasurementSet AS CM ON H.CPatientId = CM.CPatientId
   	WHERE CM.Timestamp BETWEEN H.Start AND H.End
   	AND CM.Type = 4 AND CM.SubType = 1
   	GROUP BY CPatientId
   ) AS LastAppearances
   JOIN CMeasurementSet AS CM ON LastAppearances.CPatientId = CM.CPatientId
   WHERE CM.Timestamp = LastAppearances.MaxTimestamp
) AS Subquery
GROUP BY Date;