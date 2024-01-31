
SET @StartDate = '2022-10-03 00:00:00.000';
SET @EndDate = '2022-12-31 23:59:59.000';

SELECT
	SUM(Failure) AS Falhas,
	COUNT(DISTINCT CPatientId) AS TotalPacientesVentilação,
	SUM(Failure) / COUNT(DISTINCT CPatientId) * 100 AS NIVM
FROM (
   SELECT *,
  	 CASE
  		 WHEN Invasivo = 'não' AND (LEAD(Invasivo) OVER (PARTITION BY CPatientId, Ventilacao ORDER BY Timestamp) = 'sim')
      		 THEN 1
  		 ELSE 0
  	 END AS Failure
   FROM (
  	 SELECT
  		 CPatientId,
  		 Timestamp,
  		 VentilationMode,
  		 CASE WHEN VentilationMode IN ('NKV_UNKNOWN','NKV_A_CMV_PC','NKV_A_CMV_VC','NKV_A_CMV_PRVC','NKV_SIMV_PC_PS','NKV_SIMV_VC_PS','NKV_SIMV_PRVC_PS','NKV_APRV',
                                		 'NKV_UNKNOWN','NKV_A_CMV_PC','NKV_A_CMV_VC','NKV_A_CMV_PRVC','NKV_SIMV_PC_PS','NKV_SIMV_VC_PS','NKV_SIMV_PRVC_PS','NKV_APRV',
                                		 'PCV_MAQUET','VCV_MAQUET','PRVC_MAQUET','VOL_SUPPORT','SIMV_VCV_PLUS_PSV_MAQUET','SIMV_PCV_PLUS_PSV_MAQUET','PSV_CPAP_MAQUET',
                                		 'VM_NOT_SUPPORTED_CIE','SIMV_PRVC_PLUS_PSV','BIVENT','NAVA','CVC_AM_ON','PRVC_AM_ON','PSV_CPAP_AM_ON','VOL_SUPPORT_1_AM_ON',
                                		 'VOL_SUPPORT_2_AM_ON','PCV','VCV','PRVC','SIMV_VCV_PLUS_PSV','SIMV_PCV_PLUS_PSV','PSV_CPAP','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED',
                                		 'APRV','TCPL','TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL','EMERGENCY','VCV','PCV','PSV_CPAP','SIMV_VCV_PLUS_PSV',
                                		 'SIMV_PCV_PLUS_PSV','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED','APRV','TCPL','TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL',
                                		 'EMERGENCY','PRVC','VCV','PCV','PSV_CPAP','SIMV_VCV_PLUS_PSV','SIMV_PCV_PLUS_PSV','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED','APRV','TCPL',
                                		 'TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL','EMERGENCY','PRVC','VCV','PCV','PSV_CPAP','SIMV_VCV_PLUS_PSV',
                                		 'SIMV_PCV_PLUS_PSV','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED','APRV','TCPL','TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL',
                                		 'EMERGENCY','PRVC','VCV','PCV','PSV_CPAP','SIMV_VCV_PLUS_PSV','SIMV_PCV_PLUS_PSV','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED','APRV','TCPL',
                                		 'TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL','EMERGENCY','PRVC','VCV','PCV','PSV_CPAP','SIMV_VCV_PLUS_PSV',
                                		 'SIMV_PCV_PLUS_PSV','MMV_PLUS_PSV','PSV_PLUS_VT_ASSURED','APRV','TCPL','TCPL_PLUS_SIMV_PSV','BACKUP_VCV','BACKUP_PCV','BACKUP_TCPL',
                                		 'EMERGENCY','PRVC','MANUAL','SIMV_PRVC_PLUS_PSV','BIVENT')
      		 	THEN 'sim'
  		 	WHEN VentilationMode IN ('', 'STAND_BY')
  		     	THEN 0
      		 ELSE 'não'
  		 END Invasivo,
  		 SUM(MudançaVentilação) OVER (PARTITION BY CPatientId ORDER BY Timestamp) AS Ventilacao
  	 FROM
  	 (
  		 SELECT
      		 Pacientes_hospitalizados.CPatientId,
      		 Timestamp,
      		 TIMESTAMPDIFF(SECOND, LAG(Timestamp) OVER (PARTITION BY Pacientes_hospitalizados.CPatientId ORDER BY Timestamp), Timestamp) AS Diff,
      		 CASE
          		 WHEN TIMESTAMPDIFF(SECOND, LAG(Timestamp) OVER (PARTITION BY Pacientes_hospitalizados.CPatientId ORDER BY Timestamp), Timestamp) >= 900
              		 OR TIMESTAMPDIFF(SECOND, LAG(Timestamp) OVER (PARTITION BY Pacientes_hospitalizados.CPatientId ORDER BY Timestamp), Timestamp) IS NULL
              		 THEN 1
          		 ELSE 0
      		 END AS MudançaVentilação,
      		 JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') AS VentilationMode
  		 FROM (
      		 SELECT * FROM NewCHospitalizationSet
      		 WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
  		 ) AS Pacientes_hospitalizados
  		 JOIN CMeasurementSet AS MS ON Pacientes_hospitalizados.CPatientId = MS.CPatientId
  		 WHERE (MS.Timestamp BETWEEN @StartDate AND @EndDate)
  		 AND (MS.Timestamp BETWEEN Start AND End)
  		 AND MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
  		 AND Type = 2
  		 AND UNIX_TIMESTAMP(Timestamp) % 600 = 0
  		 ORDER BY CPatientId
  	 ) AS Subquery
   ) AS Query
   ORDER BY CPatientId
) AS Failures
WHERE Invasivo = 'sim' or Invasivo = 'não';