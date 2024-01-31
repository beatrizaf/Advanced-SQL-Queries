
SET @StartDate = '2022-03-01 00:00:00.000';
SET @EndDate = '2022-03-31 23:59:59.000';

SELECT
   SerialNumber,
   SUM(DifHoras) / 3600 AS Horas
FROM (
   SELECT
       *,
       CASE
           WHEN (StartDate >= EndDateAnterior) OR (EndDateAnterior IS NULL)  THEN
               TIMESTAMPDIFF(SECOND, StartDate, EndDate)
           WHEN (StartDate < EndDateAnterior) AND (EndDate < EndDateAnterior) THEN
               0
           WHEN (StartDate < EndDateAnterior) AND (EndDate > EndDateAnterior) THEN
               TIMESTAMPDIFF(SECOND, EndDateAnterior, EndDate)
       END AS DifHoras
   FROM
   (
       SELECT
           SerialNumber, Channel, StartDate, EndDate,
           LAG(StartDate) OVER (PARTITION BY SerialNumber ORDER BY StartDate) AS StartDateAnterior,
           LAG(EndDate) OVER (PARTITION BY SerialNumber ORDER BY StartDate) AS EndDateAnterior
       FROM CInfusionSet AS CI
       JOIN CDeviceSet AS DS ON DS.Id = CI.CDeviceId
       WHERE (CI.StartDate >= @StartDate AND CI.StartDate < @EndDate)
             AND CI.CPatientId IS NOT NULL
             AND DS.Type = 'InfusionPump'
   ) AS Subquery
) AS Result
GROUP BY SerialNumber;