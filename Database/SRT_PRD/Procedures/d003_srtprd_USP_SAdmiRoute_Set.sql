-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdmiRoute_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdmiRoute_Set`(
    IN var_Method_Name VARCHAR(50),
    IN var_Org_Id VARCHAR(50),
    IN var_Entry_Id VARCHAR(50),      -- This is the Route_Id
    IN var_SalesArea_Id VARCHAR(50),
    IN var_Route_Name VARCHAR(100),
    IN var_Route_Day_Id VARCHAR(50),
    IN var_Working_Status VARCHAR(1), -- '1' or '0'
    IN var_Is_Active INT,             -- 1 or 0
    IN var_Remarks VARCHAR(255),
    IN var_User_Id VARCHAR(50),       -- For CreatedBy/LastEditedBy
    IN var_User_Name VARCHAR(100)
)
BEGIN
    -- Error Handling: Rollback on any SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'Error' AS Status, 'An error occurred while saving the route.' AS Message;
    END;

    START TRANSACTION;

    -- CASE 1: INSERT NEW ROUTE
    IF (var_Entry_Id IS NULL OR var_Entry_Id = '') THEN
        
        -- Generate a simple ID or let Auto-Increment handle it. 
        -- Assuming Route_Id is auto-increment; if not, you'd generate it here.
        
        INSERT INTO m019_salesuserroute_header (
            Org_Id, 
            SalesArea_Id, 
            SalesUser_Id,
            Route_Name, 
            RouteDay_Id, 
            Working_Status, 
            Total_Retailers, 
            Remarks, 
            Is_Active, 
            Is_Deleted, 
            Created_On, 
            CreatedBy_Id, 
            CreatedBy_Name,
            LastEdited_On
        ) 
        VALUES (
            var_Org_Id,
            var_SalesArea_Id,
            '',
            var_Route_Name,
            var_Route_Day_Id,
            var_Working_Status,
            '0',               -- Default Total_Retailers to 0
            var_Remarks,
            var_Is_Active,
            '0',               -- Is_Deleted default
            NOW(),
            var_User_Id,
            var_User_Name,
            NOW()
        );

        SELECT 'Success' AS Status, 'Route created successfully.' AS Message;

    -- CASE 2: UPDATE EXISTING ROUTE
    ELSE
        UPDATE m019_salesuserroute_header 
        SET 
            SalesArea_Id = var_SalesArea_Id,
            Route_Name = var_Route_Name,
            RouteDay_Id = var_Route_Day_Id,
            Working_Status = var_Working_Status,
            Remarks = var_Remarks,
            Is_Active = var_Is_Active,
            LastEditedBy_Id = var_User_Id,
            LastEditedBy_Name = var_User_Name,
            LastEdited_On = NOW()
        WHERE Route_Id = var_Entry_Id AND Org_Id = var_Org_Id;

        SELECT 'Success' AS Status, 'Route updated successfully.' AS Message; 

    END IF;

    COMMIT;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
