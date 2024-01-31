
SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SET @TotalPatients = (SELECT COUNT(*) FROM NewCHospitalizationSet
             		   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SELECT
    COUNT(CASE WHEN HealthInsurance = 'sus' THEN 1 END) AS SUS,
    COUNT(CASE WHEN HealthInsurance = 'private' THEN 1 END)  AS Private,
    @TotalPatients - COUNT(CASE WHEN HealthInsurance = 'sus' THEN 1 END) - COUNT(CASE WHEN HealthInsurance = 'private' THEN 1 END) AS NotDefined,
    ((@TotalPatients - COUNT(CASE WHEN HealthInsurance = 'sus' THEN 1 END) - COUNT(CASE WHEN HealthInsurance = 'private' THEN 1 END)) * 100) / @TotalPatients AS Percent_NotDefined,
    (COUNT(CASE WHEN HealthInsurance = 'sus' THEN 1 END) * 100) / @TotalPatients AS Percent_SUS,
    (COUNT(CASE WHEN HealthInsurance = 'private' THEN 1 END) * 100) / @TotalPatients AS Percent_Private
FROM CPatientSet AS P
JOIN NewCHospitalizationSet AS H ON P.Id = H.CPatientID
WHERE (H.End IS NULL OR H.End >= @StartDate) AND H.Start <= @EndDate;