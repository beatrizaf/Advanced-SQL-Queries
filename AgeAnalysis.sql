SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT
	COUNT(CASE WHEN age.Idade <= 1 THEN 1 END) AS Less_1,
	COUNT(CASE WHEN age.Idade > 1 AND age.Idade <= 6 THEN 1 END) AS 1_6,
	COUNT(CASE WHEN age.Idade >= 7 AND age.Idade <= 12 THEN 1 END) AS 7_12,
	COUNT(CASE WHEN age.Idade >= 13 AND age.Idade <= 18 THEN 1 END) AS 13_18,
	COUNT(CASE WHEN age.Idade >= 19 AND age.Idade <= 35 THEN 1 END) AS 19_35,
	COUNT(CASE WHEN age.Idade >= 36 AND age.Idade <= 45 THEN 1 END) AS 36_45,
	COUNT(CASE WHEN age.Idade >= 46 AND age.Idade <= 55 THEN 1 END) AS 46_55,
	COUNT(CASE WHEN age.Idade >= 56 AND age.Idade <= 64 THEN 1 END) AS 56_64,
	COUNT(CASE WHEN age.Idade >= 65 AND age.Idade <= 80 THEN 1 END) AS 65_80,
	COUNT(CASE WHEN age.Idade > 80 THEN 1 END) AS Over_80,
	COUNT(CASE WHEN age.Idade IS NULL THEN 1 END) AS Not_Defined,

	(COUNT(CASE WHEN age.Idade <= 1 THEN 1 END)) * 100 / COUNT(*) AS Percent_Less1,
	(COUNT(CASE WHEN age.Idade > 1 AND age.Idade <= 6 THEN 1 END)) * 100 / COUNT(*) AS Percent_1_6,
	(COUNT(CASE WHEN age.Idade >= 7 AND age.Idade <= 12 THEN 1 END)) * 100 / COUNT(*) AS Percent_7_12,
	(COUNT(CASE WHEN age.Idade >= 13 AND age.Idade <= 18 THEN 1 END)) * 100 / COUNT(*) AS Percent_13_18,
	(COUNT(CASE WHEN age.Idade >= 19 AND age.Idade <= 35 THEN 1 END)) * 100 / COUNT(*) AS Percent_19_35,
	(COUNT(CASE WHEN age.Idade >= 36 AND age.Idade <= 45 THEN 1 END)) * 100 / COUNT(*) AS Percent_36_45,
	(COUNT(CASE WHEN age.Idade >= 46 AND age.Idade <= 55 THEN 1 END)) * 100 / COUNT(*) AS Percent_46_55,
	(COUNT(CASE WHEN age.Idade >= 56 AND age.Idade <= 64 THEN 1 END)) * 100 / COUNT(*) AS Percent_56_64,
	(COUNT(CASE WHEN age.Idade >= 65 AND age.Idade <= 80 THEN 1 END)) * 100 / COUNT(*) AS Percent_65_80,
	(COUNT(CASE WHEN age.Idade > 80 THEN 1 END)) * 100 / COUNT(*) AS Percent_Over80,
    (COUNT(CASE WHEN age.Idade IS NULL THEN 1 END)) * 100 / COUNT(*) AS Percent_NotDefined
FROM (
    SELECT CPatientId, Start, BirthDate, FLOOR(DATEDIFF(Start, BirthDate) / 365.25) AS Idade
    FROM NewCHospitalizationSet
    JOIN CPatientSet ON CPatientSet.Id = CPatientId
	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
) AS age;