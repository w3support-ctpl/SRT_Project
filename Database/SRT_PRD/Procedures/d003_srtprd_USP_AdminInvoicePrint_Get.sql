-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminInvoicePrint_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminInvoicePrint_Get`(
	var_Method_Name varchar(255),
	var_Org_Id varchar(255),
    var_Param1 varchar(50),
    var_Param2 varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get_Farmer_Invoice_List') then  
		select t027.Org_Id, t027.Voucher_Id, t027.Farmer_Id, t027.MCC_Id,  
        case 
        when (m005.MCCType_Id = 'C014003') then
			concat('Bulk Supplier Milk Procurement Bill From ', DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' to ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) 
        when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023001') then   
            concat('Society Milk Procurement Bill From ', DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' to ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) 
		when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023002' ) then
			concat('Farmer Milk Procurement Bill From ', DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' to ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) 
		else
			''
		end as InvoiceTitle,
		m005.MCC_Code as MCCCode,
		m005.MCC_Name as MCCName,
		mu05.Agent_Name as AgentName,
		mu05.Mobile_No as AgentMobileNo,
		mu04.Farmer_Code as FarmerCode,
		mu04.Farmer_Name as FarmerName,
		mu04.Mobile_No as FarmerMobileNo,
        
        case 
        when (m005.MCCType_Id = 'C014003') then
			m005.Account_No 
		when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023001') then 
			m005.Account_No 
        else
			mu04.Account_No 
        end as FarmerAccountNo,
        
        case 
        when (m005.MCCType_Id = 'C014003') then
			m015_A.Bank_Name
		when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023001') then 
			m015_A.Bank_Name
        else
			m015_F.Bank_Name
        end as FarmerBankName,
        
        case 
        when (m005.MCCType_Id = 'C014003') then
			m005.IFSC_Code
		when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023001') then 
			m005.IFSC_Code
        else
			mu04.IFSC_Code
        end as FarmerIFSCCode,
        
		Invoice_No as InvoiceNo,
		DATE_FORMAT(Invoice_Date, '%d/%m/%Y') as InvoiceDate,
		'Cow' as MilkType,
		'0.00' as TotalMilkPayment,
		'0.00' as TotalIncentive,
		'0.00' as TotalDeductions,
		'0.00' as TotalNetPayment,
        
        case 
        when (m005.MCCType_Id = 'C014003') then
			'none'
		when (m005.MCCType_Id <> 'C014003' and m005.MCCWorkType_Id = 'C023001') then 
			'none'
        else
			'block'
        end as FarmerRowDisplay
        
        from t027_invoice_farmer t027
        inner join mu04_farmer mu04 on t027.Org_Id = mu04.Org_Id and t027.Farmer_Id = mu04.Farmer_Id
        inner join m005_mcc m005 on t027.Org_Id = m005.Org_Id and t027.MCC_Id = m005.MCC_Id
        left join m015_bank m015_F on m015_F.Org_Id = t027.Org_Id and m015_F.Bank_Id = mu04.Bank_Id
        left join m015_bank m015_A on m015_A.Org_Id = t027.Org_Id and m015_A.Bank_Id = m005.Bank_Id
        left join mu05_agent mu05 on t027.Org_Id = mu05.Org_Id and mu05.Agent_Id = m005.Agent_Id
		where t027.Org_Id = var_Org_Id and Is_InvoicePDFGenerated = 1;

	elseif (var_Method_Name = 'Get_Farmer_Invoice_Data') then
		begin
			Declare var_Farmer_Id varchar(20);
            Declare var_MCC_Id varchar(20);
            Declare var_MCCType_Id varchar(20);
            Declare var_MCCWorkType_Id varchar(20);
            Declare var_InvoiceType varchar(20);
            
            DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			 Voucher_Id varchar(20));
	
            insert into temp_Voucher(Voucher_Id)
            select t2.Voucher_Id from t027_invoice_farmer t1
			inner join t027_invoice_farmer t2 on
			t1.Org_Id = t2.Org_Id
			and t1.MCC_Id = t2.MCC_Id
			and t1.Farmer_Id = t2.Farmer_Id
			and t1.MusterCycle_StartDate = t2.MusterCycle_StartDate
			and t1.MusterCycle_EndDate = t2.MusterCycle_EndDate
			where t1.Org_Id = var_Org_Id
			and t1.Voucher_Id = var_Param1
			and t1.Is_InvoicePDFGenerated >0
			and t2.Is_InvoicePDFGenerated >0;
            
            select Farmer_Id, MCC_Id into var_Farmer_Id, var_MCC_Id 
            from t027_invoice_farmer where Org_Id = var_Org_Id and Voucher_Id = var_Param1;
            
            -- Find if this is Online MCC or Offline MCC
            select MCCType_Id, MCCWorkType_Id into var_MCCType_Id, var_MCCWorkType_Id
            from m005_mcc where Org_Id = var_Org_Id and MCC_Id =var_MCC_Id;
            
            if (var_MCCType_Id = 'C014003') then	-- Bulk
				set var_InvoiceType = 'MCCWise';
			else
				if (var_MCCWorkType_Id = 'C023002') then -- Online
					set var_InvoiceType = 'FarmerWise';
				else 
					set var_InvoiceType = 'MCCWise';
				end if;
			end if;
            
            if (var_InvoiceType = 'FarmerWise') then
				select 
				DATE_FORMAT(t4.Collection_Date, '%d/%m') as CollectionDate,
				left(t4.CollectionShift_Name,1) as CollectionShift, 
				Quantity_Ltr as QtyLts, 
				case when t5.MilkStatus_Id = 'C016001' then Fat else '-' end as FAT, 
				case when t5.MilkStatus_Id = 'C016001' then SNF else '-' end as SNF, 
				case when t5.MilkStatus_Id = 'C016001' then ApplicableRate else '-' end as Rate, 
				case when t5.MilkStatus_Id = 'C016001' then Amount else '-' end as BaseAmt 
				from t005_milkcollectionfarmer t5 inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
				and t5.MCC_Id = t4.MCC_Id and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
				where t5.Org_Id = var_Org_Id and t5.Invoice_Id in (select Voucher_Id from temp_Voucher)
				order by t4.Collection_Date, t4.CollectionShift_Id;
			else
				/*
				select 
				DATE_FORMAT(f10.Collection_Date, '%d/%m') as CollectionDate,
				left( ifnull(c15.CollectionShift_Name, 'All Day'), 1) as CollectionShift, 
				Dairy_Quantity_Ltr as QtyLts, 
				Dairy_Fat as FAT, 
				Dairy_SNF as SNF, 
				MilkRate as Rate, 
				MilkPrice as BaseAmt 
				from t009_milkcollectiondairy_header t9 
				inner join f010_milkcollectionmcc_final f10 on t9.Org_Id = f10.Org_Id and t9.MilkCollectionDairy_Id = f10.MilkCollectionDairy_Id  
				inner join t027_invoice_farmer t27 on t27.Org_Id = f10.Org_Id and t27.MCC_Id = f10.MCC_Id and t27.Voucher_Id = t9.OutsideInvoice_Id 
				left join c015_collectionshift c15 on f10.CollectionShift_Id = c15.CollectionShift_Id
				where t9.Org_Id = var_Org_Id and t9.OutsideInvoice_Id = var_Param1
				order by f10.Collection_Date, f10.CollectionShift_Id; */
                
                select 
				DATE_FORMAT(f10.Collection_Date, '%d/%m') as CollectionDate,
				left( ifnull(c15.CollectionShift_Name, 'All Day'), 1) as CollectionShift, 
				Dairy_Quantity_Ltr as QtyLts, 
				Dairy_Fat as FAT, 
				Dairy_SNF as SNF, 
				MilkRate as Rate, 
				MilkPrice as BaseAmt 
				from f010_milkcollectionmcc_final f10 
				inner join t027_invoice_farmer t27 on t27.Org_Id = f10.Org_Id and t27.MCC_Id = f10.MCC_Id and t27.Voucher_Id = f10.OutsideInvoice_Id 
				left join c015_collectionshift c15 on f10.CollectionShift_Id = c15.CollectionShift_Id
				where f10.Org_Id = var_Org_Id and f10.OutsideInvoice_Id in (select Voucher_Id from temp_Voucher)
				order by f10.Collection_Date, f10.CollectionShift_Id;
                
            end if;
        end;
    elseif (var_Method_Name = 'Get_Farmer_Invoice_Summary') then
		Begin
			Declare var_TotalMilkPayment decimal(60,2) default 0;
			Declare var_TotalIncentive decimal(60,2) default 0;
            Declare var_TotalDeductions decimal(60,2) default 0;
            Declare var_TotalNetPayment decimal(60,2) default 0;
            Declare var_TotalMilkQty decimal(60,2) default 0;
            Declare var_DairyAnamat decimal(60,2) default 0;
            Declare var_MilkTransport decimal(60,2) default 0;
            Declare var_BankEMI_Amount decimal(60,2) default 0;
            Declare var_ProductSales_Amount decimal(60,2) default 0;
            Declare var_TMSales_Amount decimal(60,2) default 0;
            Declare var_MCCAdvance_Amount decimal(60,2) default 0;
            Declare var_DairyAdvance_Amount decimal(60,2) default 0;
            Declare var_DairyAnamat_OpenBal decimal(60,2) default 0;
            Declare var_DairyAnamat_OpenBal_cr decimal(60,2) default 0;
            Declare var_TDS_Amount decimal(18,2);
            
            Declare var_Farmer_Id varchar(20);
            Declare var_MCC_Id varchar(20);
            Declare var_MCCType_Id varchar(20);
            Declare var_MCCWorkType_Id varchar(20);
            Declare var_InvoiceType varchar(20);
            
            Declare var_TotalAvgFAT decimal(60,2) default 0;
            Declare var_TotalAvgSNF decimal(60,2) default 0;
            
            DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			 Voucher_Id varchar(20));
	
            insert into temp_Voucher(Voucher_Id)
            select t2.Voucher_Id from t027_invoice_farmer t1
			inner join t027_invoice_farmer t2 on
			t1.Org_Id = t2.Org_Id
			and t1.MCC_Id = t2.MCC_Id
			and t1.Farmer_Id = t2.Farmer_Id
			and t1.MusterCycle_StartDate = t2.MusterCycle_StartDate
			and t1.MusterCycle_EndDate = t2.MusterCycle_EndDate
			where t1.Org_Id = var_Org_Id
			and t1.Voucher_Id = var_Param1
			and t1.Is_InvoicePDFGenerated >0
			and t2.Is_InvoicePDFGenerated >0;
            
            select Farmer_Id, MCC_Id into var_Farmer_Id, var_MCC_Id 
            from t027_invoice_farmer where Org_Id = var_Org_Id and Voucher_Id = var_Param1;
            
            -- Find if this is Online MCC or Offline MCC
            select MCCType_Id, MCCWorkType_Id into var_MCCType_Id, var_MCCWorkType_Id
            from m005_mcc where Org_Id = var_Org_Id and MCC_Id =var_MCC_Id;
            
            if (var_MCCType_Id = 'C014003') then
				set var_InvoiceType = 'MCCWise';
			elseif (var_MCCWorkType_Id = 'C023002') then
				set var_InvoiceType = 'FarmerWise';
			else 
				set var_InvoiceType = 'MCCWise';
            end if;
            
            if (var_InvoiceType = 'FarmerWise') then
				select sum(Quantity_Ltr) , round(sum(Amount)),
                -- Roundoff('Quality', (IFNULL((SUM(Quantity_Ltr * Fat)) / SUM(Quantity_Ltr), 0)) ) AS FAT,
                -- Roundoff('Quality', (IFNULL((SUM(Quantity_Ltr * SNF)) / SUM(Quantity_Ltr), 0)) ) AS SNF
                CASE 
					WHEN SUM(Quantity_Ltr) = 0 and SUM(Quantity_Ltr * Fat) = 0 THEN 0 
					ELSE Roundoff('Quality', (IFNULL((SUM(Quantity_Ltr * Fat)) / SUM(Quantity_Ltr), 0)) )
				END AS FAT,
				CASE 
					WHEN SUM(Quantity_Ltr) = 0 and SUM(Quantity_Ltr * SNF) = 0 THEN 0 
					ELSE Roundoff('Quality', (IFNULL((SUM(Quantity_Ltr * SNF)) / SUM(Quantity_Ltr), 0)) )
				END AS SNF
				INTO var_TotalMilkQty, var_TotalMilkPayment, var_TotalAvgFAT, var_TotalAvgSNF
				from t005_milkcollectionfarmer t5 
				where t5.Org_Id = var_Org_Id and t5.Invoice_Id in (select Voucher_Id from temp_Voucher);
            else 
				/*
				select sum(Dairy_Quantity_Ltr), round(sum(MilkPrice))  
                INTO var_TotalMilkQty, var_TotalMilkPayment
				from t009_milkcollectiondairy_header t9 
				inner join f010_milkcollectionmcc_final f10 on t9.Org_Id = f10.Org_Id and t9.MilkCollectionDairy_Id = f10.MilkCollectionDairy_Id  
				inner join t027_invoice_farmer t27 on t27.Org_Id = f10.Org_Id and t27.MCC_Id = f10.MCC_Id and t27.Voucher_Id = t9.OutsideInvoice_Id 
				where t9.Org_Id = var_Org_Id and t9.OutsideInvoice_Id = var_Param1;
				*/
                select sum(Dairy_Quantity_Ltr), round(sum(MilkPrice))  ,
                Roundoff('Quality', (IFNULL((SUM(Dairy_Fat * Dairy_Quantity_Ltr)) / SUM(Dairy_Quantity_Ltr), 0)) ) AS FAT,
				Roundoff('Quality', (IFNULL((SUM(Dairy_SNF * Dairy_Quantity_Ltr)) / SUM(Dairy_Quantity_Ltr), 0)) ) AS SNF
                INTO var_TotalMilkQty, var_TotalMilkPayment, var_TotalAvgFAT, var_TotalAvgSNF
				from f010_milkcollectionmcc_final f10 
				inner join t027_invoice_farmer t27 on t27.Org_Id = f10.Org_Id and t27.MCC_Id = f10.MCC_Id and t27.Voucher_Id = f10.OutsideInvoice_Id 
				where f10.Org_Id = var_Org_Id and f10.OutsideInvoice_Id in (select Voucher_Id from temp_Voucher);
            end if;
            -- Update Deduction related things
            -- Dairy Anamat & -- Transport Deduction
            select sum(DairyAnamat_Amount), sum(Transport_Amount), sum(TDS_Amount)
            INTO var_DairyAnamat, var_MilkTransport, var_TDS_Amount
			from t027_invoice_farmer  
			where Org_Id = var_Org_Id and Voucher_Id in (select Voucher_Id from temp_Voucher);
            
            -- Get opening balance for Dairy_Anamat
            
           call USP_AdminFarmer_Anamat('GetOpeningBal', var_Org_Id, var_Param2, '', 0 , CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_DairyAnamat_OpenBal);
         
            -- Bank EMI
            select round(sum(Deduction_Amount)) into var_BankEMI_Amount 
            from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			where t033.Org_Id = var_Org_Id and Request_User_Id = var_Param2 and Deduction_Type = 'BL' and Invoice_id in (select Voucher_Id from temp_Voucher);
            
            -- Product Sales
            select round(sum(Deduction_Amount)) into var_ProductSales_Amount 
            from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			where t033.Org_Id = var_Org_Id and Request_User_Id = var_Param2 and Deduction_Type = 'PS' and Invoice_id in (select Voucher_Id from temp_Voucher);
            
            -- TM Sales
			select round(sum(Deduction_Amount)) into var_TMSales_Amount 
            from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			where t033.Org_Id = var_Org_Id and Request_User_Id = var_Param2 and Deduction_Type = 'TM' and Invoice_id in (select Voucher_Id from temp_Voucher);
            
            -- MCC Advance Deduction
            select round(sum(Deduction_Amount)) into var_MCCAdvance_Amount 
            from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			where t033.Org_Id = var_Org_Id and Request_User_Id = var_Param2 and Deduction_Type = 'MA' and Invoice_id in (select Voucher_Id from temp_Voucher);
            
         
            -- DairyAdvance Deduction
            select round(sum(Deduction_Amount)) into var_DairyAdvance_Amount 
            from t033_deductions_header t033  
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			where t033.Org_Id = var_Org_Id and Request_User_Id = var_Param2 and Deduction_Type = 'DA' and Invoice_id in (select Voucher_Id from temp_Voucher);
            
            set var_TotalIncentive = 0;
            set var_TotalDeductions = ifnull(var_DairyAnamat,0) + ifnull(var_MilkTransport,0) + ifnull(var_BankEMI_Amount, 0) +
            ifnull(var_ProductSales_Amount, 0) + ifnull(var_TMSales_Amount, 0) + ifnull(var_MCCAdvance_Amount, 0) + ifnull(var_DairyAdvance_Amount, 0);
            
            set var_TotalNetPayment = var_TotalMilkPayment + var_TotalIncentive - var_TotalDeductions;
            
            -- Update Farmer Invoice Flat table for farmer
            Delete from f012_farmer_invoice where Org_Id = var_Org_Id and Invoice_Id in (select Voucher_Id from temp_Voucher);
           
            insert into f012_farmer_invoice (Org_Id, Invoice_Id, Farmer_Id, MCC_Id, Invoice_Date,
            Invoice_No, MusterCycle_StartDate, MusterCycle_EndDate, TotalMilk_QtyLtr, MilkPayment_Amount, Created_On, 
            DairyAnamat_Amount, Transport_Amount, BankEMI_Amount, ProductSales_Amount, TMSales_Amount, MCCAdvance_Amount, 
            DairyAdvance_Amount, DairyAnamat_OpenBal, TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount,
            Avg_FAT, Avg_SNF)
            select Org_Id, Voucher_Id, Farmer_Id, MCC_Id, Invoice_Date, Invoice_No, MusterCycle_StartDate, MusterCycle_EndDate,
            var_TotalMilkQty, var_TotalMilkPayment, CONVERT_TZ(NOW(), '+00:00', '+00:00'), ifnull(var_DairyAnamat,0), 
            ifnull(var_MilkTransport,0), ifnull(var_BankEMI_Amount, 0), ifnull(var_ProductSales_Amount, 0), 
            ifnull(var_TMSales_Amount, 0), ifnull(var_MCCAdvance_Amount, 0), ifnull(var_DairyAdvance_Amount, 0),
            ifnull(var_DairyAnamat_OpenBal,0), ifnull(var_TotalDeductions, 0), ifnull(var_TotalIncentive, 0),
            ifnull(var_TotalNetPayment, 0), ifnull(-1 * var_TDS_Amount, 0), ifnull(var_TotalAvgFAT,0), ifnull(var_TotalAvgSNF,0)
            from t027_invoice_farmer t027
            where Org_Id = var_Org_Id and Voucher_Id = var_Param1;
			
            -- Update DairyAnamat Amount
          call USP_AdminFarmer_Anamat('Create', var_Org_Id, var_Param2, 'cr', var_DairyAnamat, CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_DairyAnamat_OpenBal_cr);
           -- select 	1;
            -- set var_TotalNetPayment = ifnull(var_TotalDeductions,0)  + ifnull(-1 * var_TDS_Amount, 0);
            
            -- Return Output
            select var_TotalMilkQty as TotalMilkQty, var_TotalMilkPayment as TotalMilkPayment, var_TotalIncentive as TotalIncentive, 
            -- var_TotalDeductions as TotalDeductions,
            ifnull(var_TotalDeductions,0) + ifnull(-1 * var_TDS_Amount, 0) as TotalDeductions,
            -- var_TotalNetPayment as TotalNetPayment, 
            ifnull(var_TotalNetPayment,0) - ifnull(-1 * var_TDS_Amount, 0) as TotalNetPayment,
            var_BankEMI_Amount as BankEMI_Amount, var_DairyAnamat as DairyAnamat_Amount, var_MilkTransport as Transport_Amount,
            var_BankEMI_Amount as BankEMI_Amount, var_ProductSales_Amount as ProductSales_Amount, var_TMSales_Amount as TMSales_Amount,
            var_MCCAdvance_Amount as MCCAdvance_Amount, var_DairyAdvance_Amount as DairyAdvance_Amount, var_DairyAnamat_OpenBal as DairyAnamat_OpenBal ,
            ifnull(-1 * var_TDS_Amount, 0) as TotalTDS;
            
        
        end;
	elseif (var_Method_Name = 'Set_Farmer_Invoice_Status') then  
		Begin
			declare var_Invoice_No varchar(50);
			DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			 Voucher_Id varchar(20));
	
            insert into temp_Voucher(Voucher_Id)
            select t2.Voucher_Id from t027_invoice_farmer t1
			inner join t027_invoice_farmer t2 on
			t1.Org_Id = t2.Org_Id
			and t1.MCC_Id = t2.MCC_Id
			and t1.Farmer_Id = t2.Farmer_Id
			and t1.MusterCycle_StartDate = t2.MusterCycle_StartDate
			and t1.MusterCycle_EndDate = t2.MusterCycle_EndDate
			where t1.Org_Id = var_Org_Id
			and t1.Voucher_Id = var_Param1
			and t1.Is_InvoicePDFGenerated >0
			and t2.Is_InvoicePDFGenerated >0;
            
           set var_Invoice_No =  (select Invoice_No from t027_invoice_farmer  
								   where Org_Id = var_Org_Id 
								   and Voucher_Id = var_Param1 limit 1);
            
			update t027_invoice_farmer
            set Is_InvoicePDFGenerated = 2,
            Invoice_No = var_Invoice_No
            where Org_Id = var_Org_Id and Voucher_Id  in (select Voucher_Id from temp_Voucher) 
            and Farmer_Id = var_Param2;
            
            
            
		end;
	elseif (var_Method_Name = 'Get_MCC_Invoice_List') then  
		select t028.Org_Id, t028.Voucher_Id, t028.MCC_Id,  
		concat('MPP Incentive Bill From ', DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' to ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) as InvoiceTitle,
		m005.MCC_Code as MCCCode,
		m005.MCC_Name as MCCName,
		mu05.Agent_Name as AgentName,
		mu05.Mobile_No as AgentMobileNo,
        m005.Account_No  as MCCAccountNo,
        m015_A.Bank_Name as MCCBankName,
        m005.IFSC_Code as MCCIFSCCode,
		Invoice_No as InvoiceNo,
		DATE_FORMAT(Invoice_Date, '%d/%m/%Y') as InvoiceDate

        from t028_invoice_mcc t028
        inner join m005_mcc m005 on t028.Org_Id = m005.Org_Id and t028.MCC_Id = m005.MCC_Id
        left join m015_bank m015_A on m015_A.Org_Id = t028.Org_Id and m015_A.Bank_Id = m005.Bank_Id
        left join mu05_agent mu05 on t028.Org_Id = mu05.Org_Id and mu05.Agent_Id = m005.Agent_Id
		where t028.Org_Id = var_Org_Id and Is_InvoicePDFGenerated = 1 
        and Voucher_Id = Primary_Voucher_Id;
        
	elseif (var_Method_Name = 'Get_MCC_Invoice_Summary') then
		Begin
			Declare var_TotalMPPIPayment decimal(60,2) default 0;
            Declare var_OtherIncentive decimal(60,2) default 0;
			Declare var_TotalIncentive decimal(60,2) default 0;
            Declare var_TotalDeductions decimal(60,2) default 0;
            Declare var_TotalNetPayment decimal(60,2) default 0;
            Declare var_TotalMilkQty decimal(60,2) default 0;
            Declare var_MCCAdvance_Amount_From_Farmer decimal(60,2) default 0;
            -- Declare var_DairyAnamat decimal(30,2);
            Declare var_BankEMI_Amount decimal(60,2) default 0;
            Declare var_ProductSales_Amount decimal(60,2) default 0;
            Declare var_TMSales_Amount decimal(60,2) default 0;
            Declare var_DairyAdvance_Amount decimal(60,2) default 0;
            Declare var_GainLoss_Amount decimal(60,2) default 0;
            
            Declare var_MusterCycle_StartDate varchar(20);
            Declare var_MusterCycle_EndDate varchar(20);
            
            Declare var_TDS_Amount decimal(60,2) default 0;
            Declare var_DairyAnamat decimal(60,2) default 0;
            Declare var_MilkTransport decimal(60,2) default 0;
            
            Declare var_Protein_Amount decimal(60,2) default 0;
            Declare var_Ash_Amount decimal(60,2) default 0;
            Declare var_Sodium_Amount decimal(60,2) default 0;
            Declare var_Incentive_Amount decimal(60,2) default 0;
            
            SET SQL_SAFE_UPDATES = 0;

            set @C_Invoice_Date = (select Invoice_Date from t028_invoice_mcc
					where Org_Id = var_Org_Id
					and MCC_Id = var_Param2
					and Voucher_Id = var_Param1
					order by Created_On asc limit 1); 


			update t028_invoice_mcc 
			set Primary_Voucher_Id = var_Param1
			where Org_Id = var_Org_Id
			and MCC_Id = var_Param2
			and date(Invoice_Date) = date(@C_Invoice_Date)
			and Primary_Voucher_Id <> var_Param1;
            
            
            Delete from f013_mcc_invoice where Org_Id = var_Org_Id 
            and MCC_Id = var_Param2
			and date(Invoice_Date) = date(@C_Invoice_Date);
                
            DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			Voucher_Id varchar(20));
	   
            insert into temp_Voucher(Voucher_Id)
            select t2.Voucher_Id from t028_invoice_mcc t1
			inner join t028_invoice_mcc t2 on
			t1.Org_Id = t2.Org_Id
			and t1.MCC_Id = t2.MCC_Id
			and t1.MusterCycle_StartDate = t2.MusterCycle_StartDate
			and t1.MusterCycle_EndDate = t2.MusterCycle_EndDate
			where t1.Org_Id = var_Org_Id
			and t1.Voucher_Id = var_Param1
			and t1.Is_InvoicePDFGenerated >0
			and t2.Is_InvoicePDFGenerated >0;
            
           
            
            -- Muster Start and End Date
            select MusterCycle_StartDate, MusterCycle_EndDate
            into var_MusterCycle_StartDate, var_MusterCycle_EndDate
            from t028_invoice_mcc t028
            where t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Voucher_Id = var_Param1;
            
            -- Total Milk Quantity
            select ifnull(sum(Liters),0) INTO var_TotalMilkQty 
            from t028_invoice_mcc t028 
			inner join t009_milkcollectiondairy_mcccommission t009 on t028.Org_Id = t009.Org_Id and t028.MCC_Id = t009.MCC_Id and t028.Voucher_Id = t009.Invoice_Id
			where t028.Org_Id = var_Org_Id 
            and t028.mcc_id = var_Param2 
            and t009.MPPIType_Id = 'C047001'
            and t028.Voucher_Id in (select Voucher_Id from temp_Voucher);
             
             
            -- Total MPPI Amount
            -- select  
            -- ifnull(sum(Invoice_Amount),0)
            -- INTO var_TotalMPPIPayment 
            -- from t028_invoice_mcc t028 
			-- where t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Voucher_Id in (select Voucher_Id from temp_Voucher);
            
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_TotalMPPIPayment 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047001';
            
			set var_OtherIncentive = 0;
            
            -- Find MPPI Advance paid by farmers to this MCC in the current muster cycle
            set var_MCCAdvance_Amount_From_Farmer = 0;
            
            select sum(ifnull(MCCAdvance_Amount,0))
            into var_MCCAdvance_Amount_From_Farmer
            from f012_farmer_invoice f12 
            where f12.Org_Id = var_Org_Id and f12.mcc_id = var_Param2
            and date(f12.Invoice_Date) >= date(var_MusterCycle_StartDate) and date(f12.Invoice_Date) <= date(var_MusterCycle_EndDate) ;
            
            -- set var_DairyAnamat = 0;
            
            -- Update Deduction related things
            -- Dairy Anamat & -- Transport Deduction
            select sum(DairyAnamat_Amount), sum(Transport_Amount), sum(TDS_Amount)
            INTO var_DairyAnamat, var_MilkTransport, var_TDS_Amount
			from t028_invoice_mcc  
			where Org_Id = var_Org_Id and Voucher_Id in (select Voucher_Id from temp_Voucher);
            
            
            -- Bank EMI
            select round(sum(Deduction_Amount)) into var_BankEMI_Amount 
			from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			inner join t028_invoice_mcc t028 on t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Primary_Voucher_Id in (select Voucher_Id from temp_Voucher) 
            and (t028.MPPIType_Id  is null or t028.MPPIType_Id  = '')
			where t033.Org_Id = var_Org_Id and Deduction_Type = 'BL'
            and t028.Voucher_Id = t033i.Invoice_Id;

            -- Product Sales
            select round(sum(Deduction_Amount)) into var_ProductSales_Amount 
			from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			inner join t028_invoice_mcc t028 on t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Primary_Voucher_Id in (select Voucher_Id from temp_Voucher) 
            and (t028.MPPIType_Id  is null or t028.MPPIType_Id  = '')
			where t033.Org_Id = var_Org_Id and Deduction_Type = 'PS'
            and t028.Voucher_Id = t033i.Invoice_Id;
            
            -- TM Sales
            select round(sum(Deduction_Amount)) into var_TMSales_Amount 
			from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			inner join t028_invoice_mcc t028 on t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Primary_Voucher_Id in (select Voucher_Id from temp_Voucher) 
            and (t028.MPPIType_Id  is null or t028.MPPIType_Id  = '')
			where t033.Org_Id = var_Org_Id and Deduction_Type = 'TM'
            and t028.Voucher_Id = t033i.Invoice_Id;
            
            -- DairyAdvance Deduction
            select round(sum(Deduction_Amount)) into var_DairyAdvance_Amount 
			from t033_deductions_header t033 
			inner join m020_deductions_head m020 on t033.Org_Id = m020.Org_Id and t033.Request_Type = m020.DeductionHead_Id
			inner join t033_deductions_item t033i on t033.Org_Id = t033i.Org_Id and t033.Deductions_Id = t033i.Deductions_Id
			inner join t028_invoice_mcc t028 on t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Primary_Voucher_Id in (select Voucher_Id from temp_Voucher) 
            and (t028.MPPIType_Id  is null or t028.MPPIType_Id  = '')
			where t033.Org_Id = var_Org_Id and Deduction_Type = 'DA'
            and t028.Voucher_Id = t033i.Invoice_Id;
        
            -- Gain Loss Deduction
            set var_GainLoss_Amount = 0;
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_GainLoss_Amount 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047003';
            
            
            -- If GainLoss Recovery is POSITIVE i.e. there is Gain then add it in Other incentive
            if(ifnull(var_GainLoss_Amount,'') <> '')then
				if (var_GainLoss_Amount > 0) then
					set var_OtherIncentive = abs(var_GainLoss_Amount);
					set var_GainLoss_Amount = 0;
					
				else
					set var_GainLoss_Amount = abs(var_GainLoss_Amount);
				End if;
			else
				set var_GainLoss_Amount = 0;
                set var_OtherIncentive = 0;
			end if;
            
            -- Protein Deduction
            set var_Protein_Amount = 0;
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_Protein_Amount 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047006';
            
            -- If GainLoss Recovery is POSITIVE i.e. there is Gain then add it in Other incentive
            if(ifnull(var_Protein_Amount,'') <> '')then
				if (var_Protein_Amount > 0) then
					set var_Protein_Amount = abs(var_Protein_Amount);
					-- set var_Protein_Amount = 0;
				else
					set var_Protein_Amount = abs(var_Protein_Amount);
				End if;
			else
				set var_Protein_Amount = 0;
            end if;

            -- Ash Deduction
            set var_Ash_Amount = 0;
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_Ash_Amount 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047007';
            
            -- If GainLoss Recovery is POSITIVE i.e. there is Gain then add it in Other incentive
            if(ifnull(var_Ash_Amount,'') <> '')then
				if (var_Ash_Amount > 0) then
					set var_Ash_Amount = abs(var_Ash_Amount);
					-- set var_Ash_Amount = 0;
				else
					set var_Ash_Amount = abs(var_Ash_Amount);
				End if;
			else
				set var_Ash_Amount = 0;
            end if;

            -- Sodium Deduction
            set var_Sodium_Amount = 0;
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_Sodium_Amount 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047008';
            
            -- If GainLoss Recovery is POSITIVE i.e. there is Gain then add it in Other incentive
            if(ifnull(var_Sodium_Amount,'') <> '')then 
				if (var_Sodium_Amount > 0) then
					set var_Sodium_Amount = abs(var_Sodium_Amount);
					-- set var_Sodium_Amount = 0;
				else
					set var_Sodium_Amount = abs(var_Sodium_Amount);
				End if;
            else
				set var_Sodium_Amount = 0;
            end if;

            -- Incentive Deduction
            set var_Incentive_Amount = 0;
            select  
            round(sum(ifnull(Amount,0)))
            INTO var_Incentive_Amount 
            from t009_milkcollectiondairy_mcccommission t9
			where t9.Org_Id = var_Org_Id and t9.mcc_id = var_Param2 and t9.Invoice_id in (select Voucher_Id from temp_Voucher) 
            and MPPIType_Id = 'C047009';
            
            -- If GainLoss Recovery is POSITIVE i.e. there is Gain then add it in Other incentive
            if(ifnull(var_Incentive_Amount,'') <> '')then
				if (var_Incentive_Amount > 0) then
					set var_Incentive_Amount = abs(var_Incentive_Amount);
					-- set var_Incentive_Amount = 0;
				else
					set var_Incentive_Amount = abs(var_Incentive_Amount);
				End if;
            else
				set var_Incentive_Amount = 0;
            end if;
            
			
			set var_OtherIncentive = ifnull(abs(var_OtherIncentive),0) + var_Incentive_Amount;
            
            
            set var_TotalIncentive = ifnull(var_TotalMPPIPayment,0) + ifnull(var_OtherIncentive,0) + ifnull(var_MCCAdvance_Amount_From_Farmer,0);
            set var_TotalDeductions = ifnull(var_DairyAnamat,0) + ifnull(var_MilkTransport,0)  + ifnull(var_BankEMI_Amount, 0) +
            ifnull(var_ProductSales_Amount, 0) + ifnull(var_TMSales_Amount, 0) + ifnull(var_DairyAdvance_Amount, 0) + ifnull(var_GainLoss_Amount,0) +
            ifnull(var_Protein_Amount,0) + ifnull(var_Ash_Amount,0) + ifnull(var_Sodium_Amount,0);
            
            set var_TotalNetPayment = var_TotalIncentive - var_TotalDeductions;
            
            
            -- Update MCC Invoice Flat table for MCC
            Delete from f013_mcc_invoice where Org_Id = var_Org_Id and Invoice_Id = var_Param1;
            
            insert into f013_mcc_invoice (Org_Id, Invoice_Id, MCC_Id, Invoice_Date,
            Invoice_No, MusterCycle_StartDate, MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, 
            MCCAdvance_Amount, OtherIncentive_Amount, DairyAnamat_Amount,Transport_Amount, BankEMI_Amount, ProductSales_Amount, TMSales_Amount, 
            DairyAdvance_Amount, GainLoss_Amount, PMRecovery_Amount, TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, Created_On,TDS_Amount,
            Protein_Amount,Ash_Amount,Sodium_Amount,Incentive_Amount)
            
            select Org_Id, Voucher_Id, MCC_Id, Invoice_Date, Invoice_No, MusterCycle_StartDate, MusterCycle_EndDate,
            ifnull(var_TotalMilkQty,0) as TotalMilkQty, ifnull(var_TotalMPPIPayment, 0) as TotalMPPIPayment, 
            ifnull(var_MCCAdvance_Amount_From_Farmer, 0) as MCCAdvance_Amount_From_Farmer, 
            ifnull(var_OtherIncentive, 0) as OtherIncentive, ifnull(var_DairyAnamat, 0) as DairyAnamat,
            ifnull(var_MilkTransport,0) as Transport_Amount,
            ifnull(var_BankEMI_Amount, 0) as BankEMI_Amount,
            ifnull(var_ProductSales_Amount,0) as ProductSales_Amount, ifnull(var_TMSales_Amount, 0) as TMSales_Amount, ifnull(var_DairyAdvance_Amount, 0) as DairyAdvance_Amount,
            ifnull(var_GainLoss_Amount, 0) as GainLoss_Amount, 0 as PMRecovery_Amount, ifnull(var_TotalDeductions,0) as TotalDeductions, ifnull(var_TotalIncentive, 0) as TotalIncentive, 
            ifnull(var_TotalNetPayment,0) as TotalNetPayment, CONVERT_TZ(NOW(), '+00:00', '+00:00'),
            ifnull(-1 * var_TDS_Amount, 0),
            ifnull(var_Protein_Amount, 0),ifnull(var_Ash_Amount, 0),ifnull(var_Sodium_Amount, 0),ifnull(var_Incentive_Amount, 0)
            from t028_invoice_mcc t028
            where t028.Org_Id = var_Org_Id and t028.mcc_id = var_Param2 and t028.Voucher_Id = var_Param1;
            
            -- set var_TotalNetPayment = ifnull(var_TotalDeductions,0) + ifnull(-1 * var_TDS_Amount, 0) ;
            
            set var_TotalNetPayment = ifnull(var_TotalNetPayment,0) - ifnull(-1 * var_TDS_Amount, 0);
            
            select 
            ifnull(var_TotalMilkQty,0) as TotalMilkQty, ifnull(var_TotalMPPIPayment, 0) as TotalMPPIPayment, 
            ifnull(var_MCCAdvance_Amount_From_Farmer, 0) as MCCAdvance_Amount_From_Farmer, 
            ifnull(var_OtherIncentive, 0) as OtherIncentive, 
            ifnull(var_DairyAnamat, 0) as DairyAnamat, 
            ifnull(var_MilkTransport,0) as Transport_Amount,
            ifnull(var_BankEMI_Amount, 0) as BankEMI_Amount,
            ifnull(-1 * var_TDS_Amount, 0) as TotalTDS,
            ifnull(var_ProductSales_Amount,0) as ProductSales_Amount, ifnull(var_TMSales_Amount, 0) as TMSales_Amount, ifnull(var_DairyAdvance_Amount, 0) as DairyAdvance_Amount,
            ifnull(var_GainLoss_Amount, 0) as GainLoss_Amount, 0 as PMRecovery_Amount, 
            -- ifnull(var_TotalDeductions,0) as TotalDeductions,
            ifnull(var_TotalDeductions,0) + ifnull(-1 * var_TDS_Amount, 0) as TotalDeductions,
            ifnull(var_TotalIncentive, 0) as TotalIncentive, 
            -- ifnull(var_TotalNetPayment,0) as TotalNetPayment, 
            ifnull(var_TotalNetPayment,0) as TotalNetPayment,
            ifnull(var_Protein_Amount,0) as TotalProtein,
			ifnull(var_Ash_Amount,0) as TotalAsh,
			ifnull(var_Sodium_Amount,0) as TotalSodium,
			-- ifnull(var_Incentive_Amount,0) as TotalIncentives,
            case when var_TotalNetPayment < 0 then concat('Negative ', NumberInWords(abs(var_TotalNetPayment)))
            else NumberInWords(abs(var_TotalNetPayment))
			end as TotalNetPaymentInWord ;
        End;
	elseif (var_Method_Name = 'Set_MCC_Invoice_Status') then  
		Begin
			update t028_invoice_mcc
            set Is_InvoicePDFGenerated = 2
            where Org_Id = var_Org_Id and Voucher_Id = var_Param1 and MCC_Id = var_Param2 and Voucher_Id = Primary_Voucher_Id;
            
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
