-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRoute_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRoute_Get`(
    IN var_Method_Name VARCHAR(20), -- 'GetAll' or 'GetById'
    IN var_Org_Id VARCHAR(10),
    IN var_Search_Text VARCHAR(20),
    IN var_Route_Id VARCHAR(20)     -- Pass NULL or '0' for GetAll
)
BEGIN
    SET sql_mode = '';

    -- 1. Get ALL routes with real-time retailer counts
    IF (var_Method_Name = 'GetAll') THEN
        SELECT 
            DISTINCT
            IFNULL(sr_header.Route_Id, '0') AS Route_Id, 
            IFNULL(sr_header.Route_Name, '') AS Route_Name,
            sr_header.Org_Id,
            IFNULL(sr_header.Remarks, '') AS Remarks,
            -- Real-time count from mapping table to ensure accuracy (161 vs 167 fix)
            (SELECT COUNT(*) 
             FROM mu19_route_retailer_mapping map 
             WHERE map.Route_Id = sr_header.Route_Id 
             AND map.Org_Id = var_Org_Id) AS Total_Retailers, 
            sr_header.Working_Status, 
            sr_header.Is_Active, 
            sr_header.Is_Deleted,
            IFNULL(sr_header.SalesArea_Id, '') AS SalesArea_Id,
            IFNULL(sr_header.Dealer_Id, '') AS Dealer_Id
        FROM mu19_route sr_header
        WHERE sr_header.Org_Id = var_Org_Id 
            AND sr_header.Is_Deleted = 0 
            AND (sr_header.Route_Name LIKE CONCAT('%', var_Search_Text, '%') OR var_Search_Text IS NULL OR var_Search_Text = '');

    -- 2. Get ONE specific route by its ID
    ELSEIF (var_Method_Name = 'GetById') THEN
        SELECT
            sr_header.Org_Id, 
            IFNULL(sr_header.Route_Id, '0') AS Route_Id, 
            IFNULL(sr_header.Remarks, '') AS Remarks,
            sr_header.Working_Status, 
            -- Real-time count from mapping table
            (SELECT COUNT(*) 
             FROM mu19_route_retailer_mapping map 
             WHERE map.Route_Id = sr_header.Route_Id 
             AND map.Org_Id = var_Org_Id) AS Total_Retailers, 
            sr_header.Is_Active, 
            sr_header.Is_Deleted,
            IFNULL(sr_header.Route_Name, '') AS Route_Name,
            IFNULL(sr_header.SalesArea_Id, '') AS SalesArea_Id,
            IFNULL(sr_header.Dealer_Id, '') AS Dealer_Id
        FROM mu19_route sr_header 
        WHERE sr_header.Org_Id = var_Org_Id 
            AND sr_header.Route_Id = var_Route_Id
        LIMIT 1;
          
    END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
