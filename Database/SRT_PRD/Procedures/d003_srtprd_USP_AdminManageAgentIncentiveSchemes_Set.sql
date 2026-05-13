-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminManageAgentIncentiveSchemes_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminManageAgentIncentiveSchemes_Set`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_IncentiveScheme_Id VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Stop_Incentive') THEN
    BEGIN
		UPDATE m011_incentivescheme
        SET Is_Active = 0,
        LastEdited_On =  CONVERT_TZ(NOW(), '+00:00', '+00:00'),
        LastEditedBy_Id = var_User_Id,
        LastEditedBy_Name = var_User_Name
        WHERE Org_Id = var_Org_Id
        AND IncentiveScheme_Id = var_IncentiveScheme_Id;
        
        SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_IncentiveScheme_Id AS Result_Extra_Key;
        
    END;
    ELSEIF(var_Method_Name = 'Post_Incentive') THEN
    BEGIN
		UPDATE m011_incentivescheme
        SET Is_Completed = 1,
        LastEdited_On =  CONVERT_TZ(NOW(), '+00:00', '+00:00'),
        LastEditedBy_Id = var_User_Id,
        LastEditedBy_Name = var_User_Name
        WHERE Org_Id = var_Org_Id
        AND IncentiveScheme_Id = var_IncentiveScheme_Id;
        
        SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_IncentiveScheme_Id AS Result_Extra_Key;
        
    END;
    ELSEIF(var_Method_Name = 'Calculate_Incentive') THEN
    BEGIN
    
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
