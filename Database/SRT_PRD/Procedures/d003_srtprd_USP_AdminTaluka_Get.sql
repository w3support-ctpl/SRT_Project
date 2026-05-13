-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTaluka_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTaluka_Get`(
    var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_State_Id varchar(20),
    var_District_Id varchar(20),
    var_Taluka_Id varchar(20),
    var_Taluka_Name varchar(50)
)
BEGIN
    if (var_Method_Name = 'Get') then
        begin
            select ml04.Org_Id, ml02.State_Id, ml02.State_Name, ml03.District_Id, ml03.District_Name, 
            Taluka_Id, Taluka_Name,Taluka_Id as Taluka_Code, ml04.Is_Active, ml04.Is_Deleted 
            from ml04_taluka ml04
            inner join ml02_state ml02 on ml02.State_Id = ml04.State_Id
				and ml02.Org_Id = ml04.Org_Id
            inner join ml03_district ml03 on ml03.District_Id = ml04.District_Id
				and ml03.Org_Id = ml04.Org_Id
            where ml04.Org_Id = var_Org_Id and ml04.Is_Deleted = 0 
            and ml04.State_Id like var_State_Id 
            and ml04.District_Id like var_District_Id 
            and Taluka_Name like  var_Taluka_Name
            order by Taluka_Name;
        end;
    elseif (var_Method_Name = 'Get_One') then
        begin
            select ml04.Org_Id, ml04.State_Id, ml04.District_Id, ml04.Taluka_Id, ml04.Taluka_Name, 
            ml04.Taluka_Id as Taluka_Code,ml04.Is_Active, ml04.Is_Deleted ,
            CASE
					WHEN ml05.Taluka_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM ml04_taluka ml04
			LEFT JOIN (
				SELECT DISTINCT Taluka_Id
				FROM ml05_village
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) ml05 ON ml05.Taluka_Id = ml04.Taluka_Id
            where ml04.Org_Id = var_Org_Id and ml04.Taluka_Id = var_Taluka_Id 
            and ml04.Is_Deleted = 0;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
