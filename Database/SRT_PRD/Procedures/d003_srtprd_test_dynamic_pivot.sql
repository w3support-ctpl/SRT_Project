-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `test_dynamic_pivot` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `test_dynamic_pivot`(
    IN `var_org_id` VARCHAR(10),
    IN `var_MCCType_Id` TEXT,
    IN `var_ReportPeriod` VARCHAR(50),
    IN `var_MCC_Id` TEXT,
    IN `var_MCCWorkType_Id` TEXT
)
BEGIN
    DECLARE var_StartDate DATE;
    DECLARE var_EndDate DATE;

    SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
    SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

    SET sql_mode = '';

    -- Split MCCType
    DROP TEMPORARY TABLE IF EXISTS t;
    CREATE TEMPORARY TABLE t(txt TEXT);
    INSERT INTO t VALUES(IFNULL(var_MCCType_Id, ''));

    DROP TEMPORARY TABLE IF EXISTS temp_MCCType;
    CREATE TEMPORARY TABLE temp_MCCType(MCCType_Id CHAR(255));
    SET @sql = CONCAT('INSERT INTO temp_MCCType (MCCType_Id) VALUES (\'', 
                      REPLACE((SELECT GROUP_CONCAT(DISTINCT txt) FROM t), ',', '\'),(\''), '\');');
    PREPARE stmt1 FROM @sql;
    EXECUTE stmt1;

    -- Split MCCWorkType
    DROP TEMPORARY TABLE IF EXISTS t;
    CREATE TEMPORARY TABLE t(txt TEXT);
    INSERT INTO t VALUES(IFNULL(var_MCCWorkType_Id, ''));

    DROP TEMPORARY TABLE IF EXISTS temp_MCCWorkType;
    CREATE TEMPORARY TABLE temp_MCCWorkType(MCCWorkType_Id CHAR(255));
    SET @sql = CONCAT('INSERT INTO temp_MCCWorkType (MCCWorkType_Id) VALUES (\'', 
                      REPLACE((SELECT GROUP_CONCAT(DISTINCT txt) FROM t), ',', '\'),(\''), '\');');
    PREPARE stmt1 FROM @sql;
    EXECUTE stmt1;

    -- Split MCC
    DROP TEMPORARY TABLE IF EXISTS t;
    CREATE TEMPORARY TABLE t(txt TEXT);
    INSERT INTO t VALUES(IFNULL(var_MCC_Id, ''));

    DROP TEMPORARY TABLE IF EXISTS temp_MCC;
    CREATE TEMPORARY TABLE temp_MCC(MCC_Id CHAR(255));

    IF (IFNULL(var_MCC_Id, '') <> '') THEN
        SET @sql4 = CONCAT('INSERT INTO temp_MCC (MCC_Id) VALUES (\'', 
                           REPLACE((SELECT GROUP_CONCAT(DISTINCT txt) FROM t), ',', '\'),(\''), '\');');
        PREPARE stmt4 FROM @sql4;
        EXECUTE stmt4;
    ELSE
        INSERT INTO temp_MCC (MCC_Id)
        SELECT MCC_Id 
        FROM m005_mcc 
        WHERE Org_Id = var_org_id 
          AND MCCType_Id IN (SELECT MCCType_Id FROM temp_MCCType) 
          AND MCCWorkType_Id IN (SELECT MCCWorkType_Id FROM temp_MCCWorkType);
    END IF;

    -- Build SELECT columns
    SELECT GROUP_CONCAT(DISTINCT CONCAT(
        'MAX(CASE WHEN f012.Invoice_Date = ''', DATE_FORMAT(f012.Invoice_Date, '%Y-%m-%d'),
        ''' THEN f012.DairyAnamat_Amount ELSE 0 END) AS `',
        DATE_FORMAT(f012.Invoice_Date, '%Y-%m-%d'), '`'
    )) INTO @select_column_list
    FROM f012_farmer_invoice f012
    INNER JOIN temp_MCC tm ON tm.MCC_Id = f012.MCC_Id
    WHERE f012.Org_Id = var_org_id
      AND f012.Invoice_Date BETWEEN var_StartDate AND var_EndDate;

    -- Build CREATE TABLE columns
    SELECT GROUP_CONCAT(DISTINCT CONCAT(
        '`', DATE_FORMAT(f012.Invoice_Date, '%Y-%m-%d'), '` longtext'
    )) INTO @create_column_list
    FROM f012_farmer_invoice f012
    INNER JOIN temp_MCC tm ON tm.MCC_Id = f012.MCC_Id
    WHERE f012.Org_Id = var_org_id
      AND f012.Invoice_Date BETWEEN var_StartDate AND var_EndDate;


-- Step 1: Create temp table
SET @create_temp_table_sql = CONCAT(
    'DROP TEMPORARY TABLE IF EXISTS temp_pivot_result;
     CREATE TEMPORARY TABLE temp_pivot_result (
        RowType longtext,
        MCC_Name longtext,
        MCC_Code longtext,
        MCCType_Name longtext,
        Farmer_Name longtext,
        Farmer_Code longtext, ',
        @select_column_list, ',
        Total longtext
     );'
);


select @create_temp_table_sql;
select 1;
    PREPARE stmt_temp FROM @create_temp_table_sql;
    EXECUTE stmt_temp;
    DEALLOCATE PREPARE stmt_temp;
select 1;
    -- Step 2: Insert header
    SET @insert_header_sql = CONCAT(
        'INSERT INTO temp_pivot_result
         SELECT ''TH'' AS RowType,
                ''MCC Name'',
                ''MCC Code'',
                ''MCC Type'',
                ''Farmer Name'',
                ''Farmer Code'', ',
        REPLACE(@select_column_list, 
            'MAX(CASE WHEN f012.Invoice_Date = ''', 
            '0 AS `'),
        ', 0 AS `Total`;'
    );
    PREPARE stmt_hdr FROM @insert_header_sql;
    EXECUTE stmt_hdr;
    DEALLOCATE PREPARE stmt_hdr;

    -- Step 3: Insert real data
    SET @sql_text = CONCAT(
        'INSERT INTO temp_pivot_result
         SELECT ''TR'' AS RowType, 
                m005.MCC_Name,
                m005.MCC_Code,
                c014.MCCType_Name,
                mu04.Farmer_Name,
                mu04.Farmer_Code, ',
                @select_column_list, ',
                SUM(IFNULL(f012.DairyAnamat_Amount, 0)) AS `Total`
         FROM f012_farmer_invoice f012
         INNER JOIN temp_MCC tm ON tm.MCC_Id = f012.MCC_Id
         INNER JOIN m005_mcc m005 ON m005.MCC_Id = f012.MCC_Id AND m005.Org_Id = f012.Org_Id
         INNER JOIN mu04_farmer mu04 ON mu04.Farmer_Id = f012.Farmer_Id AND mu04.Org_Id = f012.Org_Id
         INNER JOIN c014_mcctype c014 ON c014.MCCType_Id = m005.MCCType_Id
         WHERE f012.Org_Id = ''', var_org_id, '''
         AND f012.Invoice_Date BETWEEN ''', var_StartDate, ''' AND ''', var_EndDate, '''
         GROUP BY f012.Farmer_Id, f012.MCC_Id, m005.MCC_Name, m005.MCC_Code, c014.MCCType_Name, mu04.Farmer_Name, mu04.Farmer_Code;'
    );
    PREPARE stmt_data FROM @sql_text;
    EXECUTE stmt_data;
    DEALLOCATE PREPARE stmt_data;


    -- Step 4: Output
    SELECT * FROM temp_pivot_result;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
