-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerInSAP_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerInSAP_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_InvoiceData longtext,
    var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year varchar(20),
    var_Invoice_Id longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
SET SESSION sql_require_primary_key = 0;
SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Invoice_Id varchar(20);
            Declare New_Invoice_No varchar(20);
            Declare Year_Id varchar(10);
            Declare Voucher_No_Pre varchar(20);
            
			DECLARE k INT UNSIGNED DEFAULT 0;
            DECLARE j INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
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
           
				-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_invoice;
				CREATE TEMPORARY TABLE temp_invoice (PKeyRowNum int, 
                Org_Id varchar(20),
                -- Invoice_Id varchar(20),Invoice_No varchar(20),
				Check_Id varchar(20),Farmer_Id varchar(20), MCC_Id varchar(20), 
                MusterCycle_StartDate date, MusterCycle_EndDate date, 
                Invoice_Amount decimal(30,2),Is_Voucher int);
                
				SET row_count := extractValue(var_InvoiceData,'count(//Invoice/InvoiceItem)');
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Invoice/InvoiceItem[', k, ']');
                    -- Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T024', '', New_Invoice_Id );
                    
                    SET @StartDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/StartDate')), '%m/%d/%Y %H:%i:%s');
					SET @EndDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/EndDate')), '%m/%d/%Y %H:%i:%s');
				
					INSERT INTO temp_invoice VALUES (
						k,
                        var_Org_Id,
						extractValue(var_InvoiceData, concat(xpath,'/Check_Id')),
						extractValue(var_InvoiceData, concat(xpath,'/Farmer_Id')),
						extractValue(var_InvoiceData, concat(xpath,'/MCC_Id')),
						@StartDate,
						@EndDate,
                        extractValue(var_InvoiceData, concat(xpath,'/Amount')),
                        extractValue(var_InvoiceData, concat(xpath,'/Is_Voucher'))
					);
				END WHILE;
                
				DROP TEMPORARY TABLE IF EXISTS temp_minus;
				CREATE TEMPORARY TABLE temp_minus (
				Farmer_Id varchar(20), MCC_Id varchar(20),
                Invoice_Amount decimal(30,2));
                
                insert into temp_minus (Farmer_Id,MCC_Id,Invoice_Amount)
                select Farmer_Id ,MCC_Id, sum(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END) from temp_invoice
                group by Farmer_Id ,MCC_Id
                having sum(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END) < 0;
                
				UPDATE t005_milkcollectionfarmer t005
					inner join temp_invoice temp on  
                    temp.Check_Id = t005.Farmercollection_Id
					SET Is_Check = 1

                    where 
                    temp.Org_Id = t005.Org_Id 
                    and temp.Is_Voucher = 0
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and t005.Farmer_Id not in (select Farmer_Id from temp_minus);
				
                UPDATE f010_milkcollectionmcc_final t009
					inner join temp_invoice temp on  
                    temp.Check_Id = t009.Entry_Id
					SET Is_OutsideCheck = 1

                    where 
                    temp.Org_Id = t009.Org_Id 
                    and temp.Is_Voucher = 0
                    and (OutsideInvoice_Id = '' or OutsideInvoice_Id IS NULL)
                    and Is_OutsideInvoiceCreated = 0
                    -- and Is_OutsideVehicle  = 1
                    and t009.MCC_Id not in (select Farmer_Id from temp_minus);
                    
				UPDATE t033_deductions_item t033
					inner join temp_invoice temp on  
                    temp.Check_Id = t033.Entry_Id
                    inner join t033_deductions_header t0332 on 
                    t033.Deductions_Id = t0332.Deductions_Id
					and temp.Check_Id = t033.Entry_Id
					SET Is_Check = 1,
                    Is_Deducted = 1
                    where 
                    temp.Org_Id = t033.Org_Id 
                    and temp.Is_Voucher = 1
                    and date(t033.Deduction_Date) <= date(CONVERT_TZ(NOW(), '+00:00', '+00:00'))
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and t0332.Request_User_Id not in (select Farmer_Id from temp_minus)
                    ;
                    
				UPDATE t033_deductions_header t033
					inner join temp_invoice temp on  
					temp.Org_Id = t033.Org_Id
                    inner join t033_deductions_item t0332 on 
                    t033.Deductions_Id = t0332.Deductions_Id
					and temp.Check_Id = t0332.Entry_Id
					SET t033.Amount_Deducted = (select sum(t0331.Deduction_Amount) from t033_deductions_item t0331
												where 
												t033.Deductions_Id = t0331.Deductions_Id
												and t033.Org_Id = t0331.Org_Id
												and t0331.Is_Deducted = 1)
					where 
					temp.Org_Id = t033.Org_Id 
					and temp.Is_Voucher = 1
                    and t033.Request_User_Id not in (select Farmer_Id from temp_minus)
                    ;
                    
				UPDATE t033_deductions_header t033
					inner join temp_invoice temp on  
					temp.Org_Id = t033.Org_Id
                    inner join t033_deductions_item t0332 on 
                    t033.Deductions_Id = t0332.Deductions_Id
					and temp.Check_Id = t0332.Entry_Id
					SET t033.Balance = t033.Total_Amount - t033.Amount_Deducted
					where
					temp.Org_Id = t033.Org_Id 
					and temp.Is_Voucher = 1
                    and t033.Request_User_Id not in (select Farmer_Id from temp_minus)
                    ;
                    
				UPDATE t033_deductions_header t033
					inner join temp_invoice temp on  
					temp.Org_Id = t033.Org_Id
                    inner join t033_deductions_item t0332 on 
                    t033.Deductions_Id = t0332.Deductions_Id
					and temp.Check_Id = t0332.Entry_Id
					SET t033.Is_Closed = CASE
											WHEN t033.Total_Amount - t033.Amount_Deducted = 0 THEN 1
											ELSE 0
										END
					WHERE temp.Org_Id = t033.Org_Id 
					AND temp.Is_Voucher = 1
                    and t033.Request_User_Id not in (select Farmer_Id from temp_minus)
                    ;
					
                DROP TEMPORARY TABLE IF EXISTS temp_invoice_main;
				CREATE TEMPORARY TABLE temp_invoice_main (PKeyRowNum INT, 
					Org_Id varchar(10),
					Invoice_Id varchar(20),
					Invoice_No varchar(20),
					Farmer_Id varchar(20),
					MCC_Id varchar(20),
					MusterCycle_StartDate DATE,
					MusterCycle_EndDate DATE,
					Invoice_Amount DECIMAL(30, 2)
                    );
					SET @PKeyRowNum := 0;
                
				INSERT INTO temp_invoice_main (PKeyRowNum,Org_Id, Farmer_Id, MCC_Id, 
					MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Amount)
				SELECT @PKeyRowNum := @PKeyRowNum + 1,  Org_Id, Farmer_Id, MCC_Id,
					MusterCycle_StartDate, MusterCycle_EndDate,
                    -- SUM(Invoice_Amount)
                    SUM(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END)
				FROM temp_invoice
                where Farmer_Id not in (select Farmer_Id from temp_minus)
				GROUP BY Org_Id, Farmer_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate;
                
                
                
				SELECT COUNT(*) INTO total_rows FROM temp_invoice_main;
                
				WHILE loop_counter <= total_rows DO
                
					SELECT Org_Id, Farmer_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate
					INTO current_org_id, current_farmer_id, current_mcc_id, current_start_date, current_end_date
					FROM temp_invoice_main
					WHERE PKeyRowNum = loop_counter;

					Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T027', '', New_Invoice_Id );
                    Call USP_Number_Range ('t027_Farmer_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
                    
                    set New_Invoice_No = concat(left(New_Invoice_No, 5), right(New_Invoice_No, 6));
                    
                    set New_Invoice_Id = New_Invoice_Id; 

                    set New_Invoice_No = New_Invoice_No;

					UPDATE temp_invoice_main
					SET Invoice_Id = New_Invoice_Id,
						Invoice_No = New_Invoice_No -- RIGHT(New_Invoice_Id, 9)
					WHERE Org_Id = current_org_id
					AND Farmer_Id = current_farmer_id
					AND MCC_Id = current_mcc_id
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date;
					

                    UPDATE t005_milkcollectionfarmer
					SET Invoice_Id = New_Invoice_Id,
						Is_InvoiceCreated = 1,
						InvoiceCreated_On = NOW()
					WHERE Org_Id = current_org_id
					AND Farmer_Id = current_farmer_id
					AND MCC_Id = current_mcc_id
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and Is_Check =1;
                    
                    UPDATE f010_milkcollectionmcc_final t009
					Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = t009.Org_Id 
                    -- and f010.Entry_Id = t009.Entry_Id
                    AND f010.MCC_Id = current_mcc_id
                    AND f010.MCC_Id = current_farmer_id
					SET t009.OutsideInvoice_Id = New_Invoice_Id,
						t009.Is_OutsideInvoiceCreated = 1,
						t009.OutsideInvoiceCreated_On = NOW()
					WHERE t009.Org_Id = current_org_id
					-- AND date(t009.Created_On) = current_start_date
                    and (t009.OutsideInvoice_Id = '' or t009.OutsideInvoice_Id IS NULL)
                    and t009.Is_OutsideInvoiceCreated =0
                    and t009.Is_OutsideCheck =1
                    -- and t009.Is_OutsideVehicle =1
                    ;
				

                
                    UPDATE t033_deductions_item t0331
                   inner join t033_deductions_header t033 on  
                    t033.Org_Id = t0331.Org_Id
                    and t033.Deductions_Id = t0331.Deductions_Id
                    and t033.Request_User_Id = current_farmer_id
                    and t033.MCC_Id = current_mcc_id
                    and t033.Request_User_Type = 'Farmer'
					SET t0331.Invoice_Id = New_Invoice_Id,
						t0331.Is_InvoiceCreated = 1,
						t0331.InvoiceCreated_On = NOW()
					WHERE t0331.Org_Id = current_org_id
                    and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
                    and t0331.Is_InvoiceCreated =0
                    and t0331.Is_Check =1
                    and t0331.Is_Deducted =1
                    AND date(t0331.Deduction_Date) BETWEEN current_start_date AND current_end_date
                    -- AND MusterCycle_StartDate = current_start_date
					-- AND MusterCycle_EndDate = current_end_date
                    ;
                    
                    set New_Invoice_Id = ''; 

                    set New_Invoice_No = '';

					SET loop_counter = loop_counter + 1;
                    
				END WHILE;
                
                
		
                Insert into t027_invoice_farmer
				(Org_Id, Voucher_Id, Farmer_Id, MCC_Id,Invoice_Date, Invoice_No, 
                MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				SELECT Org_Id, Invoice_Id, Farmer_Id, MCC_Id,DATE(CONVERT_TZ(MusterCycle_EndDate, '+00:00', '+00:00')), Invoice_No, 
                MusterCycle_StartDate,MusterCycle_EndDate,round(Invoice_Amount),
                1,0,Now(),var_User_Id,var_User_Name
				from temp_invoice_main;  
                
                drop temporary table temp_invoice;
                drop temporary table temp_invoice_main;
                
                SELECT 
				1 AS Result_Id,
				'Create' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
        end;
		elseif (var_Method_Name = 'Update') then  
			begin
				UPDATE t027_invoice_farmer
					SET SAP_Document_Id = var_SAP_Document_Id,
                    SAP_Document_Year = var_SAP_Document_Year,
                    Is_InvoicePosted = 1,
                    Is_Posted = var_InvoiceData
					WHERE Org_Id = var_Org_Id
					AND Voucher_Id = var_Invoice_Id;
                    
				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
			end;
		elseif (var_Method_Name = 'Update_Income') then  
			begin
				UPDATE t027_invoice_farmer
				SET Income_SAP_Document_Id = var_SAP_Document_Id,
				Income_SAP_Document_Year = var_SAP_Document_Year,
				Is_IncomePosted = var_InvoiceData
				WHERE Org_Id = var_Org_Id
                and Is_IncomePosted <> 4
				AND Voucher_Id = var_Invoice_Id;
                    
				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
			end;
		elseif (var_Method_Name = 'Update_Deduction') then  
			begin
				UPDATE t027_invoice_farmer
				SET Deduction_SAP_Document_Id = var_SAP_Document_Id,
				Deduction_SAP_Document_Year = var_SAP_Document_Year,
				Is_DeductionPosted = var_InvoiceData
				WHERE Org_Id = var_Org_Id
                and Is_DeductionPosted <> 4
				AND Voucher_Id = var_Invoice_Id;
                
                /*
                
                UPDATE t027_invoice_farmer
				SET Is_InvoicePDFGenerated = 1
				WHERE Org_Id = var_Org_Id
				AND Voucher_Id = var_Invoice_Id;
                
                */

				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
			end;
	elseif (var_Method_Name = 'SetFlag') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_Posted = 1,
            Is_IncomePosted = 1,
            Is_DeductionPosted = 1
			where Org_Id = var_Org_Id 
            and Is_IncomePosted = 0
			and ifnull(Income_SAP_Document_Id,'') =''
			and ifnull(Income_SAP_Document_Year,'') = ''
            and Is_DeductionPosted = 0
			and ifnull(Deduction_SAP_Document_Id,'') =''
			and ifnull(Deduction_SAP_Document_Year,'') = ''
			and FIND_IN_SET(Voucher_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'SetFlagDummy') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_Posted = 10,
            Is_IncomePosted = 10,
            Is_DeductionPosted = 10
			where Org_Id = var_Org_Id 
			and FIND_IN_SET(Voucher_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseVoucher') then
		begin
			Update t005_milkcollectionfarmer
			set 
			Invoice_Id ='',
			Is_InvoiceCreated = 0,
			Is_Check = 0
			where Org_Id = var_Org_Id 
			and Invoice_Id = var_Invoice_Id;

			Update t033_deductions_header t033
			inner join  t033_deductions_item t0331 on
			t033.Deductions_Id = t0331.Deductions_Id
			and t033.Org_Id = t0331.Org_Id
			set 
			t033.Is_Closed = 0,
			t033.Amount_Deducted = t033.Total_Amount - t0331.Deduction_Amount
			where t0331.Org_Id = var_Org_Id 
			and t0331.Invoice_Id = var_Invoice_Id;

			Update t033_deductions_header t033
			inner join  t033_deductions_item t0331 on
			t033.Deductions_Id = t0331.Deductions_Id
			and t033.Org_Id = t0331.Org_Id
			set 
			t033.Balance = t033.Total_Amount - t033.Amount_Deducted
			where t0331.Org_Id = var_Org_Id 
			and t0331.Invoice_Id = var_Invoice_Id;

			Update t033_deductions_item 
			set 
			Invoice_Id ='',
			Is_InvoiceCreated = 0,
			Is_Check = 0,
			Is_Deducted = 0
			where Org_Id = var_Org_Id 
			and Invoice_Id = var_Invoice_Id;

			Update f010_milkcollectionmcc_final
			set 
			OutsideInvoice_Id ='',
			Is_OutsideInvoiceCreated = 0,
			Is_OutsideCheck = 0
			where Org_Id = var_Org_Id 
			and OutsideInvoice_Id = var_Invoice_Id;

			DELETE f012
			FROM f012_farmer_invoice f012
			INNER JOIN t027_invoice_farmer t027 ON
				f012.Invoice_No = t027.Invoice_No
				AND f012.Org_Id = t027.Org_Id
			WHERE t027.Org_Id = var_Org_Id 
				AND t027.Voucher_Id = var_Invoice_Id;

			DELETE FROM t027_invoice_farmer
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseIncome') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_IncomePosted = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseDeduction') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_DeductionPosted = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseIncomeDeduction') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_IncomePosted = 1,
            Is_DeductionPosted = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'NCreate') then
		begin
		Declare New_Invoice_Id varchar(20);
		Declare New_Invoice_No varchar(20);
		Declare Year_Id varchar(10);
		Declare Voucher_No_Pre varchar(20);
		
		DECLARE k INT UNSIGNED DEFAULT 0;
		DECLARE j INT UNSIGNED DEFAULT 0;
		DECLARE row_count INT UNSIGNED;
		DECLARE xpath TEXT;
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
		end if;

		set Voucher_No_Pre = (select concat('P', Year_No, Year_No + 1));
	   
			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_invoice;
			CREATE TEMPORARY TABLE temp_invoice (PKeyRowNum int, 
			Org_Id varchar(20),
			-- Invoice_Id varchar(20),Invoice_No varchar(20),
			Check_Id varchar(20),Farmer_Id varchar(20), MCC_Id varchar(20), 
			MusterCycle_StartDate date, MusterCycle_EndDate date, 
			Invoice_Amount decimal(30,2),Is_Voucher int);
			
			SET row_count := extractValue(var_InvoiceData,'count(//Invoice/InvoiceItem)');
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//Invoice/InvoiceItem[', k, ']');
				-- Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T024', '', New_Invoice_Id );
				
				SET @StartDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/StartDate')), '%m/%d/%Y %H:%i:%s');
				SET @EndDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/EndDate')), '%m/%d/%Y %H:%i:%s');
			
				INSERT INTO temp_invoice VALUES (
					k,
					var_Org_Id,
					extractValue(var_InvoiceData, concat(xpath,'/Check_Id')),
					extractValue(var_InvoiceData, concat(xpath,'/Farmer_Id')),
					extractValue(var_InvoiceData, concat(xpath,'/MCC_Id')),
					@StartDate,
					@EndDate,
					extractValue(var_InvoiceData, concat(xpath,'/Amount')),
					extractValue(var_InvoiceData, concat(xpath,'/Is_Voucher'))
				);
			END WHILE;
			
			
			UPDATE t005_milkcollectionfarmer t005
				inner join temp_invoice temp on  
				temp.Check_Id = t005.Farmercollection_Id
				SET Is_Check = 1

				where 
				temp.Org_Id = t005.Org_Id 
				and temp.Is_Voucher = 0
				and (Invoice_Id = '' or Invoice_Id IS NULL)
				and Is_InvoiceCreated =0;
			
			UPDATE f010_milkcollectionmcc_final t009
				inner join temp_invoice temp on  
				temp.Check_Id = t009.Entry_Id
				SET Is_OutsideCheck = 1

				where 
				temp.Org_Id = t009.Org_Id 
				and temp.Is_Voucher = 0
				and (OutsideInvoice_Id = '' or OutsideInvoice_Id IS NULL)
				and Is_OutsideInvoiceCreated = 0;
				
			UPDATE t033_deductions_item t033
				inner join temp_invoice temp on  
				temp.Check_Id = t033.Entry_Id
				inner join t033_deductions_header t0332 on 
				t033.Deductions_Id = t0332.Deductions_Id
				and temp.Check_Id = t033.Entry_Id
				SET Is_Check = 1,
				Is_Deducted = 1
				where 
				temp.Org_Id = t033.Org_Id 
				and temp.Is_Voucher = 1
				and date(t033.Deduction_Date) <= date(CONVERT_TZ(NOW(), '+00:00', '+00:00'))
				and (Invoice_Id = '' or Invoice_Id IS NULL)
				and Is_InvoiceCreated =0;
				
			UPDATE t033_deductions_header t033
				inner join temp_invoice temp on  
				temp.Org_Id = t033.Org_Id
				inner join t033_deductions_item t0332 on 
				t033.Deductions_Id = t0332.Deductions_Id
				and temp.Check_Id = t0332.Entry_Id
				SET t033.Amount_Deducted = (select sum(t0331.Deduction_Amount) from t033_deductions_item t0331
											where 
											t033.Deductions_Id = t0331.Deductions_Id
											and t033.Org_Id = t0331.Org_Id
											and t0331.Is_Deducted = 1)
				where 
				temp.Org_Id = t033.Org_Id 
				and temp.Is_Voucher = 1;
				
			UPDATE t033_deductions_header t033
				inner join temp_invoice temp on  
				temp.Org_Id = t033.Org_Id
				inner join t033_deductions_item t0332 on 
				t033.Deductions_Id = t0332.Deductions_Id
				and temp.Check_Id = t0332.Entry_Id
				SET t033.Balance = t033.Total_Amount - t033.Amount_Deducted
				where
				temp.Org_Id = t033.Org_Id 
				and temp.Is_Voucher = 1;
				
			UPDATE t033_deductions_header t033
				inner join temp_invoice temp on  
				temp.Org_Id = t033.Org_Id
				inner join t033_deductions_item t0332 on 
				t033.Deductions_Id = t0332.Deductions_Id
				and temp.Check_Id = t0332.Entry_Id
				SET t033.Is_Closed = CASE
										WHEN t033.Total_Amount - t033.Amount_Deducted = 0 THEN 1
										ELSE 0
									END
				WHERE temp.Org_Id = t033.Org_Id 
				AND temp.Is_Voucher = 1;
				
			DROP TEMPORARY TABLE IF EXISTS temp_invoice_main;
			CREATE TEMPORARY TABLE temp_invoice_main (PKeyRowNum INT, 
				Org_Id varchar(10),
				Invoice_Id varchar(20),
				Invoice_No varchar(20),
				Farmer_Id varchar(20),
				MCC_Id varchar(20),
				MusterCycle_StartDate DATE,
				MusterCycle_EndDate DATE,
				Invoice_Amount DECIMAL(30, 2)
				);
				SET @PKeyRowNum := 0;
			
			INSERT INTO temp_invoice_main (PKeyRowNum,Org_Id, Farmer_Id, MCC_Id, 
				MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Amount)
			SELECT @PKeyRowNum := @PKeyRowNum + 1,  Org_Id, Farmer_Id, MCC_Id,
				MusterCycle_StartDate, MusterCycle_EndDate,
				-- SUM(Invoice_Amount)
				SUM(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END)
			FROM temp_invoice
			GROUP BY Org_Id, Farmer_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate;
			
			
			
			SELECT COUNT(*) INTO total_rows FROM temp_invoice_main;
			
			WHILE loop_counter <= total_rows DO
			
				SELECT Org_Id, Farmer_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate
				INTO current_org_id, current_farmer_id, current_mcc_id, current_start_date, current_end_date
				FROM temp_invoice_main
				WHERE PKeyRowNum = loop_counter;

				Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T027', '', New_Invoice_Id );
				Call USP_Number_Range ('t027_Farmer_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
				
				set New_Invoice_No = concat(left(New_Invoice_No, 5), right(New_Invoice_No, 6));
                
                set New_Invoice_Id = New_Invoice_Id; 

				set New_Invoice_No = New_Invoice_No;

				UPDATE temp_invoice_main
				SET Invoice_Id = New_Invoice_Id,
					Invoice_No = New_Invoice_No -- RIGHT(New_Invoice_Id, 9)
				WHERE Org_Id = current_org_id
				AND Farmer_Id = current_farmer_id
				AND MCC_Id = current_mcc_id
				AND MusterCycle_StartDate = current_start_date
				AND MusterCycle_EndDate = current_end_date;
				

				UPDATE t005_milkcollectionfarmer
				SET Invoice_Id = New_Invoice_Id,
					Is_InvoiceCreated = 1,
					InvoiceCreated_On = NOW()
				WHERE Org_Id = current_org_id
				AND Farmer_Id = current_farmer_id
				AND MCC_Id = current_mcc_id
				AND MusterCycle_StartDate = current_start_date
				AND MusterCycle_EndDate = current_end_date
				and (Invoice_Id = '' or Invoice_Id IS NULL)
				and Is_InvoiceCreated =0
				and Is_Check =1;
				
				UPDATE f010_milkcollectionmcc_final t009
				Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = t009.Org_Id 
				-- and f010.Entry_Id = t009.Entry_Id
				AND f010.MCC_Id = current_mcc_id
                AND f010.MCC_Id = current_farmer_id
				SET t009.OutsideInvoice_Id = New_Invoice_Id,
					t009.Is_OutsideInvoiceCreated = 1,
					t009.OutsideInvoiceCreated_On = NOW()
				WHERE t009.Org_Id = current_org_id
				-- AND date(t009.Created_On) = current_start_date
				and (t009.OutsideInvoice_Id = '' or t009.OutsideInvoice_Id IS NULL)
				and t009.Is_OutsideInvoiceCreated =0
				and t009.Is_OutsideCheck =1
				-- and t009.Is_OutsideVehicle =1
				;
			

			
				UPDATE t033_deductions_item t0331
			   inner join t033_deductions_header t033 on  
				t033.Org_Id = t0331.Org_Id
				and t033.Deductions_Id = t0331.Deductions_Id
				and t033.Request_User_Id = current_farmer_id
				and t033.Request_User_Type = 'Farmer'
                and t033.MCC_Id = current_mcc_id
				SET t0331.Invoice_Id = New_Invoice_Id,
					t0331.Is_InvoiceCreated = 1,
					t0331.InvoiceCreated_On = NOW()
				WHERE t0331.Org_Id = current_org_id
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				and t0331.Is_InvoiceCreated =0
				and t0331.Is_Check =1
				and t0331.Is_Deducted =1
				-- AND MusterCycle_StartDate = current_start_date
				-- AND MusterCycle_EndDate = current_end_date
                AND date(t0331.Deduction_Date) BETWEEN current_start_date AND current_end_date
                ;
				set New_Invoice_Id = ''; 

				set New_Invoice_No = '';
                
				SET loop_counter = loop_counter + 1;
				
			END WHILE;
			
			
	
			Insert into t027_invoice_farmer
			(Org_Id, Voucher_Id, Farmer_Id, MCC_Id,Invoice_Date, Invoice_No, 
			MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
			Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
			SELECT Org_Id, Invoice_Id, Farmer_Id, MCC_Id,DATE(CONVERT_TZ(MusterCycle_EndDate, '+00:00', '+00:00')), Invoice_No, 
			MusterCycle_StartDate,MusterCycle_EndDate,round(Invoice_Amount),
			1,0,Now(),var_User_Id,var_User_Name
			from temp_invoice_main;  
			
			drop temporary table temp_invoice;
			drop temporary table temp_invoice_main;
			
			SELECT 
			1 AS Result_Id,
			'Create' AS Result_Description,
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_TDS') then
		begin
        
			Update t027_invoice_farmer
			set 
            Is_TDSDownloaded = 1,
            TDS_Amount = CAST(var_InvoiceData AS DECIMAL(30, 2)),
            Is_InvoicePDFGenerated = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'TDS' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_MusterCycle') then  
			begin
            
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Invoice_Id, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Invoice_Id, ' - ', -1), '%m/%d/%Y');
				
				update t005_milkcollectionfarmer t005
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				and m005.MCC_Id = var_SAP_Document_Id
				set t005.MusterCycle_StartDate = date(var_StartDate),
					t005.MusterCycle_EndDate = date(var_EndDate)
				where t005.Org_Id = var_Org_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0;
                
                SELECT 1 AS Result_Id, 
				'MusterCycle' AS Result_Description, 
				var_Invoice_Id AS Result_Extra_Key;
                
            end;
	elseif (var_Method_Name = 'Set_Pending') then
		begin
        
			select 
			Voucher_Id, 
			ifnull(Income_SAP_Document_Id,'') as Income_SAP_Document_Id, ifnull(Income_SAP_Document_Year,'') as Income_SAP_Document_Year,
			ifnull(Deduction_SAP_Document_Id,'') as Deduction_SAP_Document_Id, ifnull(Deduction_SAP_Document_Year,'') as Deduction_SAP_Document_Year
			into 
			@Voucher_Id,
			@Income_SAP_Document_Id,@Income_SAP_Document_Year,
			@Deduction_SAP_Document_Id,@Deduction_SAP_Document_Year
			from t027_invoice_farmer
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            
            if(@Income_SAP_Document_Id <> '' or @Income_SAP_Document_Id <> null)then
            
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't027_invoice_farmer', @Voucher_Id, @Income_SAP_Document_Id, @Income_SAP_Document_Year, 
				var_User_Id, var_User_Name);
                
            end if;
            
            if(@Deduction_SAP_Document_Id <> '' or @Deduction_SAP_Document_Id <> null)then
            
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't027_invoice_farmer', @Voucher_Id, @Deduction_SAP_Document_Id, @Deduction_SAP_Document_Year, 
				var_User_Id, var_User_Name);
                
            end if;
            
        
			Update t027_invoice_farmer
			set 
            Is_IncomePosted = 0,
            Income_SAP_Document_Id = '',
            Income_SAP_Document_Year = '',
            Is_DeductionPosted = 0,
            Deduction_SAP_Document_Id = '',
            Deduction_SAP_Document_Year = ''
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end ;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
