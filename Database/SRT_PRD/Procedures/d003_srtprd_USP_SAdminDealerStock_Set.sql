-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerStock_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerStock_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(255),
    var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_DealerStock_Id VARCHAR(20),
    var_Dealer_Id VARCHAR(20),
    var_Date VARCHAR(45),
    var_Product_Data LONGTEXT,
    var_Is_Active INT,
    var_Is_Deleted INT
)
BEGIN
	-- Declare required variabled for new record
    DECLARE New_DealerStock_Id VARCHAR(20);
	DECLARE Year_Id VARCHAR(10);
    DECLARE k INT UNSIGNED DEFAULT 0;
	DECLARE row_count INT UNSIGNED;
	DECLARE xpath TEXT;
    
	-- CREATE NEW RECORD (header & item)
	IF(var_Method_Name = 'Create') THEN
    BEGIN
    
    
		
    
		if(SELECT 1 FROM t035_dealerstock_header 
			WHERE Org_Id = var_Org_Id 
            AND Dealer_Id = var_Dealer_Id
            AND Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d')
            and Is_Active = 1
            and Is_Deleted = 0 limit 1)then
            
            
            
            set New_DealerStock_Id = (SELECT DealerStock_Id FROM t035_dealerstock_header 
										WHERE Org_Id = var_Org_Id 
										AND Dealer_Id = var_Dealer_Id
										AND Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d')
										and Is_Active = 1
										and Is_Deleted = 0 limit 1);
                                        
			
            
            SET row_count := extractValue(var_Product_Data,'count(//Products/ProductItem)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Products/ProductItem[', k, ']');
                
                
                -- Check if Product_Id exists in m017_product
                IF EXISTS (SELECT 1 
                            FROM t035_dealerstock_item 
                            WHERE Org_Id = var_Org_Id 
                            AND DealerStock_Id = New_DealerStock_Id
                            AND Product_Id = extractValue(var_Product_Data, concat(xpath,'/Product_Id'))
                            ) THEN
					
						
                    -- Update existing record
                    UPDATE t035_dealerstock_item AS t035
                    SET t035.Quantity =  t035.Quantity + extractValue(var_Product_Data, concat(xpath,'/Quantity'))
                    WHERE t035.Org_Id = var_Org_Id 
                    AND t035.DealerStock_Id = New_DealerStock_Id
                    AND t035.Product_Id = extractValue(var_Product_Data, concat(xpath,'/Product_Id'));
                    
                ELSE
				
                
                    -- Insert new record
                    INSERT INTO t035_dealerstock_item(
                        Org_Id, DealerStock_Id, 
                        Product_Id, Quantity)
                    VALUES (
                        var_Org_Id, 
                        New_DealerStock_Id, 
                        extractValue(var_Product_Data, concat(xpath,'/Product_Id')), 
                        extractValue(var_Product_Data, concat(xpath,'/Quantity'))
                        );

                END IF;
			END WHILE;
            
        else
        
			-- Generate Id
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t035_dealerstock_header', Year_Id, 'T035', '', New_DealerStock_Id);
				
			-- INSERT IN HEADER TABLE
			INSERT INTO t035_dealerstock_header(
				Org_Id, DealerStock_Id, Dealer_Id, 
				Month_Year, 
				Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id, CreatedBy_Name
			)
			VALUES(
				var_Org_Id, New_DealerStock_Id, var_Dealer_Id,
				STR_TO_DATE(var_Date,'%Y-%m-%d'),
				var_Is_Active, var_Is_Deleted, 
				CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
			);
			
			-- INSERT IN ITEM TABLE
			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_dealer_stock;
			CREATE TEMPORARY TABLE temp_dealer_stock(
				PKeyRowNum INT primary key,
				Product_Id VARCHAR(20),
				Quantity INT
			);
			
			-- add data to temporary table
			SET row_count := extractValue(var_Product_Data,'count(//Products/ProductItem)');
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Products/ProductItem[', k, ']');
					INSERT INTO temp_dealer_stock VALUES (
						k,
						extractValue(var_Product_Data, concat(xpath,'/Product_Id')),
						extractValue(var_Product_Data, concat(xpath,'/Quantity'))
					);
				END WHILE;
			
			-- INSERT IN ITEM TABLE
			INSERT INTO t035_dealerstock_item(
				Org_Id, DealerStock_Id, 
				Product_Id, Quantity
			) 
			SELECT var_Org_Id, New_DealerStock_Id,
				Product_Id, Quantity
			FROM temp_dealer_stock;
			
			-- Drop temp table
			DROP TEMPORARY TABLE temp_dealer_stock;
			
        end if;
        
		-- Send Success Message
		SELECT 1 AS Result_Id, 
		'Created' AS Result_Description, 
		New_DealerStock_Id AS Result_Extra_Key;
	
    END;
    
    -- UPDATE EXISTING RECORD (header & item)
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		-- UPDATE HEADER TABLE
        UPDATE t035_dealerstock_header
        SET Dealer_Id = var_Dealer_Id, 
            Month_Year = STR_TO_DATE(var_Date,'%Y-%m-%d'),
            Is_Active = var_Is_Active, 
            Is_Deleted = var_Is_Deleted,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),  
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
        WHERE Org_Id = var_Org_Id
		AND DealerStock_Id = var_DealerStock_Id;
        
        -- UPDATE ITEM TABLE
        -- Drop values from Item Table
        DELETE FROM t035_dealerstock_item
        WHERE Org_Id = var_Org_Id
		AND DealerStock_Id = var_DealerStock_Id;
        
        -- Convert XML Data to Table format
		DROP TEMPORARY TABLE IF EXISTS temp_dealer_stock;
		CREATE TEMPORARY TABLE temp_dealer_stock(
			PKeyRowNum INT,
            Product_Id VARCHAR(20),
            Quantity INT
        );
        
        -- add data to temporary table
        SET row_count := extractValue(var_Product_Data,'count(//Products/ProductItem)');
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//Products/ProductItem[', k, ']');
				INSERT INTO temp_dealer_stock VALUES (
					k,
					extractValue(var_Product_Data, concat(xpath,'/Product_Id')),
					extractValue(var_Product_Data, concat(xpath,'/Quantity'))
				);
			END WHILE;
        
		-- INSERT IN ITEM TABLE
        INSERT INTO t035_dealerstock_item(
			Org_Id, DealerStock_Id, 
            Product_Id, Quantity
        ) 
		SELECT var_Org_Id, var_DealerStock_Id,
			Product_Id, Quantity
		FROM temp_dealer_stock;
        
        -- Drop temp table
		DROP TEMPORARY TABLE temp_dealer_stock;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		New_DealerStock_Id AS Result_Extra_Key;
       
    END;
    
    -- DELETE EXISTING RECORD (header & item)
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		-- SET IS_DELETED=1 IN HEADER TABLE
        UPDATE t035_dealerstock_header
		SET Is_Active = 0,
            Is_Deleted = 1,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
		WHERE Org_Id = var_Org_Id
		AND DealerStock_Id = var_DealerStock_Id;
        
        -- DELETE ENTRIES FROM ITEM TABLE
        DELETE FROM t035_dealerstock_item
        WHERE Org_Id = var_Org_Id
		AND DealerStock_Id = var_DealerStock_Id;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Deleted' AS Result_Description, 
		var_DealerStock_Id AS Result_Extra_Key;
        
    END;
	ELSEIF(var_Method_Name = 'UpdateData') THEN
    BEGIN
		
        SET row_count := extractValue(var_Product_Data,'count(//Products/ProductItem)');
		WHILE k < row_count DO
			SET k := k + 1;
			SET xpath := concat('//Products/ProductItem[', k, ']');
			
			
			IF EXISTS (SELECT 1 FROM 
			t035_dealerstock_item 
			WHERE Org_Id = var_Org_Id 
			AND DealerStock_Id = extractValue(var_Product_Data, concat(xpath,'/DealerStock_Id'))
			AND Product_Id = extractValue(var_Product_Data, concat(xpath,'/Product_Id'))
			) THEN
				-- Update existing record
				UPDATE t035_dealerstock_item AS t035
				SET t035.Quantity = extractValue(var_Product_Data, concat(xpath,'/Quantity'))
				WHERE t035.Org_Id = var_Org_Id 
				AND DealerStock_Id = extractValue(var_Product_Data, concat(xpath,'/DealerStock_Id'))
				AND Product_Id = extractValue(var_Product_Data, concat(xpath,'/Product_Id'));

			END IF;
		END WHILE;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		'' AS Result_Extra_Key;
       
    END;
    END IF;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
