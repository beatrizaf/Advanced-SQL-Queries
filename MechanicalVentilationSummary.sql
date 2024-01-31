SET @StartDate = '2021-12-24 00:00:00.000';
SET @EndDate = '2021-12-31 23:59:59.000';

SET @HORAS = (SELECT
                 ROUND(SUM(segundos.Seconds) / 3600, 1) AS Total_hours
             FROM (
                 SELECT
                   COUNT(CPatientId) * 600 AS seconds
                 FROM (
                     SELECT DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode
                     FROM (
                          SELECT
                              MS.CPatientId, MS.Timestamp, MS.Type, UNIX_TIMESTAMP(Timestamp) % 600 = 0 AS Time,
                              JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') AS VentilationMode
                          FROM (
                              SELECT CPatientId, Number, Start, End
                              FROM NewCHospitalizationSet
                              WHERE (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
                          ) AS Pacientes_hospitalizados
                          JOIN CMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
                          WHERE (MS.Timestamp BETWEEN @StartDate AND @EndDate)
                          AND (MS.Timestamp BETWEEN Pacientes_hospitalizados.Start and Pacientes_hospitalizados.End)
                          AND MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
                          AND Type = 2
                     ) AS Subconsulta
                     WHERE Time = 1 AND VentilationMode not in ('', 'STAND_BY')
                 ) AS Tempo_infusões
             ) AS segundos);


SET @MEDIA = (SELECT
                 ROUND(SUM(HorasVentilações),1) / COUNT(CPatientId) AS Média
             FROM (
                 SELECT CPatientId, (COUNT(DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode) * 600) / 3600 AS HorasVentilações
                 FROM (
                   SELECT
                       MS.CPatientId, MS.Timestamp, MS.Type, UNIX_TIMESTAMP(Timestamp) % 600 = 0 AS Time,
                       JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') AS VentilationMode
                   FROM (
                       SELECT CPatientId, Number, Start, End
                       FROM NewCHospitalizationSet
                       WHERE (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
                   ) AS Pacientes_hospitalizados
                   JOIN CMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
                   WHERE (MS.Timestamp BETWEEN @StartDate AND @EndDate)
                   AND (MS.Timestamp BETWEEN Pacientes_hospitalizados.Start and Pacientes_hospitalizados.End)
                   AND MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
                   AND Type = 2
                 ) AS Subconsulta
                 WHERE Time = 1 AND VentilationMode not in ('', 'STAND_BY')
                 GROUP BY CPatientId
                 ORDER BY CPatientId
             ) AS Tempo_infusões);

SET @MEDIANA = (SELECT AVG(HorasVentilacoes) AS MedianaHorasVentilacoes
FROM (
   SELECT
       CPatientId,
       (COUNT(DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode) * 600) / 3600 AS HorasVentilacoes,
       ROW_NUMBER() OVER (ORDER BY (COUNT(DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode) * 600) / 3600) AS RowAsc,
       ROW_NUMBER() OVER (ORDER BY (COUNT(DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode) * 600) / 3600 DESC) AS RowDesc
   FROM (
       SELECT
           MS.CPatientId,
           MS.Timestamp,
           MS.Type,
           UNIX_TIMESTAMP(MS.Timestamp) % 600 = 0 AS Time,
           JSON_EXTRACT(CAST(MS.value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') AS VentilationMode
       FROM (
           SELECT CPatientId, Number, Start, End
           FROM NewCHospitalizationSet
           WHERE (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
       ) AS Pacientes_hospitalizados
       JOIN CMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
       WHERE (MS.Timestamp BETWEEN @StartDate AND @EndDate)
           AND (MS.Timestamp BETWEEN Pacientes_hospitalizados.Start AND Pacientes_hospitalizados.End)
           AND MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
           AND Type = 2
   ) AS Subconsulta
   WHERE Time = 1 AND VentilationMode NOT IN ('', 'STAND_BY')
   GROUP BY CPatientId
) AS HorasVentilacoesPorPaciente
WHERE RowAsc = RowDesc OR RowAsc + 1 = RowDesc OR RowAsc - 1 = RowDesc);


SET @DESVIOPADRÃO = (SELECT STDDEV(HorasVentilações) AS DesvioPadrão
             FROM (
                 SELECT CPatientId, (COUNT(DISTINCT CPatientId, Timestamp, Type, Time, VentilationMode) * 600) / 3600 AS HorasVentilações
                 FROM (
                   SELECT
                       MS.CPatientId, MS.Timestamp, MS.Type, UNIX_TIMESTAMP(Timestamp) % 600 = 0 AS Time,
                       JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') AS VentilationMode
                   FROM (
                       SELECT CPatientId, Number, Start, End
                       FROM NewCHospitalizationSet
                       WHERE (End IS NULL OR End >= @StartDate) AND Start <= @EndDate
                   ) AS Pacientes_hospitalizados
                   JOIN CMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
                   WHERE (MS.Timestamp BETWEEN @StartDate AND @EndDate)
                   AND (MS.Timestamp BETWEEN Pacientes_hospitalizados.Start and Pacientes_hospitalizados.End)
                   AND MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
                   AND Type = 2
                 ) AS Subconsulta
                 WHERE Time = 1 AND VentilationMode not in ('', 'STAND_BY')
                 GROUP BY CPatientId
                 ORDER BY CPatientId
             ) AS Tempo_infusões);


SELECT ROUND(@HORAS,1), ROUND(@MEDIA,1), ROUND(@MEDIANA, 1), ROUND(@DESVIOPADRÃO, 1)