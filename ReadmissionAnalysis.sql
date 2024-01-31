SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SELECT
	CPatientId,
    CASE
   	 WHEN Readmission <= 86400 THEN '24H'
   	 WHEN Readmission > 86400 AND Readmission <= 172800 THEN '48H'
   	 WHEN Readmission >  172800 THEN 'MORE48H'
    END AS Readmissions
FROM
(
    SELECT CPatientId, Start, End,
  		 LEAD(Start) OVER (PARTITION BY CPatientId ORDER BY Start) AS NextStartDate,
  		 CASE
      		 WHEN LEAD(Start) OVER (PARTITION BY CPatientId ORDER BY Start) IS NOT NULL
           		 THEN TIMESTAMPDIFF(SECOND, End, LEAD(Start) OVER (PARTITION BY CPatientId ORDER BY Start))
  		 END as Readmission
    FROM NewCHospitalizationSet
    WHERE CPatientId IN (
   	 SELECT CPatientId
   	 FROM (
   		 SELECT CPatientId, Start, End,
          		 ROW_NUMBER() OVER (PARTITION BY CPatientId ORDER BY CPatientId) AS NumHosp
   		 FROM NewCHospitalizationSet
   		 WHERE CPatientId IN (
       		 SELECT CPatientId
       		 FROM NewCHospitalizationSet
       		 WHERE (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
   		 ) AND Start <= @EndDate
   	 ) AS Subquery
   	 WHERE NumHosp > 1
    )
) AS Query;