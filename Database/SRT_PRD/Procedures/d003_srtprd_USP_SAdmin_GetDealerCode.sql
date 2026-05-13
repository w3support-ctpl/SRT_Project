-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdmin_GetDealerCode` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdmin_GetDealerCode`()
BEGIN

select Dealer_Code from mu08_dealer where Is_Active = 1 and Is_Deleted = 0;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
