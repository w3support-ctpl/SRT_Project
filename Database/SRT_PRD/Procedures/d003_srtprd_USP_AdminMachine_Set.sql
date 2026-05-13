-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMachine_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMachine_Set`(
var_Org_Id varchar(10),
var_Method_Name varchar(45),
var_Machine_Type varchar(45),
var_Machine_Value longtext
)
BEGIN
	if (var_Method_Name = 'Update') then
		begin
			if(var_Machine_Type = 'Machine1') then
				UPDATE l001_machinedata
				SET Machine1 = var_Machine_Value
				WHERE Org_Id = var_Org_Id;

				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
				
            elseif (var_Machine_Type = 'Machine2') then
	
				UPDATE l001_machinedata
				SET Machine2 = var_Machine_Value
				WHERE Org_Id = var_Org_Id;

				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;

            elseif (var_Machine_Type = 'Machine3') then
				
				UPDATE l001_machinedata
				SET Machine3 = var_Machine_Value
				WHERE Org_Id = var_Org_Id;

				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;

            end if;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
