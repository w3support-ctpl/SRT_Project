-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminChemist_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminChemist_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Chemist_Id varchar(20),
    var_Search_Text varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select Org_Id,Chemist_Id,Chemist_Id as Chemist_Code,Chemist_Name,Mobile_No,date_format(Joining_Date, '%d %M %Y') as Joining_Date,Is_Active,Is_Deleted
            from mu07_routechemist 
            where Org_Id = var_Org_Id and Is_Deleted = 0 and ifnull(Is_Hidden, 0) = 0 
            and (Chemist_Name like var_Search_Text 
				or Chemist_Code like var_Search_Text
                or Mobile_No like var_Search_Text
                or Pan_No like var_Search_Text)
            order by Chemist_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, Chemist_Id,Chemist_Id as Chemist_Code, Chemist_Name, date_format(Joining_Date, '%Y-%m-%d') as Joining_Date, Mobile_No, 
			date_format(Birth_Date, '%Y-%m-%d') as Birth_Date,Pan_No,Aadhar_No,Is_Active, Is_Deleted ,Online_App_Flag as onlineapp_flag
            from mu07_routechemist 
            where Org_Id = var_Org_Id and Chemist_Id = var_Chemist_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
