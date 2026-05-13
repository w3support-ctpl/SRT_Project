-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMachine_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMachine_Get`(
var_Method_Name varchar(45),
var_Org_Id varchar(10)
)
BEGIN
	if (var_Method_Name = 'Get') then
		BEGIN
			SELECT Org_Id,Machine1,Machine2,Machine3 
			FROM l001_machinedata 
			where Org_Id = var_Org_Id;
		END;
	elseif(var_Method_Name = 'Machine1') then
		BEGIN
			SELECT Org_Id,ifnull(Machine1,'') as Machine_Data
			FROM l001_machinedata 
			where Org_Id = var_Org_Id;
		END;
	elseif(var_Method_Name = 'Machine2') then
		BEGIN
			SELECT Org_Id,ifnull(Machine2,'') as Machine_Data
			FROM l001_machinedata 
			where Org_Id = var_Org_Id;
		END;
	elseif(var_Method_Name = 'Machine3') then
		BEGIN
			SELECT Org_Id,ifnull(Machine3,'') as Machine_Data 
			FROM l001_machinedata 
			where Org_Id = var_Org_Id;
		END;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
