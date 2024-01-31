SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT
	DrugCode,
	COUNT(CPatientId) AS QuantPatient,
	ROUND(SUM(Volume), 3) AS VolumeTotal,
	ROUND(SUM(Custo) / COUNT(CPatientId), 2) AS MédiaCUsto
FROM (
	SELECT
    	DrugCode, CPatientId, Start,
    	SUM(CAST(json_unquote(json_extract(Volume, CONCAT('$[', json_length(Volume) - 1, ']'))) AS DOUBLE)) AS Volume,
    	SUM(CostDrug) AS Custo
	FROM (
    	SELECT
        	CPatientId, Start,
        	Subquery.DrugCode,
        	Volume,
        	CAST(json_unquote(json_extract(Subquery.Volume, CONCAT('$[', json_length(Subquery.Volume) - 1, ']'))) AS DOUBLE) * 0.174 AS CostDrug
      	FROM (
          	SELECT
              	CI.CPatientId, Start, CI.DrugCode,
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
  		 	FROM (
  			 	SELECT * FROM NewCHospitalizationSet
  			 	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
  		 	) AS H
  		 	JOIN CInfusionSet AS CI
  		 	WHERE (H.CPatientId = CI.CPatientId)
  		 	AND CI.DrugCode IN ('3', '10', '11', '19', '22', '27', '34', '69', '70', '74', '75', '76',
                  			  '77', '78', '79', '80', '81', '152', '153', '154', '155', '156', '157',
                  			  '160', '161', '174', '175', '176', '184', '185', '186', '187', '188')
  		 	AND CI.StartDate <= @EndDate
  		 	AND CI.EndDate BETWEEN @StartDate AND @EndDate
  		 	AND ((CI.EndDate BETWEEN H.Start AND H.End) OR (H.End IS NULL AND CI.EndDate >= H.Start))
      	) AS Subquery
	) AS Query
	GROUP BY DrugCode, CPatientId, Start
) AS Final
GROUP BY DrugCode;