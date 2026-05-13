-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCInSAP_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCInSAP_Set`(
	var_Method_Name longtext,
    var_Org_Id varchar(10),
    var_InvoiceData longtext,
    var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year varchar(20),
    var_Invoice_Id longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int)
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
			DECLARE current_mcc_id varchar(20);
			DECLARE current_start_date DATE;
			DECLARE current_end_date DATE;
            DECLARE current_mppitype_id varchar(20);
            DECLARE Anamat_PerLtr decimal(8,2);
			DECLARE Freight_PerLtr decimal(8,2);
            DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
            
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

			set Voucher_No_Pre = (select concat('M', Year_No, Year_No + 1));

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Invoice_Id, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Invoice_Id, ' - ', -1), '%m/%d/%Y');
			
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			
            	-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_invoice;
				CREATE TEMPORARY TABLE temp_invoice (PKeyRowNum int, 
                Org_Id varchar(20),
                -- Invoice_Id varchar(20),Invoice_No varchar(20),
				Check_Id varchar(20), MCC_Id varchar(20), 
                MusterCycle_StartDate date, MusterCycle_EndDate date, 
                Invoice_Amount decimal(30,2),Is_Voucher int,
                MPPIType_Id varchar(20));
                
				SET row_count := extractValue(var_InvoiceData,'count(//Invoice/InvoiceItem)');
                
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Invoice/InvoiceItem[', k, ']');
                    -- Call USP_Number_Range ('t027_invoice_farmer', Year_Id, 'T024', '', New_Invoice_Id );
                    
                    -- SET @StartDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/StartDate')), '%m/%d/%Y %H:%i:%s');
					-- SET @EndDate := STR_TO_DATE(extractValue(var_InvoiceData, concat(xpath, '/EndDate')), '%m/%d/%Y %H:%i:%s');
                    
                    
					INSERT INTO temp_invoice VALUES (
						k,
                        var_Org_Id,
						extractValue(var_InvoiceData, concat(xpath,'/Check_Id')),
						extractValue(var_InvoiceData, concat(xpath,'/MCC_Id')),
						-- @StartDate,
						-- @EndDate,
                        extractValue(var_InvoiceData, concat(xpath, '/StartDate')),
                        extractValue(var_InvoiceData, concat(xpath, '/EndDate')),
                        extractValue(var_InvoiceData, concat(xpath,'/Amount')),
                        extractValue(var_InvoiceData, concat(xpath,'/Is_Voucher')),
                        extractValue(var_InvoiceData, concat(xpath,'/MPPIType_Id'))
					);
				END WHILE;
                
                
                    UPDATE t009_milkcollectiondairy_mcccommission t008
					inner join temp_invoice temp on  
                    temp.Check_Id = t008.MilkCollectionMCCCommission_Id
                    and (temp.MPPIType_Id is not null or  temp.MPPIType_Id  <>'')
					SET Is_Check = 1,
                    MCC_Commision = temp.Invoice_Amount
                    where 
                    temp.Org_Id = t008.Org_Id 
                    and temp.Is_Voucher = 0
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0;
                    -- AND t008.MPPIType_Id = temp.MPPIType_Id;
                    
                    UPDATE t009_milkcollectiondairy_mcccommission t008
					inner join temp_invoice temp on  
                    temp.Check_Id = t008.MilkCollectionMCCCommission_Id
                    and (temp.MPPIType_Id is  null or  temp.MPPIType_Id = '')
					SET Is_Check = 1,
                    MCC_Commision = temp.Invoice_Amount
                    where 
                    temp.Org_Id = t008.Org_Id 
                    and temp.Is_Voucher = 3
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0;
                    
					UPDATE t033_deductions_item t033
					inner join temp_invoice temp on  
                    temp.Check_Id = t033.Entry_Id
                    and (temp.MPPIType_Id is null or  temp.MPPIType_Id = '')
					SET Is_Check = 1,
                    Is_Deducted = 1
                    where 
                    temp.Org_Id = t033.Org_Id 
                    and temp.Is_Voucher = 1
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
					MCC_Id varchar(20),
					MusterCycle_StartDate DATE,
					MusterCycle_EndDate DATE,
					Invoice_Amount DECIMAL(30, 2),
                    MPPIType_Id varchar(20));
					SET @PKeyRowNum := 0;
                   
				DROP TEMPORARY TABLE IF EXISTS temp_invoice_secondary;
				CREATE TEMPORARY TABLE temp_invoice_secondary (
					PKeyRowNum INT, 
					Org_Id VARCHAR(10),
					Invoice_Id VARCHAR(20),
					Invoice_No VARCHAR(20),
					MCC_Id VARCHAR(20),
					MusterCycle_StartDate DATE,
					MusterCycle_EndDate DATE,
					Invoice_Amount DECIMAL(30, 2),
					MPPIType_Id VARCHAR(20),
					Primary_Invoice_Id VARCHAR(20)
				);
                SET @PKeyRowNumSecondary := 0;
                
				INSERT INTO temp_invoice_main (PKeyRowNum,Org_Id, MCC_Id, 
					MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Amount,MPPIType_Id)
				SELECT @PKeyRowNum := @PKeyRowNum + 1,  Org_Id, MCC_Id,
					MusterCycle_StartDate, MusterCycle_EndDate,sum(Invoice_Amount),
                    -- SUM(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END),
                     MPPIType_Id
				FROM temp_invoice
				GROUP BY Org_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate,MPPIType_Id;
                
                
                INSERT INTO temp_invoice_secondary (PKeyRowNum,Org_Id, MCC_Id, 
					MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Amount,MPPIType_Id)
				SELECT @PKeyRowNumSecondary := @PKeyRowNumSecondary + 1,  Org_Id, MCC_Id,
					MusterCycle_StartDate, MusterCycle_EndDate,sum(Invoice_Amount),
                    -- SUM(CASE WHEN Is_Voucher = 0 THEN Invoice_Amount ELSE -Invoice_Amount END),
                     MPPIType_Id
				FROM temp_invoice
				GROUP BY Org_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate,MPPIType_Id;
                
                
				SELECT COUNT(*) INTO total_rows FROM temp_invoice_main;
                
                
                
				WHILE loop_counter <= total_rows DO
					
					SELECT Org_Id, MCC_Id, MusterCycle_StartDate, MusterCycle_EndDate,MPPIType_Id
					INTO current_org_id, current_mcc_id, current_start_date, current_end_date,current_mppitype_id
					FROM temp_invoice_main
					WHERE PKeyRowNum = loop_counter;
                    
					Call USP_Number_Range ('t028_invoice_mcc', Year_Id, 'T028', '', New_Invoice_Id );
					Call USP_Number_Range ('t028_MCC_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
                    
                    
                    set New_Invoice_Id = New_Invoice_Id; 

                    set New_Invoice_No = New_Invoice_No;
                    
					UPDATE temp_invoice_main
					SET Invoice_Id = New_Invoice_Id,
						Invoice_No = New_Invoice_No -- RIGHT(New_Invoice_Id, 9)
					WHERE Org_Id = current_org_id
					AND MCC_Id = current_mcc_id
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date
                    and MPPIType_Id = current_mppitype_id;
                    
                    UPDATE temp_invoice_secondary  temp2
					SET temp2.Invoice_Id = New_Invoice_Id,
						temp2.Invoice_No = New_Invoice_No -- RIGHT(New_Invoice_Id, 9)
					WHERE temp2.Org_Id = current_org_id
					AND temp2.MCC_Id = current_mcc_id
					AND temp2.MusterCycle_StartDate = current_start_date
					AND temp2.MusterCycle_EndDate = current_end_date
                    and MPPIType_Id = current_mppitype_id;
                    
					UPDATE temp_invoice_secondary  temp2
					SET temp2.Primary_Invoice_Id  = (
							SELECT IFNULL(temp1.Invoice_Id, New_Invoice_Id)
							FROM temp_invoice_main temp1
							WHERE temp1.Org_Id = temp2.Org_Id
								AND temp1.MCC_Id = temp2.MCC_Id
								AND temp1.MusterCycle_StartDate = temp2.MusterCycle_StartDate
								AND temp1.MusterCycle_EndDate = temp2.MusterCycle_EndDate
							ORDER BY temp1.Invoice_Id ASC
							LIMIT 1)
					WHERE temp2.Org_Id = current_org_id
					AND temp2.MCC_Id = current_mcc_id
					AND temp2.MusterCycle_StartDate = current_start_date
					AND temp2.MusterCycle_EndDate = current_end_date;
					
                   /*
                     UPDATE t009_milkcollectiondairy_mcccommission
					SET Invoice_Id = New_Invoice_Id,
						Is_InvoiceCreated = 1,
						InvoiceCreated_On = NOW()
					WHERE Org_Id = current_org_id
					AND MCC_Id = current_mcc_id
                    -- AND MPPIType_Id = current_mppitype_id
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and Is_Check =1;
                    */
                    
                    UPDATE t009_milkcollectiondairy_mcccommission
					SET Invoice_Id = New_Invoice_Id,
						Is_InvoiceCreated = 1,
						InvoiceCreated_On = NOW()
					WHERE Org_Id = current_org_id
					AND MCC_Id = current_mcc_id
					AND MPPIType_Id in('C047001','C047003','C047009')
                    AND current_mppitype_id  =  'C047001'
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and Is_Check =1;
                    
                    
                    UPDATE t009_milkcollectiondairy_mcccommission
					SET Invoice_Id = New_Invoice_Id,
						Is_InvoiceCreated = 1,
						InvoiceCreated_On = NOW()
					WHERE Org_Id = current_org_id
					AND MCC_Id = current_mcc_id
					AND MPPIType_Id in('C047004','C047005','C047006','C047007','C047008')
                    AND ifnull(current_mppitype_id ,'') = ''
					AND MusterCycle_StartDate = current_start_date
					AND MusterCycle_EndDate = current_end_date
                    and (Invoice_Id = '' or Invoice_Id IS NULL)
                    and Is_InvoiceCreated =0
                    and Is_Check =1;
				
					UPDATE t033_deductions_item t0331
                   inner join t033_deductions_header t033 on  
                    t033.Org_Id = t0331.Org_Id
                    and t033.Deductions_Id = t0331.Deductions_Id
                    and t033.Request_User_Type = 'Agent'
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
                    and (current_mppitype_id = '' or current_mppitype_id is null);
                    
                    
					set New_Invoice_Id = ''; 

					set New_Invoice_No = '';
                
					SET loop_counter = loop_counter + 1;
                   
				END WHILE;
                
               
                Insert into t028_invoice_mcc
				(Org_Id, Voucher_Id, MCC_Id,Invoice_Date, Invoice_No, 
                MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,MPPIType_Id,Primary_Voucher_Id)
				SELECT Org_Id, Invoice_Id, MCC_Id,DATE(MusterCycle_EndDate), Invoice_No, 
                MusterCycle_StartDate,MusterCycle_EndDate,round(Invoice_Amount),
                1,0,Now(),var_User_Id,var_User_Name,MPPIType_Id,Primary_Invoice_Id
				from temp_invoice_secondary;  
                
                
                drop temporary table temp_invoice;
                drop temporary table temp_invoice_main;
                drop temporary table temp_invoice_secondary;
                
                SELECT 
				1 AS Result_Id,
				'Create' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
        end;
		elseif (var_Method_Name = 'Update') then  
			begin
				UPDATE t028_invoice_mcc
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
				UPDATE t028_invoice_mcc
					SET SAP_Document_Id = var_SAP_Document_Id,
                    SAP_Document_Year = var_SAP_Document_Year,
                    Is_Posted = var_InvoiceData
					WHERE Org_Id = var_Org_Id
                    and Is_Posted <> 4
					AND Voucher_Id = var_Invoice_Id;
                    
                    /*
                    UPDATE t028_invoice_mcc
					SET Is_InvoicePDFGenerated = 1
					WHERE Org_Id = var_Org_Id
					AND Voucher_Id = var_Invoice_Id;
                    */
                    
				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
			end;
	elseif (var_Method_Name = 'Update_Deduction') then  
			begin
				UPDATE t028_invoice_mcc
					SET SAP_Document_Id = var_SAP_Document_Id,
                    SAP_Document_Year = var_SAP_Document_Year,
                    Is_Posted = var_InvoiceData
					WHERE Org_Id = var_Org_Id
                    and Is_Posted <> 4
					AND Voucher_Id = var_Invoice_Id;
                    
                    /*
                    UPDATE t028_invoice_mcc
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
        
			Update t028_invoice_mcc
			set 
            Is_Posted = 1
			where Org_Id = var_Org_Id 
            and Is_Posted = 0
			and ifnull(SAP_Document_Id,'') =''
			and ifnull(SAP_Document_Year,'') = ''
			and FIND_IN_SET(Voucher_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'SetFlagDummy') then
		begin
        
			Update t028_invoice_mcc
			set 
            Is_Posted = 2
			where Org_Id = var_Org_Id 
			and FIND_IN_SET(Voucher_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseVoucher') then
		begin
			Update t009_milkcollectiondairy_mcccommission
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

			DELETE f013
			FROM f013_mcc_invoice f013
			INNER JOIN t028_invoice_mcc t028 ON
				f013.Invoice_No = t028.Invoice_No
				AND f013.Org_Id = t028.Org_Id
			WHERE t028.Org_Id = var_Org_Id 
				AND t028.Voucher_Id = var_Invoice_Id;

			DELETE FROM t028_invoice_mcc
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ReverseMCC') then
		begin
        
			Update t028_invoice_mcc
			set 
            Is_Posted = 1
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_TDS') then
		begin
        
			Update t028_invoice_mcc
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
				
				update t009_milkcollectiondairy_mcccommission t0091
                inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
				set t0091.MusterCycle_StartDate = var_StartDate,
					t0091.MusterCycle_EndDate = var_EndDate
				where t0091.Org_Id = var_Org_Id
                and t0091.MCC_Id = var_SAP_Document_Id
				AND t0091.Is_InvoiceCreated = 0 
				and t0091.Is_Check = 0
				AND ifnull(t0091.Invoice_Id,'') = '';
                
                SELECT 1 AS Result_Id, 
				'MusterCycle' AS Result_Description, 
				var_Invoice_Id AS Result_Extra_Key;
                
            end;
            
	elseif (var_Method_Name = 'Set_Pending') then
		begin
        
			select 
			Voucher_Id, 
			ifnull(SAP_Document_Id,'') as SAP_Document_Id, ifnull(SAP_Document_Year,'') as SAP_Document_Year
			into 
			@Voucher_Id,
			@SAP_Document_Id,@SAP_Document_Year
			from t028_invoice_mcc
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            
			call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			't028_invoice_mcc', @Voucher_Id, @SAP_Document_Id, @SAP_Document_Year, 
			var_User_Id, var_User_Name);
               
			Update t028_invoice_mcc
			set 
            Is_Posted = 0,
            SAP_Document_Id = '',
            SAP_Document_Year = ''
			where Org_Id = var_Org_Id 
			and Voucher_Id = var_Invoice_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_Invoice_Id AS Result_Extra_Key;
        end ;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
