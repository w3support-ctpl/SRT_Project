-- Function Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP FUNCTION IF EXISTS `GetMusterCycleDates` ;;
CREATE DEFINER=`appuser`@`%` FUNCTION `GetMusterCycleDates`(
    New_MCC_Id varchar(255),
    New_Created_On DATETIME
) RETURNS longtext CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE Set_MusterType_Id varchar(255);
    DECLARE Set_MusterType varchar(255);
    DECLARE MusterCycle_StartDate DATE;
    DECLARE MusterCycle_EndDate DATE;
    DECLARE Current_Datetime DATETIME;

    -- Get MusterType_Id based on New_MCC_Id and New_Created_On
    SET Set_MusterType_Id = (SELECT m005.MusterType_Id
                         FROM m005_mcc_version m005
                         WHERE MCC_Id = New_MCC_Id AND is_deleted = 0
                               AND Applicable_Date <= New_Created_On
                         ORDER BY Applicable_Date DESC LIMIT 1);
	
    -- Get MusterType based on MusterType_Id
    SET Set_MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = Set_MusterType_Id limit 1);

    -- Set Current_Datetime
    SET Current_Datetime = New_Created_On;

    -- Determine MusterCycle_StartDate and MusterCycle_EndDate based on MusterType
    IF (Set_MusterType = 1) THEN
        SET MusterCycle_StartDate = Current_Datetime;
        SET MusterCycle_EndDate = Current_Datetime;
    ELSEIF (Set_MusterType = 7) THEN
        IF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 1 AND 7) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-01');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-07');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 8 AND 14) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-08');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-14');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 15 AND 21) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-15');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-21');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 16 AND 31) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-16');
            SET MusterCycle_EndDate = LAST_DAY(Current_Datetime);
        END IF;
	ELSEIF (Set_MusterType = 15) THEN
        IF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 1 AND 15) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-01');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-015');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 16 AND 31) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-16');
            SET MusterCycle_EndDate = LAST_DAY(Current_Datetime);
        END IF;
	ELSEIF (Set_MusterType = 5) THEN
        IF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 1 AND 5) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-01');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-05');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 6 AND 10) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-06');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-10');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 11 AND 15) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-11');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-15');
		ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 16 AND 20) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-16');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-20');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 21 AND 25) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-21');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-25');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 26 AND 31) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-26');
            SET MusterCycle_EndDate = LAST_DAY(Current_Datetime);
        END IF;
	ELSEIF (Set_MusterType = 10) THEN
        IF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 1 AND 10) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-01');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-10');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 11 AND 20) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-11');
            SET MusterCycle_EndDate = DATE_FORMAT(Current_Datetime, '%Y-%m-20');
        ELSEIF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 21 AND 31) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-21');
            SET MusterCycle_EndDate = LAST_DAY(Current_Datetime);
        END IF;
	ELSEIF (Set_MusterType = 30) THEN
        IF (DATE_FORMAT(Current_Datetime, '%d') BETWEEN 1 AND 31) THEN
            SET MusterCycle_StartDate = DATE_FORMAT(Current_Datetime, '%Y-%m-01');
            SET MusterCycle_EndDate = LAST_DAY(Current_Datetime);
        END IF;
    END IF;

    -- Return the values as a concatenated string
    RETURN CONCAT('MusterType_Id: ', Set_MusterType_Id, ', MusterCycle_StartDate: ', MusterCycle_StartDate, ', MusterCycle_EndDate: ', MusterCycle_EndDate);
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:33
