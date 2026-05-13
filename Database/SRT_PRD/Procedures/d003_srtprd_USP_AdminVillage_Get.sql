-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminVillage_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminVillage_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_State_Id varchar(20),
    var_District_Id varchar(20),
    var_Taluka_Id varchar(20),
    var_Village_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select ml05.Org_Id,ml02.State_Id,ml02.State_Name, ml03.District_Id,ml03.District_Name,
            ml04.Taluka_Id,ml04.Taluka_Name, Village_Id, Village_Name, 
            ml05.Is_Active, ml05.Is_Deleted 
            from ml05_village ml05
			inner join ml02_state ml02 ON ml02.State_Id = ml05.State_Id 
				and ml02.Org_Id = ml05.Org_Id
            inner join ml03_district ml03 ON ml03.District_Id = ml05.District_Id
				and ml03.Org_Id = ml05.Org_Id
			inner join ml04_taluka ml04 ON ml04.Taluka_Id = ml05.Taluka_Id 
				and ml04.Org_Id = ml05.Org_Id
            where ml05.Org_Id = var_Org_Id and ml05.Is_Deleted = 0 
            and ml05.State_Id like var_State_Id 
            and ml05.District_Id like var_District_Id 
            and ml05.Taluka_Id like var_Taluka_Id 
            order by Village_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
            
            SELECT ml05.Org_Id,ml05.State_Id, ml05.District_Id,ml05.Taluka_Id, ml05.Village_Id, 
            ml05.Village_Name,ml05.Pin_Code,ml05.Is_Active,ml05.Is_Deleted,
				   CASE
					   WHEN m005.Village_Id IS NOT NULL
							OR m009.Village_Id IS NOT NULL
							OR mu04.Village_Id IS NOT NULL
							OR mu05.Village_Id IS NOT NULL
					   THEN 1
					   ELSE 0
				   END AS Is_Locked
			FROM ml05_village ml05
			LEFT JOIN m005_mcc m005 ON m005.Village_Id = ml05.Village_Id
				and m005.Org_Id = ml05.Org_Id
			LEFT JOIN m009_transporter m009 ON m009.Village_Id = ml05.Village_Id
				and m009.Org_Id = ml05.Org_Id
			LEFT JOIN mu04_farmer mu04 ON mu04.Village_Id = ml05.Village_Id
				and mu04.Org_Id = ml05.Org_Id
			LEFT JOIN mu05_agent mu05 ON mu05.Village_Id = ml05.Village_Id
				and mu05.Org_Id = ml05.Org_Id
			where ml05.Org_Id = var_Org_Id and ml05.Village_Id = var_Village_Id 
			AND ml05.Is_Deleted = 0
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
