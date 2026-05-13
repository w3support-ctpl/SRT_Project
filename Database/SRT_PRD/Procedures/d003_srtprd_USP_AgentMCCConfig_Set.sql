-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCConfig_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCConfig_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Is_Morning varchar(20),
    var_Morning_Start_Time varchar(20),
    var_Morning_End_Time varchar(20),
    var_Is_Evening varchar(20),
    var_Evening_Start_Time varchar(20),
    var_Evening_End_Time varchar(20),
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            
			if exists(select MCC_Id from m005_mcc_offline_config where Org_Id = var_Org_Id 
				and MCC_Id = var_MCC_Id ) then
                        
				Update m005_mcc_offline_config
				set 
				Is_Morning = var_Is_Morning,
				Morning_Start_Time = var_Morning_Start_Time,
				Morning_End_Time = var_Morning_End_Time,
				Is_Evening = var_Is_Evening,
				Evening_Start_Time = var_Evening_Start_Time,
				Evening_End_Time = var_Evening_End_Time,
				LastEdited_On = now(),
				LastEditedBy_Id = var_User_Id,
				LastEditedBy_Name = var_User_Name
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id;
                
                SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				var_MCC_Id AS Result_Extra_Key;
			else
            
                Insert Into m005_mcc_offline_config
                (Org_Id,MCC_Id,
                Is_Morning,Morning_Start_Time,Morning_End_Time,
                Is_Evening,Evening_Start_Time,Evening_End_Time,
                Created_On,CreatedBy_Id,CreatedBy_Name)
                value(
                var_Org_Id,var_MCC_Id,
                var_Is_Morning,var_Morning_Start_Time,var_Morning_End_Time,
                var_Is_Evening,var_Evening_Start_Time,var_Evening_End_Time,
                now(),var_User_Id,var_User_Name
                );
                
                SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				var_MCC_Id AS Result_Extra_Key;
                
            end if;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
