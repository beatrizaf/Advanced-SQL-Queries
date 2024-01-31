
SET @StartDate = '2022-07-01 00:00:00.000';
SET @EndDate = '2022-12-31 23:59:59.000';

SELECT
	COUNT(CASE WHEN Falha = 1 THEN 1 END) AS Falhas,
	(SELECT COUNT(CASE WHEN Ventilação = 1 THEN 1 END)) AS Ventilações,
	((COUNT(CASE WHEN Falha = 1 THEN 1 END) / COUNT(CASE WHEN Ventilação = 1 THEN 1 END)) * 100) AS Extubation_Failure
FROM(
	SELECT *
	FROM (
    	SELECT
         	Pacientes_hospitalizados.CPatientId,
         	Start, End,
         	StartDate, EndDate,
         	LAG(EndDate) OVER (PARTITION BY MS.CPatientId, Start ORDER BY StartDate) AS EndDateAnterior,
         	TIMESTAMPDIFF(SECOND, LAG(EndDate) OVER (PARTITION BY MS.CPatientId, Start ORDER BY StartDate), StartDate) AS Dif,
         	CASE
             	WHEN (TIMESTAMPDIFF(SECOND, LAG(EndDate) OVER (PARTITION BY MS.CPatientId, Start ORDER BY StartDate), StartDate) >= 10) OR
                     	(TIMESTAMPDIFF(SECOND, LAG(EndDate) OVER (PARTITION BY MS.CPatientId, Start ORDER BY StartDate), StartDate) IS NULL)
                 	THEN 1
         	END AS Ventilação,
         	CASE
             	WHEN TIMESTAMPDIFF(SECOND, LAG(EndDate) OVER (PARTITION BY MS.CPatientId, Start ORDER BY StartDate), StartDate) BETWEEN  10 AND 172800
                 	THEN 1
         	END AS Falha
    	FROM (
         	SELECT * FROM NewCHospitalizationSet
         	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
    	) AS Pacientes_hospitalizados
    	JOIN CDBMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
    	WHERE MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
    	AND (MS.StartDate >= DATE_SUB(@StartDate, INTERVAL 48 HOUR) AND MS.StartDate < @EndDate)
    	ORDER BY CPatientId, StartDate
	) AS Subquery
	WHERE StartDate >= @StartDate
	AND ((EndDate BETWEEN Start AND End) or (End IS NULL AND EndDate >= Start))
) AS Query;