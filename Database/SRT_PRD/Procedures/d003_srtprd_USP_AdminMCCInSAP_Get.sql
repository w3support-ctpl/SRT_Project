-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCInSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCInSAP_Get`(
	var_Method_Name longtext,
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_Invoice_Id varchar(20),
    var_ApprovalStatus_Id varchar(2),
    var_MCC_Id varchar(20),
    var_MCCType_Id varchar(20) 
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    if(var_Method_Name = 'Get') then 
		begin
			select
					t028.Voucher_Id as Invoice_Id,t028.Invoice_No,
                    DATE_FORMAT(t028.Invoice_Date, '%d %b %Y') AS Invoice_Date,
					ifnull(m005.MCC_Id,'') as MCC_Id, 
                    ifnull(m005.MCC_Name,'') as MCC_Name, 
                    ifnull(m005.MCC_Code,'') as MCC_Code, 
                    ifnull(t028.SAP_Document_Id,'')  as Income_Document,
					CONCAT(
					DATE_FORMAT(t028.MusterCycle_StartDate, '%d'),
					' - ',
					DATE_FORMAT(t028.MusterCycle_EndDate, '%d')
					) AS MusterCycle,
					t028.Invoice_Amount as Amount,
                    t028.Is_Posted as Is_Posted,
                    ifnull(c047.MPPIType_Id,'')  as MPPIType_Id,
					ifnull(c047.MPPIType_Name,'Deduction')  as MPPIType_Name
				FROM t028_invoice_mcc t028
				
				inner Join m005_mcc m005 on m005.MCC_Id = t028.MCC_Id
                and  m005.Org_Id = t028.Org_Id
                and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
                and m005.MCC_Id = t028.MCC_Id
                left JOIN c047_mppitype c047 ON c047.MPPIType_Id = t028.MPPIType_Id
				where  t028.Org_Id = var_Org_Id
				-- and t028.Invoice_Date <= var_Date
                and t028.Invoice_Date = var_Date
                and t028.Is_Posted = var_ApprovalStatus_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then  
		begin
				SELECT 
					t028.Voucher_Id as Invoice_Id,t028.Invoice_No,
					t028.Invoice_Amount as Amount,
					m005.MCC_Id,m005.MCC_Name,m005.MCC_Code
				FROM t028_invoice_mcc t028
				Inner Join m005_mcc m005 on m005.MCC_Id = t028.MCC_Id
                and m005.Org_Id = t028.Org_Id
				where t028.Org_Id = var_Org_Id
                and t028.Voucher_Id = var_Invoice_Id;
			end;
	elseif (var_Method_Name = 'Get_Generate') then  
		begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
				
            
            
					SELECT * FROM (
					select 
					t0091.MilkCollectionMCCCommission_Id as Check_Id,
					m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
					t0091.Amount as Amount,
					CONCAT(
						ifnull(	GROUP_CONCAT(DISTINCT c011.MilkType_Name ORDER BY c011.MilkType_Id SEPARATOR ' & '),''),
						' | Qty : ',
						IFNULL(SUM(t0091.Liters), 0),
						' Ltr | Fat : ',
						IFNULL(SUM(t0091.Fat), 0),
						'% | SNF : ',
						IFNULL(SUM(t0091.SNF), 0),
                        '%'
					) as Particulars,
					ifnull(t0091.MusterCycle_StartDate,'') as StartDate,
					ifnull(t0091.MusterCycle_EndDate,'') as EndDate,
					DATE_FORMAT(t009.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
					c047.MPPIType_Name as Entry_Type,
                    'C047001' as MPPIType_Id,
					'0' as Is_Voucher 
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
                    and m005.MCCType_Id like var_MCCType_Id
                    and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023002'
					and m005.MCC_Id like var_MCC_Id
					INNER JOIN c011_milktype c011 ON c011.MilkType_Id = t0091.MilkType_Id
                    INNER JOIN c047_mppitype c047 ON c047.MPPIType_Id = t0091.MPPIType_Id
                    where
					t0091.Org_Id =var_Org_Id
                    and t0091.MPPIType_Id  in('C047001','C047003')
                    AND t0091.Is_InvoiceCreated = 0 
                    and t0091.Is_Check = 0
					AND (t0091.Invoice_Id = '' OR t0091.Invoice_Id IS NULL)
					GROUP BY t0091.MilkCollectionMCCCommission_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0091.MusterCycle_StartDate, t0091.MusterCycle_EndDate, t009.Created_On,c047.MPPIType_Name,
                    t0091.MPPIType_Id,
                   t0091.Amount 
                   
                   union all
                   
                   select 
					t0091.MilkCollectionMCCCommission_Id as Check_Id,
					m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
					t0091.Amount as Amount,
					CONCAT(
						ifnull(	GROUP_CONCAT(DISTINCT c011.MilkType_Name ORDER BY c011.MilkType_Id SEPARATOR ' & '),''),
						' | Qty : ',
						IFNULL(SUM(t0091.Liters), 0),
						' Ltr | Fat : ',
						IFNULL(SUM(t0091.Fat), 0),
						'% | SNF : ',
						IFNULL(SUM(t0091.SNF), 0),
                        '%'
					) as Particulars,
					ifnull(t0091.MusterCycle_StartDate,'') as StartDate,
					ifnull(t0091.MusterCycle_EndDate,'') as EndDate,
					DATE_FORMAT(t009.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
					c047.MPPIType_Name as Entry_Type,
                    'C047001' as MPPIType_Id,
					'0' as Is_Voucher 
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
                    and m005.MCCType_Id like var_MCCType_Id
                    and m005.MCCType_Id in('C014003')
					and m005.MCC_Id like var_MCC_Id
					INNER JOIN c011_milktype c011 ON c011.MilkType_Id = t0091.MilkType_Id
                    INNER JOIN c047_mppitype c047 ON c047.MPPIType_Id = t0091.MPPIType_Id
                    where
					t0091.Org_Id =var_Org_Id
                    and t0091.MPPIType_Id  in('C047001')
                    AND t0091.Is_InvoiceCreated = 0 
                    and t0091.Is_Check = 0
					AND (t0091.Invoice_Id = '' OR t0091.Invoice_Id IS NULL)
					GROUP BY t0091.MilkCollectionMCCCommission_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0091.MusterCycle_StartDate, t0091.MusterCycle_EndDate, t009.Created_On,c047.MPPIType_Name,
                    t0091.MPPIType_Id,
                   t0091.Amount 
                   
				union all
                
				select 
					t0091.MilkCollectionMCCCommission_Id as Check_Id,
					m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
					t0091.Amount as Amount,
					CONCAT(
						ifnull(	GROUP_CONCAT(DISTINCT c011.MilkType_Name ORDER BY c011.MilkType_Id SEPARATOR ' & '),''),
						' | Qty : ',
						IFNULL(SUM(t0091.Liters), 0),
						' Ltr | Fat : ',
						IFNULL(SUM(t0091.Fat), 0),
						'% | SNF : ',
						IFNULL(SUM(t0091.SNF), 0),
                        '%'
					) as Particulars,
					ifnull(t0091.MusterCycle_StartDate,'') as StartDate,
					ifnull(t0091.MusterCycle_EndDate,'') as EndDate,
					DATE_FORMAT(t009.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
					c047.MPPIType_Name as Entry_Type,
                    'C047001' as MPPIType_Id,
					'0' as Is_Voucher 
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
                    and m005.MCCType_Id like var_MCCType_Id
                    and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023001'
					and m005.MCC_Id like var_MCC_Id
					INNER JOIN c011_milktype c011 ON c011.MilkType_Id = t0091.MilkType_Id
                    INNER JOIN c047_mppitype c047 ON c047.MPPIType_Id = t0091.MPPIType_Id
                    where
					t0091.Org_Id =var_Org_Id
                    and t0091.MPPIType_Id  in('C047001')
                    AND t0091.Is_InvoiceCreated = 0 
                    and t0091.Is_Check = 0
					AND (t0091.Invoice_Id = '' OR t0091.Invoice_Id IS NULL)
					GROUP BY t0091.MilkCollectionMCCCommission_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0091.MusterCycle_StartDate, t0091.MusterCycle_EndDate, t009.Created_On,c047.MPPIType_Name,
                    t0091.MPPIType_Id,
                   t0091.Amount
                   
				union all
                
				SELECT 
					t0331.Entry_Id as Check_Id,
					ifnull(m005.MCC_Id,'') as MCC_Id, 
                    ifnull(m005.MCC_Name,'') as MCC_Name, 
                    ifnull(m005.MCC_Code,'') as MCC_Code, 
					SUM(t0331.Deduction_Amount) as Amount,
					CONCAT(
						' ( ',
						ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
						' - ',
						ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
						' )'
					) as Particulars,
					var_StartDate as StartDate, var_EndDate as EndDate,
					DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
					CASE
						WHEN t033.Request_Type = 'M020231000007' THEN 'Bank Loan - ICICI'
						WHEN t033.Request_Type = 'M020231000008' THEN 'Trading Material'
						WHEN t033.Request_Type = 'M020231000009' THEN 'Product Sales'
                        WHEN t033.Request_Type = 'M020231000010' THEN 'Dairy Advance'
						WHEN t033.Request_Type = 'M020231000016' THEN 'Bank Loan - Society'
						ELSE ''
					END AS Entry_Type,
                    '' as MPPIType_Id,
					'1' as Is_Voucher 
				FROM t033_deductions_header t033
				INNER JOIN t033_deductions_item t0331 ON 
					t0331.Org_Id = t033.Org_Id 
					AND t0331.Deductions_Id = t033.Deductions_Id 
					AND t0331.Is_Deducted = 0 
					AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				inner JOIN m005_mcc m005 ON m005.Org_Id = t033.Org_Id 
				AND t033.MCC_Id = m005.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCC_Id like var_MCC_Id
				WHERE t033.Org_Id = var_Org_Id
                AND t033.Request_User_Type = 'Agent'
				GROUP BY 
					t0331.Entry_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0331.MusterCycle_StartDate, t0331.MusterCycle_EndDate, 
					t0331.Deduction_Date, t033.Request_Type
		
        
        union all
                   
                   select 
					t0091.MilkCollectionMCCCommission_Id as Check_Id,
					m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
					t0091.Amount as Amount,
					CONCAT(
						ifnull(	GROUP_CONCAT(DISTINCT c011.MilkType_Name ORDER BY c011.MilkType_Id SEPARATOR ' & '),''),
						' | Qty : ',
						IFNULL(SUM(t0091.Liters), 0),
						' Ltr | Fat : ',
						IFNULL(SUM(t0091.Fat), 0),
						'% | SNF : ',
						IFNULL(SUM(t0091.SNF), 0),
                        '%'
					) as Particulars,
					ifnull(t0091.MusterCycle_StartDate,'') as StartDate,
					ifnull(t0091.MusterCycle_EndDate,'') as EndDate,
					DATE_FORMAT(t009.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
					c047.MPPIType_Name as Entry_Type,
                    '' as MPPIType_Id,
					'3' as Is_Voucher 
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
                    and m005.MCCType_Id like var_MCCType_Id
					and m005.MCC_Id like var_MCC_Id
					INNER JOIN c011_milktype c011 ON c011.MilkType_Id = t0091.MilkType_Id
                    INNER JOIN c047_mppitype c047 ON c047.MPPIType_Id = t0091.MPPIType_Id
                    where
					t0091.Org_Id =var_Org_Id
                    and t0091.MPPIType_Id  in('C047004','C047005','C047006','C047007','C047008')
                    AND t0091.Is_InvoiceCreated = 0 
                    and t0091.Is_Check = 0
					AND (t0091.Invoice_Id = '' OR t0091.Invoice_Id IS NULL)
					GROUP BY t0091.MilkCollectionMCCCommission_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0091.MusterCycle_StartDate, t0091.MusterCycle_EndDate, t009.Created_On,c047.MPPIType_Name,
                    t0091.MPPIType_Id,
					t0091.Amount 
                    
					union all
                   
                   select 
					t0091.MilkCollectionMCCCommission_Id as Check_Id,
					m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
					t0091.Amount as Amount,
					CONCAT(
						ifnull(	GROUP_CONCAT(DISTINCT c011.MilkType_Name ORDER BY c011.MilkType_Id SEPARATOR ' & '),''),
						' | Qty : ',
						IFNULL(SUM(t0091.Liters), 0),
						' Ltr | Fat : ',
						IFNULL(SUM(t0091.Fat), 0),
						'% | SNF : ',
						IFNULL(SUM(t0091.SNF), 0),
                        '%'
					) as Particulars,
					ifnull(t0091.MusterCycle_StartDate,'') as StartDate,
					ifnull(t0091.MusterCycle_EndDate,'') as EndDate,
					DATE_FORMAT(t009.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
					c047.MPPIType_Name as Entry_Type,
                    'C047001' as MPPIType_Id,
					'0' as Is_Voucher 
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
                    and m005.MCCType_Id like var_MCCType_Id
					and m005.MCC_Id like var_MCC_Id
					INNER JOIN c011_milktype c011 ON c011.MilkType_Id = t0091.MilkType_Id
                    INNER JOIN c047_mppitype c047 ON c047.MPPIType_Id = t0091.MPPIType_Id
                    where
					t0091.Org_Id =var_Org_Id
                    and t0091.MPPIType_Id  in('C047009')
                    AND t0091.Is_InvoiceCreated = 0 
                    and t0091.Is_Check = 0
					AND (t0091.Invoice_Id = '' OR t0091.Invoice_Id IS NULL)
					GROUP BY t0091.MilkCollectionMCCCommission_Id, m005.MCC_Id, m005.MCC_Name, m005.MCC_Code, 
					t0091.MusterCycle_StartDate, t0091.MusterCycle_EndDate, t009.Created_On,c047.MPPIType_Name,
                    t0091.MPPIType_Id,
					t0091.Amount
                   
                    ) AS subquery
					ORDER BY subquery.MCC_Name asc, subquery.StartDate asc, subquery.EndDate asc;
			end;
	elseif (var_Method_Name = 'Get_Voucher') then 
		begin
				DECLARE Set_MPPIType_Id varchar(255);
				DECLARE CommissionAmount decimal(30,2);
                DECLARE LossAmount decimal(30,2);
                DECLARE PurchaseAmount decimal(30,2);
                DECLARE DateTime varchar(255);
                DECLARE Date varchar(255);
                DECLARE MusterCycle varchar(255);
                DECLARE xmlData longtext;
                DECLARE Counter INT DEFAULT 1;
                DECLARE AccountingDocumentTypeGL varchar(255);
                DECLARE AccountingDocumentTypeMPPI varchar(255);
                DECLARE CompanyCode varchar(255);
                DECLARE GLAccount_Gross varchar(255);
                DECLARE GLAccount_Loss varchar(255);
                DECLARE Creditor_Debtor varchar(50);
                
                set @set_MCC_Id = (select MCC_Id from t028_invoice_mcc
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
					
				
				SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
				inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
					and m005.MCC_Id = t028.MCC_Id 
				where t028.Org_Id = var_Org_Id 
				and t028.Voucher_Id = var_Invoice_Id;
                
                
                
                SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
				SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
                SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
                
				Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
				SELECT 
					CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t028_invoice_mcc t028
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
				
				-- GrossAmount
                
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    CommissionAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id AND t033.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
               
					if(Set_MPPIType_Id = 'C047001') then
						SET xmlData  = 
						concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
						<soapenv:Envelope
							xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
							xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n    
							<soapenv:Header/>\n    
							<soapenv:Body>\n        
								<sfin:JournalEntryBulkCreateRequest>\n            
									<MessageHeader>\n                
										<CreationDateTime>',DateTime,'</CreationDateTime>\n                
										<!--Zero or more repetitions:-->\n                
										<!--Zero or more repetitions:-->\n                
										<BusinessScope>\n                    
											<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n                    
											<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n                    
											<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n                
										</BusinessScope>\n            
									</MessageHeader>\n            
									<!--1 or more repetitions:-->\n            
									<JournalEntryCreateRequest>\n                
										<MessageHeader>\n                    
											<CreationDateTime>',DateTime,'</CreationDateTime>\n                    
											<SenderParty></SenderParty>\n                    
											<!--Zero or more repetitions:-->\n                
										</MessageHeader>\n                
										<JournalEntry>\n                    
											<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
											<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
											<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
											<AccountingDocumentType>',AccountingDocumentTypeMPPI,'</AccountingDocumentType>\n                    
											<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n                    
											<DocumentHeaderText></DocumentHeaderText>\n                    
											<CreatedByUser>CB9980000000</CreatedByUser>\n                    
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                    
											<DocumentDate>',Date,'</DocumentDate>\n                    
											<PostingDate>',Date,'</PostingDate>\n                    
											<PostingFiscalPeriod></PostingFiscalPeriod>\n                    
											<TaxReportingDate>',Date,'</TaxReportingDate>\n                    
											<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n                    
											<Reference1InDocumentHeader></Reference1InDocumentHeader>\n                    
											<Reference2InDocumentHeader></Reference2InDocumentHeader>\n');
                                    
		                IF CommissionAmount IS NOT NULL AND CommissionAmount != '' AND CommissionAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n                        
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
									<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
									<GLAccount>',GLAccount_Gross,'</GLAccount>\n                        
									<AmountInTransactionCurrency currencyCode=\"INR\">',CommissionAmount,'</AmountInTransactionCurrency>\n                        
									<DebitCreditCode>S</DebitCreditCode>\n                        
									<DocumentItemText>Milk Commission from ',MusterCycle,'</DocumentItemText>\n                        
									<BusinessPlace></BusinessPlace>\n                        
									<AccountAssignment>\n                        
										<CostCenter></CostCenter>\n 
                                        <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n
									</AccountAssignment>\n                    
								</Item>\n\t\t '
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
						IF CommissionAmount IS NOT NULL AND CommissionAmount != '' AND CommissionAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n                        
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
									<Creditor>',Creditor_Debtor,'</Creditor>\n                        
									<AmountInTransactionCurrency currencyCode=\"INR\">-',CommissionAmount,'</AmountInTransactionCurrency>\n                        
									<DebitCreditCode>H</DebitCreditCode>\n                        
									<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
									<DocumentItemText>Milk Commission from ',MusterCycle,'</DocumentItemText>\n                        
									<AssignmentReference></AssignmentReference>\n                        
									<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
									<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
									<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
									<DownPaymentTerms>\n             \t\t
										<SpecialGLCode></SpecialGLCode>\n\t\t        
									</DownPaymentTerms>                    \n\t\t    
								</CreditorItem>\n\t\t '
								);
                                SET Counter = Counter + 1;
                            END IF;
						
						
                        
						SET xmlData = CONCAT(xmlData, 
								'<!--Zero or more repetitons:-->\n                    
													<!--Zero or more repetitions:-->\n                
												</JournalEntry>\n            
											</JournalEntryCreateRequest>\n        
										</sfin:JournalEntryBulkCreateRequest>\n    
									</soapenv:Body>\n
								</soapenv:Envelope>'
								);
                                
						SELECT xmlData;
                    elseif(Set_MPPIType_Id = 'C047003') then
						SET xmlData  = 
						concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
						<soapenv:Envelope
							xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
							xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n    
							<soapenv:Header/>\n    
							<soapenv:Body>\n        
								<sfin:JournalEntryBulkCreateRequest>\n            
									<MessageHeader>\n                
										<CreationDateTime>',DateTime,'</CreationDateTime>\n                
										<!--Zero or more repetitions:-->\n                
										<!--Zero or more repetitions:-->\n                
										<BusinessScope>\n                    
											<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n                    
											<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n                    
											<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n                
										</BusinessScope>\n            
									</MessageHeader>\n            
									<!--1 or more repetitions:-->\n            
									<JournalEntryCreateRequest>\n                
										<MessageHeader>\n                    
											<CreationDateTime>',DateTime,'</CreationDateTime>\n                    
											<SenderParty></SenderParty>\n                    
											<!--Zero or more repetitions:-->\n                
										</MessageHeader>\n                
										<JournalEntry>\n                    
											<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
											<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
											<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
											<AccountingDocumentType>',AccountingDocumentTypeGL,'</AccountingDocumentType>\n                    
											<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n                    
											<DocumentHeaderText></DocumentHeaderText>\n                    
											<CreatedByUser>CB9980000000</CreatedByUser>\n                    
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                    
											<DocumentDate>',Date,'</DocumentDate>\n                    
											<PostingDate>',Date,'</PostingDate>\n                    
											<PostingFiscalPeriod></PostingFiscalPeriod>\n                    
											<TaxReportingDate>',Date,'</TaxReportingDate>\n                    
											<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n                    
											<Reference1InDocumentHeader></Reference1InDocumentHeader>\n                    
											<Reference2InDocumentHeader></Reference2InDocumentHeader>\n');
                                    
		                
                            
						IF LossAmount IS NOT NULL AND LossAmount != '' AND LossAmount <> 0 THEN
								if(LossAmount < 0)then
									SET xmlData = CONCAT(xmlData, 
										'<Item>\n                        
											<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
											<GLAccount>',GLAccount_Loss,'</GLAccount>\n                        
											<AmountInTransactionCurrency currencyCode=\"INR\">',LossAmount,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>H</DebitCreditCode>\n                        
											<DocumentItemText>Milk FAT SNF Loss from ',MusterCycle,'</DocumentItemText>\n                        
											<BusinessPlace></BusinessPlace>\n                        
											<AccountAssignment>\n                        
												<CostCenter>11001002</CostCenter>\n                        
											</AccountAssignment>\n                    
										</Item>\n\t\t '
										);
								elseif(LossAmount > 0)then
									SET xmlData = CONCAT(xmlData, 
										'<Item>\n                        
											<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
											<GLAccount>',GLAccount_Loss,'</GLAccount>\n                        
											<AmountInTransactionCurrency currencyCode=\"INR\">',LossAmount,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>S</DebitCreditCode>\n                        
											<DocumentItemText>Milk FAT SNF Gain from ',MusterCycle,'</DocumentItemText>\n                        
											<BusinessPlace></BusinessPlace>\n                        
											<AccountAssignment>\n                        
												<CostCenter>11001002</CostCenter>\n                        
											</AccountAssignment>\n                    
										</Item>\n\t\t '
										);
                                end if;
								
                                SET Counter = Counter + 1;
                            END IF;
                        
						IF LossAmount IS NOT NULL AND LossAmount != '' AND LossAmount <> 0 THEN
                            
								if(LossAmount < 0)then
									SET xmlData = CONCAT(xmlData, 
										'<CreditorItem>\n                        
											<ReferenceDocumentItem></ReferenceDocumentItem>\n                        
											<Creditor>',Creditor_Debtor,'</Creditor>\n                    
											<AmountInTransactionCurrency currencyCode=\"INR\">',(LossAmount * -1 ) ,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>S</DebitCreditCode>\n                        
											<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
											<DocumentItemText>Milk FAT SNF Loss from ',MusterCycle,'</DocumentItemText>\n                        
											<AssignmentReference></AssignmentReference>\n                        
											<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
											<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
											<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
											<DownPaymentTerms>\n             \t\t
												<SpecialGLCode></SpecialGLCode>\n\t\t        
											</DownPaymentTerms>                    \n\t\t    
										</CreditorItem>        \n\t\t'
										);
									
								elseif(LossAmount > 0)then
									SET xmlData = CONCAT(xmlData, 
										'<CreditorItem>\n                        
											<ReferenceDocumentItem></ReferenceDocumentItem>\n                        
											<Creditor>',Creditor_Debtor,'</Creditor>\n                    
											<AmountInTransactionCurrency currencyCode=\"INR\">-',LossAmount ,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>H</DebitCreditCode>\n                        
											<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
											<DocumentItemText>Milk FAT SNF Gain from ',MusterCycle,'</DocumentItemText>\n                        
											<AssignmentReference></AssignmentReference>\n                        
											<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
											<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
											<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
											<DownPaymentTerms>\n             \t\t
												<SpecialGLCode></SpecialGLCode>\n\t\t        
											</DownPaymentTerms>                    \n\t\t    
										</CreditorItem>        \n\t\t'
										);
								end if;
								
                                SET Counter = Counter + 1;
                            END IF;
                        
						SET xmlData = CONCAT(xmlData, 
								'<!--Zero or more repetitons:-->\n                    
													<!--Zero or more repetitions:-->\n                
												</JournalEntry>\n            
											</JournalEntryCreateRequest>\n        
										</sfin:JournalEntryBulkCreateRequest>\n    
									</soapenv:Body>\n
								</soapenv:Envelope>'
								);
                                
						SELECT xmlData;
                    end if;
                        
					 
                
            end;
	elseif (var_Method_Name = 'Get_Voucher_MPPI') then 
		begin
				DECLARE Set_MPPIType_Id varchar(255);
				DECLARE CommissionAmount decimal(30,2);
                DECLARE LossAmount decimal(30,2);
                DECLARE PurchaseAmount decimal(30,2);
                DECLARE DateTime varchar(255);
                DECLARE Date varchar(255);
                DECLARE MusterCycle varchar(255);
                DECLARE xmlData longtext;
                DECLARE Counter INT DEFAULT 1;
                DECLARE AccountingDocumentTypeGL varchar(255);
                DECLARE AccountingDocumentTypeMPPI varchar(255);
                DECLARE CompanyCode varchar(255);
                DECLARE GLAccount_Gross varchar(255);
                DECLARE GLAccount_Loss varchar(255);
                DECLARE Creditor_Debtor varchar(50);
	
				
				SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
				inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
					and m005.MCC_Id = t028.MCC_Id 
				where t028.Org_Id = var_Org_Id 
				and t028.Voucher_Id = var_Invoice_Id;
                
                
                set @set_MCC_Id = (select MCC_Id from t028_invoice_mcc
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
                
                
                
                SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
				SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
                SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
                
				Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
				SELECT 
					CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t028_invoice_mcc t028
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
				
				-- GrossAmount
                
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    CommissionAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id AND t033.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
               
					
						SET xmlData  = 
						concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
						<soapenv:Envelope
							xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
							xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n    
							<soapenv:Header/>\n    
							<soapenv:Body>\n        
								<sfin:JournalEntryBulkCreateRequest>\n            
									<MessageHeader>\n                
										<CreationDateTime>',DateTime,'</CreationDateTime>\n                
										<!--Zero or more repetitions:-->\n                
										<!--Zero or more repetitions:-->\n                
										<BusinessScope>\n                    
											<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n                    
											<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n                    
											<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n                
										</BusinessScope>\n            
									</MessageHeader>\n            
									<!--1 or more repetitions:-->\n            
									<JournalEntryCreateRequest>\n                
										<MessageHeader>\n                    
											<CreationDateTime>',DateTime,'</CreationDateTime>\n                    
											<SenderParty></SenderParty>\n                    
											<!--Zero or more repetitions:-->\n                
										</MessageHeader>\n                
										<JournalEntry>\n                    
											<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
											<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
											<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
											<AccountingDocumentType>',AccountingDocumentTypeMPPI,'</AccountingDocumentType>\n                    
											<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n                    
											<DocumentHeaderText></DocumentHeaderText>\n                    
											<CreatedByUser>CB9980000000</CreatedByUser>\n                    
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                    
											<DocumentDate>',Date,'</DocumentDate>\n                    
											<PostingDate>',Date,'</PostingDate>\n                    
											<PostingFiscalPeriod></PostingFiscalPeriod>\n                    
											<TaxReportingDate>',Date,'</TaxReportingDate>\n                    
											<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n                    
											<Reference1InDocumentHeader></Reference1InDocumentHeader>\n                    
											<Reference2InDocumentHeader></Reference2InDocumentHeader>\n');
                                    
		                IF CommissionAmount IS NOT NULL AND CommissionAmount != '' AND CommissionAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n                        
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
									<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
									<GLAccount>',GLAccount_Gross,'</GLAccount>\n                        
									<AmountInTransactionCurrency currencyCode=\"INR\">',round(CommissionAmount),'</AmountInTransactionCurrency>\n                        
									<DebitCreditCode>S</DebitCreditCode>\n                        
									<DocumentItemText>Milk Commission from ',MusterCycle,'</DocumentItemText>\n                        
									<BusinessPlace></BusinessPlace>\n                        
									<AccountAssignment>\n                        
										<CostCenter></CostCenter>\n 
                                        <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n
									</AccountAssignment>\n                    
								</Item>\n\t\t '
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
						IF CommissionAmount IS NOT NULL AND CommissionAmount != '' AND CommissionAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n                        
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
									<Creditor>',Creditor_Debtor,'</Creditor>\n                        
									<AmountInTransactionCurrency currencyCode=\"INR\">-',round(CommissionAmount),'</AmountInTransactionCurrency>\n                        
									<DebitCreditCode>H</DebitCreditCode>\n                        
									<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
									<DocumentItemText>Milk Commission from ',MusterCycle,'</DocumentItemText>\n                        
									<AssignmentReference></AssignmentReference>\n                        
									<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
									<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
									<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
									<DownPaymentTerms>\n             \t\t
										<SpecialGLCode></SpecialGLCode>\n\t\t        
									</DownPaymentTerms>                    \n\t\t    
								</CreditorItem>\n\t\t '
								);
                                SET Counter = Counter + 1;
                            END IF;
						
						
						SET xmlData = CONCAT(xmlData, 
								'<!--Zero or more repetitons:-->\n                    
													<!--Zero or more repetitions:-->\n                
												</JournalEntry>\n            
											</JournalEntryCreateRequest>\n        
										</sfin:JournalEntryBulkCreateRequest>\n    
									</soapenv:Body>\n
								</soapenv:Envelope>'
								);
					
					SELECT xmlData;
		end;
	elseif (var_Method_Name = 'Get_Voucher_GainLoss') then 
		begin
				DECLARE Set_MPPIType_Id varchar(255);
				DECLARE CommissionAmount decimal(30,2);
                DECLARE LossAmount decimal(30,2);
                DECLARE PurchaseAmount decimal(30,2);
                DECLARE DateTime varchar(255);
                DECLARE Date varchar(255);
                DECLARE MusterCycle varchar(255);
                DECLARE xmlData longtext;
                DECLARE Counter INT DEFAULT 1;
                DECLARE AccountingDocumentTypeGL varchar(255);
                DECLARE AccountingDocumentTypeMPPI varchar(255);
                DECLARE CompanyCode varchar(255);
                DECLARE GLAccount_Gross varchar(255);
                DECLARE GLAccount_Loss varchar(255);
                DECLARE Creditor_Debtor varchar(50);
	
				
				SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
				inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
					and m005.MCC_Id = t028.MCC_Id 
				where t028.Org_Id = var_Org_Id 
				and t028.Voucher_Id = var_Invoice_Id;
                
                
                
                SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
				SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
                SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
                
				Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
				SELECT 
					CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t028_invoice_mcc t028
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
				
				-- GrossAmount
                
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    CommissionAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
				SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id AND t033.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
               
               if(LossAmount is null or LossAmount = '' or LossAmount = 0)then
					UPDATE t028_invoice_mcc t028
					SET t028.Is_Posted = 4
					WHERE t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id;
				end if;
					
						SET xmlData  = 
						concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
						<soapenv:Envelope
							xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
							xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n    
							<soapenv:Header/>\n    
							<soapenv:Body>\n        
								<sfin:JournalEntryBulkCreateRequest>\n            
									<MessageHeader>\n                
										<CreationDateTime>',DateTime,'</CreationDateTime>\n                
										<!--Zero or more repetitions:-->\n                
										<!--Zero or more repetitions:-->\n                
										<BusinessScope>\n                    
											<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n                    
											<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n                    
											<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n                
										</BusinessScope>\n            
									</MessageHeader>\n            
									<!--1 or more repetitions:-->\n            
									<JournalEntryCreateRequest>\n                
										<MessageHeader>\n                    
											<CreationDateTime>',DateTime,'</CreationDateTime>\n                    
											<SenderParty></SenderParty>\n                    
											<!--Zero or more repetitions:-->\n                
										</MessageHeader>\n                
										<JournalEntry>\n                    
											<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
											<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
											<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
											<AccountingDocumentType>',AccountingDocumentTypeGL,'</AccountingDocumentType>\n                    
											<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n                    
											<DocumentHeaderText></DocumentHeaderText>\n                    
											<CreatedByUser>CB9980000000</CreatedByUser>\n                    
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                    
											<DocumentDate>',Date,'</DocumentDate>\n                    
											<PostingDate>',Date,'</PostingDate>\n                    
											<PostingFiscalPeriod></PostingFiscalPeriod>\n                    
											<TaxReportingDate>',Date,'</TaxReportingDate>\n                    
											<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n                    
											<Reference1InDocumentHeader></Reference1InDocumentHeader>\n                    
											<Reference2InDocumentHeader></Reference2InDocumentHeader>\n');
                                    
		                
                            
						IF LossAmount IS NOT NULL AND LossAmount != '' AND LossAmount <> 0 THEN
								if(LossAmount < 0)then
									SET xmlData = CONCAT(xmlData, 
										'<Item>\n                        
											<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
											<GLAccount>',GLAccount_Loss,'</GLAccount>\n                        
											<AmountInTransactionCurrency currencyCode=\"INR\">',round(LossAmount),'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>H</DebitCreditCode>\n                        
											<DocumentItemText>Milk FAT SNF Loss from ',MusterCycle,'</DocumentItemText>\n                        
											<BusinessPlace></BusinessPlace>\n                        
											<AccountAssignment>\n                        
												<CostCenter>11001002</CostCenter>\n                        
											</AccountAssignment>\n                    
										</Item>\n\t\t '
										);
								elseif(LossAmount > 0)then
									SET xmlData = CONCAT(xmlData, 
										'<Item>\n                        
											<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
											<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
											<GLAccount>',GLAccount_Loss,'</GLAccount>\n                        
											<AmountInTransactionCurrency currencyCode=\"INR\">',round(LossAmount),'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>S</DebitCreditCode>\n                        
											<DocumentItemText>Milk FAT SNF Gain from ',MusterCycle,'</DocumentItemText>\n                        
											<BusinessPlace></BusinessPlace>\n                        
											<AccountAssignment>\n                        
												<CostCenter>11001002</CostCenter>\n                        
											</AccountAssignment>\n                    
										</Item>\n\t\t '
										);
                                end if;
								
                                SET Counter = Counter + 1;
                            END IF;
                        
						IF LossAmount IS NOT NULL AND LossAmount != '' AND LossAmount <> 0 THEN
                            
								if(LossAmount < 0)then
									SET xmlData = CONCAT(xmlData, 
										'<CreditorItem>\n                        
											<ReferenceDocumentItem></ReferenceDocumentItem>\n                        
											<Creditor>',Creditor_Debtor,'</Creditor>\n                    
											<AmountInTransactionCurrency currencyCode=\"INR\">',(round(LossAmount) * -1 ) ,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>S</DebitCreditCode>\n                        
											<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
											<DocumentItemText>Milk FAT SNF Loss from ',MusterCycle,'</DocumentItemText>\n                        
											<AssignmentReference></AssignmentReference>\n                        
											<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
											<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
											<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
											<DownPaymentTerms>\n             \t\t
												<SpecialGLCode></SpecialGLCode>\n\t\t        
											</DownPaymentTerms>                    \n\t\t    
										</CreditorItem>        \n\t\t'
										);
									
								elseif(LossAmount > 0)then
									SET xmlData = CONCAT(xmlData, 
										'<CreditorItem>\n                        
											<ReferenceDocumentItem></ReferenceDocumentItem>\n                        
											<Creditor>',Creditor_Debtor,'</Creditor>\n                    
											<AmountInTransactionCurrency currencyCode=\"INR\">-',round(LossAmount) ,'</AmountInTransactionCurrency>\n                        
											<DebitCreditCode>H</DebitCreditCode>\n                        
											<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
											<DocumentItemText>Milk FAT SNF Gain from ',MusterCycle,'</DocumentItemText>\n                        
											<AssignmentReference></AssignmentReference>\n                        
											<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
											<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
											<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t
											<DownPaymentTerms>\n             \t\t
												<SpecialGLCode></SpecialGLCode>\n\t\t        
											</DownPaymentTerms>                    \n\t\t    
										</CreditorItem>        \n\t\t'
										);
								end if;
								
                                SET Counter = Counter + 1;
                            END IF;
                        
						SET xmlData = CONCAT(xmlData, 
								'<!--Zero or more repetitons:-->\n                    
													<!--Zero or more repetitions:-->\n                
												</JournalEntry>\n            
											</JournalEntryCreateRequest>\n        
										</sfin:JournalEntryBulkCreateRequest>\n    
									</soapenv:Body>\n
								</soapenv:Envelope>'
								);
                                
						SELECT xmlData;
                   
		end;
	elseif (var_Method_Name = 'Get_Voucher_Deductions') then 
		begin
				DECLARE GrossAmount decimal(30,2);
                DECLARE PurchaseAmount decimal(30,2);
                DECLARE TotalAmount decimal(30,2);
                DECLARE AnamatAmount decimal(30,2);
                DECLARE FreightAmount decimal(30,2);
                DECLARE Set_MPPIType_Id varchar(255);
                
                DECLARE DateTime varchar(255);
                DECLARE Date varchar(255);
                DECLARE MusterCycle varchar(255);
                DECLARE xmlData longtext;
                DECLARE Counter INT DEFAULT 1;
				DECLARE AccountingDocumentTypeMPPI varchar(255);
                DECLARE CompanyCode varchar(255);
                DECLARE GLAccount_Freight varchar(255);
                
                DECLARE GLAccount_Protein varchar(255);
				DECLARE GLAccount_Ash varchar(255);
				DECLARE GLAccount_Sodium varchar(255);
				DECLARE GLAccount_Incentives varchar(255);
               
				DECLARE Debtor varchar(255);
                DECLARE Creditor varchar(255);
                DECLARE AltvRecnclnAccts_Anamat varchar(255);
                DECLARE AltvRecnclnAccts_Loan varchar(255);
                DECLARE AltvRecnclnAccts_Advance varchar(255);
                DECLARE Creditor_Debtor varchar(50);
                DECLARE Creditor_Debtor_Name varchar(50);
                DECLARE To_Anamat varchar(255);
                DECLARE To_Freight varchar(255);
                
                
                DECLARE CattleFeed decimal(30,2);
                
                DECLARE Advance decimal(30,2);
				DECLARE BankLoan_ICICI decimal(30,2);
                DECLARE BankLoan_Society decimal(30,2);
                
                DECLARE ICICI_GLCode varchar(255);
				DECLARE Society__GLCode varchar(255);
                
                set @set_MCC_Id = (select MCC_Id from t028_invoice_mcc
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
			
				SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
				inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
					and m005.MCC_Id = t028.MCC_Id 
				where t028.Org_Id = var_Org_Id 
				and t028.Voucher_Id = var_Invoice_Id;
                
                
                Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
               	SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
                SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';
				SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
				SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Freight';
				
                SELECT Constant_Value into GLAccount_Protein  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Protein';
				SELECT Constant_Value into GLAccount_Ash  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Ash';
				SELECT Constant_Value into GLAccount_Sodium  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Sodium';
				SELECT Constant_Value into GLAccount_Incentives  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Incentives';		

				select 
				m005.Anamat_Applicable_To, 
				m005.Freight_Applicable_To 
                into 
                To_Anamat, 
                To_Freight
				from t028_invoice_mcc t028
				inner join m005_mcc_version m005 on
				m005.Org_Id = t028.Org_Id 
				and m005.MCC_Id = t028.MCC_Id 
                and m005.Applicable_Date <= t028.Invoice_Date
				where t028.Org_Id = var_Org_Id
				and t028.Voucher_Id =  var_Invoice_Id
                and m005.Is_Deleted = 0
                order by m005.Applicable_Date desc
                limit 1;
				
                SELECT GL_Code into ICICI_GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id
				and DeductionHead_Id ='M020231000007';
                
                SELECT GL_Code into Society__GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id 
				and DeductionHead_Id ='M020231000016';
                
                SELECT 
					CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t028_invoice_mcc t028
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
				
                
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
                INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000009'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
			-- Trading Material (Cattle Feed)
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  CattleFeed
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
                INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000008'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- Advance Recovered
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  Advance
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000010'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- Bank Loan - ICICI
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_ICICI
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000007'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- Bank Loan - Society
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_Society
				FROM t028_invoice_mcc t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000016'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- AnamatAmount
                
                
				SELECT 
                    COALESCE(SUM(IFNULL(t006.MCC_Commision, 0)), 0),
                    t006.MPPIType_Id
                    into 
                    AnamatAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047004'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
				
                -- FreightAmount
                
				SELECT 
                    COALESCE(SUM(IFNULL(t006.MCC_Commision, 0)), 0),
                    t006.MPPIType_Id
                    into 
                    FreightAmount,
                    Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
                AND t006.Invoice_Id = t028.Voucher_Id
                and t006.MPPIType_Id = 'C047005'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
                    group by t006.MPPIType_Id;
                    
				if(To_Anamat = 'MCC')then
					if(AnamatAmount = '' or AnamatAmount is null)then
						UPDATE t028_invoice_mcc t028
						SET t028.DairyAnamat_Amount = 0
						WHERE 
							t028.Org_Id = var_Org_Id
							AND t028.Voucher_Id = var_Invoice_Id;
                            
					else 
						UPDATE t028_invoice_mcc t028
						SET t028.DairyAnamat_Amount =  round(AnamatAmount)
						WHERE 
							t028.Org_Id = var_Org_Id
							AND t028.Voucher_Id = var_Invoice_Id;
                    end if;
				else
					UPDATE t028_invoice_mcc t028
					SET t028.DairyAnamat_Amount = 0
					WHERE 
						t028.Org_Id = var_Org_Id
						AND t028.Voucher_Id = var_Invoice_Id;
                end if;
                
                if(To_Freight = 'MCC')then
					if(FreightAmount = '' or FreightAmount is null)then
						UPDATE t028_invoice_mcc t028
						SET t028.Transport_Amount = 0
						WHERE 
							t028.Org_Id = var_Org_Id
							AND t028.Voucher_Id = var_Invoice_Id;
                            
					else 
						UPDATE t028_invoice_mcc t028
						SET t028.Transport_Amount = round(FreightAmount)
						WHERE 
							t028.Org_Id = var_Org_Id
							AND t028.Voucher_Id = var_Invoice_Id;
                    end if;
				else
					UPDATE t028_invoice_mcc t028
					SET t028.Transport_Amount = 0
					WHERE 
						t028.Org_Id = var_Org_Id
						AND t028.Voucher_Id = var_Invoice_Id;
                end if;
                
                
				if(AnamatAmount = '' or AnamatAmount is null)then
					set AnamatAmount = 0;
                end if;
                if(FreightAmount = '' or FreightAmount is null)then
					set FreightAmount = 0;
                end if;
                
                set TotalAmount =  round(PurchaseAmount)  + round(Advance) + round(CattleFeed) + round(BankLoan_ICICI) + round(BankLoan_Society) 
                + round(AnamatAmount)
                + round(FreightAmount)
                ;
                
                if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
					UPDATE t028_invoice_mcc t028
					SET t028.Is_Posted = 4
					WHERE t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id;
				end if;
                
                
                
                SET xmlData  = 
				concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
				<soapenv:Envelope\n\t
					xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"\n\t
					xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n\t
					<soapenv:Header/>\n\t
					<soapenv:Body>\n\t\t
						<sfin:JournalEntryBulkCreateRequest>\n\t\t\t
							<MessageHeader>\n\t\t\t\t
								<CreationDateTime>',DateTime,'</CreationDateTime>\n\t\t\t\t
								<!--Zero or more repetitions:-->\n\t\t\t\t
								<!--Zero or more repetitions:-->\n\t\t\t\t
								<BusinessScope>\n\t\t\t\t\t
									<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n\t\t\t\t\t
									<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n\t\t\t\t\t
									<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n\t\t\t\t
								</BusinessScope>\n\t\t\t
							</MessageHeader>\n\t\t\t
							<!--1 or more repetitions:-->\n\t\t\t
							<JournalEntryCreateRequest>\n\t\t\t\t
								<MessageHeader>\n\t\t\t\t\t
									<CreationDateTime>',DateTime,'</CreationDateTime>\n\t\t\t\t\t
									<SenderParty></SenderParty>\n\t\t\t\t\t
									<!--Zero or more repetitions:-->\n\t\t\t\t
								</MessageHeader>\n\t\t\t\t
								<JournalEntry>\n\t\t\t\t\t
									<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n\t\t\t\t\t
									<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n\t\t\t\t\t
									<BusinessTransactionType>RFBU</BusinessTransactionType>\n\t\t\t\t\t
									<AccountingDocumentType>',AccountingDocumentTypeMPPI,'</AccountingDocumentType>\n\t\t\t\t\t
									<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n\t\t\t\t\t
									<DocumentHeaderText></DocumentHeaderText>\n\t\t\t\t\t
									<CreatedByUser>CB9980000000</CreatedByUser>\n\t\t\t\t\t
									<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t
									<DocumentDate>',Date,'</DocumentDate>\n\t\t\t\t\t
									<PostingDate>',Date,'</PostingDate>\n\t\t\t\t\t
									<PostingFiscalPeriod></PostingFiscalPeriod>\n\t\t\t\t\t
									<TaxReportingDate>',Date,'</TaxReportingDate>\n\t\t\t\t\t
									<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n\t\t\t\t\t
									<Reference1InDocumentHeader></Reference1InDocumentHeader>\n\t\t\t\t\t
									<Reference2InDocumentHeader></Reference2InDocumentHeader>\n\t\t\t\t\t');
			
                            
                            
                            
                            
                
                            IF FreightAmount IS NOT NULL and FreightAmount != '' AND FreightAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t\t
										<GLAccount>',GLAccount_Freight,'</GLAccount>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(FreightAmount),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<DocumentItemText>Milk Freight Recovered</DocumentItemText>\n\t\t\t\t\t\t
										<BusinessPlace></BusinessPlace>\n\t\t\t\t\t\t
										<AccountAssignment>\n\t\t\t\t\t\t\t
											<ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n\t\t\t\t\t\t\t
											<Segment></Segment>\n\t\t\t\t\t\t\t
											<CostCenter></CostCenter>\n\t\t\t\t\t\t
										</AccountAssignment>\n\t\t\t\t\t
									</Item>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF PurchaseAmount IS NOT NULL AND PurchaseAmount != '' AND PurchaseAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<DebtorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Debtor>', Creditor_Debtor, '</Debtor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(PurchaseAmount),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DocumentItemText>Purchase from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t
									</DebtorItem>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF CattleFeed IS NOT NULL AND CattleFeed != '' AND CattleFeed <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<DebtorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Debtor>', Creditor_Debtor, '</Debtor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(CattleFeed),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DocumentItemText>Cattle Feed from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t
									</DebtorItem>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF AnamatAmount IS NOT NULL and AnamatAmount != '' AND AnamatAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(AnamatAmount),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', AltvRecnclnAccts_Anamat, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Anamat from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
										</DownPaymentTerms>\n\t\t\t\t\t
									</CreditorItem>\n'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            
						
                            
                            IF Advance IS NOT NULL AND Advance != '' AND Advance <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
                                        
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(Advance),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', AltvRecnclnAccts_Advance, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Advance Recovered from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
                                            <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n\t\t\t\t\t\t
										</DownPaymentTerms>\n\t\t\t\t\t
									</CreditorItem>\n'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF BankLoan_ICICI IS NOT NULL AND BankLoan_ICICI != '' AND BankLoan_ICICI <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', ICICI_GLCode, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankLoan_ICICI),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts></AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Bank Loan from ICICI ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner>',Creditor_Debtor,'</Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
										</DownPaymentTerms>\n\t\t\t\t\t
									</CreditorItem>\n'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            
                            IF BankLoan_Society IS NOT NULL AND BankLoan_Society != '' AND BankLoan_Society <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Society__GLCode, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankLoan_Society),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts></AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Bank Loan from Society ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner>',Creditor_Debtor,'</Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
										</DownPaymentTerms>\n\t\t\t\t\t
									</CreditorItem>\n'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF TotalAmount IS NOT NULL AND TotalAmount != '' AND TotalAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">',round(TotalAmount),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>S</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts></AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Total Deductions from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
                                            <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n\t\t\t\t\t\t
										</DownPaymentTerms>\n\t\t\t\t\t
									</CreditorItem>\n\t\t\t\t\t\n\t\t\t\t\t'
								);
                            END IF;
						
						
                        SET xmlData = CONCAT(xmlData, 
								'<!--Zero or more repetitons:-->\n\t\t\t\t\t
								<!--Zero or more repetitions:-->\n\t\t\t\t
													</JournalEntry>\n\t\t\t
												</JournalEntryCreateRequest>\n\t\t
											</sfin:JournalEntryBulkCreateRequest>\n\t
										</soapenv:Body>\n
									</soapenv:Envelope>'
								);
                                
				SELECT xmlData;
	
		end;
    elseif (var_Method_Name = 'Get_GainLoss') then 
        begin
			select 
			DATE_FORMAT(f010.Collection_Date, '%d %b %Y') AS Collection_Date,
			c015.CollectionShift_Id,
			c015.CollectionShift_Name,
			c011.MilkType_Id,
			c011.MilkType_Name,
			f010.Agent_Quantity_Kg,
			f010.Agent_Quantity_Ltr,
			f010.Agent_Fat,
			f010.Agent_SNF,
			f010.Agent_Fat_Kg,
			f010.Agent_SNF_Kg,
			f010.Dairy_Quantity_Kg,
			f010.Dairy_Quantity_Ltr,
			f010.Dairy_Fat,
			f010.Dairy_SNF,
			f010.Dairy_Fat_Kg,
			f010.Dairy_SNF_Kg,
			f010.FatKG_GainLoss,
			f010.SNFKG_GainLoss,
			f010.FatKG_Rate,
			f010.SNFKG_Rate,
			f010.Total_GainLoss
			from t028_invoice_mcc t028
			inner join t009_milkcollectiondairy_mcccommission t009 on 
			t009.Org_Id = t028.Org_Id
			and t009.Invoice_Id = t028.Voucher_Id
			inner join f010_milkcollectionmcc_final f010 on 
			t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
			and t028.MCC_Id = f010.MCC_Id
			inner join c015_collectionshift c015 on 
			c015.CollectionShift_Id = f010.CollectionShift_Id
			inner join c011_milktype c011 on 
			c011.MilkType_Id = f010.MilkType_Id
			where t028.Org_Id = var_Org_Id
			and t028.Voucher_Id = var_Invoice_Id;
        end;
	elseif (var_Method_Name = 'Get_MPPI') then 
        begin
			select 
			DATE_FORMAT(f010.Collection_Date, '%d %b %Y') AS Collection_Date,
			c015.CollectionShift_Id,
			c015.CollectionShift_Name,
			c011.MilkType_Id,
			c011.MilkType_Name,
			f010.Dairy_Quantity_Ltr,
			t009.MCC_Commision as AgentCost,
			t009.BaseRate as Rate 
			from t028_invoice_mcc t028
			inner join t009_milkcollectiondairy_mcccommission t009 on 
			t009.Org_Id = t028.Org_Id
			and t009.Invoice_Id = t028.Voucher_Id
			inner join f010_milkcollectionmcc_final f010 on 
			t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
			and t028.MCC_Id = f010.MCC_Id
            and t028.MCC_Id = t009.MCC_Id
            and f010.MCC_Id = t009.MCC_Id
			inner join c015_collectionshift c015 on 
			c015.CollectionShift_Id = f010.CollectionShift_Id
			inner join c011_milktype c011 on 
			c011.MilkType_Id = f010.MilkType_Id
			where t028.Org_Id = var_Org_Id
			and t028.Voucher_Id = var_Invoice_Id;
        end;
	elseif (var_Method_Name = 'Get_Income_Header') then
		begin
			DECLARE Set_MPPIType_Id varchar(255);
			DECLARE CommissionAmount decimal(30,2);
			DECLARE LossAmount decimal(30,2);
			DECLARE PurchaseAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentTypeGL varchar(255);
			DECLARE AccountingDocumentTypeMPPI varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Gross varchar(255);
			DECLARE GLAccount_Loss varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            DECLARE TotalAmount decimal(30,2);
            DECLARE Set_MCCType_Id varchar(255);
			DECLARE Set_MCCWorkType_Id varchar(255);
            
            SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
			SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
			
            SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
			inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
				and m005.MCC_Id = t028.MCC_Id 
			where t028.Org_Id = var_Org_Id 
			and t028.Voucher_Id = var_Invoice_Id;
                
			Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
			-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
			SELECT 
				CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t028_invoice_mcc t028
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
			GROUP BY
				t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
                
			select 
            m005.MCCType_Id,
            m005.MCCWorkType_Id 
            into 
			Set_MCCType_Id,
			Set_MCCWorkType_Id
			from m005_mcc m005 
			inner join t028_invoice_mcc t028 on
			t028.Org_Id = m005.Org_Id 
			and t028.MCC_Id = m005.MCC_Id 
			where m005.Org_Id = var_Org_Id
			and t028.Voucher_Id =var_Invoice_Id;
			
            
            if(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
				-- GrossAmount
			
			SELECT 
				ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
				t006.MPPIType_Id
				into 
				CommissionAmount,
				Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047001'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
				-- Gain Loss
			SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047003'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
					
				-- Gain Loss
				SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						LossAmount,
						Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014003')then
				-- MPPI
				-- GrossAmount
			
					SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						CommissionAmount,
						Set_MPPIType_Id
					FROM t028_invoice_mcc t028
					INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
					AND t006.Invoice_Id = t028.Voucher_Id
					and t006.MPPIType_Id = 'C047001'
					WHERE 
						t028.Org_Id = var_Org_Id
						AND t028.Voucher_Id = var_Invoice_Id
						group by t006.MPPIType_Id;
					
                set LossAmount =0;
					
			elseif(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
					-- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
                
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			end if;
            
            
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
            
            
            set TotalAmount = round(COALESCE(CommissionAmount,0)) + round(COALESCE(LossAmount,0));
            
            SELECT 
			Current_Year as FiscalYear,
			CompanyCode as CompanyCode,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t028.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as DocumentDate,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t028.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as PostingDate,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as CreationDate,
			'123T' as SupplierInvoiceIDByInvcgParty,
			Creditor_Debtor as InvoicingParty,
			'INR' as DocumentCurrency,
			round(abs(TotalAmount)) as InvoiceGrossAmount,
			'SV00' as PaymentTerms,
			AccountingDocumentTypeMPPI as AccountingDocumentType,
			'5' as SupplierInvoiceStatus,
			true as TaxIsCalculatedAutomatically,
			'IN27' as BusinessPlace,
			'1829'as BusinessSectionCode,
			false as SuplrInvcIsCapitalGoodsRelated,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t028.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxDeterminationDate,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t028.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxReportingDate,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t028.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxFulfillmentDate,
			false as IsEUTriangularDeal,
			false as IsReversal,
			false as IsReversed ,
			concat('Milk Commission from ',MusterCycle) as SupplierPostingLineItemText,
			CASE
			WHEN ROUND(TotalAmount) < 0 THEN 'X' -- If TotalAmount is negative, set DebitCreditCode to 'H'
			WHEN ROUND(TotalAmount) > 0 THEN '' -- If TotalAmount is positive, set DebitCreditCode to 'S'
			ELSE '' -- For any other case, set DebitCreditCode to empty string
			END as SupplierInvoiceIsCreditMemo
			FROM t028_invoice_mcc t028
			where
			t028.Org_Id = var_Org_Id
			AND t028.Voucher_Id = var_Invoice_Id;
            
				
        end;
	elseif (var_Method_Name = 'Get_SupplierInvoiceItemGLAcct') then
		begin
			DECLARE Set_MPPIType_Id varchar(255);
			DECLARE CommissionAmount decimal(30,2);
			DECLARE LossAmount decimal(30,2);
			DECLARE PurchaseAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentTypeGL varchar(255);
			DECLARE AccountingDocumentTypeMPPI varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Gross varchar(255);
			DECLARE GLAccount_Loss varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            DECLARE TotalAmount decimal(30,2);
            DECLARE Set_MCCType_Id varchar(255);
			DECLARE Set_MCCWorkType_Id varchar(255);
            
            SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
			SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
			
            SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
			inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
				and m005.MCC_Id = t028.MCC_Id 
			where t028.Org_Id = var_Org_Id 
			and t028.Voucher_Id = var_Invoice_Id;
            
            set @set_MCC_Id = (select MCC_Id from t028_invoice_mcc
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
                
			Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
			-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
			SELECT 
				CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t028_invoice_mcc t028
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
			GROUP BY
				t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
                
			select 
            m005.MCCType_Id,
            m005.MCCWorkType_Id 
            into 
			Set_MCCType_Id,
			Set_MCCWorkType_Id
			from m005_mcc m005 
			inner join t028_invoice_mcc t028 on
			t028.Org_Id = m005.Org_Id 
			and t028.MCC_Id = m005.MCC_Id 
			where m005.Org_Id = var_Org_Id
			and t028.Voucher_Id =var_Invoice_Id;
			
			if(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
				-- GrossAmount
			
			SELECT 
				ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
				t006.MPPIType_Id
				into 
				CommissionAmount,
				Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047001'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
				-- Gain Loss
			SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047003'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
					
				-- Gain Loss
				SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						LossAmount,
						Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014003')then
				-- MPPI
				-- GrossAmount
			
					SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						CommissionAmount,
						Set_MPPIType_Id
					FROM t028_invoice_mcc t028
					INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
					AND t006.Invoice_Id = t028.Voucher_Id
					and t006.MPPIType_Id = 'C047001'
					WHERE 
						t028.Org_Id = var_Org_Id
						AND t028.Voucher_Id = var_Invoice_Id
						group by t006.MPPIType_Id;
					
                 set LossAmount =0;
					
			elseif(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
					-- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
                
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			end if;
                
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
            
            set TotalAmount = round(COALESCE(CommissionAmount,0)) + round(COALESCE(LossAmount,0));
            
            select 
			Current_Year as FiscalYear,
			'1' as SupplierInvoiceItem,
			CompanyCode as CompanyCode,
			'' as CostCenter ,
			@ProfitCenter as ProfitCenter,
			GLAccount_Gross as GLAccount,
			'INR' as DocumentCurrency,
			round(abs(TotalAmount)) as SupplierInvoiceItemAmount,
			'0C' as TaxCode,
			CASE
				WHEN ROUND(TotalAmount) < 0 THEN 'H' -- If TotalAmount is negative, set DebitCreditCode to 'H'
				WHEN ROUND(TotalAmount) > 0 THEN 'S' -- If TotalAmount is positive, set DebitCreditCode to 'S'
				ELSE '' -- For any other case, set DebitCreditCode to empty string
			END as DebitCreditCode,
            
            -- 'S' as DebitCreditCode,
			false as IsNotCashDiscountLiable,
			'0.00' as TaxBaseAmountInTransCrcy,
			concat('Milk Commission from ',MusterCycle) as SupplierInvoiceItemText
			FROM t028_invoice_mcc t028
            where
            t028.Org_Id = var_Org_Id
			AND t028.Voucher_Id = var_Invoice_Id;
            
        end;
	elseif (var_Method_Name = 'Get_SupplierInvoiceWhldgTax') then
		begin
			DECLARE Set_MPPIType_Id varchar(255);
			DECLARE CommissionAmount decimal(30,2);
			DECLARE LossAmount decimal(30,2);
			DECLARE PurchaseAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentTypeGL varchar(255);
			DECLARE AccountingDocumentTypeMPPI varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Gross varchar(255);
			DECLARE GLAccount_Loss varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            DECLARE TotalAmount decimal(30,2);
            DECLARE Set_MCCType_Id varchar(255);
			DECLARE Set_MCCWorkType_Id varchar(255);
            
            SELECT Constant_Value into AccountingDocumentTypeGL  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeGL';
			SELECT Constant_Value into AccountingDocumentTypeMPPI  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'AccountingDocumentTypeMPPI';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Loss  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCVoucher' and Constant_Name = 'GLAccount_Loss';
			
            SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
			inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
				and m005.MCC_Id = t028.MCC_Id 
			where t028.Org_Id = var_Org_Id 
			and t028.Voucher_Id = var_Invoice_Id;
                
			Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
			-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
			SELECT 
				CONCAT(DATE_FORMAT(t028.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t028.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t028_invoice_mcc t028
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
			GROUP BY
				t028.MusterCycle_StartDate,t028.MusterCycle_EndDate;
                
			select 
            m005.MCCType_Id,
            m005.MCCWorkType_Id 
            into 
			Set_MCCType_Id,
			Set_MCCWorkType_Id
			from m005_mcc m005 
			inner join t028_invoice_mcc t028 on
			t028.Org_Id = m005.Org_Id 
			and t028.MCC_Id = m005.MCC_Id 
			where m005.Org_Id = var_Org_Id
			and t028.Voucher_Id =var_Invoice_Id;
			
			if(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
				-- GrossAmount
			
			SELECT 
				ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
				t006.MPPIType_Id
				into 
				CommissionAmount,
				Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047001'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
				-- Gain Loss
			SELECT 
                    ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
                    t006.MPPIType_Id
                    into 
                    LossAmount,
                    Set_MPPIType_Id
			FROM t028_invoice_mcc t028
			INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
			AND t006.Invoice_Id = t028.Voucher_Id
			and t006.MPPIType_Id = 'C047003'
			WHERE 
				t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id
				group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023002')then
				-- MPPI / Gain Loss
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
					
				-- Gain Loss
				SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						LossAmount,
						Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047003'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                
			elseif(Set_MCCType_Id  = 'C014003')then
				-- MPPI
				-- GrossAmount
			
					SELECT 
						ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
						t006.MPPIType_Id
						into 
						CommissionAmount,
						Set_MPPIType_Id
					FROM t028_invoice_mcc t028
					INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
					AND t006.Invoice_Id = t028.Voucher_Id
					and t006.MPPIType_Id = 'C047001'
					WHERE 
						t028.Org_Id = var_Org_Id
						AND t028.Voucher_Id = var_Invoice_Id
						group by t006.MPPIType_Id;
					
				set LossAmount =0;
					
			elseif(Set_MCCType_Id  = 'C014001' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
					-- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			elseif(Set_MCCType_Id  = 'C014002' and Set_MCCWorkType_Id  = 'C023001')then
				-- MPPI
                
                -- GrossAmount
			
				SELECT 
					ROUND(SUM(IFNULL(t006.MCC_Commision, 0)), 2),
					t006.MPPIType_Id
					into 
					CommissionAmount,
					Set_MPPIType_Id
				FROM t028_invoice_mcc t028
				INNER JOIN t009_milkcollectiondairy_mcccommission t006 ON t006.Org_Id = t028.Org_Id 
				AND t006.Invoice_Id = t028.Voucher_Id
				and t006.MPPIType_Id = 'C047001'
				WHERE 
					t028.Org_Id = var_Org_Id
					AND t028.Voucher_Id = var_Invoice_Id
					group by t006.MPPIType_Id;
                    
				set LossAmount =0;
			end if;
            
                
			set TotalAmount = round(COALESCE(CommissionAmount,0)) + round(COALESCE(LossAmount,0));
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
            
            if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
				UPDATE t028_invoice_mcc t028
				SET t028.Is_Posted = 4
				WHERE t028.Org_Id = var_Org_Id
				AND t028.Voucher_Id = var_Invoice_Id;
           end if;
            
            select 
			CASE
				WHEN m005.MCCWorkType_Id = 'C023001' THEN '4Q'
				WHEN m005.MCCWorkType_Id = 'C023002' THEN '6H'
				ELSE ''
			END as WithholdingTaxType,
			'INR' as DocumentCurrency,
			CASE
				WHEN m005.MCCWorkType_Id = 'C023001' THEN '4Q'
				WHEN m005.MCCWorkType_Id = 'C023002' THEN '6H'
				ELSE ''
			END as WithholdingTaxCode,
			round(abs(TotalAmount)) as WithholdingTaxBaseAmount
			FROM t028_invoice_mcc t028
			inner join m005_mcc m005 on m005.Org_Id = t028.Org_Id
			and m005.MCC_Id = t028.MCC_Id
			where
			t028.Org_Id = var_Org_Id
			AND t028.Voucher_Id = var_Invoice_Id;
        end;
	elseif (var_Method_Name = 'GetIncomeError') then
		begin
		DECLARE Creditor_Debtor varchar(50);
        
        SELECT m005.MCC_Code  into Creditor_Debtor FROM t028_invoice_mcc t028
		inner join  m005_mcc m005 on m005.Org_Id = t028.Org_Id 
			and m005.MCC_Id = t028.MCC_Id 
		where t028.Org_Id = var_Org_Id 
		and t028.Voucher_Id = var_Invoice_Id;
        
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
	elseif (var_Method_Name = 'GetDeductionError') then
		begin
        
			SELECT 
            Request_Body,
            Response_Body
			FROM l002_sapapilog
			WHERE Response_Code = '500'
			AND Transaction_Name = 'SOAP'
            and Org_Id = var_Org_Id
			AND Request_Body LIKE CONCAT('%<DocumentReferenceID>',var_Invoice_Id,'%</DocumentReferenceID>%')
			order by Entry_Date desc limit 1;

        end;
	elseif (var_Method_Name = 'Lock') then
		begin
			declare Is_Locked varchar(255);
            DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
            
            set Is_Locked = '';

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if((var_MCCType_Id is not null or var_MCCType_Id <> '') and (var_MCC_Id is null or var_MCC_Id = ''))then
				
                set Is_Locked = (SELECT COUNT(*) 
					FROM (
						SELECT 
							t009.MusterCycle_StartDate, 
							t009.MusterCycle_EndDate
						FROM 
							t009_milkcollectiondairy_mcccommission t009
						inner join m005_mcc m005 on 
							m005.Org_Id = t009.Org_Id
							and m005.MCC_Id = t009.MCC_Id
							and MCCType_Id = var_MCCType_Id
						WHERE 
							t009.MilkCollectionDairy_Id IN (
								SELECT MilkCollectionDairy_Id 
								FROM t009_milkcollectiondairy_header 
								WHERE DATE(Created_On) >= DATE(var_StartDate)
								  AND DATE(Created_On) <= DATE(var_EndDate)
							)
						-- and t009.Is_Check = 0
						GROUP BY 
							t009.MusterCycle_StartDate, 
							t009.MusterCycle_EndDate
					) AS DistinctDates);
                    
			if(Is_Locked = 0)then
					set Is_Locked = 1;
                end if;
			
			elseif((var_MCCType_Id is not null or var_MCCType_Id <> '') and (var_MCC_Id is not null or var_MCC_Id <> ''))then
				
				set Is_Locked = (SELECT COUNT(*)
					FROM (
						SELECT 
							MusterCycle_StartDate, 
							MusterCycle_EndDate
						FROM 
							t009_milkcollectiondairy_mcccommission
						WHERE 
							MCC_Id = var_MCC_Id
							AND MilkCollectionDairy_Id IN (
								SELECT MilkCollectionDairy_Id 
								FROM t009_milkcollectiondairy_header 
								WHERE DATE(Created_On) >= DATE(var_StartDate)
								  AND DATE(Created_On) <= DATE(var_EndDate)
							)
						GROUP BY 
							MusterCycle_StartDate, 
							MusterCycle_EndDate
					) AS DistinctDates);
			
            if(Is_Locked = 0)then
					set Is_Locked = 1;
                end if;
                
			elseif((var_MCCType_Id is  null or var_MCCType_Id = '') and (var_MCC_Id is null or var_MCC_Id = ''))then
				
				set Is_Locked = 1;
                
			else 
            
			set Is_Locked = 1;
            
			end if;
            
            /*
            if(var_MCC_Id is null or var_MCC_Id = '')then
            
				select 1 as Is_Locked;
                
            else
				SELECT COUNT(*) into Is_Locked
					FROM (
						SELECT 
							MusterCycle_StartDate, 
							MusterCycle_EndDate
						FROM 
							t009_milkcollectiondairy_mcccommission
						WHERE 
							MCC_Id = var_MCC_Id
							AND MilkCollectionDairy_Id IN (
								SELECT MilkCollectionDairy_Id 
								FROM t009_milkcollectiondairy_header 
								WHERE DATE(Created_On) >= DATE(var_StartDate)
								  AND DATE(Created_On) <= DATE(var_EndDate)
							)
						GROUP BY 
							MusterCycle_StartDate, 
							MusterCycle_EndDate
					) AS DistinctDates;
            end if;
            
            if(Is_Locked = '' or Is_Locked is null) then
            
				set Is_Locked = 1;
			end if;
			*/
            /*
             if(Is_Locked = '' or Is_Locked is null) then
            
				set Is_Locked = 1;
			end if;
            */
            select Is_Locked;
		
			
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
