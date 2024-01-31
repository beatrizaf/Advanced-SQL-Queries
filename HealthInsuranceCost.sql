SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT
    Subquery.CostSUS * COUNT(Date) AS TotalCostSus,
    Subquery.CostPrivate * COUNT(Date) AS TotalCostPrivate
FROM (
	SELECT
  	 	CPatientId, Start, End,
   	 COUNT(CASE WHEN HealthInsurance = 'sus' THEN 1 END) * 49 AS CostSUS,
   	 COUNT(CASE WHEN HealthInsurance = 'private' THEN 1 END) * 79 AS CostPrivate,
   	 DATE_FORMAT(d.Date, '%y-%m-%d') AS Date
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
    	SELECT CPatientId, Number, P.HealthInsurance,
  			 CASE WHEN Start < @StartDate THEN @StartDate ELSE Start END AS Start,
  			 CASE WHEN End > @EndDate THEN DATE_ADD(@EndDate, INTERVAL 1 day) ELSE End END AS End
  	 	FROM NewCHospitalizationSet AS H1
  	 	JOIN CPatientSet AS P ON H1.CPatientId = P.Id
  	 	WHERE P.HealthInsurance = 'sus' or P.HealthInsurance = 'private'
  	 	GROUP BY CPatientId, Number, P.HealthInsurance, Start, End
  	 	HAVING (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
	) AS p
	ON DATE_FORMAT(d.Date, '%y-%m-%d') >= DATE_FORMAT(p.Start, '%y-%m-%d') AND
	DATE_FORMAT(d.Date, '%y-%m-%d') < DATE_FORMAT(p.End, '%y-%m-%d')
	GROUP BY CPatientId, Start, End, Date
) AS Subquery
GROUP BY CostPrivate, CostSUS;