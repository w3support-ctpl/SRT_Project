-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDriver_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDriver_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_DriverType_Id varchar(20),
	var_Driver_Id varchar(20),
    var_Search_Text varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select mu06.Org_Id,Driver_Id,c028.DriverType_Id, c028.DriverType_Name, 
            Driver_Name, 
            Mobile_No,Driver_Id as Driver_Code,mu06.Is_Active, mu06.Is_Deleted 
            from mu06_driver mu06
			inner join c028_drivertype c028 on c028.DriverType_Id = mu06.DriverType_Id 
            where mu06.Org_Id = var_Org_Id and mu06.Is_Deleted = 0 
            and mu06.DriverType_Id like var_DriverType_Id 
            and (mu06.Driver_Name like var_Search_Text 
				or mu06.Driver_Code like var_Search_Text
                or mu06.Mobile_No like var_Search_Text
                or mu06.Pan_No like var_Search_Text)
            order by Driver_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select mu06.Org_Id, mu06.Driver_Id,mu06.Driver_Id as Driver_Code, mu06.Driver_Name, 
            date_format(mu06.Birth_Date, '%Y-%m-%d') as Birth_Date,
            date_format(mu06.Joining_Date, '%Y-%m-%d') as Joining_Date, mu06.Mobile_No, 
            mu06.DriverType_Id, mu06.DrivingLicense_No,mu06.Pan_No,mu06.Aadhar_No,
            mu06.Online_App_Flag,mu06.Is_Active, mu06.Is_Deleted, 
            CASE
					WHEN m008.Driver_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM mu06_driver mu06
			LEFT JOIN (
				SELECT DISTINCT Driver_Id
				FROM m008_route_vehicle
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m008 ON m008.Driver_Id = mu06.Driver_Id
            where mu06.Org_Id = var_Org_Id and mu06.Driver_Id = var_Driver_Id 
            and mu06.Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
