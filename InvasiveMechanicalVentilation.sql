SET @StartDate = '2022-01-01 00:00:00.000';
SET @EndDate = '2022-01-08 23:59:59.000';

SET @TotalPatients = (SELECT COUNT(*) FROM NewCHospitalizationSet
             		   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SET @UseInvasive = (SELECT COUNT(DISTINCT MS.CPatientId, NumHosp)
                	FROM (
                    	SELECT *, ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
                    	FROM NewCHospitalizationSet
                    	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
                	) AS H
                	JOIN CMeasurementSet AS MS ON H.CPatientId = MS.CPatientId
                	WHERE MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
                	AND ((Timestamp BETWEEN Start AND End) OR (End IS NULL AND Timestamp >= Start))
                	AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id')
                	IN ('NKV_UNKNOWN','NKV_A_CMV_PC','NKV_A_CMV_VC','NKV_A_CMV_PRVC','NKV_SIMV_PC_PS','NKV_SIMV_VC_PS','NKV_SIMV_PRVC_PS','NKV_APRV',
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
                	);

SET @Discharged = (SELECT COUNT(DISTINCT CPatientId, NumHosp)
                   		   FROM (
                       		 SELECT CPatientId,ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
                       		 FROM NewCHospitalizationSet
              			        WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate) AND Death = 0
                   		  ) AS H
          				  	);

SET @DidntUseInvasive = (@TotalPatients - @UseInvasive);

SET @UseDischarged = (@UseInvasive / @Discharged);

SET @Percent_UseInvasive= ((@UseInvasive * 100) / @TotalPatients);
SET @Percent_DidntUseInvasive = ((@DidntUseInvasive * 100) / @TotalPatients);

SELECT @UseInvasive AS UseInvasive,
   	@DidntUseInvasive AS DidntUseInvasive,
   	ROUND(@UseDischarged,2) AS UseDischarged,
     	ROUND(@Percent_UseInvasive, 2) AS Percent_use,
     	ROUND(@Percent_DidntUseInvasive,2) AS Percent_DidntUse;