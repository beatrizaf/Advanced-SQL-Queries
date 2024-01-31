SET @StartDate = '2022-10-03 00:00:00.000';
SET @EndDate = '2022-12-31 23:59:59.000';

SELECT
	COUNT(DISTINCT Subquery.Id) AS NumBombas,
	COUNT(DISTINCT Subquery.Id) / 64 AS PumpsByBed
FROM (
	SELECT DISTINCT DS.Id, DS.type, CI.StartDate, CI.EndDate, CI.CPatientId
	FROM CDeviceSet DS
	JOIN CInfusionSet AS CI ON DS.Id = CI.CDeviceId
	WHERE DS.Type = 'InfusionPump' AND
      	(CI.StartDate >= @StartDate AND CI.StartDate < @EndDate) OR
      	(CI.StartDate < @StartDate AND CI.EndDate >= @StartDate)
) AS Subquery;

