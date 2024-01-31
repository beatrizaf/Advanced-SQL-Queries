SET @StartDate = '2022-02-01 00:00:00.000';
SET @EndDate = '2022-02-15 23:59:59.000';

SELECT
   Subquery.DrugCode,
   SUM(CAST(json_unquote(json_extract(Subquery.Volume, CONCAT('$[', json_length(Subquery.Volume) - 1, ']'))) AS DOUBLE)) AS Volume,
   SUM(CAST(json_unquote(json_extract(Subquery.Volume, CONCAT('$[', json_length(Subquery.Volume) - 1, ']'))) AS DOUBLE)) * 0.174 AS CostDrug
FROM (
   SELECT
  	  CI.DrugCode, CI.StartDate, CI.EndDate,
		  CASE
			  WHEN JSON_EXTRACT(CI.Info, '$.mode') = 1 OR JSON_EXTRACT(CI.Info, '$.mode') = 2 THEN
  			  JSON_EXTRACT(CI.Info, '$.drugQuantity')
			  WHEN JSON_EXTRACT(CI.Info, '$.mode') = 0 THEN
    			  CASE
        			  WHEN JSON_EXTRACT(CI.Info, '$.evolutions[*].cancelTotalVolume') IS NOT NULL THEN
            			  JSON_EXTRACT(CI.Info, '$.evolutions[*].cancelTotalVolume')
        			  ELSE
            			  JSON_ARRAY(JSON_EXTRACT(CI.Info, '$.totalVolume'))
  			  END
			  WHEN JSON_EXTRACT(CI.Info, '$.mode') IS NULL THEN '[0]'
  	  END AS Volume
   FROM CInfusionSet AS CI
   WHERE CI.DrugCode IN ('3', '10', '11', '19', '22', '27', '34', '69', '70', '74', '75', '76',
   				  	 '77', '78', '79', '80', '81', '152', '153', '154', '155', '156', '157',
   				  	 '160', '161', '174', '175', '176', '184', '185', '186', '187', '188')
   AND CI.StartDate <= @EndDate
   AND CI.EndDate BETWEEN @StartDate AND @EndDate
) AS Subquery
GROUP BY Subquery.DrugCode;