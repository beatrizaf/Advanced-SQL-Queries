SET @StartDate = '2022-07-01 00:00:00.000';
SET @EndDate = '2022-12-31 23:59:59.000';

SELECT
	DrugCode,
	Volume,
	CASE
  	  WHEN DrugCode IN ('3', '10', '11', '19', '22', '27', '34', '69', '70', '74', '75', '76',
                 		 '77', '78', '79', '80', '81', '152', '153', '154', '155', '156', '157',
                 		 '160', '161', '174', '175', '176', '184', '185', '186', '187', '188') THEN
  		  ROUND(Volume * 0.174, 2)

  	  WHEN DrugCode IN ('0', '406') THEN
  		  ROUND(Volume * 1.06, 2)

  	  WHEN DrugCode IN ('12', '21', '23', '28', '59', '91', '92', '104', '114', '150', '162', '163', '243', '264', '266') THEN
  		  ROUND(Volume * 0.1604, 2)

  	  WHEN Subquery.DrugCode IN ('220', '352', '380', '422', '423', '424') THEN
  		  ROUND(Volume * 1.3096, 2)
	END AS CostDrug
FROM (
    SELECT
  	 Subquery.DrugCode,
  	 ROUND(SUM(CAST(json_unquote(json_extract(Volume, CONCAT('$[', json_length(Volume) - 1, ']'))) AS DOUBLE)), 3) AS Volume
    FROM (
  	 SELECT
    		 CI.DrugCode,
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
                   		 '160', '161', '174', '175', '176', '184', '185', '186', '187', '188', '0', '406',
                    		 '12', '21', '23', '28', '59', '91', '92', '104', '114', '150', '162', '163', '243',
                    		 '264', '266', '220', '352', '380', '422', '423', '424')
  	 AND CI.StartDate <= @EndDate
  	 AND CI.EndDate BETWEEN @StartDate AND @EndDate
    ) AS Subquery
    GROUP BY Subquery.DrugCode
) AS Subquery
GROUP BY Subquery.DrugCode, CostDrug;