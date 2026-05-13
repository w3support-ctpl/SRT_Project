-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminApiLog_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminApiLog_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Transaction_Name varchar(45),
	var_Request_URL text,
    var_Request_Body longtext,
	var_Response_Code varchar(10),
    var_Response_Body longtext
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
		if (var_Method_Name = 'Create') then
			begin
				Declare Duplicate_Flag int;
				Declare New_Entry_Id varchar(20);
				Declare Year_Id varchar(10);
                
                set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('l002_apilog', Year_Id, 'L002', '', New_Entry_Id );
                
                Insert Into l002_apilog
                (Org_Id, Entry_Id, Entry_Date,Transaction_Name,
                Request_URL, Request_Body, 
				Response_Code, Response_Body)
				Values (var_Org_Id, New_Entry_Id, CONVERT_TZ(NOW(), '+00:00', '+00:00'),var_Transaction_Name,
                var_Request_URL, var_Request_Body, 
				var_Response_Code, var_Response_Body);

				SELECT 
				1 AS Result_Id,
				'Saved' AS Result_Description,
				New_Entry_Id AS Result_Extra_Key;
				
            end;
		end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
