-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSAPPosting_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSAPPosting_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_Invoice_Id varchar(20),
    var_MCC_Id varchar(20),
    var_MCCType_Id varchar(20)
)
BEGIN
SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then  
		begin
			select 
			t045.Voucher_Id as Invoice_Id,t045.Invoice_No,
			DATE_FORMAT(t045.Invoice_Date, '%d %b %Y') AS Invoice_Date,
			mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
			m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
			ifnull(t045.SAP_Document_Id,'')  as Income_Document,
			CONCAT(
			DATE_FORMAT(t045.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t045.MusterCycle_EndDate, '%d')
			) AS MusterCycle,
			t045.Invoice_Amount as Amount,
			t045.Is_Posted as Is_Posted,
			t045.Is_Posted as Is_IncomePosted,
            ifnull(Remark,'') as Remark
			from t045_sapposting t045
			Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t045.Farmer_Id 
			and  mu04.Org_Id = t045.Org_Id
			Inner Join m005_mcc m005 on m005.MCC_Id = t045.MCC_Id
			and  m005.Org_Id = t045.Org_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCC_Id like var_MCC_Id
			where  t045.Org_Id = var_Org_Id
			and t045.Invoice_Date = var_Date
            
            union all
            
            select 
			t045.Voucher_Id as Invoice_Id,t045.Invoice_No,
			DATE_FORMAT(t045.Invoice_Date, '%d %b %Y') AS Invoice_Date,
			m005.MCC_Id as Farmer_Id,m005.MCC_Name as Farmer_Name,m005.MCC_Code as Farmer_Code,
			m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
			ifnull(t045.SAP_Document_Id,'')  as Income_Document,
			CONCAT(
			DATE_FORMAT(t045.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t045.MusterCycle_EndDate, '%d')
			) AS MusterCycle,
			t045.Invoice_Amount as Amount,
			t045.Is_Posted as Is_Posted,
			t045.Is_Posted as Is_IncomePosted,
            ifnull(Remark,'') as Remark
			from t045_sapposting t045
			Inner Join m005_mcc m005 on m005.MCC_Id = t045.MCC_Id
			and  m005.Org_Id = t045.Org_Id
            and m005.MCC_Id = t045.Farmer_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCC_Id like var_MCC_Id
			where  t045.Org_Id = var_Org_Id
			and t045.Invoice_Date = var_Date;
            
		end;
	elseif (var_Method_Name = 'GetIncomeError') then
		begin
		DECLARE Creditor_Debtor varchar(50);
        
		set @IncomeFor = (select IncomeFor from t045_sapposting t045
							where t045.Org_Id = var_Org_Id 
							and t045.Voucher_Id = var_Invoice_Id limit 1);
	
		if(@IncomeFor = 'MCC')then
        
			SELECT m005.MCC_Code  into Creditor_Debtor   FROM t045_sapposting t045
			inner join  m005_mcc m005 on t045.Org_Id = m005.Org_Id 
			and m005.MCC_Id = t045.MCC_Id 
			where t045.Org_Id = var_Org_Id 
			and t045.Voucher_Id = var_Invoice_Id
            and t045.IncomeFor = 'MCC';
            
        elseif(@IncomeFor = 'Farmer')then
        
			SELECT mu04.Farmer_Code into Creditor_Debtor FROM t045_sapposting t045
			inner join  mu04_farmer mu04 on mu04.Org_Id = t045.Org_Id 
			and mu04.Farmer_Id = t045.Farmer_Id 
			where t045.Org_Id = var_Org_Id 
			and t045.Voucher_Id = var_Invoice_Id
            and t045.IncomeFor = 'Farmer';
            
        end if;
        
		
        
        SELECT
        Request_Body,
		Response_Body
        FROM l002_sapapilog 
		WHERE Response_Code = '500'
		AND Transaction_Name ='SOAP'
        and Org_Id = var_Org_Id
		AND Request_Body LIKE CONCAT('%\"InvoicingParty\":\"', Creditor_Debtor,'\"%')
		order by Entry_Date desc limit 1;
        
        end;
	
elseif (var_Method_Name = 'Get_Income_Header') then
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


			set @IncomeFor = (select IncomeFor from t045_sapposting t045
							where t045.Org_Id = var_Org_Id 
							and t045.Voucher_Id = var_Invoice_Id limit 1);
	
			if(@IncomeFor = 'MCC')then

				SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
			
			
				SELECT m005.MCC_Code into Creditor_Debtor FROM t045_sapposting t045
				inner join  m005_mcc m005 on t045.Org_Id = m005.Org_Id 
				and m005.MCC_Id = t045.MCC_Id 
				where t045.Org_Id = var_Org_Id 
				and t045.Voucher_Id = var_Invoice_Id
				and t045.IncomeFor = 'MCC';
				
			elseif(@IncomeFor = 'Farmer')then


				SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			
			
				SELECT mu04.Farmer_Code into Creditor_Debtor FROM t045_sapposting t045
				inner join  mu04_farmer mu04 on mu04.Org_Id = t045.Org_Id 
				and mu04.Farmer_Id = t045.Farmer_Id 
				where t045.Org_Id = var_Org_Id 
				and t045.Voucher_Id = var_Invoice_Id
				and t045.IncomeFor = 'Farmer';
				
			end if;
		
			
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
                
                
			
            
            SELECT 
				CONCAT(DATE_FORMAT(t045.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t045.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t045.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t045_sapposting t045
			WHERE 
				t045.Org_Id = var_Org_Id
				AND t045.Voucher_Id = var_Invoice_Id
			GROUP BY
				t045.MusterCycle_StartDate,t045.MusterCycle_EndDate;
            
			
			-- GrossAmount
			
			set GrossAmount = ( select Invoice_Amount from  t045_sapposting WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);
				
				SELECT 
				Current_Year as FiscalYear,
				CompanyCode as CompanyCode,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t045.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as DocumentDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t045.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as PostingDate,
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
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t045.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxDeterminationDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t045.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxReportingDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t045.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxFulfillmentDate,
				false as IsEUTriangularDeal,
				false as IsReversal,
				false as IsReversed,
                /*
				CASE
					WHEN IncomeFor = 'Farmer' THEN concat('Milk Invoice from ',MusterCycle)
					WHEN IncomeFor =  'MCC' THEN concat('Milk Commission from ',MusterCycle)
					ELSE '' 
				END 
                */
                t045.Remark as SupplierPostingLineItemText,
                CASE
				WHEN ROUND(GrossAmount) < 0 THEN 'X' -- If TotalAmount is negative, set DebitCreditCode to 'H'
				WHEN ROUND(GrossAmount) > 0 THEN '' -- If TotalAmount is positive, set DebitCreditCode to 'S'
				ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as SupplierInvoiceIsCreditMemo
				FROM t045_sapposting t045
				where
				t045.Org_Id = var_Org_Id
				AND t045.Voucher_Id = var_Invoice_Id;
                
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
            
            set @IncomeFor = (select IncomeFor from t045_sapposting t045
							where t045.Org_Id = var_Org_Id 
							and t045.Voucher_Id = var_Invoice_Id limit 1);
	
			if(@IncomeFor = 'MCC')then

				SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
			
			
				SELECT m005.MCC_Code into Creditor_Debtor FROM t045_sapposting t045
				inner join  m005_mcc m005 on t045.Org_Id = m005.Org_Id 
				and m005.MCC_Id = t045.MCC_Id 
				where t045.Org_Id = var_Org_Id 
				and t045.Voucher_Id = var_Invoice_Id
				and t045.IncomeFor = 'MCC';
				
			elseif(@IncomeFor = 'Farmer')then


				SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			
			
				SELECT mu04.Farmer_Code into Creditor_Debtor FROM t045_sapposting t045
				inner join  mu04_farmer mu04 on mu04.Org_Id = t045.Org_Id 
				and mu04.Farmer_Id = t045.Farmer_Id 
				where t045.Org_Id = var_Org_Id 
				and t045.Voucher_Id = var_Invoice_Id
				and t045.IncomeFor = 'Farmer';
				
			end if;

			SELECT
				CASE
					WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
					ELSE YEAR(CURDATE()) - 1
				END into Current_Year;

			
                        SELECT 
				CONCAT(DATE_FORMAT(t045.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t045.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t045.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t045_sapposting t045
			WHERE 
				t045.Org_Id = var_Org_Id
				AND t045.Voucher_Id = var_Invoice_Id
			GROUP BY
				t045.MusterCycle_StartDate,t045.MusterCycle_EndDate;
			
		
			
				
	
			set GrossAmount = ( select Invoice_Amount from  t045_sapposting WHERE 
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
				false as IsNotCashDiscountLiable,
				'0.00' as TaxBaseAmountInTransCrcy,
                /*
                CASE
					WHEN IncomeFor = 'Farmer' THEN concat('Milk Invoice from ',MusterCycle)
					WHEN IncomeFor =  'MCC' THEN concat('Milk Commission from ',MusterCycle)
					ELSE '' 
				END
                */
                t045.Remark as SupplierInvoiceItemText
				FROM t045_sapposting t045
				where
				t045.Org_Id = var_Org_Id
				AND t045.Voucher_Id = var_Invoice_Id;
            
        end;
	elseif (var_Method_Name = 'Get_SupplierInvoiceWhldgTax') then
		begin
		DECLARE GrossAmount decimal(30,2);
        DECLARE Total_Ltr decimal(30,3);
		
			-- GrossAmount
				set GrossAmount = ( select Invoice_Amount from  t045_sapposting WHERE 
				Org_Id = var_Org_Id
				AND Voucher_Id = var_Invoice_Id);
				
                select 
				'4Q' as WithholdingTaxType,
				'INR' as DocumentCurrency,
				'4Q' as WithholdingTaxCode,
				round(abs(GrossAmount)) as WithholdingTaxBaseAmount
				from t045_sapposting t045
				Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t045.Farmer_Id 
				and  mu04.Org_Id = t045.Org_Id
				Inner Join m005_mcc m005 on m005.MCC_Id = t045.MCC_Id
				and  m005.Org_Id = t045.Org_Id
				where
				t045.Org_Id = var_Org_Id
				AND t045.Voucher_Id = var_Invoice_Id
                
                union all
                
                select 
                CASE
					WHEN m005.MCCWorkType_Id = 'C023001' THEN '4Q'
					WHEN m005.MCCWorkType_Id = 'C023002' THEN '1H'
					ELSE ''
				END as WithholdingTaxType,
				'INR' as DocumentCurrency,
				CASE
					WHEN m005.MCCWorkType_Id = 'C023001' THEN '4Q'
					WHEN m005.MCCWorkType_Id = 'C023002' THEN 'H1'
					ELSE ''
				END as WithholdingTaxCode,
				round(abs(GrossAmount)) as WithholdingTaxBaseAmount
				from t045_sapposting t045
				Inner Join m005_mcc m005 on m005.MCC_Id = t045.MCC_Id
				and  m005.Org_Id = t045.Org_Id
				and m005.MCC_Id = t045.Farmer_Id
				where
				t045.Org_Id = var_Org_Id
                and t045.Is_MilkPayment = 0
				AND t045.Voucher_Id = var_Invoice_Id
                
                union all
                
                select 
                '4Q' as WithholdingTaxType,
				'INR' as DocumentCurrency,
				'4Q' as WithholdingTaxCode,
				round(abs(GrossAmount)) as WithholdingTaxBaseAmount
				from t045_sapposting t045
				Inner Join m005_mcc m005 on m005.MCC_Id = t045.MCC_Id
				and  m005.Org_Id = t045.Org_Id
				and m005.MCC_Id = t045.Farmer_Id
				where
				t045.Org_Id = var_Org_Id
                and t045.Is_MilkPayment = 1
				AND t045.Voucher_Id = var_Invoice_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
