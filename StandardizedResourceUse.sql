SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT
	SUM(TempoPermanencia) / COUNT(CASE WHEN H1.End IS NOT NULL AND Death = 0 THEN 1 END) AS SRU
FROM (
	SELECT *, ROUND(TIMESTAMPDIFF(second, Start, End) / 86400, 2) AS TempoPermanencia
	FROM (
    	SELECT * FROM NewCHospitalizationSet
    	WHERE ((End >= @StartDate) AND Start <= @EndDate) AND End <= @EndDate
	) AS subquery
) AS H1;