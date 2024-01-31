
SET @StartDate = '2022-03-01 00:00:00.000';
SET @EndDate = '2022-03-31 23:59:59.000';

SELECT
   SerialNumber,
   CEIL(SUM(TIMESTAMPDIFF(SECOND, MS.StartDate, MS.EndDate)) / 3600) AS DifHoras
FROM CDBMeasurementSet AS MS
JOIN CDeviceSet AS DS ON DS.Id = MS.CDeviceId
WHERE (MS.StartDate >= @StartDate AND MS.StartDate < @EndDate)
AND MS.CPatientId IS NOT NULL
AND DS.Type = 'Respirator'
GROUP BY SerialNumber
ORDER BY SerialNumber;