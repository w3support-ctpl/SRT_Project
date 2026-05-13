-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRoute_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRoute_Set`(
    IN var_Method_Name VARCHAR(50),
    IN var_Org_Id VARCHAR(10),
    IN var_Entry_Id VARCHAR(20),      -- Acts as Route_Id
    IN var_SalesArea_Id VARCHAR(20),
    IN var_Route_Name VARCHAR(100),
    IN var_Working_Status VARCHAR(1), -- '1' or '0'
    IN var_Is_Active INT,              
    IN var_Remarks VARCHAR(255),
    IN var_User_Id VARCHAR(20),        
    IN var_User_Name VARCHAR(100),
    IN var_Dealer_Id VARCHAR(20),
    IN var_Retailer_List JSON          -- Pass JSON from JS: JSON.stringify(selectedRetailers)
)
BEGIN
    -- Declare local variables for ID generation
    DECLARE New_Route_Id VARCHAR(20);
    DECLARE New_Mapping_Id VARCHAR(20);
    DECLARE Year_Id VARCHAR(10);
    DECLARE i INT DEFAULT 0;
    DECLARE row_count INT DEFAULT 0;
    DECLARE current_retailer_id VARCHAR(20);

    -- Error Handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @text = MESSAGE_TEXT;
        ROLLBACK;
        SELECT -1 AS Result_Id, @text AS Result_Description, '' AS Result_Extra_Key;
    END;

    START TRANSACTION;

    SET Year_Id = RIGHT(LEFT(CURDATE(),4),2);

    -- ---------------------------------------------------------
    -- METHOD: SAVE (CREATE OR UPDATE)
    -- ---------------------------------------------------------
    IF (var_Method_Name = 'Save') THEN
    BEGIN
        -- 1. Check for Duplicate Route Name
        IF EXISTS (
            SELECT Route_Id FROM mu19_route 
            WHERE Route_Name = var_Route_Name AND Org_Id = var_Org_Id 
            AND Route_Id <> IFNULL(var_Entry_Id, '') AND Is_Deleted = 0
        ) THEN
            SELECT -1 AS Result_Id, 'Route Name already exists' AS Result_Description, '' AS Result_Extra_Key;
            ROLLBACK;
        ELSE
            -- 2. Insert or Update Master Route
            IF (var_Entry_Id IS NULL OR var_Entry_Id = '') THEN
                CALL USP_Number_Range('mu19_route', Year_Id, 'MU19', '', New_Route_Id);
                SET var_Entry_Id = New_Route_Id;

                INSERT INTO mu19_route (
                    Org_Id, Route_Id, Dealer_Id, SalesArea_Id, Route_Name, 
                    Working_Status, Remarks, Is_Active, Is_Deleted, 
                    Created_On, CreatedBy_Id, CreatedBy_Name, LastEdited_On
                ) 
                VALUES (
                    var_Org_Id, var_Entry_Id, var_Dealer_Id, var_SalesArea_Id, var_Route_Name,
                    var_Working_Status, var_Remarks, var_Is_Active, 0, 
                    NOW(), var_User_Id, var_User_Name, NOW()
                );
            ELSE
                UPDATE mu19_route SET 
                    SalesArea_Id = var_SalesArea_Id,
                    Dealer_Id = var_Dealer_Id,
                    Route_Name = var_Route_Name,
                    Working_Status = var_Working_Status,
                    Remarks = var_Remarks,
                    Is_Active = var_Is_Active,
                    LastEditedBy_Id = var_User_Id,
                    LastEditedBy_Name = var_User_Name,
                    LastEdited_On = NOW()
                WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;
                
                -- Clear current mapping for this specific route for refresh
                -- Also clear from the Sales User Item mapping as the retailer list is changing
                DELETE FROM m019_salesuserroute_item WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;
                DELETE FROM mu19_route_retailer_mapping WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;
            END IF;

            -- 3. Insert Retailer Mappings from JSON
            SET row_count = JSON_LENGTH(var_Retailer_List);
            
            WHILE i < row_count DO
                -- Extract retailer_id from JSON array
                SET current_retailer_id = JSON_UNQUOTE(JSON_EXTRACT(var_Retailer_List, CONCAT('$[', i, '].retailer_id')));
                
                -- MANDATORY: Ensure retailer is NOT assigned to any other route
                -- This removes them from any old Master mapping AND any Sales User assignments
                DELETE FROM mu19_route_retailer_mapping 
                WHERE Retailer_Id = current_retailer_id AND Org_Id = var_Org_Id;

                DELETE FROM m019_salesuserroute_item 
                WHERE Retailer_Id = current_retailer_id AND Org_Id = var_Org_Id;

                -- Generate Mapping ID using your standard function
                CALL USP_Number_Range('mu19_route_retailer_mapping', Year_Id, 'MU19', '', New_Mapping_Id);
                
                INSERT INTO mu19_route_retailer_mapping (
                    Org_Id, Entry_Id, Route_Id, Retailer_Id, Created_On, CreatedBy_Id
                )
                VALUES (
                    var_Org_Id, New_Mapping_Id, var_Entry_Id, current_retailer_id, NOW(), var_User_Id
                );
                
                SET i = i + 1;
            END WHILE;

            -- 4. Update Total Counts
            -- Update Master Route Count
            UPDATE mu19_route SET Total_Retailers = row_count WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;

            -- Update Sales User Header Counts (Recalculate based on what remains after deletions)
            UPDATE m019_salesuserroute_header h
            SET h.Total_Retailers = (
                SELECT COUNT(*) 
                FROM m019_salesuserroute_item i 
                WHERE i.Route_Id = h.Route_Id 
                AND i.RouteDay_Id = h.RouteDay_Id 
                AND i.Org_Id = h.Org_Id
            )
            WHERE h.Org_Id = var_Org_Id AND h.Route_Id = var_Entry_Id;

            SELECT 1 AS Result_Id, 'Route saved and mappings synced successfully' AS Result_Description, var_Entry_Id AS Result_Extra_Key;
            COMMIT;
        END IF;
    END;

    -- ---------------------------------------------------------
    -- METHOD: DELETE
    -- ---------------------------------------------------------
    ELSEIF (var_Method_Name = 'Delete') THEN
    BEGIN
        UPDATE mu19_route SET Is_Active = 0, Is_Deleted = 1, LastEdited_On = NOW()
        WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;

        -- Clean up all mappings related to this route
        DELETE FROM mu19_route_retailer_mapping WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;
        DELETE FROM m019_salesuserroute_item WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;
        
        -- Reset counts for any Sales User headers that were using this route
        UPDATE m019_salesuserroute_header SET Total_Retailers = 0 
        WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;

        SELECT 1 AS Result_Id, 'Deleted and all mappings cleared' AS Result_Description, var_Entry_Id AS Result_Extra_Key;
        COMMIT;
    END;
    END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
