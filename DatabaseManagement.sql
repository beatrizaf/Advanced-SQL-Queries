CREATE VIEW NewCHospitalizationSet AS
WITH RankedRows AS (
   SELECT
       CPatientId, Number, Start, End, FirstStart, Death,
       MAX(CASE WHEN FirstStart IS NOT NULL THEN 1 ELSE 0 END) OVER (PARTITION BY CPatientId, Number) AS HasFirstStart,
       ROW_NUMBER() OVER (PARTITION BY CPatientId, Number ORDER BY COALESCE(End, '9999-12-31') DESC) AS RowRank,
       COUNT(Number) OVER (PARTITION BY CPatientId, Number) AS CountHosp
   FROM CHospitalizationSet
)
, MergedRows AS (
   SELECT
       CPatientId, Number,
       COALESCE(MIN(COALESCE(FirstStart, Start)), MIN(Start)) AS Start,
       MAX(End) AS End,
       MAX(FirstStart) AS FirstStart,
       MAX(Death) AS Death
   FROM RankedRows
   WHERE RowRank = 1 AND (HasFirstStart = 1 OR CountHosp = 1)
   GROUP BY CPatientId, Number
)
, UnmergedRows AS (
   SELECT
       CPatientId, Number, Start , End, FirstStart, Death
   FROM RankedRows
   WHERE HasFirstStart = 0 AND CountHosp > 1
)
SELECT * FROM MergedRows UNION ALL SELECT * FROM UnmergedRows;

SELECT * FROM NewCHospitalizationSet;