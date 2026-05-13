-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRetailerOrders_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRetailerOrders_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(255),
    var_User_Id VARCHAR(20),
    var_RetailerOrder_Id VARCHAR(20),
    var_Status VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Update') THEN
		BEGIN
			
			update t034_retailerorder_header
			set Is_Closed = var_Status
			where Org_Id = var_Org_Id
			and RetailerOrder_Id = var_RetailerOrder_Id;
            
             select 1 as Result_Id, 'Update' as Result_Description, var_RetailerOrder_Id as Result_Extra_Key; 
            
            
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
