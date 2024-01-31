SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
    COUNT(CASE WHEN H1.End IS NULL OR
		   H1.End > @EndDate THEN 1 END) AS Hospitalizado,

	COUNT(CASE WHEN H1.Death = 0 AND
		  H1.End IS NOT NULL AND
		  H1.End >= @StartDate AND
		  H1.END <= @EndDate THEN 1 END) AS Alta,

	COUNT(CASE WHEN H1.Death = 1 AND
		  H1.End IS NOT NULL AND
		  H1.End >= @StartDate AND
		  H1.END <= @EndDate THEN 1 END) AS Obito,

    COALESCE((COUNT(CASE WHEN H1.End IS NULL OR
		   H1.End > @EndDate THEN 1 END) * 100.0) / COUNT(*), 0) AS Percent_Hospitalizado,

	COALESCE((COUNT(CASE WHEN H1.Death = 0 AND
		  H1.End IS NOT NULL AND
		  H1.End >= @StartDate AND
		  H1.END <= @EndDate THEN 1 END) * 100.0) / COUNT(*), 0) AS Percent_Alta,

	COALESCE((COUNT(CASE WHEN H1.Death = 1 AND
		  H1.End IS NOT NULL AND
		  H1.End >= @StartDate AND
		  H1.END <= @EndDate THEN 1 END) * 100.0) / COUNT(*), 0) AS Percent_Obito
FROM (
	SELECT * FROM NewCHospitalizationSet
	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS H1;