-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `usp_SaveRouteSU` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `usp_SaveRouteSU`(
    IN v_method_name VARCHAR(50),
    IN v_org_id VARCHAR(50),
    IN v_route_name VARCHAR(200),
    IN v_route_day_id VARCHAR(50),
    IN v_working_status VARCHAR(10),
    IN v_is_active TINYINT,
    IN v_remarks TEXT,
    IN v_entry_id VARCHAR(50),
    IN v_sales_user_id VARCHAR(50),
    IN v_route_id VARCHAR(50),
    IN v_status VARCHAR(10)
)
BEGIN
    -- Handling the "Save" logic
    IF v_method_name = 'Save' THEN
        
        INSERT INTO RouteMaster (
            Org_Id, 
            Entry_Id, 
            SalesUser_Id, 
            RouteId, 
            Route_Name, 
            RouteDay_Id, 
            Working_Status, 
            Is_Active, 
            Remarks, 
            Start_Time, 
            Status, 
            Date
        )
        VALUES (
            v_org_id,
            v_entry_id,
            v_sales_user_id,
            v_route_id,
            v_route_name,
            v_route_day_id,
            v_working_status,
            v_is_active,
            v_remarks,
            NOW(),      -- Capture current timestamp for Start_Time
            v_status,
            NOW()       -- Capture current timestamp for Date
        );

        -- Returning the result to match your AJAX "success" block
        SELECT 'Success' AS Status, 'Route saved successfully' AS Message;

    ELSEIF v_method_name = 'Update' THEN
        -- You can add Update logic here later if needed
        SELECT 'Info' AS Status, 'Update logic not implemented' AS Message;
        
    ELSE
        SELECT 'Error' AS Status, 'Invalid Method Name' AS Message;
    END IF;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
