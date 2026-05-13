-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterial_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterial_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Material_Id varchar(20),
    var_Material_Name longtext,
    var_BaseUnit varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Material_Id varchar(20);
			Declare Year_Id varchar(10);
            
			if exists(select Material_Id from m101_mcc_material where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Material_Name = var_Material_Name
                        and BaseUnit = var_BaseUnit
                        and Is_Deleted = 0) then
                        
				SELECT -1 AS Result_Id, 
                CONCAT('Material "', var_Material_Name, '" with unit "', var_BaseUnit, '" already exists.') AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m101_mcc_material', Year_Id, 'M101', '', New_Material_Id );
                
                Insert Into m101_mcc_material
                (Org_Id,MCC_Id,Material_Id,Material_Name,BaseUnit,Is_Active,Is_Deleted,
                Created_On,CreatedBy_Id,CreatedBy_Name)
                value(
                var_Org_Id,var_MCC_Id,New_Material_Id,var_Material_Name,var_BaseUnit,var_Is_Active,var_Is_Deleted,
                now(),var_User_Id,var_User_Name
                );
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Material_Id AS Result_Extra_Key;
            end if;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Material_Id from m101_mcc_material where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Material_Name = var_Material_Name
                        and BaseUnit = var_BaseUnit
                        and Is_Deleted = 0
                        and Material_Id <> var_Material_Id) then
                        
				SELECT -1 AS Result_Id, 
                CONCAT('Material "', var_Material_Name, '" with unit "', var_BaseUnit, '" already exists.') AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				
				Update m101_mcc_material
                set 
                Material_Name = var_Material_Name,
                BaseUnit = var_BaseUnit,
                Is_Active = var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = now(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Material_Id = var_Material_Id;
                
                SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Material_Id AS Result_Extra_Key;
                
            end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			
			Update m101_mcc_material
			set 
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Material_Id = var_Material_Id;
			
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Material_Id AS Result_Extra_Key;
                
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
