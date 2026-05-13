-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerCode_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerCode_Get`(
var_Org_Id varchar(20),
var_Dealer_Id varchar(20)
)
BEGIN

		
        Select Dealer_Code as dealer_code from mu08_dealer where 
        Org_Id = var_Org_Id and Dealer_Id = var_Dealer_Id;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
