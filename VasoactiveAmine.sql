SET @StartDate = '2023-01-01 00:00:00.000';
SET @EndDate = '2023-03-31 23:59:59.000';

SET @TotalPatients = (SELECT COUNT(*) FROM NewCHospitalizationSet
             		   WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate));

SET @UseAminas = (SELECT COUNT(DISTINCT CI.CPatientId, NumHosp)
   			   FROM (
                    	SELECT CPatientId, Start, End, ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
                    	FROM NewCHospitalizationSet
                    	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate)
   			   ) AS H
   			   JOIN CInfusionSet AS CI ON (H.CPatientId = CI.CPatientId)
   			   WHERE CI.DrugCode IN ('3', '10', '11', '19', '22', '27', '34', '69', '70', '74', '75', '76',
                       			  '77', '78', '79', '80', '81', '152', '153', '154', '155', '156', '157',
                       			  '160', '161', '174', '175', '176', '184', '185', '186', '187', '188')
        		   AND ((EndDate BETWEEN Start AND End) OR (End IS NULL AND EndDate >= Start))
   			   );

SET @UseAminasDischarged = (SELECT COUNT(DISTINCT CPatientId, NumHosp)
                        	FROM (
                            	SELECT CPatientId,ROW_NUMBER() OVER (ORDER BY CPatientId) AS NumHosp
                            	FROM NewCHospitalizationSet
                   		 	WHERE ((End IS NULL OR End >= @StartDate) AND Start <= @EndDate) AND Death = 0
                        	) AS H
               			 );

SET @DidntUseAminas = (@TotalPatients - @UseAminas);
SET @UseDischarged = (@UseAminas / @UseAminasDischarged);

SET @Percent_useAminas = ((@UseAminas * 100) / @TotalPatients);
SET @Percent_DidntUseAminas = ((@DidntUseAminas * 100) / @TotalPatients);

SELECT @UseAminas AS UseAminas,
    @DidntUseAminas AS DidntUseAminas,
  	 ROUND(@UseDischarged,2) AS UseDischarged,
      ROUND(@Percent_useAminas, 2) AS Percent_use,
      ROUND(@Percent_DidntUseAminas,2) AS Percent_DidntUse;