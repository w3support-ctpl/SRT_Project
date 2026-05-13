-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_Import_Dispatch_FromExcel` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_Import_Dispatch_FromExcel`(
    IN var_Org_Id VARCHAR(10)
)
BEGIN

    DECLARE v_Year_Id VARCHAR(2);
    DECLARE v_Start_No INT;

    -- Year suffix
    SET v_Year_Id = RIGHT(YEAR(CURDATE()),2);

    -- Step 1: Delete existing records for same dispatch dates
    DELETE d
    FROM t039_dispatch_crate d
    INNER JOIN (
        SELECT DISTINCT
            STR_TO_DATE(TRIM(REPLACE(`Posting Date in the Document`, '\r','')), '%Y%m%d') AS post_date
        FROM exceltosave
    ) x
        ON d.Dispatch_Date = x.post_date;

    -- Step 2: Get current max running number for this year
    SELECT IFNULL(MAX(CAST(RIGHT(Dispatch_Id,6) AS UNSIGNED)),0)
    INTO v_Start_No
    FROM t039_dispatch_crate
    WHERE Dispatch_Id LIKE CONCAT('T039', v_Year_Id, '%');

    -- Step 3: Bulk insert
    INSERT INTO t039_dispatch_crate
    (
        Org_Id,
        Dispatch_Id,
        Dealer_Code,
        Dealer_Name,
        Dispatch_Date,
        Quantity,
        Material_Code,
        Invoice_Number,
        Created_On
    )
    SELECT
        var_Org_Id,

        -- Generate Dispatch ID
        CONCAT(
            'T039',
            v_Year_Id,
            LPAD(v_Start_No + ROW_NUMBER() OVER (), 6, '0')
        ) AS Dispatch_Id,

        `Account Number of Customer`,
        '',
        STR_TO_DATE(TRIM(REPLACE(`Posting Date in the Document`, '\r','')), '%Y%m%d'),
        CAST(Quantity AS DECIMAL(18,3)),
        TRIM(LEADING '0' FROM `Material Number`),
        Delivery,
        NOW()

    FROM exceltosave;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
