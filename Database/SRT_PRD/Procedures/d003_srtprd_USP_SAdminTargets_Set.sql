-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminTargets_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminTargets_Set`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_Entry_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_FinancialYear_Id VARCHAR(20),
    var_Dealer_Id VARCHAR(20),
    var_ProductGroup_Id VARCHAR(20),
    var_Product_Id VARCHAR(20),
    var_ProductUOM VARCHAR(20),
    var_Quantity VARCHAR(45),
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_Date VARCHAR(45)
)
BEGIN
	-- creating new record
	IF(var_Method_Name = 'Create') THEN
    BEGIN
		
        -- check if dealer, product, sales user & financial year are unique for each entry
        -- if there already present such entry, send error message
        IF EXISTS(
			SELECT Entry_Id
            FROM t036_salesuser_targets
            WHERE Org_Id = var_Org_Id
            AND SalesUser_Id = var_SalesUser_Id
            AND Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d')
            AND Dealer_Id = var_Dealer_Id
            AND ProductGroup_Id = var_ProductGroup_Id
            AND Product_Id = var_Product_Id
            AND ProductUOM = var_ProductUOM
            AND Is_Deleted = 0
        ) THEN
        BEGIN
			-- send error message
            SELECT -1 AS Result_Id,
			'Record already Exist' AS Result_Description,
			var_Entry_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			-- Declare required variabled to create new Id
			DECLARE New_Entry_Id VARCHAR(20);
			DECLARE Year_Id VARCHAR(10);
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t036_salesuser_targets', Year_Id, 'T036', '', New_Entry_Id);
        
			-- insert new record in the table
            INSERT INTO t036_salesuser_targets(
				Org_Id, Entry_Id, SalesUser_Id, 
                Month_Year, 
                Dealer_Id,ProductGroup_Id, Product_Id,ProductUOM, Quantity, 
                Is_Active, Is_Deleted, 
                Created_On, CreatedBy_Id, CreatedBy_Name
            )
            VALUES(
				var_Org_Id, New_Entry_Id, var_SalesUser_Id, 
                STR_TO_DATE(var_Date,'%Y-%m-%d'),
                var_Dealer_Id, var_ProductGroup_Id, var_Product_Id,var_ProductUOM, var_Quantity, 
                var_Is_Active, var_Is_Deleted,
                CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
            );
            
            -- Send Success Message
            SELECT 1 AS Result_Id, 
			'Created' AS Result_Description, 
			 New_Entry_Id AS Result_Extra_Key;
            
        END;
        END IF;
        
    END;
    
    
    -- updating existing record
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		-- check if dealer, product, sales user & financial year are unique for each entry
        -- if there already present such entry, send error message
        IF EXISTS(
			SELECT Entry_Id
            FROM t036_salesuser_targets
            WHERE Org_Id = var_Org_Id
            AND SalesUser_Id = var_SalesUser_Id
            AND Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d')
            AND Dealer_Id = var_Dealer_Id
            AND ProductGroup_Id = var_ProductGroup_Id
            AND Product_Id = var_Product_Id
            AND ProductUOM = var_ProductUOM
            AND Is_Deleted = 0
            AND Entry_Id <> var_Entry_Id
        ) THEN
        BEGIN
			-- send error message
            SELECT -1 AS Result_Id,
			'Record already Exist' AS Result_Description,
			var_Entry_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			-- update record
            UPDATE t036_salesuser_targets
            SET SalesUser_Id = var_SalesUser_Id,
				Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d'),
                Dealer_Id = var_Dealer_Id,
				ProductGroup_Id = var_ProductGroup_Id,
				Product_Id = var_Product_Id,
				ProductUOM = var_ProductUOM,
                Quantity = var_Quantity,
                LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
			WHERE Org_Id = var_Org_Id
            AND Entry_Id = var_Entry_Id;
        
			-- Send Success Message
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			 var_Entry_Id AS Result_Extra_Key;
        
        END;
        END IF;
        
        
    END;
    
    
    -- delete existing record
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		UPDATE t036_salesuser_targets
        SET Is_Active = 0,
			Is_Deleted = 1
        WHERE Org_Id = var_Org_Id
        AND Entry_Id = var_Entry_Id;
		
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Deleted' AS Result_Description, 
		var_Entry_Id AS Result_Extra_Key;
        
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
