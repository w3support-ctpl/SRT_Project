-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSAPPostingDebit_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSAPPostingDebit_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_InvoiceData longtext,
    var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year varchar(20),
    var_Invoice_Id longtext
)
BEGIN
	if (var_Method_Name = 'Update') then  
		begin
			Declare Year_Id varchar(10);
            Declare New_Deductions_Id varchar(20);
            Declare New_Entry_Id varchar(20);
            SET SQL_SAFE_UPDATES = 0;
            set Year_Id = (select right(left(curdate(),4),(2)));
            
				UPDATE t046_debitsapposting
				SET SAP_Document_Id = var_SAP_Document_Id,
				SAP_Document_Year = var_SAP_Document_Year,
				Is_Posted = var_InvoiceData
				WHERE Org_Id = var_Org_Id
				AND Voucher_Id = var_Invoice_Id;
                
                if(var_InvoiceData = '2')then
                
					Call USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Id );
					Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
					
					INSERT INTO t033_deductions_header(
					Org_Id, Deductions_Id, Entry_Date, 
					Request_User_Type, Request_User_Id,MCC_Id,
					Request_Type, Total_Amount, 
					Amount_Deducted, Balance, 
					Is_Closed, No_Of_Installments
					)
					select 
					Org_Id, New_Deductions_Id,MusterCycle_EndDate,
					'Farmer',Farmer_Id,MCC_Id,
					'M020231000015',round(Invoice_Amount),
					0,round(Invoice_Amount),
					0,1
					from t046_debitsapposting
					WHERE 
					Org_Id = var_Org_Id
					AND Voucher_Id = var_Invoice_Id limit 1;
					
					SET @response =  (select GetMusterCycleDates(MCC_Id,Invoice_Date) 
						from t046_debitsapposting
						where Org_Id = 'C005'
						and Voucher_Id = 'T046231000001');

					set @MusterType_Id = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterType_Id: ', -1), ', ', 1);
					set @MusterCycle_StartDate = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterCycle_StartDate: ', -1), ', ', 1);
					set @MusterCycle_EndDate = SUBSTRING_INDEX(SUBSTRING_INDEX(@response, 'MusterCycle_EndDate: ', -1), ', ', 1);
					
					INSERT INTO t033_deductions_item(
					Org_Id,Entry_Id,Deductions_Id,Deduction_Date,
					Deduction_Amount,Is_Deducted,
					MusterCycle_StartDate,MusterCycle_EndDate
					)
					select 
					var_Org_Id,New_Entry_Id,New_Deductions_Id,
					@MusterCycle_EndDate,
					round(Invoice_Amount),0,
					@MusterCycle_StartDate,
					@MusterCycle_EndDate
					from t046_debitsapposting
					WHERE 
					Org_Id = var_Org_Id
					AND Voucher_Id = var_Invoice_Id limit 1;
                
                end if;
                      
			SELECT 
			1 AS Result_Id,
			'Updated' AS Result_Description,
			var_Org_Id AS Result_Extra_Key;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
