-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_RunEvent_MilkRate` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_RunEvent_MilkRate`()
BEGIN
		DROP TEMPORARY TABLE IF EXISTS temp_data;
        CREATE TEMPORARY TABLE temp_data (id INT AUTO_INCREMENT PRIMARY KEY, org_id varchar(20));

        INSERT INTO temp_data(org_id)
        select DISTINCT org_id FROM f001_milk_rate where 
        Item_Applicable_Date = 
        DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d %H:%i:00') or Header_Applicable_Date =  DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d %H:%i:00') ;
        
        set @datacount = (select COUNT(*) from temp_data) ;
        set @K = 1;
	
        While @k <= @datacount do
        
        CALL USP_AdminMilkRate_Current((SELECT org_id FROM temp_data WHERE id = @K));
        
		SET @K= @K + 1 ;
        
		END WHILE;
        
        

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
