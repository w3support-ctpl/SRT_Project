-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminUser_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminUser_Get`(
 	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_User_Name varchar(20),
    var_Role_Id varchar(20),
    var_Entry_User_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select mu03.Org_Id,User_Id, mu01.Role_Id, mu01.Role_Name,ifnull(Employee_Id,'') as Employee_Id, User_Name, Mobile_No, Email_Id,
            mu03.Is_Active, mu03.Is_Deleted
            from mu03_user mu03
            inner join mu01_role mu01 on mu01.Role_Id = mu03.Role_Id 
				and mu01.Org_Id = mu03.Org_Id 
            where mu03.Org_Id = var_Org_Id and mu03.Is_Deleted = 0 
			and mu03.Role_Id like var_Role_Id 
            and User_Name like var_User_Name
            order by User_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, User_Id,ifnull(Employee_Id,'') as Employee_Id, User_Name, date_format(Joining_Date, '%Y-%m-%d') as Joining_Date, Mobile_No, Role_Id, Email_Id,
            Pan_No,Aadhar_No,Is_Active, Is_Deleted, Is_PasswordReset,
            CASE Is_PasswordReset
				WHEN 1 THEN Login_Password
				WHEN 0 THEN ''
            END AS Login_Password
            from mu03_user 
            where Org_Id = var_Org_Id and User_Id = var_User_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
