SET @StartDate = '2022-05-01 00:00:00.000';
SET @EndDate = '2022-06-30 23:59:59.000';

SET @UseMechanical = (SELECT COUNT(DISTINCT MS.CPatientId, NumHosp)
  				   	FROM (
  				     	SELECT *, ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
  					 	FROM NewCHospitalizationSet
  					 	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
  				   	) AS H
  				   	JOIN CMeasurementSet AS MS ON H.CPatientId = MS.CPatientId
  				   	WHERE MS.CDeviceId IN ('11', '27', '28', '29', '30', '31', '32', '33', '34', '35')
  				   	AND ((Timestamp BETWEEN Start AND End) OR (End IS NULL AND Timestamp >= Start))
  				   	AND JSON_EXTRACT(CAST(value AS CHAR CHARACTER SET utf8), '$.config.general.ventilationMode.id') NOT IN ('', 'STAND_BY')
  				   	);

SET @TotalPacientes = (SELECT COUNT(*)
   					FROM NewCHospitalizationSet
   					WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SELECT @UseMechanical AS UseMechanical,
  	 @TotalPacientes - @UseMechanical AS NotUseMechanical,
  	 (@UseMechanical * 100.0) /  @TotalPacientes AS Percent_Use,
  	 ((@TotalPacientes - @UseMechanical) * 100.0) /  @TotalPacientes AS Percent_Not_Use;