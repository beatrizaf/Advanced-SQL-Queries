SET @StartDate = '2022-10-03 00:00:00.000';
SET @EndDate = '2022-12-31 23:59:59.000';

SELECT
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
) AS segundos;