-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesUserRoute_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesUserRoute_Get`(
    var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_SalesArea_Id VARCHAR(20),
    var_Entry_Id varchar(20),
    var_Dealer_Id varchar(20),
    var_Route_Id JSON,        -- now JSON input
    var_RouteDay_Id VARCHAR(45)
)
BEGIN
    SET sql_mode = '';
    SET SESSION group_concat_max_len = 10000;

    -- =====================================================
    -- GET : Fetch route summary per day for sales user
    -- =====================================================
 IF (var_Method_Name = 'Get') THEN
  
    BEGIN
    -- 1. Fetch Sales User info once at the start to avoid redundant queries
    SELECT 
        u.SalesUser_Name, 
        u.SalesArea_Id 
    INTO @Current_UserName, @Current_AreaId
    FROM mu12_sales_user u
    WHERE u.SalesUser_Id = var_SalesUser_Id
      AND u.Org_Id = var_Org_Id
    LIMIT 1;

    -- 2. Check if the Sales User has any routes assigned
    IF EXISTS (
        SELECT 1
        FROM m019_salesuserroute_header
        WHERE SalesUser_Id = var_SalesUser_Id
          AND Org_Id = var_Org_Id
    ) THEN

        -- Return days with aggregated routes (Comma Separated)
        SELECT
            var_Org_Id AS Org_Id,
            var_SalesUser_Id AS SalesUser_Id,
            IFNULL(@Current_UserName, '') AS SalesUser_Name,
            IFNULL(@Current_AreaId, '') AS SalesArea_Id,
            d.RouteDay_Id,
            d.RouteDay_Name,
            IFNULL(h.Agg_Route_Ids, '') AS Route_Id,
            IFNULL(h.Agg_Route_Names, '') AS Route_Name,
            IFNULL(h.Working_Status, 0) AS Working_Status,
            IFNULL(h.Total_Retailers, 0) AS Total_Retailers,
            IFNULL(h.Remarks, '') AS Remarks,
            IFNULL(h.Is_Active, 1) AS Is_Active,
            IFNULL(h.Is_Deleted, 0) AS Is_Deleted
        FROM c045_route_day d
        LEFT JOIN (
            -- Subquery to aggregate all routes per day for this specific user
            SELECT
                Org_Id,
                RouteDay_Id,
                SalesUser_Id,
                -- We use DISTINCT to ensure if a route is doubled, it only shows once
                GROUP_CONCAT(DISTINCT Route_Id ORDER BY Route_Id SEPARATOR ',') AS Agg_Route_Ids,
                GROUP_CONCAT(DISTINCT Route_Name ORDER BY Route_Name SEPARATOR ', ') AS Agg_Route_Names,
                MAX(Working_Status) AS Working_Status,
                SUM(Total_Retailers) AS Total_Retailers,
                MAX(Is_Active) AS Is_Active,
                MAX(Is_Deleted) AS Is_Deleted,
                GROUP_CONCAT(DISTINCT Remarks SEPARATOR ' | ') AS Remarks
            FROM m019_salesuserroute_header
            WHERE SalesUser_Id = var_SalesUser_Id
              AND Org_Id = var_Org_Id
            GROUP BY Org_Id, RouteDay_Id, SalesUser_Id
        ) h ON d.RouteDay_Id = h.RouteDay_Id
        ORDER BY d.RouteDay_Id;

    ELSEIF (var_SalesUser_Id <> '') THEN
        
        -- Case where Sales User exists but has NO routes assigned yet
        -- Return all days from the master table with empty values
        SELECT
            var_Org_Id AS Org_Id,
            var_SalesUser_Id AS SalesUser_Id,
            IFNULL(@Current_UserName, '') AS SalesUser_Name,
            IFNULL(@Current_AreaId, '') AS SalesArea_Id,
            route.RouteDay_Id,
            route.RouteDay_Name,
            '' AS Route_Id,
            '' AS Route_Name,
            0 AS Working_Status,
            0 AS Total_Retailers,
            '' AS Remarks,
            1 AS Is_Active,
            0 AS Is_Deleted
        FROM c045_route_day route
        ORDER BY route.RouteDay_Id;

    END IF;
END;

    -- =====================================================
    -- GET_ONE : Fetch retailers using JSON route list
    -- =====================================================
    ELSEIF (var_Method_Name = 'Get_One') THEN
    BEGIN
  
SELECT
    r.Retailer_Id,
    r.Retailer_Name,
    sa.SalesArea_Id,
    sa.SalesArea_Name,
    su.SalesUser_Name,
    jr.Route_Id,
    h.Route_Name,
    -- EXISTING LOGIC: Locked for this specific user/route/day
    CASE 
        WHEN sri.Retailer_Id IS NOT NULL THEN 1
        ELSE 0
    END AS Is_Locked,
    -- NEW LOGIC: Assigned to someone else (for the badge)
    CASE 
        WHEN conflict.Retailer_Id IS NOT NULL THEN 1
        ELSE 0
    END AS Assigned,
    -- Fetch the name for the badge tooltip
    IFNULL(other_u.SalesUser_Name, '') AS assigned_To_Other_User

FROM JSON_TABLE(
    var_Route_Id,
    '$[*]' COLUMNS (
        Route_Id VARCHAR(20) PATH '$'
    )
) jr

-- Get mappings for the routes provided in JSON
INNER JOIN mu19_route_retailer_mapping m
    ON m.Route_Id = jr.Route_Id
    AND m.Org_Id = var_Org_Id

-- Get Retailer details
INNER JOIN mu09_retailer r
    ON r.Retailer_Id = m.Retailer_Id
    AND r.Org_Id = var_Org_Id
    AND r.Is_Active = 1
    AND r.Is_Deleted = 0

-- Get Route Name from header
LEFT JOIN mu19_route h
    ON h.Route_Id = jr.Route_Id
    AND h.Org_Id = var_Org_Id

-- EXISTING JOIN: Assignment for CURRENT user
LEFT JOIN m019_salesuserroute_item sri
    ON sri.Retailer_Id = r.Retailer_Id
    AND sri.Route_Id = jr.Route_Id
    AND sri.RouteDay_Id = var_RouteDay_Id
    AND sri.SalesUser_Id = var_SalesUser_Id
    AND sri.Org_Id = var_Org_Id

-- NEW JOIN: Assignment for OTHER users
LEFT JOIN m019_salesuserroute_item conflict
    ON conflict.Retailer_Id = r.Retailer_Id
    AND conflict.Route_Id = jr.Route_Id
    AND conflict.RouteDay_Id = var_RouteDay_Id
    AND conflict.Org_Id = var_Org_Id
    AND conflict.SalesUser_Id <> var_SalesUser_Id -- Exclude the current user

-- NEW JOIN: To get the name of the other user for the badge
LEFT JOIN mu12_sales_user other_u
    ON other_u.SalesUser_Id = conflict.SalesUser_Id
    AND other_u.Org_Id = var_Org_Id

-- Sales Area details
LEFT JOIN m013_salesarea sa
    ON sa.SalesArea_Id = r.SalesArea_Id
    AND sa.Org_Id = var_Org_Id

-- Sales User details
LEFT JOIN mu12_sales_user su
    ON su.SalesUser_Id = var_SalesUser_Id
    AND su.Org_Id = var_Org_Id

GROUP BY r.Retailer_Id, jr.Route_Id
ORDER BY r.Retailer_Name;

     

  end;

    

 
      ELSEIF (var_Method_Name = 'Get_Retailer') THEN
    BEGIN
SELECT
    r.Retailer_Id,
    r.Retailer_Name,
    m.route_Id,
    -- If a mapping exists for this route/entry, set Is_Locked to 1, else 0
    CASE 
        WHEN m.Retailer_Id IS NOT NULL  and m.route_Id is not null THEN 1 
        ELSE 0 
    END AS Is_Locked

FROM mu09_retailer r
-- Join with the mapping table to check for existing assignments
LEFT JOIN mu19_route_retailer_mapping m 
    ON r.Retailer_Id = m.Retailer_Id 
    AND m.Org_Id = var_Org_Id
and m.route_Id = var_Entry_Id
WHERE r.Org_Id = var_Org_Id
  AND r.SalesArea_Id = var_SalesArea_Id
  AND r.Dealer_Id = var_Dealer_Id
  AND r.Is_Active = 1
  AND r.Is_Deleted = 0

ORDER BY r.Retailer_Name;

     

  end;

ELSEIF (var_Method_Name = 'Get_Dealer') THEN
    BEGIN
		/*
		set @SalesArea_Id = (
			select SalesArea_Id 
			from mu12_sales_user 
			where Org_Id = var_Org_Id
			and SalesUser_Id = var_SalesUser_Id
			limit 1
		);

		select 
			d.Org_Id,
			d.Dealer_Id,
			d.Dealer_Code,
			d.Dealer_Name,
			case 
				when r.Dealer_Id is not null then 1
				else 0
			end as Is_Dealer
		from mu08_dealer d
        left join mu19_route m 
			on m.Org_Id = d.Org_Id
            and m.Dealer_Id = d.Dealer_Id
		left join m019_salesuserroute_item_dealer r 
			on d.Dealer_Id = r.Dealer_Id
			and r.SalesUser_Id = var_SalesUser_Id
			and r.Org_Id = d.Org_Id
		where d.Org_Id = var_Org_Id
		and d.SalesArea_Id = @SalesArea_Id
		and d.SalesUser_Id <> var_SalesUser_Id;
        */
        
        SET @SalesArea_Id = (
			SELECT SalesArea_Id 
			FROM mu12_sales_user 
			WHERE Org_Id = var_Org_Id
			AND SalesUser_Id = var_SalesUser_Id
			LIMIT 1
		);

		SELECT 
			d.Org_Id,
			d.Dealer_Id,
			d.Dealer_Code,
			d.Dealer_Name,
			CASE 
				WHEN r.Dealer_Id IS NOT NULL THEN 1
				ELSE 0
			END AS Is_Dealer
		FROM mu08_dealer d
		INNER JOIN mu19_route m 
			ON m.Org_Id = d.Org_Id
			AND m.Dealer_Id = d.Dealer_Id
		LEFT JOIN m019_salesuserroute_item_dealer r 
			ON d.Dealer_Id = r.Dealer_Id
			AND r.SalesUser_Id = var_SalesUser_Id
			AND r.Org_Id = d.Org_Id
		WHERE d.Org_Id = var_Org_Id
		AND d.SalesArea_Id = @SalesArea_Id
		AND d.SalesUser_Id <> var_SalesUser_Id
		GROUP BY 
			d.Org_Id,
			d.Dealer_Id,
			d.Dealer_Code,
			d.Dealer_Name;
    END;
    END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
