-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminCrateApprove_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminCrateApprove_Set`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_Dealer_Id varchar(45),
    var_ReceivedCrate_Id VARCHAR(20),
    var_Is_Approved INT,
    var_Approved_Data LONGTEXT,
    Var_Date text
)
BEGIN
SET SQL_SAFE_UPDATES = 0;

	IF(var_Method_Name = 'ApproveCrate') THEN


		SET @row_count := extractValue(var_Approved_Data,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
                
                update t038_receivedcrate_header
                set Is_Approved  = 1 ,
                Approved_On = NOW()
                where ReceivedCrate_Id = extractValue(var_Approved_Data, concat(@xpath,'/CrateRecivedId'))
                and Org_Id  = var_Org_Id;
                
			END WHILE;
    
    
    			select 1 as Result_Id, 'Updated' as Result_Description, '' as Result_Extra_Key;


		elseif(var_Method_Name = 'RejectCrate') then 
        
        SET @row_count := extractValue(var_Approved_Data,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
                
                delete from t038_receivedcrate_header
                where ReceivedCrate_Id = extractValue(var_Approved_Data, concat(@xpath,'/CrateRecivedId'))
                and Org_Id  = var_Org_Id;
                
			END WHILE;
    
    
    			select 1 as Result_Id, 'Deleted' as Result_Description, '' as Result_Extra_Key;
        
		
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
