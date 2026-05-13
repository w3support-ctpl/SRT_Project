-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminOrg_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminOrg_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			SELECT Destination_Name as ConnectionName FROM c001_organization where Org_Id = var_Org_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
