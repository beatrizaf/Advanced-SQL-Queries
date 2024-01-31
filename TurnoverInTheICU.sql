SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
   (COUNT(CASE WHEN H1.End IS NOT NULL AND
  	 H1.End >= @StartDate AND
  	 H1.END <= @EndDate THEN 1 END) /
   (64 * DATEDIFF(DATE_ADD(@EndDate, INTERVAL 1 day), @StartDate))) * 100 AS Turnover
FROM (
   SELECT * FROM NewCHospitalizationSet
   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS H1;