SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
   DATE_FORMAT(H1.End, '%H:00:00') AS Hour,
   COUNT(*) AS Count
FROM (
	SELECT * FROM NewCHospitalizationSet
	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS H1
GROUP BY Hour;