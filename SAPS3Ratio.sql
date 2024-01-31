SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SET @TotalPatients = (SELECT COUNT(*) FROM NewCHospitalizationSet
                  	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SELECT
    COALESCE(SUM(CASE WHEN valor >= 29 AND valor <= 56 THEN 1 ELSE 0 END), 0) AS medio,
    COALESCE(SUM(CASE WHEN valor < 29 THEN 1 ELSE 0 END), 0) AS baixo,
    COALESCE(SUM(CASE WHEN valor > 56 THEN 1 ELSE 0 END), 0) AS alto,
    (@TotalPatients - COALESCE(SUM(CASE WHEN valor >= 29 AND valor <= 56 THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN valor < 29 THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN valor > 56 THEN 1 ELSE 0 END), 0) ) AS Not_defined,
	COALESCE(SUM(CASE WHEN valor >= 29 AND valor <= 56 THEN 1 ELSE 0 END), 0) * 100 / @TotalPatients AS Percent_medio,
	COALESCE(SUM(CASE WHEN valor < 29 THEN 1 ELSE 0 END), 0) * 100 / @TotalPatients AS Percent_baixo,
	COALESCE(SUM(CASE WHEN valor > 56 THEN 1 ELSE 0 END), 0) * 100 / @TotalPatients AS Percent_alto,
	(@TotalPatients - COALESCE(SUM(CASE WHEN valor >= 29 AND valor <= 56 THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN valor < 29 THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN valor > 56 THEN 1 ELSE 0 END), 0)) * 100 / @TotalPatients AS Percent_NotDefined
FROM (
	SELECT
    	LastAppearances.CPatientId,
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
) AS Classificacoes;