-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMaterialIssues_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMaterialIssues_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_MaterialData longtext,
    var_Date longtext
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    if (var_Method_Name = 'Create') then
		begin
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Material/MaterialData[', k, ']');
                
            
				 INSERT INTO f017_materials_issues (
					Org_Id , 
					Date , 
					ID , 
					MaterialDocumentYear , 
					MaterialDocument , 
					MaterialDocumentItem , 
					Material , 
					Plant , 
					StorageLocation , 
					PostingDate , 
					Supplier , 
					GoodsMovementType , 
					QuantityInBaseUnit , 
					MaterialBaseUnit , 
					SupplierFullName 
				 )
				VALUES (
				var_Org_Id, 
				var_Date, 
				extractValue(var_MaterialData, concat(xpath,'/ID')),
				extractValue(var_MaterialData, concat(xpath,'/MaterialDocumentYear')),
				extractValue(var_MaterialData, concat(xpath,'/MaterialDocument')),
				extractValue(var_MaterialData, concat(xpath,'/MaterialDocumentItem')),
				extractValue(var_MaterialData, concat(xpath,'/Material')),
				extractValue(var_MaterialData, concat(xpath,'/Plant')),
				extractValue(var_MaterialData, concat(xpath,'/StorageLocation')),
				extractValue(var_MaterialData, concat(xpath,'/PostingDate')),
				extractValue(var_MaterialData, concat(xpath,'/Supplier')),
				extractValue(var_MaterialData, concat(xpath,'/GoodsMovementType')),
				extractValue(var_MaterialData, concat(xpath,'/QuantityInBaseUnit')),
				extractValue(var_MaterialData, concat(xpath,'/MaterialBaseUnit')),
				extractValue(var_MaterialData, concat(xpath,'/SupplierFullName'))
				);
            
            END WHILE;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
