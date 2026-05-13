-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `new_one_two` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `new_one_two`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Shift_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN
	/* Get Version */
SET @Version_No = (
    SELECT Version_No 
    FROM m005_mcc_version 
    WHERE MCC_Id = Var_MCC_Id 
    AND Applicable_Date <= @Current_Datetime
    ORDER BY Applicable_Date DESC 
    LIMIT 1
);


 set @Current_times = (SELECT TIME(CONVERT_TZ(NOW(), '+00:00', '+00:00')));
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));


/* Get Collection Shift Count */
SELECT COUNT(*) INTO @CollectionShift
FROM m005_mcc_collectionshift
WHERE MCC_Id = Var_MCC_Id 
AND Version_No = @Version_No;


/* Get Collection Shift Id */
IF (@CollectionShift > 1) THEN

    SELECT cs.CollectionShift_Id
    INTO @CollectionShift_Id
    FROM c015_collectionshift cs
    INNER JOIN m005_mcc_collectionshift mcs
        ON cs.CollectionShift_Id = mcs.CollectionShift_Id
    WHERE mcs.MCC_Id = Var_MCC_Id
    AND mcs.Version_No = @Version_No
    AND cs.Is_Deleted = 0
    AND @Current_times BETWEEN cs.ShiftStart_Time AND cs.ShiftEnd_Time
    LIMIT 1;

    IF (@CollectionShift_Id IS NULL OR @CollectionShift_Id = '') THEN
        SELECT cs.CollectionShift_Id
        INTO @CollectionShift_Id
        FROM c015_collectionshift cs
        INNER JOIN m005_mcc_collectionshift mcs
            ON cs.CollectionShift_Id = mcs.CollectionShift_Id
        WHERE mcs.MCC_Id = Var_MCC_Id
        AND mcs.Version_No = @Version_No
        AND cs.Is_Deleted = 0
        ORDER BY cs.ShiftStart_Time DESC
        LIMIT 1;
    END IF;

ELSE
    SELECT CollectionShift_Id 
    INTO @CollectionShift_Id
    FROM m005_mcc_collectionshift 
    WHERE MCC_Id = Var_MCC_Id 
    AND Version_No = @Version_No
    LIMIT 1;
END IF;


/* Get MCC Details */
SELECT MCCType_Id, MCCWorkType_Id
INTO @MCCType_Id, @MCCWorkType_Id
FROM m005_mcc
WHERE MCC_Id = Var_MCC_Id 
AND Org_Id = Var_Org_Id
AND Is_Deleted = 0;


/* Get Current Shift */
SELECT MCCCollectionShift_Id
INTO @Current_CollectionShift_Id
FROM t004_mcccollectionshift
WHERE DATE(Collection_Date) = DATE(@Current_Datetime)
AND MCC_Id = Var_MCC_Id
AND Org_Id = Var_Org_Id
ORDER BY Collection_Date DESC
LIMIT 1;


/* Milk Data Calculation (Single Query Instead of Multiple) */
SELECT 
    MilkType_Id,
    SUM(Quantity_Ltr),
    COUNT(*),
    SUM(Quantity_Ltr * Fat) / SUM(Quantity_Ltr),
    SUM(Quantity_Ltr * SNF) / SUM(Quantity_Ltr)
INTO 
    @MilkType,
    @TotalMilk,
    @TotalQty,
    @AvgFat,
    @AvgSNF
FROM t005_milkcollectionfarmer
WHERE MCCCollectionShift_Id = @Current_CollectionShift_Id
AND MilkStatus_Id = 'C016001'
AND Is_Active = 1
GROUP BY MilkType_Id
LIMIT 1;


/* Create Temp Table */
DROP TEMPORARY TABLE IF EXISTS temp_TBL;

CREATE TEMPORARY TABLE temp_TBL(
    Today_Rate VARCHAR(20),
    Base_FAT VARCHAR(20),
    Base_SNF VARCHAR(20),
    AvgSNF VARCHAR(20),
    AvgFat VARCHAR(20),
    Total_Milk VARCHAR(20),
    Milk_Type VARCHAR(20)
);


/* Get Chart Id */
SET @ChartIdCW = (
    SELECT Chart_Id 
    FROM f002_milk_rate_current
    WHERE Header_Applicable_Date <= NOW()
    AND MCC_Id = Var_MCC_Id
    AND CollectionShift_Id = @CollectionShift_Id
    AND MilkRateEntryType_Id = 'C012001'
    AND MilkType_Id = 'C011001'
    ORDER BY Header_Applicable_Date DESC
    LIMIT 1
);

SET @ChartIdBF = (
    SELECT Chart_Id 
    FROM f002_milk_rate_current
    WHERE Header_Applicable_Date <= NOW()
    AND MCC_Id = Var_MCC_Id
    AND CollectionShift_Id = @CollectionShift_Id
    AND MilkRateEntryType_Id = 'C012001'
    AND MilkType_Id = 'C011002'
    ORDER BY Header_Applicable_Date DESC
    LIMIT 1
);


/* Insert Cow Rate */
INSERT INTO temp_TBL
SELECT 
    IFNULL(Amount,''),
    Base_FAT,
    Base_SNF,
    IFNULL(ROUND(@AvgSNF,2),''),
    IFNULL(ROUND(@AvgFat,2),''),
    IFNULL(@TotalMilk,''),
    'C011001'
FROM f002_milk_rate_current
WHERE Org_Id = Var_Org_Id
AND MCC_Id = Var_MCC_Id
AND CollectionShift_Id = @CollectionShift_Id
AND MilkRateEntryType_Id = 'C012001'
AND MilkType_Id = 'C011001'
AND Chart_Id = @ChartIdCW
AND Item_Applicable_Date <= @Current_Datetime
ORDER BY Item_Applicable_Date DESC
LIMIT 1;


/* Insert Buffalo Rate */
INSERT INTO temp_TBL
SELECT 
    IFNULL(Amount,''),
    Base_FAT,
    Base_SNF,
    IFNULL(ROUND(@AvgSNF,2),''),
    IFNULL(ROUND(@AvgFat,2),''),
    IFNULL(@TotalMilk,''),
    'C011002'
FROM f002_milk_rate_current
WHERE Org_Id = Var_Org_Id
AND MCC_Id = Var_MCC_Id
AND CollectionShift_Id = @CollectionShift_Id
AND MilkRateEntryType_Id = 'C012001'
AND MilkType_Id = 'C011002'
AND Chart_Id = @ChartIdBF
AND Item_Applicable_Date <= @Current_Datetime
ORDER BY Item_Applicable_Date DESC
LIMIT 1;


/* Final Result */
SELECT 
    *,
    @MCCType_Id AS MCC_Type,
    @CollectionShift_Id AS CollectionShift_Id,
    @MCCWorkType_Id AS MCCWorkType_Id
FROM temp_TBL;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
