-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerPayment_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerPayment_Set`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_MCC_Id Varchar(20),
    var_Voucher_Id Varchar(20),
    var_Date varchar(255),
    var_Farmer_Id varchar(20),
    var_Description longtext,
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Invoice_Id varchar(20);
            Declare New_Invoice_No varchar(20);
            Declare Year_Id varchar(10);
            Declare Voucher_No_Pre varchar(20);
            DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
            Declare Year_No varchar(10);
			Declare Month_No int;
            
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
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
			
			set @IncomeAmount = (select sum(ifnull(Amount,0)) 
							from t103_milkcollectionfarmer_offline t103
							where t103.Org_Id = var_Org_Id
							and t103.Farmer_Id = var_Farmer_Id
							and t103.MCC_Id = var_MCC_Id
							and CAST(t103.Created_On  AS DATE) >= var_StartDate 
							and CAST(t103.Created_On  AS DATE)  <= var_EndDate
							and  t103.Is_InvoiceCreated = 0 
							and (t103.Invoice_Id = '' or t103.Invoice_Id IS NULL));
                            

		set @DeductionAmount = (select sum(ifnull(Amount,0)) as Amount 
								from t107_mcc_farmer_deduction t107
								where t107.Org_Id = var_Org_Id
								and t107.Farmer_Id = var_Farmer_Id
								and t107.MCC_Id = var_MCC_Id
								and CAST(t107.Deduction_Date  AS DATE) >= var_StartDate 
								and CAST(t107.Deduction_Date  AS DATE)  <= var_EndDate
								and  t107.Is_InvoiceCreated = 0 
                                and t107.Is_Check =1
								and (t107.Invoice_Id = '' or t107.Invoice_Id IS NULL));
                                
                                
		set @AnamatAmount = (select sum(ifnull(Amount,0)) as Amount 
							from m005_mcc_offline_anamat_amount_config m005
							where m005.Org_Id = var_Org_Id
							and m005.Farmer_Id = var_Farmer_Id
							and m005.MCC_Id = var_MCC_Id
							and CAST(m005.Created_On  AS DATE) >= var_StartDate 
							and CAST(m005.Created_On  AS DATE)  <= var_EndDate
							and  m005.Is_InvoiceCreated = 0 
							and (m005.Invoice_Id = '' or m005.Invoice_Id IS NULL));
                            
			
		set @AdvanceAmount = (select sum(ifnull(Deduction_Amount,0)) as Amount 
							from t033_deductions_header_offline t033
                            inner join t033_deductions_item_offline t033i on
                            t033.Org_Id = t033i.Org_Id
                            and CAST(t033i.Deduction_Date  AS DATE) >= var_StartDate 
							and CAST(t033i.Deduction_Date  AS DATE)  <= var_EndDate
							and  t033i.Is_InvoiceCreated = 0 
							and (t033i.Invoice_Id = '' or t033i.Invoice_Id IS NULL)
                            and t033.Deductions_Id = t033i.Deductions_Id
							where t033.Org_Id = var_Org_Id
							and t033.Farmer_Id = var_Farmer_Id
							and t033.MCC_Id = var_MCC_Id);
                            
			set @IssueAmount = (select sum(ifnull(t106i.Amount,0)) as Amount 
							from t106_mcc_material_issue t106
							inner join t106_mcc_material_issue_item t106i on
							t106.Org_Id = t106i.Org_Id
							and CAST(t106i.Date  AS DATE) >= var_StartDate 
							and CAST(t106i.Date  AS DATE)  <= var_EndDate
							and  t106i.Is_InvoiceCreated = 0 
							and (t106i.Invoice_Id = '' or t106i.Invoice_Id IS NULL)
							and t106.Issue_Id = t106i.Issue_Id
							where t106.Org_Id = var_Org_Id
							and t106.Farmer_Id = var_Farmer_Id
							and t106.MCC_Id = var_MCC_Id
                            and t106.Is_Paid =0);
									
			if(@IncomeAmount is null or @IncomeAmount = '')then
			
				set @IncomeAmount = 0;
			
			end if;
			
			if(@DeductionAmount is null or @DeductionAmount = '')then
			
				set @DeductionAmount = 0;
			
			end if;
            
            if(@AnamatAmount is null or @AnamatAmount = '')then
        
			set @AnamatAmount = 0;
        
			end if;
			
			if(@AdvanceAmount is null or @AdvanceAmount = '')then
			
				set @AdvanceAmount = 0;
			
			end if;
            
            if(@IssueAmount is null or @IssueAmount = '')then
        
			set @IssueAmount = 0;
        
			end if;
			
            
			set @TotalAmount = @IncomeAmount - @DeductionAmount - @AnamatAmount - @AdvanceAmount - @IssueAmount;
			
			
            Call USP_Number_Range ('t108_mcc_farmer_payment', Year_Id, 'T108', '', New_Invoice_Id );
			Call USP_Number_Range ('t108_Farmer_Inv_No', '', Voucher_No_Pre, '', New_Invoice_No );
            
            Insert into t108_mcc_farmer_payment
			(Org_Id, Voucher_Id, Farmer_Id, MCC_Id,Invoice_Date, Invoice_No, 
			MusterCycle_StartDate,MusterCycle_EndDate,Invoice_Amount,
			Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Description)
            value(
            var_Org_Id,New_Invoice_Id,var_Farmer_Id,var_MCC_Id,var_EndDate,New_Invoice_No,
            var_StartDate,var_EndDate,@TotalAmount,
            1,0,now(),var_User_Id,var_User_Name,var_Description);
            
            
            UPDATE t103_milkcollectionfarmer_offline t103
			SET t103.Invoice_Id = New_Invoice_Id,
				t103.Is_InvoiceCreated = 1,
				t103.InvoiceCreated_On = NOW()
			where 
			t103.Org_Id = var_Org_Id
			and t103.Farmer_Id = var_Farmer_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate
			and  t103.Is_InvoiceCreated = 0 
			and (t103.Invoice_Id = '' or t103.Invoice_Id IS NULL);
            
            UPDATE t107_mcc_farmer_deduction t107
			SET t107.Invoice_Id = New_Invoice_Id,
				t107.Is_InvoiceCreated = 1,
				t107.InvoiceCreated_On = NOW()
			where t107.Org_Id = var_Org_Id
			and t107.Farmer_Id = var_Farmer_Id
			and t107.MCC_Id = var_MCC_Id
			and CAST(t107.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t107.Deduction_Date  AS DATE)  <= var_EndDate
			and  t107.Is_InvoiceCreated = 0 
            and t107.Is_Check =1
			and (t107.Invoice_Id = '' or t107.Invoice_Id IS NULL);
            
            
            UPDATE m005_mcc_offline_anamat_amount_config m005
			SET m005.Invoice_Id = New_Invoice_Id,
				m005.Is_InvoiceCreated = 1,
				m005.InvoiceCreated_On = NOW()
			where 
			m005.Org_Id = var_Org_Id
			and m005.Farmer_Id = var_Farmer_Id
			and m005.MCC_Id = var_MCC_Id
			and CAST(m005.Created_On  AS DATE) >= var_StartDate 
			and CAST(m005.Created_On  AS DATE)  <= var_EndDate
			and  m005.Is_InvoiceCreated = 0 
			and (m005.Invoice_Id = '' or m005.Invoice_Id IS NULL);


			UPDATE t033_deductions_item_offline t033i
			inner join t033_deductions_header_offline t033 on
			t033.Org_Id = t033i.Org_Id
			and CAST(t033i.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t033i.Deduction_Date  AS DATE)  <= var_EndDate
			and  t033i.Is_InvoiceCreated = 0 
			and (t033i.Invoice_Id = '' or t033i.Invoice_Id IS NULL)
			and t033.Deductions_Id = t033i.Deductions_Id
			SET t033i.Invoice_Id = New_Invoice_Id,
				t033i.Is_InvoiceCreated = 1,
                t033i.Is_Deducted = 1,
				t033i.InvoiceCreated_On = NOW()
			where t033.Org_Id = var_Org_Id
			and t033.Farmer_Id = var_Farmer_Id
			and t033.MCC_Id = var_MCC_Id;
            
            UPDATE t106_mcc_material_issue_item t106i
			inner join t106_mcc_material_issue t106 on
			t106.Org_Id = t106i.Org_Id
			and CAST(t106i.Date  AS DATE) >= var_StartDate 
			and CAST(t106i.Date  AS DATE)  <= var_EndDate
			and  t106i.Is_InvoiceCreated = 0 
			and (t106i.Invoice_Id = '' or t106i.Invoice_Id IS NULL)
			and t106.Issue_Id = t106i.Issue_Id
			SET t106i.Invoice_Id = New_Invoice_Id,
				t106i.Is_InvoiceCreated = 1,
                t106i.Is_Deducted = 1,
				t106i.InvoiceCreated_On = NOW()
			where t106.Org_Id = var_Org_Id
			and t106.Farmer_Id = var_Farmer_Id
			and t106.MCC_Id = var_MCC_Id
			and t106.Is_Paid =0;
            
            
            SELECT 
			1 AS Result_Id,
			'Create' AS Result_Description,
			var_Org_Id AS Result_Extra_Key;
            
			
				
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
