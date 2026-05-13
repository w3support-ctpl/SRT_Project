-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDistrict_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDistrict_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_State_Id varchar(20),
    var_District_Id varchar(20),
    var_District_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select ml03.Org_Id, ml02.State_Id,ml02.State_Name, District_Id, District_Name,District_Id as District_Code,
            ml03.Is_Active, ml03.Is_Deleted 
            from ml03_district ml03
            inner join ml02_state ml02 on ml02.State_Id = ml03.State_Id
            and ml02.Org_Id = ml03.Org_Id
            where ml03.Org_Id = var_Org_Id and ml03.Is_Deleted = 0 
            and ml03.State_Id like var_State_Id 
            and District_Name like var_District_Name
            order by District_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			 SELECT 
			ml03.Org_Id, ml03.State_Id, ml03.District_Id, ml03.District_Name,ml03.District_Id as District_Code,
            ml03.Is_Active, ml03.Is_Deleted,
				CASE
					WHEN ml04.District_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM ml03_district ml03
			LEFT JOIN (
				SELECT DISTINCT District_Id
				FROM ml04_taluka
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) ml04 ON ml04.District_Id = ml03.District_Id
			WHERE ml03.Org_Id = var_Org_Id 
				AND ml03.District_Id = var_District_Id
				AND ml03.Is_Deleted = 0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
