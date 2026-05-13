-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerStatus` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerStatus`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Farmer_Id varchar(20),
Var_Profile_Id varchar(20),
var_Status varchar(20)
)
BEGIN
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    set sql_mode = '';
    
    if(Var_Method_Name = 'Get')then
		begin
			select Is_Offline from mu04_farmer mu04
			where mu04.Org_Id = Var_Org_Id
			and mu04.MCC_Id = Var_MCC_Id
			and mu04.Farmer_Id = Var_Farmer_Id;
		end;
	elseif(Var_Method_Name = 'Update')then
		begin
			update mu04_farmer
            set Is_Active = var_Status
            where mu04.Org_Id = Var_Org_Id
			and mu04.MCC_Id = Var_MCC_Id
			and mu04.Farmer_Id = Var_Farmer_Id;
		end;
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
