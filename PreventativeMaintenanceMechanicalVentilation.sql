SET @Range = 240; #em Horas
SET @UltimaManutenção = '2023-01-24';

SELECT
	(COUNT(CDeviceId) * 10 / 60) AS HorasUtilizados,
	CEIL(@Range - (COUNT(CDeviceId) * 10 / 60)) AS ProximaManutenção
FROM (
	SELECT
    	CDeviceId,
    	Timestamp
	FROM CMeasurementSet
	WHERE Timestamp BETWEEN  @UltimaManutenção AND CURDATE()
	AND UNIX_TIMESTAMP(Timestamp) % 600 = 0
	AND CPatientId IS NOT NULL
	AND CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
	AND Type = '2'
	AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') NOT IN ('', 'STAND_BY')
) AS Query;