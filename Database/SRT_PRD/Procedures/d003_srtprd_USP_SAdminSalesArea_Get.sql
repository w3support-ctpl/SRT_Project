-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesArea_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesArea_Get`()
BEGIN
	SELECT SalesArea_Code as SalesGroup,SalesOffice_Code as SalesOffice FROM m013_salesarea;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
