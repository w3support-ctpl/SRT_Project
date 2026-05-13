-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSAPPosting_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSAPPosting_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_InvoiceData longtext,
    var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year varchar(20),
    var_Invoice_Id longtext,
    var_MCC_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Date varchar(60),
    var_Amount varchar(45),
    var_IncomeFor varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Remark longtext,
    var_MilkPayment varchar(20) 
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Invoice_Id varchar(20);
            Declare New_Invoice_No varchar(20);
            Declare Year_Id varchar(10);
            Declare Voucher_No_Pre varchar(20);
            Declare Year_No varchar(10);
			Declare Month_No int;
                    
			set @Current_times = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            set Year_Id = (select right(left(curdate(),4),(2)));
		
            set Year_No = (select right(left(curdate(),4),(2)));
			set Month_No = (select right(left(curdate(),7),(2)));
			if (Month_No < 4) then
				begin
					set Year_No = Year_No -1;
				end;
			else
				begin
					set Year_No = Year_No + 0;
				end;
			end if;

			set Voucher_No_Pre = (select concat('S', Year_No, Year_No + 1));
            
            Call USP_Number_Range ('t045_sapposting', Year_Id, 'T045', '', New_Invoice_Id );
			Call USP_Number_Range ('t045_Farmer_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
            
            SET @response = GetMusterCycleDates(var_MCC_Id,@Current_times);

		 
			SET @MusterType_Id = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterType_Id: ', -1), ', ', 1);
			SET @MusterCycle_StartDate = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterCycle_StartDate: ', -1), ', ', 1);
			SET @MusterCycle_EndDate = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterCycle_EndDate: ', -1), ', ', 1);
            
            Insert into t045_sapposting
			(Org_Id, Voucher_Id,Invoice_No, Farmer_Id, MCC_Id,Invoice_Date, 
			MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
			Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_Posted,IncomeFor,Remark,Is_MilkPayment)
			value(var_Org_Id, New_Invoice_Id,New_Invoice_No, var_Farmer_Id, var_MCC_Id,DATE(CONVERT_TZ(@MusterCycle_EndDate, '+00:00', '+00:00')), 
			@MusterCycle_StartDate,@MusterCycle_EndDate,round(var_Amount),
			1,0,Now(),var_User_Id,var_User_Name,1,var_IncomeFor,var_Remark,var_MilkPayment);  
            
			SELECT 
			1 AS Result_Id,
			'Create' AS Result_Description,
			New_Invoice_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Update') then  
		begin
			UPDATE t045_sapposting
				SET SAP_Document_Id = var_SAP_Document_Id,
				SAP_Document_Year = var_SAP_Document_Year,
				Is_Posted = var_InvoiceData
				WHERE Org_Id = var_Org_Id
				AND Voucher_Id = var_Invoice_Id;
				
			SELECT 
			1 AS Result_Id,
			'Updated' AS Result_Description,
			var_Org_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Set_Reverse') then
		begin
        
			Update t045_sapposting
			set 
            Is_Posted = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
