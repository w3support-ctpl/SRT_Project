-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRoleMenu_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRoleMenu_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(20),
	var_Role_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'GetAdminMenu') then
		SELECT c002_menu.Menu_Id, c002_menu.Menu_Name, c002_menu.Menu_Level, 
		c002_menu.Parent_Menu_Id, ifnull(c002_menu.Display_Order_Number,0) as Display_Order_Number, 
		c002_menu.Menu_Link, c002_menu.Menu_Icon_Name, c002_menu.Menu_Tooltip,
		ifnull(mu02_role_menu.Display_Flag,0) as Display_Flag,
		ifnull(mu02_role_menu.Add_Flag,0) as Add_Flag , 
        ifnull(mu02_role_menu.Edit_Flag,0) as Edit_Flag , 
		ifnull(mu02_role_menu.Delete_Flag,0) as Delete_Flag 
		
		from mu02_role_menu inner join c002_menu on mu02_role_menu.Menu_Id = c002_menu.Menu_Id

		where mu02_role_menu.Org_Id = var_Org_Id  and mu02_role_menu.Role_Id = var_Role_Id 
		and c002_menu.Is_Active =1 and c002_menu.Is_Deleted =0 and c002_menu.Application_Id = 'MI'
		and mu02_role_menu.Display_Flag = 1 

		order by c002_menu.Display_Order_Number;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
