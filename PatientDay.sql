SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT
 	DATE_FORMAT(d.Date, '%y-%m-%d') AS Date,
 	COUNT(p.CPatientId) AS CountHospitalizations
FROM (
 	SELECT a.Date
 	FROM (
  	   SELECT curdate() - INTERVAL (a.a + (10 * b.a) + (100 * c.a) + (1000 * d.a) ) DAY as Date
  	   FROM (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as a
  	   CROSS JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as b
  	   CROSS JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as c
  	   CROSS JOIN (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as d
 	) a
 	where a.Date >= @StartDate and a.Date < @EndDate
) AS d
LEFT JOIN (
    SELECT *, CASE WHEN End IS NULL THEN DATE_ADD(@EndDate, INTERVAL 1 day) ELSE End END AS NewEnd
    FROM NewCHospitalizationSet AS H
	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS p
ON DATE_FORMAT(d.Date, '%y-%m-%d') >= DATE_FORMAT(p.Start, '%y-%m-%d') AND
DATE_FORMAT(d.Date, '%y-%m-%d') < DATE_FORMAT(p.NewEnd, '%y-%m-%d')
GROUP BY Date;