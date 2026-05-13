-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterial_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterial_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Material_Id varchar(20)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			select Material_Id,Material_Name,BaseUnit 
			from m101_mcc_material
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            and Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select Material_Id,Material_Name,BaseUnit 
			from m101_mcc_material
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            and Material_Id = var_Material_Id
            and Is_Active = 1;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
