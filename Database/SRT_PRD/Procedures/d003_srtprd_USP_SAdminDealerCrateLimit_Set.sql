-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerCrateLimit_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerCrateLimit_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Dealer_Code varchar(20),
	var_CrateLimit varchar(45)
)
BEGIN
	if (var_Method_Name = 'Update') then
		begin
        
			Update mu08_dealer
			set CrateLimit = var_CrateLimit
			where Org_Id = var_Org_Id and Dealer_Code = var_Dealer_Code;  
            
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			'' AS Result_Extra_Key;

        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
