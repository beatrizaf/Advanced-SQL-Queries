SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
  DAYNAME(DATE_FORMAT(H1.End, '%Y-%m-%d %H:%i:%s')) AS DayOfWeek,
  COUNT(*) AS Count
FROM (
   SELECT * FROM NewCHospitalizationSet
   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS H1
GROUP BY DayOfWeek;