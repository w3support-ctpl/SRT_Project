-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesUserRoute_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesUserRoute_Set`(
    var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(255),
    var_User_Id VARCHAR(20),
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_Route_Id LONGTEXT,
    var_SalesUser_Id VARCHAR(20),
    var_SalesArea_Id VARCHAR(20),
    var_Remarks LONGTEXT,
    var_Working_Status INT,
    var_Total_Retailers INT,
    var_Retailer_List LONGTEXT,
    var_RouteDay_Id VARCHAR(20),
    var_Route_Name VARCHAR(150)
)
BEGIN

    DECLARE v_Current_Route_Id VARCHAR(20);
    DECLARE v_Actual_Count INT;
    DECLARE done INT DEFAULT 0;
    DECLARE k INT UNSIGNED DEFAULT 0;
    DECLARE row_count INT UNSIGNED;
    DECLARE xpath TEXT;
    DECLARE v_ResolvedRouteDayId VARCHAR(20);

    DECLARE cur_routes CURSOR FOR SELECT Route_Id FROM temp_routes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        ROLLBACK;
        SELECT 0 AS Result_Id, CONCAT('Error: ', @p2) AS Result_Description;
    END;

    SELECT RouteDay_Id INTO v_ResolvedRouteDayId
    FROM c045_route_day
    WHERE RouteDay_Id = var_RouteDay_Id
    LIMIT 1;

    IF (var_Method_Name = 'Update' OR var_Method_Name = 'Save') THEN

        START TRANSACTION;

        -- 1. Extract Routes
        DROP TEMPORARY TABLE IF EXISTS temp_routes;
        CREATE TEMPORARY TABLE temp_routes(Route_Id VARCHAR(20));

        SET @temp_route_str = var_Route_Id;
        IF LOCATE(',', @temp_route_str) > 0 THEN
            WHILE LOCATE(',', @temp_route_str) > 0 DO
                INSERT INTO temp_routes VALUES(TRIM(SUBSTRING_INDEX(@temp_route_str, ',', 1)));
                SET @temp_route_str = SUBSTRING(@temp_route_str, LOCATE(',', @temp_route_str) + 1);
            END WHILE;
            INSERT INTO temp_routes VALUES(TRIM(@temp_route_str));
        ELSE
            INSERT INTO temp_routes VALUES(TRIM(var_Route_Id));
        END IF;

        -- 2. Extract Retailers from XML
        DROP TEMPORARY TABLE IF EXISTS temp_retailer_data;
        CREATE TEMPORARY TABLE temp_retailer_data(Retailer_Id VARCHAR(20));

        SET row_count = extractValue(var_Retailer_List, 'count(//RetailerList/RetailerItem)');
        WHILE k < row_count DO
            SET k = k + 1;
            SET xpath = CONCAT('//RetailerList/RetailerItem[', k, ']');
            INSERT INTO temp_retailer_data(Retailer_Id)
            VALUES(extractValue(var_Retailer_List, CONCAT(xpath, '/Retailer_Id')));
        END WHILE;

        -- 3. Cleanup & Theft Prevention
        
        -- A. Delete old Header and Day Item records for the Current User/Day
        DELETE FROM m019_salesuserroute_header
        WHERE Org_Id = var_Org_Id AND SalesUser_Id = var_SalesUser_Id AND RouteDay_Id = v_ResolvedRouteDayId;

        DELETE FROM mu12_sales_user_route_day_item
        WHERE Org_Id = var_Org_Id AND SalesUser_Id = var_SalesUser_Id AND RouteDay_Id = v_ResolvedRouteDayId;

        -- B. Delete ALL retailers for this User/Day (Handles "Unselecting")
        DELETE FROM m019_salesuserroute_item
        WHERE Org_Id = var_Org_Id 
        AND SalesUser_Id = var_SalesUser_Id 
        AND RouteDay_Id = v_ResolvedRouteDayId;

        -- C. Delete these specific retailers from ANY OTHER USER for this day
        DELETE s FROM m019_salesuserroute_item s
        INNER JOIN temp_retailer_data t ON s.Retailer_Id = t.Retailer_Id
        WHERE s.Org_Id = var_Org_Id 
        AND s.RouteDay_Id = v_ResolvedRouteDayId;

        -- 4. Re-insert Data via Cursor
        OPEN cur_routes;
        route_loop: LOOP
            FETCH cur_routes INTO v_Current_Route_Id;
            IF done = 1 THEN LEAVE route_loop; END IF;

            INSERT INTO m019_salesuserroute_header(
                Org_Id, Route_Id, SalesUser_Id, RouteDay_Id, Route_Name,
                Working_Status, Total_Retailers, Remarks, Is_Active, Is_Deleted,
                Created_On, CreatedBy_Id
            )
            SELECT
                var_Org_Id, r.Route_Id, var_SalesUser_Id, v_ResolvedRouteDayId, r.Route_Name,
                var_Working_Status, 0, var_Remarks, var_Is_Active, var_Is_Deleted,
                NOW(), var_User_Id
            FROM mu19_route r
            WHERE r.Route_Id = v_Current_Route_Id AND r.Org_Id = var_Org_Id;

            INSERT INTO mu12_sales_user_route_day_item(Org_Id, SalesUser_Id, Route_Id, RouteDay_Id)
            VALUES(var_Org_Id, var_SalesUser_Id, v_Current_Route_Id, v_ResolvedRouteDayId);

            INSERT INTO m019_salesuserroute_item(Org_Id, Route_Id, Retailer_Id, RouteDay_Id, SalesUser_Id)
            SELECT
                var_Org_Id, v_Current_Route_Id, t.Retailer_Id, v_ResolvedRouteDayId, var_SalesUser_Id
            FROM temp_retailer_data t
            JOIN mu19_route_retailer_mapping m ON m.Retailer_Id = t.Retailer_Id
            WHERE m.Route_Id = v_Current_Route_Id AND m.Org_Id = var_Org_Id;

            -- Update count for current user
            SELECT COUNT(*) INTO v_Actual_Count
            FROM m019_salesuserroute_item
            WHERE Org_Id = var_Org_Id AND Route_Id = v_Current_Route_Id 
            AND RouteDay_Id = v_ResolvedRouteDayId AND SalesUser_Id = var_SalesUser_Id;

            UPDATE m019_salesuserroute_header
            SET Total_Retailers = v_Actual_Count
            WHERE Org_Id = var_Org_Id AND Route_Id = v_Current_Route_Id AND RouteDay_Id = v_ResolvedRouteDayId;
        END LOOP;
        CLOSE cur_routes;

        -- 5. FINAL SYNC: Recalculate counts for ANY header affected by the "Theft" delete
        UPDATE m019_salesuserroute_header h
        SET h.Total_Retailers = (
            SELECT COUNT(*) 
            FROM m019_salesuserroute_item i 
            WHERE i.Org_Id = h.Org_Id 
            AND i.SalesUser_Id = h.SalesUser_Id 
            AND i.Route_Id = h.Route_Id 
            AND i.RouteDay_Id = h.RouteDay_Id
        )
        WHERE h.Org_Id = var_Org_Id AND h.RouteDay_Id = v_ResolvedRouteDayId;

        COMMIT;
        SELECT 1 AS Result_Id, 'Success' AS Result_Description, var_Route_Id AS Result_Extra_Key;
	elseif (var_Method_Name = 'Update_Dealer') then
		begin
			Declare dealerArray longtext;
		
			DELETE FROM m019_salesuserroute_item_dealer
				WHERE Org_Id = var_Org_Id 
				AND SalesUser_Id = var_SalesUser_Id;
		
			SET dealerArray = var_Retailer_List;
			WHILE LENGTH(dealerArray) > 0 DO
				SET @value = SUBSTRING_INDEX(dealerArray, ',', 1);
				INSERT INTO m019_salesuserroute_item_dealer (Org_Id, SalesUser_Id, Dealer_Id)
				VALUES (var_Org_Id, var_SalesUser_Id,@value);
				SET dealerArray = SUBSTRING(dealerArray, LENGTH(@value) + 2);
			END WHILE;
			

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_SalesUser_Id AS Result_Extra_Key;
			
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
