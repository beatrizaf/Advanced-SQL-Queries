SET @StartDate = '2022-03-01 00:00:00.000';
SET @EndDate = '2022-03-31 23:59:59.000';

SET @MEDIA = (SELECT AVG(Minutos) AS Media
            FROM (
              SELECT CM.CPatientId, COUNT(Timestamp) * 10 AS Minutos
              FROM (
                   SELECT * FROM NewCHospitalizationSet
                   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
              ) AS PacientesHospitalizados
              JOIN CMeasurementSet AS CM ON PacientesHospitalizados.CPatientId = CM.CPatientId
              WHERE Timestamp BETWEEN @StartDate AND @EndDate AND CM.Type = 2
              AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.params.backrest.angle') < 45
              GROUP BY CM.CPatientId
            ) AS OrderedMinutos);

SET @MEDIANA = (SELECT AVG(Minutos) AS Mediana
              FROM (
                  SELECT CM.CPatientId, COUNT(Timestamp) * 10 AS Minutos,
                         @rownum := @rownum + 1 AS RowNumber, @total_rows := @rownum
                  FROM (
                      SELECT * FROM NewCHospitalizationSet
                      WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
                  ) AS PacientesHospitalizados
                  JOIN CMeasurementSet AS CM ON PacientesHospitalizados.CPatientId = CM.CPatientId
                  CROSS JOIN (SELECT @rownum := 0, @total_rows := 0) AS vars
                  WHERE Timestamp BETWEEN @StartDate AND @EndDate AND CM.Type = 2
                  AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.params.backrest.angle') < 45
                  GROUP BY CM.CPatientId
                  ORDER BY Minutos
              ) AS OrderedMinutos
              WHERE RowNumber BETWEEN @total_rows / 2 AND @total_rows / 2 + 1);

SET @DESVIOPADRÃO = (SELECT stddev(Minutos) AS DesvioPadrão
                   FROM (
                       SELECT CM.CPatientId, COUNT(Timestamp) * 10 AS Minutos
                       FROM (
                          SELECT * FROM NewCHospitalizationSet
                          WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
                      ) AS PacientesHospitalizados
                      JOIN CMeasurementSet AS CM ON PacientesHospitalizados.CPatientId = CM.CPatientId
                      WHERE Timestamp BETWEEN @StartDate AND @EndDate AND CM.Type = 2
                      AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.params.backrest.angle') < 45
                      GROUP BY CM.CPatientId
                   ) AS OrderedMinutos);

SET @INTERQUARTIL = (SELECT Q3 - Q1 AS IQR
                   FROM (
                      SELECT
                          MIN(Minutos) AS Q1,
                          MAX(Minutos) AS Q3
                      FROM (
                          SELECT CM.CPatientId, COUNT(Timestamp) * 10 AS Minutos
                          FROM (
                              SELECT * FROM NewCHospitalizationSet
                              WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
                          ) AS PacientesHospitalizados
                          JOIN CMeasurementSet AS CM ON PacientesHospitalizados.CPatientId = CM.CPatientId
                          WHERE Timestamp BETWEEN @StartDate AND @EndDate AND CM.Type = 2
                          AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.params.backrest.angle') < 45
                          GROUP BY CM.CPatientId
                      ) AS MinutesSubquery
                   ) AS QuartisSubquery);

SELECT ROUND(@MEDIA, 4) AS Média, ROUND(@MEDIANA, 4) AS Mediana, ROUND(@DESVIOPADRÃO, 4) AS DesvioPadrão, ROUND(@INTERQUARTIL, 4) AS IQR