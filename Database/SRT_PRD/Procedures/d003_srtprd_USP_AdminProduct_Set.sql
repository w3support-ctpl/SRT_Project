-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminProduct_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminProduct_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Product_Id varchar(20),
	var_Photo longtext,
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    
    var_ProductData longtext
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Create') then
		begin
			Declare Year_Id varchar(10);
            DECLARE New_Product_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            set Year_Id = (select right(left(curdate(),4),(2)));
           
			SET row_count := extractValue(var_ProductData,'count(//Product/ProductData)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Product/ProductData[', k, ']');
                
                -- Check if Product_Code exists in m017_product
                IF EXISTS (SELECT 1 FROM m017_product WHERE Org_Id = var_Org_Id AND Product_Code = extractValue(var_ProductData, concat(xpath,'/Product_Code'))) THEN
                    -- Update existing record
                    UPDATE m017_product AS m017
                    SET m017.Product_Name = extractValue(var_ProductData, concat(xpath,'/Product_Name')),
                        m017.Product_Group = extractValue(var_ProductData, concat(xpath,'/Product_Group')),
                        m017.BaseUnit = extractValue(var_ProductData, concat(xpath,'/BaseUnit')),
                        m017.Division_Code = extractValue(var_ProductData, concat(xpath,'/Division')),
                        m017.Product_Type = extractValue(var_ProductData, concat(xpath,'/ProductType'))
                    WHERE m017.Org_Id = var_Org_Id AND m017.Product_Code = extractValue(var_ProductData, concat(xpath,'/Product_Code'));
                ELSE
					CALL USP_Number_Range ('m017_product', Year_Id, 'M017', '', New_Product_Id );
                    -- Insert new record
                    INSERT INTO m017_product (Org_Id, Product_Id, Product_Code, Product_Name, Product_Group, BaseUnit,Is_Active,Is_Deleted,
                    Product_Type,Division_Code)
                    VALUES (var_Org_Id, New_Product_Id, extractValue(var_ProductData, concat(xpath,'/Product_Code')), extractValue(var_ProductData, concat(xpath,'/Product_Name')), extractValue(var_ProductData, concat(xpath,'/Product_Group')), extractValue(var_ProductData, concat(xpath,'/BaseUnit')),1,0,
                    extractValue(var_ProductData, concat(xpath,'/ProductType')),extractValue(var_ProductData, concat(xpath,'/Division')));
                END IF;
			END WHILE;
            

			SELECT 1 AS Result_Id, 
			'Create' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			Update m017_product
			set 
            Image = var_Photo,
            Is_Active = var_Is_Active
			where Org_Id = var_Org_Id and Product_Id = var_Product_Id;    

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Product_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
