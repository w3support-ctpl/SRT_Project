-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRole_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRole_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Application_Id varchar(20),
    var_Role_Id varchar(20),
    var_Role_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select Org_Id, Role_Id, Role_Name,
            Is_Active, Is_Deleted, Is_SystemRole
            from mu01_role 
            where Org_Id = var_Org_Id 
			and Is_SystemRole = 0 
            and  Is_Deleted = 0
            and Role_Name like var_Role_Name
            order by Role_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			SELECT
				c002.Menu_Id,
				c002.Menu_Name,
				mu02.Display_Flag,
				mu02.Add_Flag,
				mu02.Edit_Flag,
				mu02.Delete_Flag
			FROM
				c002_menu c002
			LEFT JOIN
				mu02_role_menu mu02 ON c002.Menu_Id = mu02.Menu_Id AND mu02.Role_Id = var_Role_Id
			WHERE
				c002.Is_Deleted = 0
				and Application_Id = var_Application_Id
				AND EXISTS (
					SELECT 1
					FROM mu01_role mu01
					WHERE mu01.Role_Id = var_Role_Id
					AND mu01.Org_Id = var_Org_Id
					AND mu01.Is_Deleted = 0
				)
                 Order by Display_Order_Number;
		end;
	elseif (var_Method_Name = 'Get_Menu') then
		begin
			select c002.Menu_Id, c002.Menu_Name, 
            mu02.Display_Flag, mu02.Add_Flag, mu02.Edit_Flag, mu02.Delete_Flag
            from c002_menu c002 left outer join mu02_role_menu mu02 on mu02.Menu_Id = c002.Menu_Id 
            and mu02.Role_Id = var_Role_Id 
            and mu02.Org_Id = var_Org_Id
			where  c002.Application_Id = var_Application_Id 
            Order by Display_Order_Number;
		end;
	elseif (var_Method_Name = 'Get_Report') then
		begin
			select 
			c048.ReportType_Id,c048.ReportType_Name,ifnull(mu02i.Flag ,0) as Flag
			from c048_reporttype c048
			left join mu02_role_report mu02i   on
			c048.ReportType_Id = mu02i.ReportType_Id
			and mu02i.Org_Id =var_Org_Id
			and mu02i.Role_Id  = var_Role_Id
			where 
			c048.ReportGroup ='CR'; 
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
