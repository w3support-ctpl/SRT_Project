-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminNotification_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminNotification_Get`(
	var_Org_Id VARCHAR(10),
	var_Method_Name VARCHAR(45),
	var_Date LONGTEXT,
	var_Notification_Id VARCHAR(20)
)
BEGIN
	-- table yet to be made
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
		SELECT Org_Id, Notification_Id,
            NotificationFor_Id, NotificationType_Id,
            DATE_FORMAT(ds_header.ScheduleDate, '%d %M %Y') AS ScheduleDate,
            NotificationSubject, NotificationMessage,
            Is_Active, Is_Deleted
		FROM notification
        WHERE Is_Deleted = 0
        AND CAST(ds_header.ScheduleDate AS DATE) >= var_StartDate 
		AND CAST(ds_header.ScheduleDate AS DATE) <= var_EndDate;
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT Org_Id, Notification_Id,
            NotificationFor_Id, NotificationType_Id,
            ScheduleDate,
            NotificationSubject, NotificationMessage,
            Is_Active, Is_Deleted
		FROM notification
        WHERE Is_Deleted = 0
        AND Notification_Id = var_Notification_Id;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
