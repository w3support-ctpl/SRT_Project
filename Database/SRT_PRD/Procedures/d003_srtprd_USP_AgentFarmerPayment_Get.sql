-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerPayment_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerPayment_Get`(
	var_Method_Name VARCHAR(255),
    var_Org_Id VARCHAR(10),
    var_User_Id varchar(20),
    var_MCC_Id Varchar(20),
    var_Voucher_Id Varchar(20),
    var_Date varchar(255),
    var_Farmer_Id varchar(20)
)
BEGIN
	if(var_Method_Name = 'Get')then 
		begin
			Declare var_BaseURL varchar(200);
            Declare var_Destination_Name varchar(20);
            
			set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_org_id);
			if (var_Destination_Name = 'PRD') then
				set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
			else 
				set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
			end if;
        
			select mu04.MCC_Farmer_Code,mu04.Farmer_Name,
			t108.Voucher_Id,t108.Invoice_No,
			-- t108.MusterCycle_StartDate,t108.MusterCycle_EndDate,
            CONCAT(
				DATE_FORMAT(t108.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t108.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
            t108.Invoice_Amount,
            ifnull(t108.Description,'') as Description,
			date_format(t108.Invoice_Date, '%d %M %Y') as Invoice_Date,
            concat('VendorInvoices/FOI', t108.Org_Id, t108.Invoice_No ,'.pdf') as Invoice_Link,
            t108.Is_Posted
			from t108_mcc_farmer_payment t108
			inner join mu04_farmer mu04 on
			mu04.Org_Id = t108.Org_Id
			and mu04.Farmer_Id = t108.Farmer_Id
			where t108.Org_Id = var_Org_Id
			and t108.MCC_Id = var_MCC_Id 
			and month(t108.Invoice_Date) = month(Var_Date) 
			and year(t108.Invoice_Date) = year(Var_Date);
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select mu04.MCC_Farmer_Code,mu04.Farmer_Name,
			t108.Voucher_Id,t108.Invoice_No,
			t108.MusterCycle_StartDate,t108.MusterCycle_EndDate,t108.Invoice_Amount,
			date_format(t108.Invoice_Date, '%d %M %Y') as Invoice_Date
			from t108_mcc_farmer_payment t108
			inner join mu04_farmer mu04 on
			mu04.Org_Id = t108.Org_Id
			and mu04.Farmer_Id = t108.Farmer_Id
			where t108.Org_Id = var_Org_Id
			and t108.MCC_Id = var_MCC_Id 
            and t108.Voucher_Id = var_Voucher_Id ;
        end;
	elseif(var_Method_Name = 'Get_Farmer')then 
		begin
			select Farmer_Id as item_Id, 
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name)as item_Value 
			from mu04_farmer
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Is_Offline = 1;
        end;
	elseif(var_Method_Name = 'Get_Payment')then 
		begin
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
        
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
        
        select @IncomeAmount as IncomeAmount , 
        @DeductionAmount as DeductionAmount, 
        @AnamatAmount as AnamatAmount, 
        @AdvanceAmount as AdvanceAmount, 
        @TotalAmount as TotalAmount,
        @IssueAmount  as IssueAmount;
			
        end;
	elseif(var_Method_Name = 'Get_PaymentView')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select 
            c011.MilkType_Name,
			c016.MilkStatus_Name,
			ifnull(t103.Quantity_Ltr,0) as Quantity,
			ifnull(t103.Fat,0) as Fat,
			ifnull(t103.SNF,0) as SNF,
			t103.ApplicableRate,
			t103.Amount,
			date_format(t103.Created_On, '%d %M %Y') as Created_On
			from t103_milkcollectionfarmer_offline t103
            inner join c011_milktype c011 on
			c011.MilkType_Id = t103.MilkType_Id
			inner join c016_milkstatus c016 on
			c016.MilkStatus_Id = t103.MilkStatus_Id
			where t103.Org_Id = var_Org_Id
			and t103.Farmer_Id = var_Farmer_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate
			and  t103.Is_InvoiceCreated = 0 
			and (t103.Invoice_Id = '' or t103.Invoice_Id IS NULL);
								

			         
			
        end;
        
	elseif(var_Method_Name = 'Get_DeductionView')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select 
            t107.Deduction_Type,
			t107.Amount,
			date_format(t107.Deduction_Date, '%d %M %Y') as Deduction_Date
			from t107_mcc_farmer_deduction t107
			where t107.Org_Id = var_Org_Id
			and t107.Farmer_Id = var_Farmer_Id
			and t107.MCC_Id = var_MCC_Id
			and CAST(t107.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t107.Deduction_Date  AS DATE)  <= var_EndDate
			and  t107.Is_InvoiceCreated = 0 
            and t107.Is_Check =1
			and (t107.Invoice_Id = '' or t107.Invoice_Id IS NULL);
								

        end;
        elseif(var_Method_Name = 'Get_AnamatView')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select 
			ifnull(m005.Quantity_Ltr,0) as Quantity,
			ifnull(m005.Anamat_PerLtr ,0)ApplicableRate,
			m005.Amount,
			date_format(m005.Created_On, '%d %M %Y') as Created_On
			from m005_mcc_offline_anamat_amount_config m005
			where m005.Org_Id = var_Org_Id
			and m005.Farmer_Id = var_Farmer_Id
			and m005.MCC_Id = var_MCC_Id
			and CAST(m005.Created_On  AS DATE) >= var_StartDate 
			and CAST(m005.Created_On  AS DATE)  <= var_EndDate
			and  m005.Is_InvoiceCreated = 0 
			and (m005.Invoice_Id = '' or m005.Invoice_Id IS NULL);
								

        end;
        elseif(var_Method_Name = 'Get_AdvanceView')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select ifnull(t033i.Deduction_Amount,0) as Amount ,
			date_format(t033i.Deduction_Date, '%d %M %Y') as Created_On
			from t033_deductions_header_offline t033
			inner join t033_deductions_item_offline t033i on
			t033.Org_Id = t033i.Org_Id
			and t033.Deductions_Id = t033i.Deductions_Id
			and CAST(t033i.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t033i.Deduction_Date  AS DATE)  <= var_EndDate
			and  t033i.Is_InvoiceCreated = 0 
			and (t033i.Invoice_Id = '' or t033i.Invoice_Id IS NULL)
			where t033.Org_Id = var_Org_Id
			and t033.Farmer_Id = var_Farmer_Id
			and t033.MCC_Id = var_MCC_Id;
											

        end;
        
		elseif(var_Method_Name = 'Get_IssueView')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select ifnull(t106i.Amount,0) as Amount ,
			date_format(t106i.Date, '%d %M %Y') as Created_On
			from t106_mcc_material_issue t106
			inner join t106_mcc_material_issue_item t106i on
			t106.Org_Id = t106i.Org_Id
			and t106.Issue_Id = t106i.Issue_Id
			and CAST(t106i.Date  AS DATE) >= var_StartDate 
			and CAST(t106i.Date  AS DATE)  <= var_EndDate
			and  t106i.Is_InvoiceCreated = 0 
			and (t106i.Invoice_Id = '' or t106i.Invoice_Id IS NULL)
			where t106.Org_Id = var_Org_Id
			and t106.Farmer_Id = var_Farmer_Id
			and t106.MCC_Id = var_MCC_Id
            and t106.Is_Paid =0;
											

        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
