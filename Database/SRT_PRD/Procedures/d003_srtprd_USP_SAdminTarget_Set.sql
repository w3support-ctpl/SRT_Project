-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminTarget_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminTarget_Set`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(20),
    var_Type VARCHAR(20),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_Target_Id VARCHAR(20),
    var_Entry_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_FinancialYear_Id VARCHAR(20),
    var_Dealer_Id VARCHAR(20),
    var_ProductGroup_Id VARCHAR(20),
    var_Product_Id VARCHAR(20),
    var_ProductUOM VARCHAR(20),
    var_Quantity VARCHAR(45),
    var_Is_Active VARCHAR(20),
    var_Is_Deleted VARCHAR(20),
    var_Date VARCHAR(45)
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;

	IF(var_Method_Name = 'Create' and var_Type ='Header') THEN
		begin
			
			DECLARE New_Target_Id VARCHAR(20);
			DECLARE Year_Id VARCHAR(10);
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t036_salesusers_targets_header', Year_Id, 'T036', '', New_Target_Id);

			-- insert new record in the table
			INSERT INTO t036_salesusers_targets_header(
			Org_Id, Target_Id, SalesUser_Id, 
			Month_Year, 
			Dealer_Id,
			Is_Active, Is_Deleted, 
			Created_On, CreatedBy_Id, CreatedBy_Name
			)
			VALUES(
			var_Org_Id, New_Target_Id, var_SalesUser_Id, 
			STR_TO_DATE(var_Date,'%Y-%m-%d'),
			var_Dealer_Id, 
			var_Is_Active, var_Is_Deleted,
			CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name
			);

			-- Send Success Message
			SELECT 1 AS Result_Id, 
			'Created' AS Result_Description, 
			New_Target_Id AS Result_Extra_Key;
             
		end;
	elseIF(var_Method_Name = 'Create' and var_Type ='Item') THEN
		begin
			DECLARE New_Entry_Id VARCHAR(20);
			DECLARE Year_Id VARCHAR(10);
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t036_salesusers_targets_item', Year_Id, 'T036A', '', New_Entry_Id);

			-- insert new record in the table
			INSERT INTO t036_salesusers_targets_item(
			Org_Id, Entry_Id,Target_Id,
            ProductGroup_Id, Product_Id,ProductUOM, Quantity
			)
			VALUES(
			var_Org_Id, New_Entry_Id,var_Target_Id,
            var_ProductGroup_Id, var_Product_Id,var_ProductUOM, var_Quantity
			);

			-- Send Success Message
			SELECT 1 AS Result_Id, 
			'Created' AS Result_Description, 
			New_Entry_Id AS Result_Extra_Key;
		end;
	elseIF(var_Method_Name = 'Update' and var_Type ='Header') THEN
		begin
			
			UPDATE t036_salesusers_targets_header
            SET Is_Active = var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
			WHERE Org_Id = var_Org_Id
            AND Target_Id = var_Target_Id;
        
			-- Send Success Message
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			 var_Target_Id AS Result_Extra_Key;
             
		end;
	elseIF(var_Method_Name = 'Update' and var_Type ='Item') THEN
		begin
			
			UPDATE t036_salesusers_targets_item
            SET ProductGroup_Id = var_ProductGroup_Id,
				Product_Id = var_Product_Id,
				ProductUOM = var_ProductUOM,
                Quantity = var_Quantity
			WHERE Org_Id = var_Org_Id
            AND Target_Id = var_Target_Id
            AND Entry_Id = var_Entry_Id;
        
			-- Send Success Message
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			 var_Entry_Id AS Result_Extra_Key;
             
		end;
	elseIF(var_Method_Name = 'Delete' and var_Type ='Header') THEN
		begin
			
			UPDATE t036_salesusers_targets_header
            SET Is_Active = 0,
                Is_Deleted = 1,
                LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
			WHERE Org_Id = var_Org_Id
            AND Target_Id = var_Target_Id;
        
			-- Send Success Message
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			 var_Target_Id AS Result_Extra_Key;
             
		end;
	elseIF(var_Method_Name = 'Delete' and var_Type ='Item') THEN
		begin
			
			delete from t036_salesusers_targets_item
            WHERE Org_Id = var_Org_Id
            AND Target_Id = var_Target_Id
            AND Entry_Id = var_Entry_Id;
        
			-- Send Success Message
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			 var_Entry_Id AS Result_Extra_Key;
             
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
