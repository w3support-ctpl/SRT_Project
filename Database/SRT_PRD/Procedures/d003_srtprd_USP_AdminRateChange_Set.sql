-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRateChange_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRateChange_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_InvoiceData longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
SET SESSION sql_require_primary_key = 0;
SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Create') then
		begin
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            Declare New_Invoice_Id varchar(20);
            Declare New_Invoice_No varchar(20);
            Declare Year_Id varchar(10);
            Declare Voucher_No_Pre varchar(20);
            
            DECLARE j INT UNSIGNED DEFAULT 0;
            DECLARE loop_counter INT UNSIGNED DEFAULT 1;
			DECLARE total_rows INT;
			DECLARE current_org_id varchar(10);
			DECLARE current_farmer_id varchar(20);
			DECLARE current_mcc_id varchar(20);
			DECLARE current_start_date DATE;
			DECLARE current_end_date DATE;
            DECLARE Anamat_PerLtr decimal(8,2);
			DECLARE Freight_PerLtr decimal(8,2);
            Declare Year_No varchar(10);
			Declare Month_No int;
            
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

			set Voucher_No_Pre = (select concat('P', Year_No, Year_No + 1));
            
           
			SET row_count := extractValue(var_InvoiceData,'count(//RateChange/RateChangeItem)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//RateChange/RateChangeItem[', k, ']');
                
                SET @Invoice_Date = '';
				SET @Start_Date = '';
				SET @End_Date = '';
						
                
                SET @Invoice_Date = STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath,'/Invoice_Date')), '%m/%d/%Y %H:%i:%s');
				SET @Start_Date = STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath,'/Start_Date')), '%m/%d/%Y %H:%i:%s');
				SET @End_Date = STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath,'/End_Date')), '%m/%d/%Y %H:%i:%s');
								
				Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T027', '', New_Invoice_Id );
				Call USP_Number_Range ('t027_Farmer_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
                
				Insert into t027_invoice_farmer
				(Org_Id, Voucher_Id, Farmer_Id, MCC_Id,Invoice_Date, Invoice_No, 
                MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_RateChange)
				VALUES (var_Org_Id, 
                New_Invoice_Id, 
                extractValue(var_InvoiceData, concat(xpath,'/Farmer_Id')), 
                extractValue(var_InvoiceData, concat(xpath,'/MCC_Id')), 
                @Invoice_Date, 
                New_Invoice_No,
                @Start_Date,
                @End_Date,
                extractValue(var_InvoiceData, concat(xpath,'/Amount')),
                1,0,now(),var_User_Id,var_User_Name,1
                );
				
			END WHILE;
            

			SELECT 1 AS Result_Id, 
			'Create' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
