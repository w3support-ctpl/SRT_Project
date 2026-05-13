-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveRequest_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveRequest_Set`(
	var_Method_Name VARCHAR(20),
	var_Org_Id VARCHAR(20),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(20),
	var_Request_Id VARCHAR(20),
	var_ApprovalStatus_Id VARCHAR(20),
	var_ApprovalRemarks LONGTEXT,
	var_Request_For VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Update') THEN
    BEGIN
		UPDATE t017_incentives_request
		SET Is_Approved = var_ApprovalStatus_Id, 
			Approval_Remarks = var_ApprovalRemarks, 
			Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			Approved_Id = var_User_Id, 
			Approved_Name = var_User_Name
		WHERE Request_Id = var_Request_Id
		AND Org_Id = var_Org_Id;
    
		IF(var_ApprovalStatus_Id = '1') THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
        END;
        ELSEIF(var_ApprovalStatus_Id = '-1') THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			SELECT -1 AS Result_Id, 
			'Failed' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
        END;
        END IF;
	END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
