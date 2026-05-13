-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `test` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `test`()
BEGIN
	select Farmer_Id,MCC_Id,Invoice_Date from f012_farmer_invoice 
	where MCC_Id ='M005242000133'
	and Farmer_Id ='MU04242026877'
	and month(Invoice_Date) = month('2025-04-30')
	and year(Invoice_Date) = year('2025-04-30');
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
