-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMaterial_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMaterial_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Material_Id varchar(20),
	var_MaterialType_Id varchar(20),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
	var_MaterialData longtext
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    if (var_Method_Name = 'Create') then
		begin
			Declare Year_Id varchar(10);
            DECLARE New_Material_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            set Year_Id = (select right(left(curdate(),4),(2)));
           
			SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Material/MaterialData[', k, ']');
                
                -- Check if Material_Code exists in m010_material
                IF EXISTS (SELECT 1 FROM m010_material WHERE Org_Id = var_Org_Id AND Material_Code = extractValue(var_MaterialData, concat(xpath,'/Material_Code'))) THEN
                    -- Update existing record
                    UPDATE m010_material AS m010
                    SET m010.Material_Name = extractValue(var_MaterialData, concat(xpath,'/Material_Name')),
                        m010.Material_Group = extractValue(var_MaterialData, concat(xpath,'/Material_Group')),
                        m010.BaseUnit = extractValue(var_MaterialData, concat(xpath,'/BaseUnit')),
                        m010.Is_TradingMaterial = extractValue(var_MaterialData, concat(xpath,'/Is_TradingMaterial'))
                    WHERE m010.Org_Id = var_Org_Id AND m010.Material_Code = extractValue(var_MaterialData, concat(xpath,'/Material_Code'));
                ELSE
					CALL USP_Number_Range ('m010_material', Year_Id, 'M010', '', New_Material_Id );
                    -- Insert new record
                    INSERT INTO m010_material (Org_Id, Material_Id, Material_Code, Material_Name, Material_Group, BaseUnit,Is_Active,Is_Deleted,Is_TradingMaterial)
                    VALUES (var_Org_Id, New_Material_Id, extractValue(var_MaterialData, concat(xpath,'/Material_Code')), extractValue(var_MaterialData, concat(xpath,'/Material_Name')), extractValue(var_MaterialData, concat(xpath,'/Material_Group')), extractValue(var_MaterialData, concat(xpath,'/BaseUnit')),1,0, extractValue(var_MaterialData, concat(xpath,'/Is_TradingMaterial')));
                END IF;
			END WHILE;
            

			SELECT 1 AS Result_Id, 
			'Create' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			Update m010_material
			set 
            MaterialType_Id = var_MaterialType_Id
			where Org_Id = var_Org_Id and Material_Id = var_Material_Id;    

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Material_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
