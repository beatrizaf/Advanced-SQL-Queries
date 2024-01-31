SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SELECT DATE_FORMAT(patients.Start, '%y-%m-%d') AS Date, COUNT(DATE_FORMAT(patients.Start, '%y-%m-%d')) AS CountAdmissions
FROM(
    SELECT * FROM NewCHospitalizationSet
    WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS patients
WHERE patients.Start BETWEEN @StartDate AND @EndDate
GROUP BY Date;