-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealer_Stock_Optimized` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealer_Stock_Optimized`(
    IN target_dealer_id VARCHAR(20),
    IN target_dealer_code VARCHAR(20)
)
BEGIN
    SET sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;
    SET sql_mode = '';

    -- 1. UPSERT Receipts (Debits)
    INSERT INTO f011_dealer_stock (Org_Id, Dealer_Id, Material_Id, Good_Debit, Broken_Debit, ThirdParty_Debit, Date)
    SELECT 
        h.Org_Id, h.Dealer_Id, i.Material_Id, 
        SUM(i.Good_Quantity), SUM(i.Broken_Quantity), SUM(i.ThirdParty_Quantity), 
        DATE(h.Created_On)
    FROM t038_receivedcrate_header h
    JOIN t038_receivedcrate_item i ON h.Org_Id = i.Org_Id AND h.ReceivedCrate_Id = i.ReceivedCrate_Id
    LEFT JOIN f011_dealer_stock f ON f.Org_Id = h.Org_Id 
        AND f.Dealer_Id = h.Dealer_Id 
        AND f.Material_Id = i.Material_Id 
        AND DATE(f.Date) = DATE(h.Created_On)
    WHERE f.Date IS NULL 
        AND h.Dealer_Id = target_dealer_id
        AND h.Is_Approved = 1
    GROUP BY h.Org_Id, h.Dealer_Id, i.Material_Id, DATE(h.Created_On)
    ON DUPLICATE KEY UPDATE 
        Good_Debit = VALUES(Good_Debit), 
        Broken_Debit = VALUES(Broken_Debit);

    -- 2. UPSERT Dispatches (Credits)
    INSERT INTO f011_dealer_stock (Org_Id, Dealer_Id, Material_Id, Good_Credit, Date)
    SELECT 
        d.Org_Id, mu.Dealer_Id, m.Material_Id, 
        SUM(CAST(d.Quantity AS DECIMAL)), DATE(d.Dispatch_Date)
    FROM t039_dispatch_crate d
    JOIN m010_material m ON d.Org_Id = m.Org_Id AND d.Material_Code = m.Material_Code
    JOIN mu08_dealer mu ON mu.Dealer_Code = TRIM(LEADING '0' FROM d.Dealer_Code) AND d.Org_Id = mu.Org_Id
    LEFT JOIN f011_dealer_stock f ON f.Org_Id = d.Org_Id 
        AND f.Dealer_Id = mu.Dealer_Id 
        AND f.Material_Id = m.Material_Id 
        AND DATE(f.Date) = DATE(d.Dispatch_Date)
    WHERE f.Date IS NULL 
        AND TRIM(LEADING '0' FROM d.Dealer_Code) = target_dealer_code
        AND m.MaterialType_Id IN ('C042231000005', 'C042231000001')
    GROUP BY d.Org_Id, mu.Dealer_Id, m.Material_Id, DATE(d.Dispatch_Date)
    ON DUPLICATE KEY UPDATE Good_Credit = VALUES(Good_Credit);

    -- 3. THE CHAINING LOGIC (Running Balance)
    -- Step A: Reset Opening from Previous Day's Closing
    UPDATE f011_dealer_stock t1
    JOIN (
        SELECT f.Org_Id, f.Dealer_Id, f.Material_Id, f.Date,
               (SELECT Closing_Quantity 
                FROM f011_dealer_stock prev 
                WHERE prev.Org_Id = f.Org_Id 
                  AND prev.Dealer_Id = f.Dealer_Id 
                  AND prev.Material_Id = f.Material_Id 
                  AND prev.Date < f.Date 
                ORDER BY prev.Date DESC LIMIT 1) as LastClosing
        FROM f011_dealer_stock f
        WHERE f.Dealer_Id = target_dealer_id
    ) t2 ON t1.Org_Id = t2.Org_Id AND t1.Dealer_Id = t2.Dealer_Id 
         AND t1.Material_Id = t2.Material_Id AND t1.Date = t2.Date
    SET t1.Opening_Quantity = IFNULL(t2.LastClosing, 0);

    -- Step B: Calculate Closing for the row
    UPDATE f011_dealer_stock
    SET Closing_Quantity = (IFNULL(Opening_Quantity, 0) + IFNULL(Good_Credit, 0)) 
                           - IFNULL(Good_Debit, 0) 
                           - IFNULL(Broken_Debit, 0)
    WHERE Dealer_Id = target_dealer_id;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
