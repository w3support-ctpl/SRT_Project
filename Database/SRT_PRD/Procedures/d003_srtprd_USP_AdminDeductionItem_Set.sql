-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDeductionItem_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDeductionItem_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
	var_Ddeduction_Id varchar(20),
    var_Installation_No varchar(45),
    var_Installation_Amount varchar(45),
    var_Installation_Date datetime,
    var_Voucher_Id varchar(20),
    var_Is_SAPPosted int,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
			begin
				Declare Duplicate_Flag int;
				Declare New_Entry_Id varchar(20);
				Declare Year_Id varchar(10);
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t031_deduction_item', Year_Id, 'T031', '', New_Entry_Id );
				
				Insert Into t031_deduction_item
					(Org_Id, Entry_Id,Ddeduction_Id,Installation_No,Installation_Amount,
						Installation_Date,Voucher_Id,Is_SAPPosted,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id,New_Entry_Id,var_Ddeduction_Id,var_Installation_No,var_Installation_Amount,
						var_Installation_Date,var_Voucher_Id,var_Is_SAPPosted,
						var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
					
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				New_Entry_Id AS Result_Extra_Key;
			end;
		elseif(var_Method_Name = 'Update') then
			begin
				Update t031_deduction_item
					set 
					Ddeduction_Id = var_Ddeduction_Id,
					Installation_No = var_Installation_No,
					Installation_Amount = var_Installation_Amount,
					Installation_Date = var_Installation_Date,
					Voucher_Id = var_Voucher_Id,
					Is_SAPPosted = var_Is_SAPPosted,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name 
					where Org_Id = var_Org_Id and Entry_Id = var_Entry_Id;   

					SELECT 1 AS Result_Id, 
					'Updated' AS Result_Description, 
					var_Entry_Id AS Result_Extra_Key;
			end;
		elseif(var_Method_Name = 'Delete') then
			begin
				delete from t033_deductions_header
				where Org_Id = var_Org_Id 
				and Deductions_Id = var_Deductions_Id;   
				
				delete from t033_deductions_item
				where Org_Id = var_Org_Id 
				and Deductions_Id = var_Deductions_Id;  
				
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't033_deductions_header', var_Deductions_Id, '', '', 
				var_User_Id, var_User_Name);

				SELECT 1 AS Result_Id, 
				'Deleted' AS Result_Description, 
				var_Deductions_Id AS Result_Extra_Key;
			end;
		end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
