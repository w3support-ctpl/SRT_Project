-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCConfig_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCConfig_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			select 
            Is_Morning,Morning_Start_Time,Morning_End_Time ,
            Is_Evening,Evening_Start_Time,Evening_End_Time
			from m005_mcc_offline_config
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
