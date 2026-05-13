-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminNotification_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminNotification_Set`(
	var_Org_Id VARCHAR(10),
	var_Method_Name VARCHAR(45),
	var_Notification_Id VARCHAR(20),
	var_NotificationFor_Id VARCHAR(20),
	var_NotificationType_Id VARCHAR(20),
	var_ScheduleDate VARCHAR(45),
	var_Subject LONGTEXT,
	var_Message LONGTEXT,
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_Is_Active INT,
    var_Is_Deleted INT
)
BEGIN
	-- table yet to be made
	IF(var_Method_Name = 'Create') THEN
    BEGIN
		-- Declare required variabled for new record
		DECLARE New_Notification_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(10);
        -- Generate Id
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t_notification', Year_Id, 'T', '', New_Notification_Id);
			
    
		INSERT INTO notification(
			Org_Id, Notification_Id,
            NotificationFor_Id, NotificationType_Id,
            ScheduleDate, 
            NotificationSubject, NotificationMessage,
            Is_Active, Is_Deleted,
            Created_On, CreatedBy_Id, CreatedBy_Name
        )
        VALUES(
			var_Org_Id, New_Notification_Id,
            var_NotificationFor_Id, var_NotificationType_Id,
            STR_TO_DATE(var_ScheduleDate,'%Y-%m-%d'),
            var_Subject, var_Message,
            var_Is_Active, var_Is_Deleted,
			CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
        );
    
		-- Send Success Message
		SELECT 1 AS Result_Id, 
		'Created' AS Result_Description, 
		New_Notification_Id AS Result_Extra_Key;
    
    END;
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		UPDATE notification
        SET
            NotificationFor_Id = var_NotificationFor_Id, 
            NotificationType_Id = var_NotificationType_Id,
            ScheduleDate = STR_TO_DATE(var_ScheduleDate,'%Y-%m-%d'), 
            NotificationSubject = var_Subject, 
            NotificationMessage = var_Message,
            Is_Active = var_Is_Active, 
            Is_Deleted = var_Is_Deleted,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
            LastEditedBy_Id = var_User_Id, 
            LastEditedBy_Name = var_User_Name
		WHERE Notification_Id = var_Notification_Id
        AND Org_Id = var_Org_Id;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Update' AS Result_Description, 
		var_Notification_Id AS Result_Extra_Key;
        
    END;
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		UPDATE notification
        SET
            Is_Active = 0, 
            Is_Deleted = 1,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
            LastEditedBy_Id = var_User_Id, 
            LastEditedBy_Name = var_User_Name
		WHERE Notification_Id = var_Notification_Id
        AND Org_Id = var_Org_Id;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Deleted' AS Result_Description, 
		var_Notification_Id AS Result_Extra_Key;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
