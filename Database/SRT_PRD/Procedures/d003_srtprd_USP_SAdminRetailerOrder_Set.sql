-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRetailerOrder_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRetailerOrder_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_RetailerOrder_Id VARCHAR(20),
    var_RetailerOrderItem_Id VARCHAR(20),
    var_Retailer_Id VARCHAR(20),
    var_Dealer_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_Remarks LONGTEXT,
    var_Product_Id VARCHAR(20),
    var_UOM VARCHAR(255),
    var_Quantity DECIMAL(10,0),
    var_Request_For VARCHAR(20),
    var_Is_Active INT, 
    var_Is_Deleted INT 
)
BEGIN

	-- Declare required variabled for new record
    DECLARE New_RetailerOrder_Id VARCHAR(20);
    DECLARE New_RetailerOrderItem_Id VARCHAR(20);
	DECLARE Year_Id VARCHAR(10);

	-- Header Table
    IF(var_Request_For = 'Header') THEN
    
		-- create Retailer Order Header data
		IF(var_Method_Name = 'Create') THEN
	
    
				/*
				-- check if entry already exists
				IF EXISTS(
				SELECT RetailerOrder_Id
				FROM t034_retailerorder_header
				WHERE Retailer_Id = var_Retailer_Id
				AND Dealer_Id = var_Dealer_Id
				AND SalesUser_Id = var_SalesUser_Id
				AND Org_Id = var_Org_Id
				AND Is_Deleted = 0
				) THEN
				
					SELECT -1 AS Result_Id, 
					'Retailer Entry already exists' AS Result_Description, 
					'' AS Result_Extra_Key;

                ELSE 
                
                */
                    
					SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
					CALL USP_Number_Range ('t034_retailerorder_header', Year_Id, 'T034', '', New_RetailerOrder_Id);
			
                
					INSERT INTO t034_retailerorder_header(
						Org_Id, RetailerOrder_Id, 
                        Retailer_Id, Dealer_Id, SalesUser_Id, 
                        Order_No, Order_Date, Remarks, 
                        Is_Active, Is_Deleted, 
                        Created_On, CreatedBy_Id, CreatedBy_Name
                    )
                    VALUES(
						var_Org_Id, New_RetailerOrder_Id, 
                        var_Retailer_Id, var_Dealer_Id, var_SalesUser_Id, 
                        New_RetailerOrder_Id, CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_Remarks, 
                        var_Is_Active, var_Is_Deleted, 
                        CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
                    );
                    
                    -- Send Success Message
					SELECT 1 AS Result_Id, 
					'Created' AS Result_Description, 
					New_RetailerOrder_Id AS Result_Extra_Key;
				
                /*
                END IF;
				*/
    
		-- update Retailer Order Header data
		ELSEIF(var_Method_Name = 'Update') THEN
        
			UPDATE t034_retailerorder_header
            SET Retailer_Id = var_Retailer_Id,
                Dealer_Id = var_Dealer_Id,
                SalesUser_Id = var_SalesUser_Id, 
				Remarks = var_Remarks, 
                
				Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
                LastEditedBy_Id = var_User_Id, 
                LastEditedBy_Name = var_User_Name
			WHERE Org_Id = var_Org_Id
            AND RetailerOrder_Id = var_RetailerOrder_Id;
            
            -- Send Success Message
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_RetailerOrder_Id AS Result_Extra_Key;
            
		ELSEIF(var_Method_Name = 'Closed') THEN
        
			UPDATE t034_retailerorder_header
            SET Is_Closed = var_Is_Active,
				Closed_On = CONVERT_TZ(NOW(), '+00:00', '+00:00')
			WHERE Org_Id = var_Org_Id
            AND RetailerOrder_Id = var_RetailerOrder_Id;
            
            -- Send Success Message
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_RetailerOrder_Id AS Result_Extra_Key;

        -- delete Retailer Order Header data
        /*
		ELSEIF(var_Method_Name = 'Delete') THEN

			UPDATE t034_retailerorder_header
            SET Is_Active = 0,
            Is_Deleted = 1,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
            WHERE Org_Id = var_Org_Id
            AND RetailerOrder_Id = var_RetailerOrder_Id;
            
            -- Send Success Message
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_RetailerOrder_Id AS Result_Extra_Key;
*/

		end if;

    elseIF(var_Request_For = 'Item') THEN
    

		-- create Retailer Order Item data
		IF(var_Method_Name = 'Create') THEN

        
			-- Generate Id
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t034_retailerorder_item', Year_Id, 'T0034', '', New_RetailerOrderItem_Id);
        
			INSERT INTO t034_retailerorder_item(
				Org_Id, RetailerOrder_Id, RetailerOrderItem_Id, 
                Product_Id,UOM, Quantity, Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id, CreatedBy_Name
            )
            VALUES(
				var_Org_Id, var_RetailerOrder_Id, New_RetailerOrderItem_Id, 
                var_Product_Id, var_UOM,var_Quantity, var_Is_Active, var_Is_Deleted, 
				CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
            );
	
		
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Created' AS Result_Description, 
		New_RetailerOrderItem_Id AS Result_Extra_Key;
    
    
		-- update Retailer Order Item data
		ELSEIF(var_Method_Name = 'Update') THEN

            UPDATE t034_retailerorder_item
            SET Product_Id = var_Product_Id,
				UOM = var_UOM, 
				Quantity = var_Quantity, 
				Is_Active = var_Is_Active, 
				Is_Deleted = var_Is_Deleted, 
				LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
				LastEditedBy_Id = var_User_Id, 
				LastEditedBy_Name = var_User_Name
            WHERE Org_Id = var_Org_Id
            AND RetailerOrder_Id = var_RetailerOrder_Id
            AND RetailerOrderItem_Id = var_RetailerOrderItem_Id;
		
			-- Send Success Message
			SELECT 1 AS Result_Id, 
			'Item Updated' AS Result_Description, 
			var_RetailerOrderItem_Id AS Result_Extra_Key;
	
        
        -- delete Retailer Order Item data
		ELSEIF(var_Method_Name = 'Delete') THEN

			DELETE FROM t034_retailerorder_item
            WHERE Org_Id = var_Org_Id
            AND RetailerOrder_Id = var_RetailerOrder_Id
            AND RetailerOrderItem_Id = var_RetailerOrderItem_Id;
            
            -- Send Success Message
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_RetailerOrderItem_Id AS Result_Extra_Key;
       
        
		END IF;

	END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
