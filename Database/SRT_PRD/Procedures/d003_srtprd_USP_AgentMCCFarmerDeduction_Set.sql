-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCFarmerDeduction_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCFarmerDeduction_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_Deduction_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Deduction_Date varchar(20),
    var_Deduction_Type longtext,
    var_Amount varchar(255),
    var_Is_Check int,
    var_Description longtext,
    var_Is_Active int,
    var_Is_Deleted int,
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Deduction_Id varchar(20);
			Declare Year_Id varchar(10);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t107_mcc_farmer_deduction', Year_Id, 'T107', '', New_Deduction_Id );
            
            Insert Into t107_mcc_farmer_deduction
			(Org_Id,Deduction_Id,MCC_Id,Farmer_Id,Deduction_Date,
            Deduction_Type,Amount,Is_Check,Description,
			Is_Active,Is_Deleted,
			Created_On,CreatedBy_Id,CreatedBy_Name)
			value(
			var_Org_Id,New_Deduction_Id,var_MCC_Id,var_Farmer_Id,var_Deduction_Date,
            var_Deduction_Type,var_Amount,var_Is_Check,var_Description,
			var_Is_Active,var_Is_Deleted,
			now(),var_User_Id,var_User_Name
			);
			
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Deduction_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Update') then
		begin
        
			Update t107_mcc_farmer_deduction
			set 
			Deduction_Date = var_Deduction_Date,
			Deduction_Type = var_Deduction_Type, 
			Amount = var_Amount, 
            Is_Check = var_Is_Check, 
            Description = var_Description, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
            and Farmer_Id = var_Farmer_Id
			and Deduction_Id = var_Deduction_Id;
			
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Deduction_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update t107_mcc_farmer_deduction
			set 
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
            and Farmer_Id = var_Farmer_Id
			and Deduction_Id = var_Deduction_Id;
			
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Deduction_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
