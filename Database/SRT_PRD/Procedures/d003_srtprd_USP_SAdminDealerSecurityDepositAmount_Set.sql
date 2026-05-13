-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerSecurityDepositAmount_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerSecurityDepositAmount_Set`(
	var_Method_Name varchar(100),
    var_Org_Id varchar(10),
    var_Dealer_Code varchar(20),
    var_SecurityDepositAmount longtext
    
)
BEGIN
SET SQL_SAFE_UPDATES=0;
	IF(var_Method_Name = 'Update') THEN
		BEGIN
        
			update mu08_dealer
            set SecurityDepositAmount = var_SecurityDepositAmount
            where Org_Id = var_Org_Id
            and Dealer_Code = var_Dealer_Code;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
