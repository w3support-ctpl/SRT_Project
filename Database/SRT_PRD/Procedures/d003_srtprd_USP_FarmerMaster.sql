-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerMaster` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerMaster`(
    var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_ParentField_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'GetState') then
    
		select State_Id as Item_Id, State_Name as Item_Value
		from ml02_state where Org_Id = var_Org_Id order by State_Name asc ;
	
    elseif(var_Method_Name = 'GetDistrict') then
    
    	select District_Id as Item_Id, District_Name as Item_Value
		from ml03_district where Org_Id = var_Org_Id  and State_Id = var_ParentField_Id order by District_Name asc ;

    elseif(var_Method_Name = 'GetTakula') then
    
    	select Taluka_Id as Item_Id, Taluka_Name as Item_Value
		from ml04_taluka where Org_Id = var_Org_Id  and District_Id = var_ParentField_Id order by Taluka_Name asc ;

    elseif(var_Method_Name = 'GetVillage') then
    
    	select Village_Id as Item_Id, Village_Name as Item_Value
		from ml05_village where Org_Id = var_Org_Id  and Taluka_Id = var_ParentField_Id order by Village_Name asc ;       
        
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
