-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminProductCode_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminProductCode_Get`(
var_Org_Id varchar(20),
var_Product_Id varchar(20)
)
BEGIN

		
        Select Product_Code as product_code from m017_product where 
        Org_Id = var_Org_Id and Product_Id = var_Product_Id;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
