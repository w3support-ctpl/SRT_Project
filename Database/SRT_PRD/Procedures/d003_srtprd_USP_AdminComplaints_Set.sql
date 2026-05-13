-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminComplaints_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminComplaints_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_Complaint_Id VARCHAR(20),
    var_Remarks VARCHAR(45),
    var_Display_Flag INT,
    var_NewStatus_Id VARCHAR(20),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45)
)
BEGIN
	DECLARE New_ComplaintItem_Id varchar(20);
	DECLARE Year_Id varchar(10);
	DECLARE var_CurrentStatus_Id VARCHAR(45);
    DECLARE var_ComplaintStatus_Name VARCHAR(45);

	IF(var_Method_Name = 'Create') THEN
    BEGIN
    
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t016_complaint_item', Year_Id, 'T0016', '', New_ComplaintItem_Id);
		SET var_CurrentStatus_Id = (
			SELECT ComplaintStatus_Id
            FROM t016_complaint_header
            WHERE Complaint_Id = var_Complaint_Id
        );
        SET var_ComplaintStatus_Name = (
			SELECT ComplaintStatus_Name
            FROM c035_complaintstatus
            WHERE ComplaintStatus_Id = var_NewStatus_Id
        );
		
        INSERT INTO t016_complaint_item(
			Org_Id, Complaint_Id, Entry_Id, 
            Action_Date, Action_By_Id, 
            Action_By_Name, Remarks, Is_Display, 
            New_Status_Id, Current_Status_Id
        )
        VALUES(
			var_Org_Id, var_Complaint_Id, New_ComplaintItem_Id, 
            CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, 
            var_User_Name, var_Remarks, var_Display_Flag, 
            var_NewStatus_Id, var_CurrentStatus_Id
        );
        
        UPDATE t016_complaint_header
        SET ComplaintStatus_Id = var_NewStatus_Id
        WHERE Complaint_Id = var_Complaint_Id;
        
        
        IF(var_NewStatus_Id = 'C035003') THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Resolved' AS Result_Description, 
			var_Complaint_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			SELECT 1 AS Result_Id, 
			'Opened' AS Result_Description, 
			var_Complaint_Id AS Result_Extra_Key;
        END;
        END IF;
        
        
        
        
        /*
        -- to update status
        UPDATE t016_complaint_item
        SET Org_Id = var_Org_Id, 
			Complaint_Id = var_Complaint_Id, 
			Entry_Id = New_ComplaintItem_Id, 
            Action_Date = Now(), 
            Action_By_Id = var_User_Id, 
            Action_By_Name = var_User_Name, 
			Remarks = var_Remarks, 
            Is_Display = var_Display_Flag, 
            New_Status_Id = var_NewStatus_Id, 
            Current_Status_Id = var_CurrentStatus_Id
		WHERE 
        
        */    
		
    
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
