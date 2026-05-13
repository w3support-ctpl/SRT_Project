-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSAPPostingDebit_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSAPPostingDebit_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Invoice_Id varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get_Income_Header') then
		begin
			DECLARE Total_Ltr decimal(30,3);
			DECLARE GrossAmount decimal(30,2);
			DECLARE PurchaseAmount decimal(30,2);
			DECLARE AnamatAmount decimal(30,2);
			DECLARE FreightAmount decimal(30,2);
			DECLARE TotalAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentType varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Gross varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);

			SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
		
			SELECT mu04.Farmer_Code into Creditor_Debtor FROM t046_debitsapposting t046
			inner join  mu04_farmer mu04 on mu04.Org_Id = t046.Org_Id 
			and mu04.Farmer_Id = t046.Farmer_Id 
			where t046.Org_Id = var_Org_Id 
			and t046.Voucher_Id = var_Invoice_Id;
				
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
                
                
            SELECT 
				CONCAT(DATE_FORMAT(t046.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t046.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t046.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t046_debitsapposting t046
			WHERE 
				t046.Org_Id = var_Org_Id
				AND t046.Voucher_Id = var_Invoice_Id
			GROUP BY
				t046.MusterCycle_StartDate,t046.MusterCycle_EndDate;
            
			
			-- GrossAmount
			
			set GrossAmount = ( select Invoice_Amount from  t046_debitsapposting WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);
				
				SELECT 
				Current_Year as FiscalYear,
				CompanyCode as CompanyCode,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t046.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as DocumentDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t046.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as PostingDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as CreationDate,
				'123T' as SupplierInvoiceIDByInvcgParty,
				Creditor_Debtor as InvoicingParty,
				'INR' as DocumentCurrency,
				round(abs(GrossAmount)) as InvoiceGrossAmount,
				'SV00' as PaymentTerms,
				AccountingDocumentType as AccountingDocumentType,
				'5' as SupplierInvoiceStatus,
				true as TaxIsCalculatedAutomatically,
				'IN27' as BusinessPlace,
				'1829'as BusinessSectionCode,
				false as SuplrInvcIsCapitalGoodsRelated,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t046.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxDeterminationDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t046.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxReportingDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t046.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxFulfillmentDate,
				false as IsEUTriangularDeal,
				false as IsReversal,
				false as IsReversed,
                concat('Dedit Note Ex.Py.from ',MusterCycle) as SupplierPostingLineItemText,
                CASE
					WHEN ROUND(GrossAmount) < 0 THEN 'X' -- If TotalAmount is negative, set DebitCreditCode to 'H'
					WHEN ROUND(GrossAmount) > 0 THEN '' -- If TotalAmount is positive, set DebitCreditCode to 'S'
				ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as SupplierInvoiceIsCreditMemo
                -- 'X' as SupplierInvoiceIsCreditMemo
				FROM t046_debitsapposting t046
				where
				t046.Org_Id = var_Org_Id
				AND t046.Voucher_Id = var_Invoice_Id;
                
        end;
    
    elseif (var_Method_Name = 'Get_SupplierInvoiceItemGLAcct') then
		begin
			DECLARE Total_Ltr decimal(30,3);
			DECLARE GrossAmount decimal(30,2);
			DECLARE PurchaseAmount decimal(30,2);
			DECLARE AnamatAmount decimal(30,2);
			DECLARE FreightAmount decimal(30,2);
			DECLARE TotalAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentType varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Gross varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            
           
			SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
		
		
			SELECT mu04.Farmer_Code into Creditor_Debtor FROM t046_debitsapposting t046
			inner join  mu04_farmer mu04 on mu04.Org_Id = t046.Org_Id 
			and mu04.Farmer_Id = t046.Farmer_Id 
			where t046.Org_Id = var_Org_Id 
			and t046.Voucher_Id = var_Invoice_Id;
				
		
			SELECT
				CASE
					WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
					ELSE YEAR(CURDATE()) - 1
				END into Current_Year;

			
			SELECT 
				CONCAT(DATE_FORMAT(t046.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t046.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t046.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t046_debitsapposting t046
			WHERE 
				t046.Org_Id = var_Org_Id
				AND t046.Voucher_Id = var_Invoice_Id
			GROUP BY
				t046.MusterCycle_StartDate,t046.MusterCycle_EndDate;
			
		
			
				
	
			set GrossAmount = ( select Invoice_Amount from  t046_debitsapposting WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);
				
				select 
				Current_Year as FiscalYear,
				'1' as SupplierInvoiceItem,
				CompanyCode as CompanyCode,
				'' as CostCenter ,
				'1100' as ProfitCenter,
				GLAccount_Gross as GLAccount,
				'INR' as DocumentCurrency,
				round(abs(GrossAmount)) as SupplierInvoiceItemAmount,
				'0C' as TaxCode,
                CASE
					WHEN ROUND(GrossAmount) < 0 THEN 'H' -- If TotalAmount is negative, set DebitCreditCode to 'H'
					WHEN ROUND(GrossAmount) > 0 THEN 'S' -- If TotalAmount is positive, set DebitCreditCode to 'S'
					ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as DebitCreditCode,
				-- 'H' as DebitCreditCode,
				false as IsNotCashDiscountLiable,
				'0.00' as TaxBaseAmountInTransCrcy,
                concat('Dedit Note Ex.Py.from ',MusterCycle) as SupplierInvoiceItemText
				FROM t046_debitsapposting t046
				where
				t046.Org_Id = var_Org_Id
				AND t046.Voucher_Id = var_Invoice_Id;
            
        end;
	elseif (var_Method_Name = 'Get_SupplierInvoiceWhldgTax') then
		begin
			DECLARE GrossAmount decimal(30,2);
			DECLARE Total_Ltr decimal(30,3);

			-- GrossAmount
			set GrossAmount = ( select Invoice_Amount from  t046_debitsapposting WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);

			select 
			'4Q' as WithholdingTaxType,
			'INR' as DocumentCurrency,
			'4Q' as WithholdingTaxCode,
			round(abs(GrossAmount)) as WithholdingTaxBaseAmount
			from t046_debitsapposting t046
			where
			t046.Org_Id = var_Org_Id
			AND t046.Voucher_Id = var_Invoice_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
