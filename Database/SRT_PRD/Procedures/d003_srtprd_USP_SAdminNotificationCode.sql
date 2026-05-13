-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminNotificationCode` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminNotificationCode`(
var_method_name varchar(50),
var_org_id varchar(20),
var_xml_data longtext
)
BEGIN

	if(var_method_name = 'InspectionCode_1') then
    begin
			Declare Year_Id varchar(10);
            DECLARE New_NotificationCode_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            set Year_Id = (select right(left(curdate(),4),(2)));
        
		SET @row_count := extractValue(var_XML_Data,'count(//Data/InspectionCode_1)');
			
		WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Data/InspectionCode_1[', k, ']');
                
                IF EXISTS (SELECT 1 FROM c051_notificationcode WHERE Org_Id = var_Org_Id AND NotificationCode_Id = extractValue(var_xml_data, concat(xpath,'/InspectionCode_1'))) THEN
                    -- Update existing record
                    UPDATE c051_notificationcode AS c051
                    SET c051.NotificationCode_Name = extractValue(var_xml_data, concat(xpath,'/InspectionCodeText'))
                    WHERE c051.Org_Id = var_Org_Id 
                    AND c051.NotificationCode_Id = extractValue(var_xml_data, concat(xpath,'/InspectionCode_1'));
                ELSE
					CALL USP_Number_Range ('c051_notificationcode', Year_Id, 'C051', '', New_NotificationCode_Id );
                    -- Insert new record
                    INSERT INTO c051_notificationcode (Org_Id, NotificationCode_Id, NotificationCode_Name)
                    VALUES (var_Org_Id, New_NotificationCode_Id, extractValue(var_xml_data, concat(xpath,'/InspectionCode_1')), extractValue(var_xml_data, concat(xpath,'/InspectionCodeText')));
                END IF;
			END WHILE;
        
          SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		'' AS Result_Extra_Key;
		end;
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
