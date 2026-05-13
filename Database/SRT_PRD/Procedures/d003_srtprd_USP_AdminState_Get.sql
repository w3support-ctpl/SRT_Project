-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminState_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminState_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_State_Id varchar(20),
    var_State_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select Org_Id, State_Id,State_Name,State_Code,Is_Active, Is_Deleted 
            from ml02_state 
			where Org_Id = var_Org_Id and Is_Deleted = 0 
            and State_Name like var_State_Name
            order by State_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, State_Id, State_Name, Is_Active, Is_Deleted 
            from ml02_state 
            where Org_Id = var_Org_Id and State_Id = var_State_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
