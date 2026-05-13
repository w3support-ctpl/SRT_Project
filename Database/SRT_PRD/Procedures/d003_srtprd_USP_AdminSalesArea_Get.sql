-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSalesArea_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSalesArea_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_SalesArea_Id varchar(20),
    var_SalesArea_Name varchar(50),
    var_SalesArea_Code varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select Org_Id,SalesArea_Id, SalesArea_Name, SalesArea_Code,Is_Active,Is_Deleted
            from m013_salesarea 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and SalesArea_Name like var_SalesArea_Name
            and SalesArea_Code like var_SalesArea_Code
            -- order by SalesArea_Name;
            order by Created_On DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,SalesArea_Id, SalesArea_Name, SalesArea_Code,Is_Active,Is_Deleted
            from m013_salesarea 
            where Org_Id = var_Org_Id and SalesArea_Id = var_SalesArea_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
