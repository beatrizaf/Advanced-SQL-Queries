SET @LastDate = '2024-11-10';
SET @Range = 10; #em dias

SET @Time = ( (CEIL(@Range - datediff(CURDATE(), @LastDate))) * 24 );

SELECT @Time As Time;