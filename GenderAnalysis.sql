SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
	P.Sex,
	COUNT(CONCAT_WS('_', H.CPatientId, H.Number)) AS total_patient,
	COUNT(CONCAT_WS('_', H.CPatientId, H.Number)) * 100.0 / SUM(COUNT(CONCAT_WS('_', H.CPatientId, H.Number))) OVER () AS Percent
FROM CPatientSet AS P
JOIN NewCHospitalizationSet AS H ON P.Id = H.CPatientID
WHERE (H.End IS NULL OR H.End >= @StartDate) AND H.Start <= @EndDate
GROUP BY P.Sex;