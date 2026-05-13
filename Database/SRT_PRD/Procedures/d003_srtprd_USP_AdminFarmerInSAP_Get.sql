-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerInSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerInSAP_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_Invoice_Id varchar(20),
    var_ApprovalStatus_Id varchar(2),
    var_MCC_Id varchar(20),
    var_MCCType_Id varchar(20),
    var_MCCWorkType_Id varchar(20),
    var_Farmer_Id varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then  
			begin
				select
				t027.Voucher_Id as Invoice_Id,t027.Invoice_No,
				DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
                ifnull(t027.Income_SAP_Document_Id,'')  as Income_Document,
				ifnull(t027.Deduction_SAP_Document_Id,'')  as Deduction_Document,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t027.Invoice_Amount as Amount,
				t027.Is_InvoicePosted as Is_Posted,
				t027.Is_IncomePosted as Is_IncomePosted,
				t027.Is_DeductionPosted as Is_DeductionPosted
				FROM t027_invoice_farmer t027
				Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t027.Farmer_Id 
				and  mu04.Org_Id = t027.Org_Id
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
				and  m005.Org_Id = t027.Org_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				where  t027.Org_Id = var_Org_Id
				-- and t027.Invoice_Date <= var_Date
                and t027.Invoice_Date = var_Date
				and t027.Is_IncomePosted = var_ApprovalStatus_Id

				union all

				select
				t027.Voucher_Id as Invoice_Id,t027.Invoice_No,
				DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
                ifnull(t027.Income_SAP_Document_Id,'')  as Income_Document,
				ifnull(t027.Deduction_SAP_Document_Id,'')  as Deduction_Document,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t027.Invoice_Amount as Amount,
				t027.Is_InvoicePosted as Is_Posted,
				t027.Is_IncomePosted as Is_IncomePosted,
				t027.Is_DeductionPosted as Is_DeductionPosted
				FROM t027_invoice_farmer t027
				Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t027.Farmer_Id 
				and  mu04.Org_Id = t027.Org_Id
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
				and  m005.Org_Id = t027.Org_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				where  t027.Org_Id = var_Org_Id
				and t027.Invoice_Date = var_Date
				and t027.Is_IncomePosted = var_ApprovalStatus_Id

				union all

				select
				t027.Voucher_Id as Invoice_Id,t027.Invoice_No,
				DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
                ifnull(t027.Income_SAP_Document_Id,'')  as Income_Document,
				ifnull(t027.Deduction_SAP_Document_Id,'')  as Deduction_Document,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t027.Invoice_Amount as Amount,
				t027.Is_InvoicePosted as Is_Posted,
				t027.Is_IncomePosted as Is_IncomePosted,
				t027.Is_DeductionPosted as Is_DeductionPosted
				FROM t027_invoice_farmer t027
				Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t027.Farmer_Id 
				and  mu04.Org_Id = t027.Org_Id
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
				and  m005.Org_Id = t027.Org_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				and m005.MCCType_Id in('C014003')
				where  t027.Org_Id = var_Org_Id
				and t027.Invoice_Date = var_Date
				and t027.Is_IncomePosted = var_ApprovalStatus_Id


				union all

				select
				t027.Voucher_Id as Invoice_Id,
				t027.Invoice_No,
				DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				m005.MCC_Id as Farmer_Id,
				m005.MCC_Name as Farmer_Name,
				m005.MCC_Code as Farmer_Code, 
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
                ifnull(t027.Income_SAP_Document_Id,'')  as Income_Document,
				ifnull(t027.Deduction_SAP_Document_Id,'')  as Deduction_Document,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t027.Invoice_Amount as Amount,
				t027.Is_InvoicePosted as Is_Posted,
				t027.Is_IncomePosted as Is_IncomePosted,
				t027.Is_DeductionPosted as Is_DeductionPosted
				FROM t027_invoice_farmer t027
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
				and  m005.Org_Id = t027.Org_Id
				and m005.MCC_Id = t027.Farmer_Id 
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				where  t027.Org_Id = var_Org_Id
				and t027.Invoice_Date = var_Date
				and t027.Is_IncomePosted = var_ApprovalStatus_Id

				union all

				select
				t027.Voucher_Id as Invoice_Id,
				t027.Invoice_No,
				DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				m005.MCC_Id as Farmer_Id,
				m005.MCC_Name as Farmer_Name,
				m005.MCC_Code as Farmer_Code, 
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
                ifnull(t027.Income_SAP_Document_Id,'')  as Income_Document,
				ifnull(t027.Deduction_SAP_Document_Id,'')  as Deduction_Document,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t027.Invoice_Amount as Amount,
				t027.Is_InvoicePosted as Is_Posted,
				t027.Is_IncomePosted as Is_IncomePosted,
				t027.Is_DeductionPosted as Is_DeductionPosted
				FROM t027_invoice_farmer t027
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
				and  m005.Org_Id = t027.Org_Id
				and m005.MCC_Id = t027.Farmer_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				and m005.MCCType_Id in('C014003')
				where  t027.Org_Id = var_Org_Id
				and t027.Invoice_Date = var_Date
				and t027.Is_IncomePosted = var_ApprovalStatus_Id;
                
			end;
            
		elseif (var_Method_Name = 'Get_One') then  
			begin
				SELECT 
					t027.Voucher_Id as Invoice_Id,t027.Invoice_No,
					t027.Invoice_Amount as Amount,
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id,m005.MCC_Name,m005.MCC_Code
				FROM t027_invoice_farmer t027
				Inner Join mu04_farmer mu04 on mu04.Farmer_Id = t027.Farmer_Id
                and mu04.Org_Id = t027.Org_Id
				Inner Join m005_mcc m005 on m005.MCC_Id = t027.MCC_Id
                and m005.Org_Id = t027.Org_Id
				where t027.Org_Id = var_Org_Id
                and t027.Voucher_Id = var_Invoice_Id;

			end;
		elseif (var_Method_Name = 'Get_Generate') then  
			begin
                DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
                
                select MCC_Id 
				into @MCC_Id
				from m005_mcc where 
				Org_Id = var_Org_Id
				and MCC_Id like var_MCC_Id
				and MCCType_Id like var_MCCType_Id limit 1;
                
                select MCCType_Id,MCCWorkType_Id 
				into @MCCType_Id ,@MCCWorkType_Id 
				from m005_mcc where 
				Org_Id = var_Org_Id
				and MCC_Id like var_MCC_Id
				and MCCType_Id like var_MCCType_Id limit 1;
                
                   
                if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = @MCC_Id ) then
					
                    if(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then 
                    
						SELECT * FROM (
						SELECT 
							t005.FarmerCollection_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							ROUND(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0), 2) as Amount,
							concat(
							c011.MilkType_Name,
							' | Qty : ',
							t005.Quantity_Ltr,
							' Ltr | Fat : ',
							t005.Fat,
							'% | SNF : ',
							t005.SNF,
							'% | Rate : ₹',
							t005.ApplicableRate
							) as Particulars,
							t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
							DATE_FORMAT(t005.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
							'Milk Deposit'  as Entry_Type,
							'0' as Is_Voucher 
						FROM t005_milkcollectionfarmer t005
						-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
						and t004.MCC_Id = t005.MCC_Id
						and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
						-- and t006.MCC_Id = t005.MCC_Id
						-- and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                        Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
						Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
						and m005.MCC_Id = t005.MCC_Id
						and m005.MCCType_Id like var_MCCType_Id
                        and m005.MCCWorkType_Id like var_MCCWorkType_Id
						and m005.MCCType_Id in('C014001','C014002')
						and m005.MCCWorkType_Id = 'C023002'
						and m005.MCC_Id like var_MCC_Id
						Inner Join c011_milktype c011 on c011.MilkType_Id = t005.MilkType_Id
						where t005.Org_Id = var_Org_Id
						and CAST(t005.Created_On  AS DATE) >= var_StartDate 
						and CAST(t005.Created_On  AS DATE)  <= var_EndDate
						and  t005.Is_InvoiceCreated = 0 
						and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
						and t005.Is_Check = 0
						
						union all
						
						SELECT 
							t0331.Entry_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							t0331.Deduction_Amount as Amount,
							concat(
							' ( ',
							 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
							' - ',
							ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
							' )'
							) as Particulars,
							var_StartDate as StartDate,var_EndDate as EndDate,
							DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							 CASE
								WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
								WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
								WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
								WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
								WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
								WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
								ELSE ''
							  END AS Entry_Type,
							  '1' as Is_Voucher 
							FROM t033_deductions_header t033
							inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
							and  t0331.Deductions_Id = t033.Deductions_Id 
							and  t0331.Is_Deducted = 0 
							AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
							and t0331.Deduction_Amount <> 0
							and t0331.Is_Check = 0
							and t0331.Is_InvoiceCreated =0
							and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
							inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
							and  mu04.Farmer_Id = t033.Request_User_Id 
							inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
							and  m005.MCC_Id = mu04.MCC_Id 
							and m005.MCCType_Id like var_MCCType_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							and m005.MCC_Id like var_MCC_Id
							where t033.Org_Id  = var_Org_Id
							and t033.Request_User_Type  ='Farmer'
						  
							) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
                            
                    end if;
                else
					
					if(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023002')then 
					SELECT * FROM (
					SELECT 
						t005.FarmerCollection_Id as Check_Id,
						mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
						m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
						ROUND(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0), 2) as Amount,
						concat(
						c011.MilkType_Name,
						' | Qty : ',
						t005.Quantity_Ltr,
						' Ltr | Fat : ',
						t005.Fat,
						'% | SNF : ',
						t005.SNF,
						'% | Rate : ₹',
						t005.ApplicableRate
						) as Particulars,
						t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
						DATE_FORMAT(t005.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
						'Milk Deposit'  as Entry_Type,
						'0' as Is_Voucher 
					FROM t005_milkcollectionfarmer t005
					-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
					-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
					Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
					and t004.MCC_Id = t005.MCC_Id
					and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
					Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
					and t006.MCC_Id = t005.MCC_Id
					and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                    Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                    and mu04.MCC_Id = t005.MCC_Id
                    and mu04.Farmer_Id = t005.Farmer_Id
					Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
					and m005.MCC_Id = t005.MCC_Id
					and m005.MCCType_Id like var_MCCType_Id
                    and m005.MCCWorkType_Id like var_MCCWorkType_Id
					and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023002'
					Inner Join c011_milktype c011 on c011.MilkType_Id = t005.MilkType_Id
					where t005.Org_Id = var_Org_Id
                    and t005.MCC_Id like var_MCC_Id
					and CAST(t005.Created_On  AS DATE) >= var_StartDate 
					and CAST(t005.Created_On  AS DATE)  <= var_EndDate
					and  t005.Is_InvoiceCreated = 0 
					and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
					and t005.Is_Check = 0
					
					union all
					
					SELECT 
						t0331.Entry_Id as Check_Id,
						mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
						m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
						t0331.Deduction_Amount as Amount,
						concat(
						' ( ',
						 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
						' - ',
						ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
						' )'
						) as Particulars,
						var_StartDate as StartDate,var_EndDate as EndDate,
						DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
						 CASE
							WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
							WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
							WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
							WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
							WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
							WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
							ELSE ''
						  END AS Entry_Type,
						  '1' as Is_Voucher 
						FROM t033_deductions_header t033
						inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
						and  t0331.Deductions_Id = t033.Deductions_Id 
						and  t0331.Is_Deducted = 0 
						AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
						and t0331.Deduction_Amount <> 0
						and t0331.Is_Check = 0
						and t0331.Is_InvoiceCreated =0
						and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
						inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
						and  mu04.Farmer_Id = t033.Request_User_Id 
						inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
						and  m005.MCC_Id = mu04.MCC_Id 
						and m005.MCCType_Id like var_MCCType_Id
                        and m005.MCCWorkType_Id like var_MCCWorkType_Id
						and m005.MCC_Id like var_MCC_Id
						where t033.Org_Id  = var_Org_Id
						and t033.Request_User_Type  ='Farmer'
						
						) AS subquery
						ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
                    
				elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then 
					
						SELECT * FROM (
						SELECT 
							t005.FarmerCollection_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							ROUND(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0), 2) as Amount,
							concat(
							c011.MilkType_Name,
							' | Qty : ',
							t005.Quantity_Ltr,
							' Ltr | Fat : ',
							t005.Fat,
							'% | SNF : ',
							t005.SNF,
							'% | Rate : ₹',
							t005.ApplicableRate
							) as Particulars,
							t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
							DATE_FORMAT(t005.Created_On, '%d %b %Y %h:%i %p') AS Entry_On,
							'Milk Deposit'  as Entry_Type,
							'0' as Is_Voucher 
						FROM t005_milkcollectionfarmer t005
						-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
						and t004.MCC_Id = t005.MCC_Id
						and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
						Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
						and t006.MCC_Id = t005.MCC_Id
						and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                        Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
						Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
						and m005.MCC_Id = t005.MCC_Id
						and m005.MCCType_Id like var_MCCType_Id
                        and m005.MCCWorkType_Id like var_MCCWorkType_Id
						and m005.MCCType_Id in('C014001','C014002')
						and m005.MCCWorkType_Id = 'C023002'
						and m005.MCC_Id like var_MCC_Id
						Inner Join c011_milktype c011 on c011.MilkType_Id = t005.MilkType_Id
						where t005.Org_Id = var_Org_Id
						and CAST(t005.Created_On  AS DATE) >= var_StartDate 
						and CAST(t005.Created_On  AS DATE)  <= var_EndDate
						and  t005.Is_InvoiceCreated = 0 
						and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
						and t005.Is_Check = 0
						
						union all
						
						SELECT 
							t0331.Entry_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							t0331.Deduction_Amount as Amount,
							concat(
							' ( ',
							 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
							' - ',
							ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
							' )'
							) as Particulars,
							var_StartDate as StartDate,var_EndDate as EndDate,
							DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							 CASE
								WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
								WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
								WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
								WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
								WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
								WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
								ELSE ''
							  END AS Entry_Type,
							  '1' as Is_Voucher 
							FROM t033_deductions_header t033
							inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
							and  t0331.Deductions_Id = t033.Deductions_Id 
							and  t0331.Is_Deducted = 0 
							AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
							and t0331.Deduction_Amount <> 0
							and t0331.Is_Check = 0
							and t0331.Is_InvoiceCreated =0
							and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
							inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
							and  mu04.Farmer_Id = t033.Request_User_Id 
							inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
							and  m005.MCC_Id = mu04.MCC_Id 
							and m005.MCCType_Id like var_MCCType_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							and m005.MCC_Id like var_MCC_Id
							where t033.Org_Id  = var_Org_Id
							and t033.Request_User_Type  ='Farmer'
						  
							) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
				elseif(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023001')then 
                
						SELECT * FROM (
						SELECT 
							t0331.Entry_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							t0331.Deduction_Amount as Amount,
							concat(
							' ( ',
							 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
							' - ',
							ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
							' )'
							) as Particulars,
							var_StartDate as StartDate,var_EndDate as EndDate,
							DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							 CASE
								WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
								WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
								WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
								WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
								WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
								WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
								ELSE ''
							  END AS Entry_Type,
							  '1' as Is_Voucher 
							FROM t033_deductions_header t033
							inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
							and  t0331.Deductions_Id = t033.Deductions_Id 
							and  t0331.Is_Deducted = 0 
							AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
							and t0331.Deduction_Amount <> 0
							and t0331.Is_Check = 0
							and t0331.Is_InvoiceCreated =0
							and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
							inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
							and  mu04.Farmer_Id = t033.Request_User_Id 
							inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
							and  m005.MCC_Id = mu04.MCC_Id 
							and m005.MCCType_Id like var_MCCType_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							and m005.MCC_Id like var_MCC_Id
							where t033.Org_Id  = var_Org_Id
							and t033.Request_User_Type  ='Farmer'
							
							union all
							
							SELECT 
								f010.Entry_Id as Check_Id,
								m005.MCC_Id as Farmer_Id,
								m005.MCC_Name as Farmer_Name,
								m005.MCC_Code as Farmer_Code,
								m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
								ifnull(f010.MilkPrice,0) as Amount,
								concat(
								c011.MilkType_Name,
								' | Qty : ',
								f010.Dairy_Quantity_Ltr,
								' Ltr | Fat : ',
								f010.Dairy_Fat,
								'% | SNF : ',
								f010.Dairy_SNF,
								'% | Rate : ₹',
								f010.MilkRate
								) as Particulars,
								var_StartDate as StartDate,
								var_EndDate as EndDate,
								DATE_FORMAT(f010.Collection_Date, '%d %b %Y %h:%i %p') AS Entry_On,
								'Milk Deposit'  as Entry_Type,
								'0' as Is_Voucher 
							FROM f010_milkcollectionmcc_final f010
                            Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
							and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
							Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
							and m005.MCC_Id = f010.MCC_Id
							and m005.MCCType_Id like var_MCCType_Id
							and m005.MCCType_Id in('C014001','C014002')
							and m005.MCCWorkType_Id = 'C023001'
							and m005.MCC_Id like var_MCC_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							Inner Join c011_milktype c011 on c011.MilkType_Id = f010.MilkType_Id
							where f010.Org_Id = var_Org_Id
                            and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
							and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
							and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
							and  f010.Is_OutsideInvoiceCreated = 0 
							and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
							and f010.Is_OutsideCheck = 0
						  
							) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
                            
				elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023001')then 
                
						SELECT * FROM (
						SELECT 
							t0331.Entry_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							t0331.Deduction_Amount as Amount,
							concat(
							' ( ',
							 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
							' - ',
							ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
							' )'
							) as Particulars,
							var_StartDate as StartDate,var_EndDate as EndDate,
							DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							 CASE
								WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
								WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
								WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
								WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
								WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
								WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
								ELSE ''
							  END AS Entry_Type,
							  '1' as Is_Voucher 
							FROM t033_deductions_header t033
							inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
							and  t0331.Deductions_Id = t033.Deductions_Id 
							and  t0331.Is_Deducted = 0 
							AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
							and t0331.Deduction_Amount <> 0
							and t0331.Is_Check = 0
							and t0331.Is_InvoiceCreated =0
							and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
							inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
							and  mu04.Farmer_Id = t033.Request_User_Id 
							inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
							and  m005.MCC_Id = mu04.MCC_Id 
							and m005.MCCType_Id like var_MCCType_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							and m005.MCC_Id like var_MCC_Id
							where t033.Org_Id  = var_Org_Id
							and t033.Request_User_Type  ='Farmer'
							
							union all
							
							SELECT 
								f010.Entry_Id as Check_Id,
								m005.MCC_Id as Farmer_Id,
								m005.MCC_Name as Farmer_Name,
								m005.MCC_Code as Farmer_Code,
								m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
								ifnull(f010.MilkPrice,0) as Amount,
								concat(
								c011.MilkType_Name,
								' | Qty : ',
								f010.Dairy_Quantity_Ltr,
								' Ltr | Fat : ',
								f010.Dairy_Fat,
								'% | SNF : ',
								f010.Dairy_SNF,
								'% | Rate : ₹',
								f010.MilkRate
								) as Particulars,
								var_StartDate as StartDate,
								var_EndDate as EndDate,
								DATE_FORMAT(f010.Collection_Date, '%d %b %Y %h:%i %p') AS Entry_On,
								'Milk Deposit'  as Entry_Type,
								'0' as Is_Voucher 
							FROM f010_milkcollectionmcc_final f010
                            Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
							and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
							Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
							and m005.MCC_Id = f010.MCC_Id
							and m005.MCCType_Id like var_MCCType_Id
							and m005.MCCType_Id in('C014001','C014002')
							and m005.MCCWorkType_Id = 'C023001'
							and m005.MCC_Id like var_MCC_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							Inner Join c011_milktype c011 on c011.MilkType_Id = f010.MilkType_Id
							where f010.Org_Id = var_Org_Id
                            and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
							and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
							and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
							and  f010.Is_OutsideInvoiceCreated = 0 
							and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
							and f010.Is_OutsideCheck = 0
						  
							) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
                            
				elseif(@MCCType_Id = 'C014003')then 
             
						SELECT * FROM (
						SELECT 
							t0331.Entry_Id as Check_Id,
							mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							t0331.Deduction_Amount as Amount,
							concat(
							' ( ',
							 ifnull(DATE_FORMAT(var_StartDate, '%d'),''),
							' - ',
							ifnull(DATE_FORMAT(var_EndDate, '%d'),''),
							' )'
							) as Particulars,
							var_StartDate as StartDate,var_EndDate as EndDate,
							DATE_FORMAT(t0331.Deduction_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							 CASE
								WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan - ICICI'
								WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan - Society'
								WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
								WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
								WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
								WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
								ELSE ''
							  END AS Entry_Type,
							  '1' as Is_Voucher 
							FROM t033_deductions_header t033
							inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
							and  t0331.Deductions_Id = t033.Deductions_Id 
							and  t0331.Is_Deducted = 0 
							AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
							and t0331.Deduction_Amount <> 0
							and t0331.Is_Check = 0
							and t0331.Is_InvoiceCreated =0
							and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
							inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
							and  mu04.Farmer_Id = t033.Request_User_Id 
							inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
							and  m005.MCC_Id = mu04.MCC_Id 
							and m005.MCCType_Id like var_MCCType_Id
                            and m005.MCCWorkType_Id like var_MCCWorkType_Id
							and m005.MCC_Id like var_MCC_Id
							where t033.Org_Id  = var_Org_Id
							and t033.Request_User_Type  ='Farmer'
							
							union all
							
							SELECT 
							f010.Entry_Id as Check_Id,
							m005.MCC_Id as Farmer_Id,
							m005.MCC_Name as Farmer_Name,
							m005.MCC_Code as Farmer_Code,
							m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
							ifnull(f010.MilkPrice, 0) as Amount,
							concat(
							c011.MilkType_Name,
							' | Qty : ',
							f010.Dairy_Quantity_Ltr,
							' Ltr | Fat : ',
							f010.Dairy_Fat,
							'% | SNF : ',
							f010.Dairy_SNF,
							'% | Rate : ₹',
							f010.MilkRate
							) as Particulars,
							var_StartDate as StartDate,
							var_EndDate as EndDate,
							DATE_FORMAT(f010.Collection_Date, '%d %b %Y %h:%i %p') AS Entry_On,
							'Milk Deposit'  as Entry_Type,
							'0' as Is_Voucher 
						FROM f010_milkcollectionmcc_final f010
                        Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
						and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
						Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
						and m005.MCC_Id = f010.MCC_Id
						and m005.MCCType_Id like var_MCCType_Id
						and m005.MCCType_Id in('C014003')
						and m005.MCC_Id like var_MCC_Id
                        and m005.MCCWorkType_Id like var_MCCWorkType_Id
						Inner Join c011_milktype c011 on c011.MilkType_Id = f010.MilkType_Id
						where f010.Org_Id = var_Org_Id
                        and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
						and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
						and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
						and  f010.Is_OutsideInvoiceCreated = 0 
						and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
						and f010.Is_OutsideCheck = 0
						  
							) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
                
                end if;
                
                end if; 
                
                
			end;
		
        elseif (var_Method_Name = 'Get_GenerateSum') then  
			begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
                
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            /*
            DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer;
			CREATE TEMPORARY TABLE temp_anamat_farmer ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_anamat_farmer (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				 m0051.Org_Id,
				 m0051.MCC_Id,
                 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
                 m0051.Anamat_Applicable_To,
                 m0051.Freight_Applicable_To,
                 m0051.Anamat_PerLtr,m0051.Freight_PerLtr
			 FROM 
				 m005_mcc_version m0051
			Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
			and m005.MCC_Id = m0051.MCC_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCC_Id like var_MCC_Id
			 WHERE 
				 m0051.Org_Id = var_Org_Id
				 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
			 GROUP BY 
				 m0051.Org_Id, m0051.MCC_Id,
                 m0051.Anamat_Applicable_To,
                 m0051.Freight_Applicable_To,
                 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
                 
			
			DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer;
			CREATE TEMPORARY TABLE temp_freight_farmer ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_freight_farmer (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				 m0051.Org_Id,
				 m0051.MCC_Id,
                 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
                 m0051.Anamat_Applicable_To,
                 m0051.Freight_Applicable_To,
                 Anamat_PerLtr,Freight_PerLtr
			 FROM 
				 m005_mcc_version m0051
			Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
			and m005.MCC_Id = m0051.MCC_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCC_Id like var_MCC_Id
			 WHERE 
				 m0051.Org_Id = var_Org_Id
				 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
			 GROUP BY 
				 m0051.Org_Id, m0051.MCC_Id,
                 m0051.Anamat_Applicable_To,
                 m0051.Freight_Applicable_To,
                 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
			*/
            
            			DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer_1;
			CREATE TEMPORARY TABLE temp_anamat_farmer_1 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_anamat_farmer_1 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;




			DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer_2;
			CREATE TEMPORARY TABLE temp_anamat_farmer_2 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_anamat_farmer_2 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;




			DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer_3;
			CREATE TEMPORARY TABLE temp_anamat_farmer_3 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_anamat_farmer_3 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;

                 
			
			DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer_1;
			CREATE TEMPORARY TABLE temp_freight_farmer_1 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_freight_farmer_1 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;

				
			DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer_2;
			CREATE TEMPORARY TABLE temp_freight_farmer_2 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_freight_farmer_2 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
			SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;



			DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer_3;
			CREATE TEMPORARY TABLE temp_freight_farmer_3 ( 
			Org_Id varchar(20), MCC_Id varchar(20), 
            Max_Applicable_Date varchar(20),
            Anamat_Applicable_To varchar(20),
            Freight_Applicable_To varchar(20),
            Anamat_PerLtr decimal(8,2),
			Freight_PerLtr decimal(8,2)
            );
			
			Insert into temp_freight_farmer_3 (
			Org_Id,MCC_Id,
            Max_Applicable_Date,
            Anamat_Applicable_To,
            Freight_Applicable_To,
            Anamat_PerLtr,Freight_PerLtr
			)
						SELECT 
				m0051.Org_Id,
				m0051.MCC_Id,
				m0051.Applicable_Date AS Max_Applicable_Date,
				m0051.Anamat_Applicable_To,
				m0051.Freight_Applicable_To,
				m0051.Anamat_PerLtr,
				m0051.Freight_PerLtr
			FROM 
				m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.Org_Id = m0051.Org_Id 
				AND m005.MCC_Id = m0051.MCC_Id
                and m0051.Is_Deleted = 0
			INNER JOIN (
				SELECT 
					Org_Id,
					MCC_Id,
					MAX(Applicable_Date) AS Max_Applicable_Date
				FROM 
					m005_mcc_version
				WHERE 
					Org_Id = var_Org_Id
                    and Is_Deleted = 0
					AND Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				GROUP BY 
					Org_Id,
					MCC_Id
			) sub ON m0051.Org_Id = sub.Org_Id
				AND m0051.MCC_Id = sub.MCC_Id
				AND m0051.Applicable_Date = sub.Max_Applicable_Date
			ORDER BY 
				m0051.Applicable_Date DESC;

                 
			select MCC_Id 
				into @MCC_Id
				from m005_mcc where 
				Org_Id = var_Org_Id
				and MCC_Id like var_MCC_Id
				and MCCType_Id like var_MCCType_Id limit 1;
                
			if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = @MCC_Id ) then
            
				SELECT * FROM (
                
				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				-- and t006.MCC_Id = t005.MCC_Id
				-- and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
                
				union all
                
				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					round(sum(t0331.Deduction_Amount)) as Amount,
					-- 0 as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate , '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					CASE
					WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
					WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
					WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
					WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
					ELSE ''
					END AS Entry_Type,
					'1' as Is_Voucher 
				FROM t033_deductions_header t033
				inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
				and  t0331.Deductions_Id = t033.Deductions_Id 
				and  t0331.Is_Deducted = 0 
				AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				and t0331.Deduction_Amount <> 0
				and t0331.Is_Check = 0
				and t0331.Is_InvoiceCreated =0
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
				and  mu04.Farmer_Id = t033.Request_User_Id 
				inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
				and  m005.MCC_Id = mu04.MCC_Id 
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				where t033.Org_Id  = var_Org_Id
				and t033.Request_User_Type  ='Farmer'
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t033.Request_Type
				-- t0331.MusterCycle_StartDate,
				-- t0331.MusterCycle_EndDate 

				union all

                SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(max_dates.Anamat_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Anamat'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				-- and t006.MCC_Id = t005.MCC_Id
				-- and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
                INNER JOIN 
						temp_anamat_farmer_1 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Anamat_Applicable_To = 'Farmer'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate,
                max_dates.Anamat_PerLtr

				union all

				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(max_dates.Freight_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Freight'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				-- and t006.MCC_Id = t005.MCC_Id
				-- and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
                INNER JOIN 
						temp_freight_farmer_1 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Freight_Applicable_To = 'Farmer'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate,
                max_dates.Freight_PerLtr
                
				union all
                    
                SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Ltr'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				and m005.MCC_Id like var_MCC_Id
				where t005.Org_Id = var_Org_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
				) AS subquery
							ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
							
                
			else
				SELECT * FROM (
				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				and t006.MCC_Id = t005.MCC_Id
				and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
                
				union all
                
				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					round(sum(t0331.Deduction_Amount)) as Amount,
					-- 0 as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate , '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					CASE
					WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
					WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
					WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
					WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
					ELSE ''
					END AS Entry_Type,
					'1' as Is_Voucher 
				FROM t033_deductions_header t033
				inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
				and  t0331.Deductions_Id = t033.Deductions_Id 
				and  t0331.Is_Deducted = 0 
				AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				and t0331.Deduction_Amount <> 0
				and t0331.Is_Check = 0
				and t0331.Is_InvoiceCreated =0
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
				and  mu04.Farmer_Id = t033.Request_User_Id 
				inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
				and  m005.MCC_Id = mu04.MCC_Id 
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				where t033.Org_Id  = var_Org_Id
				and t033.Request_User_Type  ='Farmer'
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t033.Request_Type
				-- t0331.MusterCycle_StartDate,
				-- t0331.MusterCycle_EndDate 

				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code

				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
                
                /*
                union all
				
                select 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					Anamat_PerLtr as Amount,
					0 as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Anamat'  as Entry_Type,
					'0' as Is_Voucher 
				from m005_mcc m005
				INNER JOIN 
						temp_anamat_farmer max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Anamat_Applicable_To = 'Farmer'
				INNER JOIN 
						m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
												 AND m0051.MCC_Id = max_dates.MCC_Id 
												 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
												 AND m0051.Anamat_Applicable_To = 'Farmer'
				where 
				m005.Org_Id = var_Org_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				
                union all
                
                select 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					Freight_PerLtr as Amount,
					0 as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Freight'  as Entry_Type,
					'0' as Is_Voucher 
				from m005_mcc m005
				INNER JOIN 
						temp_freight_farmer max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Freight_Applicable_To = 'Farmer'
				INNER JOIN 
						m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
												 AND m0051.MCC_Id = max_dates.MCC_Id 
												 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
												 AND m0051.Freight_Applicable_To = 'Farmer'
				where 
				m005.Org_Id = var_Org_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				*/
				
                union all

				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(max_dates.Anamat_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Anamat'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				and t006.MCC_Id = t005.MCC_Id
				and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
                INNER JOIN 
						temp_anamat_farmer_1 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Anamat_Applicable_To = 'Farmer'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate,
                max_dates.Anamat_PerLtr

				union all

				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(max_dates.Freight_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Freight'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
				and t004.MCC_Id = t005.MCC_Id
				and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
				and t006.MCC_Id = t005.MCC_Id
				and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				-- Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.MCC_Id = t005.MCC_Id
                and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
                INNER JOIN 
						temp_freight_farmer_1 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Freight_Applicable_To = 'Farmer'
				where t005.Org_Id = var_Org_Id
                and t005.MCC_Id like var_MCC_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate,
                max_dates.Freight_PerLtr

				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.Dairy_Quantity_Ltr, 0) * IFNULL(max_dates.Anamat_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Anamat'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				INNER JOIN 
						temp_anamat_farmer_2 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Anamat_Applicable_To = 'Farmer'
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				max_dates.Anamat_PerLtr

				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.Dairy_Quantity_Ltr, 0) * IFNULL(max_dates.Freight_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Freight'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				INNER JOIN 
						temp_freight_farmer_2 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Freight_Applicable_To = 'Farmer'
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				max_dates.Freight_PerLtr


				union all
				
				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.Dairy_Quantity_Ltr, 0) * IFNULL(max_dates.Anamat_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Anamat'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				INNER JOIN 
						temp_anamat_farmer_3 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Anamat_Applicable_To = 'Farmer'
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				max_dates.Anamat_PerLtr


				union all
				
				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.Dairy_Quantity_Ltr, 0) * IFNULL(max_dates.Freight_PerLtr, 0) ) )as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Freight'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				INNER JOIN 
						temp_freight_farmer_3 max_dates ON m005.Org_Id = max_dates.Org_Id 
												 AND m005.MCC_Id = max_dates.MCC_Id 
                                                 and max_dates.Freight_Applicable_To = 'Farmer'
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				max_dates.Freight_PerLtr
                
                
				union all

				SELECT 
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Amount,
					-- ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Ltr'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
                and t004.MCC_Id = t005.MCC_Id
                and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id 
                and t006.MCC_Id = t005.MCC_Id
                and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				and m005.MCC_Id like var_MCC_Id
				where t005.Org_Id = var_Org_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
                
				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Amount,
					-- ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Ltr'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
				
				union all

				SELECT 
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Amount,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Ltr'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
                Inner Join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCWorkType_Id like var_MCCWorkType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
                and ifnull(f010.MilkCollectionPosting_Id,'') <> ''
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
                
			) AS subquery
			ORDER BY subquery.Farmer_Name asc, subquery.StartDate asc, subquery.EndDate asc;
          	
            end if ;
            
			
                
            end;
		elseif (var_Method_Name = 'Get_Voucher') then 
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
                DECLARE GLAccount_Freight varchar(255);
                DECLARE Debtor varchar(255);
                DECLARE Creditor varchar(255);
                DECLARE AltvRecnclnAccts_Anamat varchar(255);
                DECLARE AltvRecnclnAccts_Loan varchar(255);
                DECLARE AltvRecnclnAccts_Advance varchar(255);
                DECLARE Creditor_Debtor varchar(50);
                
                set @set_MCC_Id = (select MCC_Id from t027_invoice_farmer
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
									
	
    
				SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
				inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
					and mu04.Farmer_Id = t027.Farmer_Id 
				where t027.Org_Id = var_Org_Id 
				and t027.Voucher_Id = var_Invoice_Id;
                
                Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
                SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
				SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
				SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
				SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
				SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
				SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';

                
                SELECT 
					-- SUM(t005.Quantity_Ltr),
                    -- COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0),
					CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t027_invoice_farmer t027
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
                -- GrossAmount
                
              
                SELECT 
					ifnull(SUM(t005.Quantity_Ltr),0),
                    COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
					-- CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y'))
                    into 
                    Total_Ltr,
                    GrossAmount
                    -- MusterCycle
				FROM t027_invoice_farmer t027
				INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				-- GROUP BY
                    -- t027.MusterCycle_StartDate,t027.MusterCycle_EndDate
                    ;
                    
                   
                    
					
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id AND t033.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
                -- AnamatAmount / FreightAmount
                
                /*
				SELECT 
				COALESCE(ROUND(SUM(IFNULL(m005.Anamat_PerLtr, 0) * IFNULL(Total_Ltr, 0)), 2), 0),
				COALESCE(ROUND(SUM(IFNULL(m005.Freight_PerLtr, 0) * IFNULL(Total_Ltr, 0)), 2), 0) 
                into AnamatAmount, FreightAmount
				 FROM t027_invoice_farmer t027
				INNER JOIN m005_mcc_version m005 ON m005.Org_Id = t027.Org_Id AND m005.MCC_Id = t027.MCC_Id
					and m005.Applicable_Date  >= CONVERT_TZ(NOW(), '+00:00', '+00:00')
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				order by m005.Applicable_Date desc 
				limit 1;
                
                */
                SELECT 
					COALESCE(ROUND(IFNULL(t027.Anamat_PerLtr, 0) * IFNULL(Total_Ltr, 0), 2), 0),
					COALESCE(ROUND(IFNULL(t027.Freight_PerLtr, 0) * IFNULL(Total_Ltr, 0), 2), 0) 
					into AnamatAmount, FreightAmount
					FROM t027_invoice_farmer t027
					WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
					limit 1;
                
                 set TotalAmount =  GrossAmount - PurchaseAmount - AnamatAmount - FreightAmount;
                
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
									<AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n\t\t\t\t\t
									<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n\t\t\t\t\t
									<DocumentHeaderText>Extra Field</DocumentHeaderText>\n\t\t\t\t\t
									<CreatedByUser>CB9980000000</CreatedByUser>\n\t\t\t\t\t
									<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t
									<DocumentDate>',Date,'</DocumentDate>\n\t\t\t\t\t
									<PostingDate>',Date,'</PostingDate>\n\t\t\t\t\t
									<PostingFiscalPeriod></PostingFiscalPeriod>\n\t\t\t\t\t
									<TaxReportingDate>',Date,'</TaxReportingDate>\n\t\t\t\t\t
									<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n\t\t\t\t\t
									<Reference1InDocumentHeader>Extra Field</Reference1InDocumentHeader>\n\t\t\t\t\t
									<Reference2InDocumentHeader>Extra Field</Reference2InDocumentHeader>\n\t\t\t\t\t');
			
							IF GrossAmount IS NOT NULL AND GrossAmount != '' AND GrossAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n\t\t\t\t\t\t
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
									<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t\t
									<GLAccount>',GLAccount_Gross,'</GLAccount>\n\t\t\t\t\t\t
									<AmountInTransactionCurrency currencyCode=\"INR\">',GrossAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
									<DebitCreditCode>S</DebitCreditCode>\n\t\t\t\t\t\t
									<DocumentItemText>Milk Payment ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
									<BusinessPlace></BusinessPlace>\n\t\t\t\t\t\t
									<AccountAssignment>\n\t\t\t\t\t\t\t
                                    <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n\t\t\t\t\t\t\t
										<CostCenter></CostCenter>\n\t\t\t\t\t\t
									</AccountAssignment>\n\t\t\t\t\t
								</Item>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF FreightAmount IS NOT NULL AND FreightAmount != '' AND FreightAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t\t
										<GLAccount>',GLAccount_Freight,'</GLAccount>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',FreightAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
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
										<AmountInTransactionCurrency currencyCode=\"INR\">-',PurchaseAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DocumentItemText>Purchase from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t
									</DebtorItem>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
                            END IF;
                            
                            IF AnamatAmount IS NOT NULL AND AnamatAmount != '' AND AnamatAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',AnamatAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', AltvRecnclnAccts_Anamat, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Anamat from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner>Ref1</Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner>Ref2</Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner>Ref3</Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
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
										<AmountInTransactionCurrency currencyCode=\"INR\">-',TotalAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts></AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Milk Payment from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
										<AssignmentReference></AssignmentReference>\n\t\t\t\t\t\t
										<Reference1IDByBusinessPartner>Ref1</Reference1IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference2IDByBusinessPartner>Ref2</Reference2IDByBusinessPartner>\n\t\t\t\t\t\t
										<Reference3IDByBusinessPartner>Ref3</Reference3IDByBusinessPartner>\n\t\t\t\t\t\t
										<DownPaymentTerms>\n\t\t\t\t\t\t\t
											<SpecialGLCode></SpecialGLCode>\n\t\t\t\t\t\t
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
		elseif (var_Method_Name = 'Get_Voucher_Deductions') then 
			begin
				DECLARE Total_Ltr decimal(30,3);
                DECLARE GrossAmount decimal(30,2);
                DECLARE PurchaseAmount decimal(30,2);
                DECLARE CattleFeed decimal(30,2);
                DECLARE AnamatAmount decimal(30,2);
                DECLARE FreightAmount decimal(30,2);
				DECLARE To_Anamat varchar(255);
                DECLARE To_Freight varchar(255);
                DECLARE TotalAmount decimal(30,2);
                DECLARE DateTime varchar(255);
                DECLARE Date varchar(255);
                DECLARE MusterCycle varchar(255);
                DECLARE xmlData longtext;
                DECLARE Counter INT DEFAULT 1;
                DECLARE AccountingDocumentType varchar(255);
                DECLARE CompanyCode varchar(255);
                DECLARE GLAccount_Gross varchar(255);
                DECLARE GLAccount_Freight varchar(255);
                DECLARE Debtor varchar(255);
                DECLARE Creditor varchar(255);
                DECLARE AltvRecnclnAccts_Anamat varchar(255);
                DECLARE AltvRecnclnAccts_Loan varchar(255);
                DECLARE AltvRecnclnAccts_Advance varchar(255);
                DECLARE Creditor_Debtor varchar(50);
                DECLARE MCC_Creditor_Debtor varchar(50);
                DECLARE DairyAdvance decimal(8,2);
                DECLARE MCCAdvance decimal(8,2);
				DECLARE BankLoan_ICICI decimal(8,2);
                DECLARE BankLoan_Society decimal(8,2);
                
                DECLARE DairyAdvance_GLCode varchar(255);
                DECLARE MCCAdvance_GLCode varchar(255);
                DECLARE ICICI_GLCode varchar(255);
				DECLARE Society__GLCode varchar(255);
                
                set @set_MCC_Id = (select MCC_Id from t027_invoice_farmer
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
    
				set @MilkCollectionDairy_Id =(select t009.MilkCollectionDairy_Id  from f010_milkcollectionmcc_final t009
				where t009.Org_Id = var_Org_Id 
				and t009.OutsideInvoice_Id = var_Invoice_Id limit 1);
					
				if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
						and mu04.Farmer_Id = t027.Farmer_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
                    
                    SELECT m005.MCC_Code into MCC_Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
						and m005.MCC_Id = t027.MCC_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				else
				
					SELECT m005.MCC_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
						and m005.MCC_Id = t027.MCC_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
                    
                    SELECT m005.MCC_Code into MCC_Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
						and m005.MCC_Id = t027.MCC_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				end if;
                
                Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
                
                SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
				SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
				SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
				SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
				SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
				SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';
				
                
                SELECT GL_Code into DairyAdvance_GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id
				and DeductionHead_Id ='M020231000015';
                
                SELECT GL_Code into MCCAdvance_GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id 
				and DeductionHead_Id ='M020231000012';
				
                SELECT GL_Code into ICICI_GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id
				and DeductionHead_Id ='M020231000011';
                
                SELECT GL_Code into Society__GLCode 
                FROM m020_deductions_head 
				where Org_Id = var_Org_Id 
				and DeductionHead_Id ='M020231000017';
                
                
                select 
				m005.Anamat_Applicable_To, 
				m005.Freight_Applicable_To 
                into 
                To_Anamat, 
                To_Freight
				from t027_invoice_farmer t027
				inner join m005_mcc_version m005 on
				m005.Org_Id = t027.Org_Id 
				and m005.MCC_Id = t027.MCC_Id 
                and m005.Applicable_Date <= t027.Invoice_Date
				where t027.Org_Id = var_Org_Id
				and t027.Voucher_Id =  var_Invoice_Id
                and m005.Is_Deleted = 0 
                order by m005.Applicable_Date desc
                limit 1;
                
                if(To_Anamat = 'Farmer')then
                
					UPDATE t027_invoice_farmer t027
					SET t027.Anamat_PerLtr = (SELECT m005.Anamat_PerLtr
												FROM m005_mcc_version  m005
												where
												m005.Org_Id = t027.Org_Id
												and m005.MCC_Id = t027.MCC_Id
												and m005.Applicable_Date  <= CONVERT_TZ(t027.Invoice_Date, '+00:00', '+00:00')
												and m005.Anamat_Applicable_To = 'Farmer'
                                                and m005.Is_Deleted = 0 
												order by m005.Applicable_Date desc 
												limit 1)
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id;
                    
                else
					UPDATE t027_invoice_farmer t027
					SET t027.Anamat_PerLtr = 0
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id;
                end if;
                
                
                if(To_Freight = 'Farmer')then
                
					UPDATE t027_invoice_farmer t027
					SET t027.Freight_PerLtr = (SELECT m005.Freight_PerLtr
												FROM m005_mcc_version  m005
												where
												m005.Org_Id = t027.Org_Id
												and m005.MCC_Id = t027.MCC_Id
												and m005.Applicable_Date  <= CONVERT_TZ(t027.Invoice_Date, '+00:00', '+00:00')
												and m005.Freight_Applicable_To = 'Farmer'
                                                and m005.Is_Deleted = 0 
												order by m005.Applicable_Date desc 
												limit 1)
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id;
                    
                else
					UPDATE t027_invoice_farmer t027
					SET t027.Freight_PerLtr = 0
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id;
                end if;
                
                    
                SELECT 
					CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t027_invoice_farmer t027
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
                
              
                if(@MilkCollectionDairy_Id  is null or @MilkCollectionDairy_Id  = '') then
            
				SELECT 
					ifnull(SUM(t005.Quantity_Ltr),0),
                    COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
					into 
                    Total_Ltr,
                    GrossAmount
                    -- MusterCycle
				FROM t027_invoice_farmer t027
				INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
                    ;
            else
            
				SELECT 
					ifnull(SUM(f010.Dairy_Quantity_Ltr),0),
                    COALESCE(ROUND(SUM(IFNULL(f010.MilkPrice, 0)), 2), 0)
					into 
                    Total_Ltr,
                    GrossAmount
                    -- MusterCycle
				FROM t027_invoice_farmer t027
				-- INNER JOIN t009_milkcollectiondairy_header t009 ON t009.Org_Id = t027.Org_Id 
                -- AND t009.OutsideInvoice_Id = t027.Voucher_Id
                Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = f010.Org_Id 
				-- and f010.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                AND f010.OutsideInvoice_Id = t027.Voucher_Id
                and f010.MCC_Id = t027.MCC_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
                    ;
            end if;
                    
                   
                   
					
                    
				-- PurchaseAmount
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  PurchaseAmount
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
                INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000013'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- Trading Material (Cattle Feed)
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  CattleFeed
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
                INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000014'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- Dairy Advance Recovered
               
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  DairyAdvance
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000015'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- MCC Advance Recovered
            
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  MCCAdvance
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000012'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				-- set Total_Advance =  (DairyAdvance + MCCAdvance);
                 
				-- Bank Loan - ICICI
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_ICICI
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000011'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                   
				-- Bank Loan - Society
                
                SELECT 
					COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_Society
				FROM t027_invoice_farmer t027
				INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t027.Org_Id 
                AND t033.Invoice_Id = t027.Voucher_Id
				INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
                AND t033.Deductions_Id = t0331.Deductions_Id
				AND t0331.Request_Type = 'M020231000017'
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
                    
				
										
				-- set Total_BankLoan =  (BankLoan_ICICI + BankLoan_Society);
                    
                -- AnamatAmount / FreightAmount
                
                if(To_Anamat = 'Farmer')then
                
					SELECT 
						COALESCE(ROUND(IFNULL(t027.Anamat_PerLtr, 0) * IFNULL(Total_Ltr, 0), 2), 0)
						into AnamatAmount
						FROM t027_invoice_farmer t027
						WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						limit 1;
                        
                else
                
					set AnamatAmount = 0;
                    
                end if;
                
                if(To_Freight = 'Farmer')then
                
					SELECT 
						COALESCE(ROUND(IFNULL(t027.Freight_PerLtr, 0) * IFNULL(Total_Ltr, 0), 2), 0) 
						into FreightAmount
						FROM t027_invoice_farmer t027
						WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						limit 1;
                        
                else
                
					set FreightAmount = 0;
                    
                end if;
                
				
				 UPDATE t027_invoice_farmer t027
					SET t027.DairyAnamat_Amount = round(AnamatAmount),
					t027.Transport_Amount = round(FreightAmount)
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id;
                
                 set TotalAmount =   round(PurchaseAmount) + round(CattleFeed)
									+ round(AnamatAmount) + round(FreightAmount) 
									+ round(DairyAdvance) + round(MCCAdvance)
									+ round(BankLoan_ICICI) + round(BankLoan_Society);
								
                                    
			if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
				UPDATE t027_invoice_farmer t027
				SET t027.Is_DeductionPosted = 4
				WHERE t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;
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
									<AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n\t\t\t\t\t
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
                            /*
                            IF Total_Advance IS NOT NULL AND Total_Advance != '' AND Total_Advance <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',Total_Advance,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', AltvRecnclnAccts_Advance, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Advance Recovered from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
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
                            */
                            IF DairyAdvance IS NOT NULL AND DairyAdvance != '' AND DairyAdvance <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(DairyAdvance),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', DairyAdvance_GLCode, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Dairy Advance Recovered from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
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
                            
                            
                            IF MCCAdvance IS NOT NULL AND MCCAdvance != '' AND MCCAdvance <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', MCC_Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(MCCAdvance),'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', MCCAdvance_GLCode, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>MCC Advance Recovered from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
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
                            /*
                            IF Total_BankLoan IS NOT NULL AND Total_BankLoan != '' AND Total_BankLoan <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<CreditorItem>\n\t\t\t\t\t\t
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
										<Creditor>', Creditor_Debtor, '</Creditor>\n\t\t\t\t\t\t
										<AmountInTransactionCurrency currencyCode=\"INR\">-',Total_BankLoan,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
										<DebitCreditCode>H</DebitCreditCode>\n\t\t\t\t\t\t
										<AltvRecnclnAccts>', AltvRecnclnAccts_Loan, '</AltvRecnclnAccts>\n\t\t\t\t\t\t
										<DocumentItemText>Advance Recovered from ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
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
                            */
                            
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
                            
                            
                            IF TotalAmount IS NOT NULL and TotalAmount != ''  AND TotalAmount <> 0 THEN
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
        elseif (var_Method_Name = 'Get_Voucher_Income') then 
			begin
				DECLARE Total_Ltr decimal(20,3);
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
                DECLARE GLAccount_Freight varchar(255);
                DECLARE Debtor varchar(255);
                DECLARE Creditor varchar(255);
                DECLARE AltvRecnclnAccts_Anamat varchar(255);
                DECLARE AltvRecnclnAccts_Loan varchar(255);
                DECLARE AltvRecnclnAccts_Advance varchar(255);
                DECLARE Creditor_Debtor varchar(50);
                
                
                set @set_MCC_Id = (select MCC_Id from t027_invoice_farmer
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
	
    
				SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
				inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
					and mu04.Farmer_Id = t027.Farmer_Id 
				where t027.Org_Id = var_Org_Id 
				and t027.Voucher_Id = var_Invoice_Id;
                
                Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
				
                SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
				SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
				SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
				SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
				SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
				SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
				SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
				SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
				SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';

                
                SELECT 
					CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
                    DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
                    into 
                    MusterCycle,
                    Date
				FROM t027_invoice_farmer t027
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				GROUP BY
                    t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
                    
                -- GrossAmount
                SELECT 
					ifnull(SUM(t005.Quantity_Ltr),0),
                    COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
					into 
                    Total_Ltr,
                    GrossAmount
                    -- MusterCycle
				FROM t027_invoice_farmer t027
				INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
                    ;
                    
				
                 set TotalAmount =  GrossAmount;
                
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
									<AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n\t\t\t\t\t
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
			
							IF GrossAmount IS NOT NULL AND GrossAmount != '' AND GrossAmount <> 0 THEN
								SET xmlData = CONCAT(xmlData, 
								'<Item>\n\t\t\t\t\t\t
									<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n\t\t\t\t\t\t
									<CompanyCode>',CompanyCode,'</CompanyCode>\n\t\t\t\t\t\t
									<GLAccount>',GLAccount_Gross,'</GLAccount>\n\t\t\t\t\t\t
									<AmountInTransactionCurrency currencyCode=\"INR\">',GrossAmount,'</AmountInTransactionCurrency>\n\t\t\t\t\t\t
									<DebitCreditCode>S</DebitCreditCode>\n\t\t\t\t\t\t
									<DocumentItemText>Milk Payment ',MusterCycle,'</DocumentItemText>\n\t\t\t\t\t\t
									<BusinessPlace></BusinessPlace>\n\t\t\t\t\t\t
									<AccountAssignment>\n\t\t\t\t\t\t\t
                                    <ProfitCenter>',@ProfitCenter,'</ProfitCenter>\n\t\t\t\t\t\t\t
										<CostCenter></CostCenter>\n\t\t\t\t\t\t
									</AccountAssignment>\n\t\t\t\t\t
								</Item>\n\t\t\t\t\t'
								);
                                SET Counter = Counter + 1;
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
			DECLARE GLAccount_Freight varchar(255);
			DECLARE Debtor varchar(255);
			DECLARE Creditor varchar(255);
			DECLARE AltvRecnclnAccts_Anamat varchar(255);
			DECLARE AltvRecnclnAccts_Loan varchar(255);
			DECLARE AltvRecnclnAccts_Advance varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);

			
            
			
			SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
			SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
			SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
			SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
			SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
			SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';
			
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
                
                
			
            
            SELECT 
				CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t027_invoice_farmer t027
			WHERE 
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id
			GROUP BY
				t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
            
				set @MilkCollectionDairy_Id =(select t009.MilkCollectionDairy_Id  from f010_milkcollectionmcc_final t009
				where t009.Org_Id = var_Org_Id 
				and t009.OutsideInvoice_Id = var_Invoice_Id limit 1);
				
					
				if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
						and mu04.Farmer_Id = t027.Farmer_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				else
				
					SELECT m005.MCC_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
						and m005.MCC_Id = t027.MCC_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				end if;
		
				-- GrossAmount
				
				if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT 
						ifnull(SUM(t005.Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				else
				
					SELECT 
						ifnull(SUM(f010.Dairy_Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(f010.MilkPrice, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					-- INNER JOIN t009_milkcollectiondairy_header t009 ON t009.Org_Id = t027.Org_Id 
					-- AND t009.OutsideInvoice_Id = t027.Voucher_Id
					Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = t027.Org_Id 
					-- and f010.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					AND f010.OutsideInvoice_Id = t027.Voucher_Id
					and f010.MCC_Id = t027.MCC_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				end if;
				
				SELECT 
				Current_Year as FiscalYear,
				CompanyCode as CompanyCode,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as DocumentDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as PostingDate,
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
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxDeterminationDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxReportingDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxFulfillmentDate,
				false as IsEUTriangularDeal,
				false as IsReversal,
				false as IsReversed,
				concat('Milk Invoice from ',MusterCycle) as SupplierPostingLineItemText,
                CASE
				WHEN ROUND(GrossAmount) < 0 THEN 'X' -- If GrossAmount is negative, set DebitCreditCode to 'H'
				WHEN ROUND(GrossAmount) > 0 THEN '' -- If GrossAmount is positive, set DebitCreditCode to 'S'
				ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as SupplierInvoiceIsCreditMemo
				FROM t027_invoice_farmer t027
				where
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;
            
           

			
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
			DECLARE GLAccount_Freight varchar(255);
			DECLARE Debtor varchar(255);
			DECLARE Creditor varchar(255);
			DECLARE AltvRecnclnAccts_Anamat varchar(255);
			DECLARE AltvRecnclnAccts_Loan varchar(255);
			DECLARE AltvRecnclnAccts_Advance varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            
            SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
			SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
			SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
			SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
			SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
			SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';
			
            set @set_MCC_Id = (select MCC_Id from t027_invoice_farmer
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
                                    
			SELECT
				CASE
					WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
					ELSE YEAR(CURDATE()) - 1
				END into Current_Year;

			
				set @MilkCollectionDairy_Id =(select t009.MilkCollectionDairy_Id  from f010_milkcollectionmcc_final t009
				where t009.Org_Id = var_Org_Id 
				and t009.OutsideInvoice_Id = var_Invoice_Id limit 1);
			   
					 
				if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
						and mu04.Farmer_Id = t027.Farmer_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				else
				
					SELECT m005.MCC_Code into Creditor_Debtor FROM t027_invoice_farmer t027
					inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
						and m005.MCC_Id = t027.MCC_Id 
					where t027.Org_Id = var_Org_Id 
					and t027.Voucher_Id = var_Invoice_Id;
					
				end if;
			
		
				-- GrossAmount
					if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT 
						ifnull(SUM(t005.Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				else
				
					SELECT 
						ifnull(SUM(f010.Dairy_Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(f010.MilkPrice, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					-- INNER JOIN t009_milkcollectiondairy_header t009 ON t009.Org_Id = t027.Org_Id 
					-- AND t009.OutsideInvoice_Id = t027.Voucher_Id
					Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = t027.Org_Id 
					-- and f010.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					AND f010.OutsideInvoice_Id = t027.Voucher_Id
					and f010.MCC_Id = t027.MCC_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				end if;
				
				SELECT 
						CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
						DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
						into 
						MusterCycle,
						Date
					FROM t027_invoice_farmer t027
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
					GROUP BY
						t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
				
				select 
				Current_Year as FiscalYear,
				'1' as SupplierInvoiceItem,
				CompanyCode as CompanyCode,
				'' as CostCenter ,
				@ProfitCenter as ProfitCenter,
				GLAccount_Gross as GLAccount,
				'INR' as DocumentCurrency,
				round(abs(GrossAmount)) as SupplierInvoiceItemAmount,
				'0C' as TaxCode,
                CASE
					WHEN ROUND(GrossAmount) < 0 THEN 'H' -- If TotalAmount is negative, set DebitCreditCode to 'H'
					WHEN ROUND(GrossAmount) > 0 THEN 'S' -- 'S' -- If TotalAmount is positive, set DebitCreditCode to 'S'
					ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as DebitCreditCode,
				false as IsNotCashDiscountLiable,
				'0.00' as TaxBaseAmountInTransCrcy,
				concat('Milk Invoice from ',MusterCycle) as SupplierInvoiceItemText
				FROM t027_invoice_farmer t027
				where
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;
            
          
            
			
        end;
	elseif (var_Method_Name = 'Get_SupplierInvoiceWhldgTax') then
		begin
		DECLARE GrossAmount decimal(30,2);
        DECLARE Total_Ltr decimal(30,3);
		
			set @MilkCollectionDairy_Id =(select t009.MilkCollectionDairy_Id  from f010_milkcollectionmcc_final t009
				where t009.Org_Id = var_Org_Id 
				and t009.OutsideInvoice_Id = var_Invoice_Id limit 1);
				
				-- GrossAmount
				   if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
				
					SELECT 
						ifnull(SUM(t005.Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					INNER JOIN t005_milkcollectionfarmer t005 ON t005.Org_Id = t027.Org_Id AND t005.Invoice_Id = t027.Voucher_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				else
				
					SELECT 
						ifnull(SUM(f010.Dairy_Quantity_Ltr),0),
						COALESCE(ROUND(SUM(IFNULL(f010.MilkPrice, 0)), 2), 0)
						into 
						Total_Ltr,
						GrossAmount
						-- MusterCycle
					FROM t027_invoice_farmer t027
					-- INNER JOIN t009_milkcollectiondairy_header t009 ON t009.Org_Id = t027.Org_Id 
					-- AND t009.OutsideInvoice_Id = t027.Voucher_Id
					Inner Join f010_milkcollectionmcc_final f010 on f010.Org_Id = t027.Org_Id 
					-- and f010.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					AND f010.OutsideInvoice_Id = t027.Voucher_Id
					and f010.MCC_Id = t027.MCC_Id
					WHERE 
						t027.Org_Id = var_Org_Id
						AND t027.Voucher_Id = var_Invoice_Id
						;
				SET SQL_SAFE_UPDATES=0;
				DROP TEMPORARY TABLE IF EXISTS temp_table;
				
				CREATE TEMPORARY TABLE temp_table AS
				SELECT mu04.Farmer_Id 
				FROM t027_invoice_farmer t027
				INNER JOIN mu04_farmer mu04 ON t027.Org_Id = mu04.Org_Id
											AND t027.MCC_Id = mu04.MCC_Id
				WHERE t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id
				LIMIT 1;
				
				UPDATE t027_invoice_farmer t027
				SET t027.Farmer_Id = (SELECT Farmer_Id FROM temp_table limit 1)
				WHERE t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;

				end if;
				
			   if(GrossAmount is null or GrossAmount = '' or GrossAmount = 0)then
					UPDATE t027_invoice_farmer t027
					SET t027.Is_IncomePosted = 4
					WHERE t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id;
			   end if;
						
				select 
				'4Q' as WithholdingTaxType,
				'INR' as DocumentCurrency,
				'4Q' as WithholdingTaxCode,
				round(abs(GrossAmount)) as WithholdingTaxBaseAmount
				FROM t027_invoice_farmer t027
				where
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;
        
			
        end;
	elseif (var_Method_Name = 'Get_Rate_Change_Income_Header') then
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
			DECLARE GLAccount_Freight varchar(255);
			DECLARE Debtor varchar(255);
			DECLARE Creditor varchar(255);
			DECLARE AltvRecnclnAccts_Anamat varchar(255);
			DECLARE AltvRecnclnAccts_Loan varchar(255);
			DECLARE AltvRecnclnAccts_Advance varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);

			
            
			
			SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
			SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
			SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
			SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
			SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
			SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';
			
			SELECT
			CASE
				WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
				ELSE YEAR(CURDATE()) - 1
			END into Current_Year;
                
            
            
            SELECT 
				CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
				DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
				into 
				MusterCycle,
				Date
			FROM t027_invoice_farmer t027
			WHERE 
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id
			GROUP BY
				t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
           
				SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
				inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
					and mu04.Farmer_Id = t027.Farmer_Id 
				where t027.Org_Id = var_Org_Id 
				and t027.Voucher_Id = var_Invoice_Id;
			
				-- GrossAmount
				
				set GrossAmount = ( select Invoice_Amount from  t027_invoice_farmer WHERE 
				Org_Id = var_Org_Id
				AND Voucher_Id = var_Invoice_Id);
				
				SELECT 
				Current_Year as FiscalYear,
				CompanyCode as CompanyCode,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as DocumentDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as PostingDate,
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
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxDeterminationDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxReportingDate,
				concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t027.Invoice_Date, '+00:00', '+05:30')) * 1000),')/') as TaxFulfillmentDate,
				false as IsEUTriangularDeal,
				false as IsReversal,
				false as IsReversed,
				concat('Milk Rate Difference ',MusterCycle) as SupplierPostingLineItemText,
				CASE
				WHEN ROUND(GrossAmount) < 0 THEN 'X' -- If TotalAmount is negative, set DebitCreditCode to 'H'
				WHEN ROUND(GrossAmount) > 0 THEN '' -- If TotalAmount is positive, set DebitCreditCode to 'S'
				ELSE '' -- For any other case, set DebitCreditCode to empty string
				END as SupplierInvoiceIsCreditMemo

				FROM t027_invoice_farmer t027
				where
				t027.Org_Id = var_Org_Id
				AND t027.Voucher_Id = var_Invoice_Id;
			
        end;
    
    elseif (var_Method_Name = 'Get_Rate_Change_SupplierInvoiceItemGLAcct') then
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
			DECLARE GLAccount_Freight varchar(255);
			DECLARE Debtor varchar(255);
			DECLARE Creditor varchar(255);
			DECLARE AltvRecnclnAccts_Anamat varchar(255);
			DECLARE AltvRecnclnAccts_Loan varchar(255);
			DECLARE AltvRecnclnAccts_Advance varchar(255);
			DECLARE Creditor_Debtor varchar(50);
            DECLARE Current_Year varchar(50);
            
            SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Gross  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Gross';
			SELECT Constant_Value into GLAccount_Freight  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'GLAccount_Freight';
			SELECT Constant_Value into Debtor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Debtor';
			SELECT Constant_Value into Creditor  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'Creditor';
			SELECT Constant_Value into AltvRecnclnAccts_Anamat  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Anamat';
			SELECT Constant_Value into AltvRecnclnAccts_Loan  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Loan';
			SELECT Constant_Value into AltvRecnclnAccts_Advance  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerVoucher' and Constant_Name = 'AltvRecnclnAccts_Advance';

			SELECT
				CASE
					WHEN MONTH(CURDATE()) BETWEEN 4 AND 12 THEN YEAR(CURDATE())
					ELSE YEAR(CURDATE()) - 1
				END into Current_Year;

			
            set @set_MCC_Id = (select MCC_Id from t027_invoice_farmer
				where Org_Id = var_Org_Id
				and Voucher_Id = var_Invoice_Id limit 1);

				set @ProfitCenter = (select ifnull(Plant_Code,'1100') from m005_mcc
									where Org_Id = var_Org_Id
									and MCC_Id = @set_MCC_Id limit 1);
    
			
		
			SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
			inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
				and mu04.Farmer_Id = t027.Farmer_Id 
			where t027.Org_Id = var_Org_Id 
			and t027.Voucher_Id = var_Invoice_Id;
				
	
			set GrossAmount = ( select Invoice_Amount from  t027_invoice_farmer WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);
			
			SELECT 
					CONCAT(DATE_FORMAT(t027.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d.%m.%y')),
					DATE_FORMAT(CONVERT_TZ(t027.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
					into 
					MusterCycle,
					Date
				FROM t027_invoice_farmer t027
				WHERE 
					t027.Org_Id = var_Org_Id
					AND t027.Voucher_Id = var_Invoice_Id
				GROUP BY
					t027.MusterCycle_StartDate,t027.MusterCycle_EndDate;
			
			select 
			Current_Year as FiscalYear,
			'1' as SupplierInvoiceItem,
			CompanyCode as CompanyCode,
			'' as CostCenter ,
			@ProfitCenter as ProfitCenter,
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
			concat('Milk Rate Difference ',MusterCycle) as SupplierInvoiceItemText
			FROM t027_invoice_farmer t027
			where
			t027.Org_Id = var_Org_Id
			AND t027.Voucher_Id = var_Invoice_Id;
            
            
			
        end;
	elseif (var_Method_Name = 'Get_Rate_Change_SupplierInvoiceWhldgTax') then
		begin
		DECLARE GrossAmount decimal(30,2);
        DECLARE Total_Ltr decimal(30,3);
		
		-- GrossAmount
			set GrossAmount = ( select Invoice_Amount from  t027_invoice_farmer WHERE 
			Org_Id = var_Org_Id
			AND Voucher_Id = var_Invoice_Id);
			
			UPDATE t027_invoice_farmer t027
			SET 
				t027.Is_DeductionPosted = 4
			WHERE t027.Org_Id = var_Org_Id
			AND t027.Voucher_Id = var_Invoice_Id;
		
			select 
			'4Q' as WithholdingTaxType,
			'INR' as DocumentCurrency,
			'4Q' as WithholdingTaxCode,
			round(abs(GrossAmount)) as WithholdingTaxBaseAmount
			FROM t027_invoice_farmer t027
			where
			t027.Org_Id = var_Org_Id
			AND t027.Voucher_Id = var_Invoice_Id;
        
        end;
	
    elseif (var_Method_Name = 'GetIncomeError') then
		begin
		DECLARE Creditor_Debtor varchar(50);
        
        set @MilkCollectionDairy_Id =(select t009.MilkCollectionDairy_Id  from f010_milkcollectionmcc_final t009
		where t009.Org_Id = var_Org_Id 
		and t009.OutsideInvoice_Id = var_Invoice_Id limit 1);
		
			
		if(@MilkCollectionDairy_Id is null or @MilkCollectionDairy_Id = '') then
		
			SELECT mu04.Farmer_Code into Creditor_Debtor FROM t027_invoice_farmer t027
			inner join  mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id 
				and mu04.Farmer_Id = t027.Farmer_Id 
			where t027.Org_Id = var_Org_Id 
			and t027.Voucher_Id = var_Invoice_Id;
			
		else
		
			SELECT m005.MCC_Code into Creditor_Debtor FROM t027_invoice_farmer t027
			inner join  m005_mcc m005 on m005.Org_Id = t027.Org_Id 
				and m005.MCC_Id = t027.MCC_Id 
			where t027.Org_Id = var_Org_Id 
			and t027.Voucher_Id = var_Invoice_Id;
			
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
	elseif (var_Method_Name = 'Locked') then
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
            DECLARE Is_Locked varchar(10);

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			set @MCCType_Id = (select MCCType_Id from m005_mcc 
								where MCC_Id = var_MCC_Id 
                                and Org_Id = var_Org_Id);
			set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc 
									where MCC_Id = var_MCC_Id
                                    and Org_Id = var_Org_Id);
			
			if(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023002')then
		
				set @Is_Locked = (select Is_VoucherLocked from f010_milkcollectionmcc_final 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Collection_Date) >= date(var_StartDate)
									and date(Collection_Date) <= date(var_EndDate)
									order by Is_VoucherLocked asc limit 1);
                
			elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then
          
				set @Is_Locked = (select Is_VoucherLocked from f010_milkcollectionmcc_final 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Collection_Date) >= date(var_StartDate)
									and date(Collection_Date) <= date(var_EndDate)
									order by Is_VoucherLocked asc limit 1);
			else
            
            set @Is_Locked = 1;
                
            end if;
            
            set Is_Locked = @Is_Locked;
            
            select Is_Locked;

		end;
	elseif (var_Method_Name = 'Lock') then
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
            DECLARE Is_Locked varchar(10);

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			set @MCCType_Id = (select MCCType_Id from m005_mcc 
								where MCC_Id = var_MCC_Id 
                                and Org_Id = var_Org_Id);
			set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc 
									where MCC_Id = var_MCC_Id
                                    and Org_Id = var_Org_Id);
			
			if(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023002')then
		
				set @Is_Locked = (select Is_VoucherLocked from f010_milkcollectionmcc_final 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Collection_Date) >= date(var_StartDate)
									and date(Collection_Date) <= date(var_EndDate)
									order by Is_VoucherLocked asc limit 1);
				
                                    
				set @Is_Lock = (select Is_FromApp from t005_milkcollectionfarmer 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Created_On) >= date(var_StartDate)
									and date(Created_On) <= date(var_EndDate)
									order by Is_FromApp asc limit 1);
                                    
				if(@Is_Locked is null or @Is_Locked = '')then
					set @Is_Locked  = 0;
                end if;
                                    
				if(@Is_Lock is null or @Is_Lock = '')then
					set @Is_Lock  = 0;
                end if;
		
			elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then
          
				set @Is_Locked = (select Is_VoucherLocked from f010_milkcollectionmcc_final 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Collection_Date) >= date(var_StartDate)
									and date(Collection_Date) <= date(var_EndDate)
									order by Is_VoucherLocked asc limit 1);
				
				set @Is_Lock = (select Is_FromApp from t005_milkcollectionfarmer 
									where MCC_Id = var_MCC_Id
									and Org_Id = var_Org_Id
									and date(Created_On) >= date(var_StartDate)
									and date(Created_On) <= date(var_EndDate)
									order by Is_FromApp asc limit 1);
				
				if(@Is_Locked is null or @Is_Locked = '')then
					set @Is_Locked  = 0;
                end if;
                
				if(@Is_Lock is null or @Is_Lock = '')then
					set @Is_Lock  = 0;
                end if;
                
			else
            
				set @Is_Locked = 1;
				set @Is_Lock = 1;
                
            end if;
              
            
            set Is_Locked = concat(@Is_Locked , ' ', @Is_Lock);
            
            select Is_Locked;

		end;
	elseif (var_Method_Name = 'Get_MCCAdvance') then
		begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
                
                select 
				t0331.Org_Id,
				t0331.Entry_Id,
				t0331.Deductions_Id,
				t0331.Deduction_Amount as Amount,
				t033.Request_User_Id as Farmer_Id
				from t033_deductions_item  t0331
				inner join t033_deductions_header t033 on
				t033.Org_Id = t0331.Org_Id 
				and t033.Deductions_Id = t0331.Deductions_Id 
				and t033.Request_Type = 'M020231000012'
				and t033.Request_User_Type = 'Farmer'
				and t033.Request_User_Id = var_Farmer_Id
				where t0331.Org_Id  = var_Org_Id
				and t0331.Deduction_Amount <> 0
				and t0331.Is_Check = 0
				and t0331.Is_InvoiceCreated =0
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				order by Deduction_Amount desc
				limit 1;
        end;
	elseif (var_Method_Name = 'Get_GenerateSum_2') then  
			begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
                
                
				SET SQL_SAFE_UPDATES = 0;
                
                select MCCType_Id,MCCWorkType_Id 
				into @MCCType_Id ,@MCCWorkType_Id 
				from m005_mcc where 
				Org_Id = var_Org_Id
				and MCC_Id like var_MCC_Id
				and MCCType_Id like var_MCCType_Id limit 1;
                
                SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_1;
				CREATE TEMPORARY TABLE temp_Farmer_Data_1 ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                Amount decimal(30,3),Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,Entry_Type longtext,Is_Voucher varchar(20)
                );
				/*
				Insert into temp_Farmer_Data_1 (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
				)
                SELECT 
					t005.Org_Id,
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
					ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				and m005.MCC_Id like var_MCC_Id
				where t005.Org_Id = var_Org_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
                t005.Org_Id,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
                
                union all

				SELECT 
					f010.Org_Id,
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
                f010.Org_Id,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code

				union all

				SELECT 
					f010.Org_Id,
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
                f010.Org_Id,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code;
				*/
                
                
                
				if(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023002')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                t005.Org_Id,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
                ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
                t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
                Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id like var_MCC_Id
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
                and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and  t005.Is_InvoiceCreated = 0 
                and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
                and t005.Is_Check = 0
                group by 
                t005.Org_Id,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.MusterCycle_StartDate,t005.MusterCycle_EndDate;

                elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                t005.Org_Id,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
                ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
                t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
                Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id like var_MCC_Id
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
                and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and  t005.Is_InvoiceCreated = 0 
                and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
                and t005.Is_Check = 0
                group by 
                t005.Org_Id,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.MusterCycle_StartDate,t005.MusterCycle_EndDate;

                elseif(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023001')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                m005.MCC_Id as Farmer_Id,
                m005.MCC_Name as Farmer_Name,
                m005.MCC_Code as Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                group by 
                f010.Org_Id,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code;

                elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023001')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                m005.MCC_Id as Farmer_Id,
                m005.MCC_Name as Farmer_Name,
                m005.MCC_Code as Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                group by 
                f010.Org_Id,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code;

                elseif(@MCCType_Id = 'C014003')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                m005.MCC_Id as Farmer_Id,
                m005.MCC_Name as Farmer_Name,
                m005.MCC_Code as Farmer_Code,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id like var_MCCType_Id
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                group by 
                f010.Org_Id,
                m005.MCC_Id, m005.MCC_Name,m005.MCC_Code;

                end if;
                
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_2;
				CREATE TEMPORARY TABLE temp_Farmer_Data_2 ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                Amount decimal(30,3),Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,Entry_Type longtext,Is_Voucher varchar(20)
                );
				
				Insert into temp_Farmer_Data_2 (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
				)
                SELECT 
					t033.Org_Id,
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					round(sum(t0331.Deduction_Amount)) as Amount,
					0 as Quality,
					concat(DATE_FORMAT(t0331.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t0331.MusterCycle_EndDate , '%d %b %Y')) as MusterCycle,
					t0331.MusterCycle_StartDate as StartDate,t0331.MusterCycle_EndDate as EndDate,
					CASE
					WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
					WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
					WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
					WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
					ELSE ''
					END AS Entry_Type,
					'1' as Is_Voucher 
				FROM t033_deductions_header t033
				inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
				and  t0331.Deductions_Id = t033.Deductions_Id 
				and  t0331.Is_Deducted = 0 
				AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				and t0331.Deduction_Amount <> 0
				and t0331.Is_Check = 0
				and t0331.Is_InvoiceCreated =0
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
				and  mu04.Farmer_Id = t033.Request_User_Id 
				inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
				and  m005.MCC_Id = mu04.MCC_Id 
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				where t033.Org_Id  = var_Org_Id
				and t033.Request_User_Type  ='Farmer'
				group by 
                t033.Org_Id,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t033.Request_Type,
				t0331.MusterCycle_StartDate,
				t0331.MusterCycle_EndDate ;
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_Main;
				CREATE TEMPORARY TABLE temp_Farmer_Data_Main ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                -- Amount decimal(30,3),
                Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,
                -- Entry_Type longtext,
                -- Is_Voucher varchar(20),
                Milk_Deposit decimal(30,3),
                Bank_Loan decimal(30,3),
				Dairy_Advance decimal(30,3),
				MCC_Advance decimal(30,3),
				Product_Sales decimal(30,3),
				Trading_Material decimal(30,3),
                Freight decimal(30,3),
				Anamat decimal(30,3)
                );
                
                Insert into temp_Farmer_Data_Main (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Milk_Deposit,Quality,MusterCycle,StartDate,EndDate
				)
                select 
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount as Milk_Deposit,
                Quality,MusterCycle,StartDate,EndDate
                from temp_Farmer_Data_1;
                
                
				Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Bank Loan'
				set tmp.Bank_Loan = Amount ;

				Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Dairy Advance'
				set tmp.Dairy_Advance = Amount ;
                
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'MCC Advance'
				set tmp.MCC_Advance = Amount ;
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Product Sales'
				set tmp.Product_Sales = Amount ;
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Trading Material'
				set tmp.Trading_Material = Amount ;
                
                DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer_1;
				CREATE TEMPORARY TABLE temp_anamat_farmer_1 ( 
				Org_Id varchar(20), MCC_Id varchar(20), 
				Max_Applicable_Date varchar(20),
				Anamat_Applicable_To varchar(20),
				Freight_Applicable_To varchar(20),
				Anamat_PerLtr decimal(8,2),
				Freight_PerLtr decimal(8,2)
				);
				
				Insert into temp_anamat_farmer_1 (
				Org_Id,MCC_Id,
				Max_Applicable_Date,
				Anamat_Applicable_To,
				Freight_Applicable_To,
				Anamat_PerLtr,Freight_PerLtr
				)
				SELECT 
					 m0051.Org_Id,
					 m0051.MCC_Id,
					 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr
				 FROM 
					 m005_mcc_version m0051
				Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
				and m005.MCC_Id = m0051.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
                and m0051.Is_Deleted = 0 
				 WHERE 
					 m0051.Org_Id = var_Org_Id
					 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				 GROUP BY 
					 m0051.Org_Id, m0051.MCC_Id,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
                     
				DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer_1;
				CREATE TEMPORARY TABLE temp_freight_farmer_1 ( 
				Org_Id varchar(20), MCC_Id varchar(20), 
				Max_Applicable_Date varchar(20),
				Anamat_Applicable_To varchar(20),
				Freight_Applicable_To varchar(20),
				Anamat_PerLtr decimal(8,2),
				Freight_PerLtr decimal(8,2)
				);
				
				Insert into temp_freight_farmer_1 (
				Org_Id,MCC_Id,
				Max_Applicable_Date,
				Anamat_Applicable_To,
				Freight_Applicable_To,
				Anamat_PerLtr,Freight_PerLtr
				)
				SELECT 
					 m0051.Org_Id,
					 m0051.MCC_Id,
					 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 Anamat_PerLtr,Freight_PerLtr
				 FROM 
					 m005_mcc_version m0051
				Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
				and m005.MCC_Id = m0051.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
                and m0051.Is_Deleted = 0 
				 WHERE 
					 m0051.Org_Id = var_Org_Id
					 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				 GROUP BY 
					 m0051.Org_Id, m0051.MCC_Id,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
                     
                Update temp_Farmer_Data_Main tmp
                INNER JOIN 
				temp_anamat_farmer_1 max_dates ON tmp.Org_Id = max_dates.Org_Id 
				AND tmp.MCC_Id = max_dates.MCC_Id 
				and max_dates.Freight_Applicable_To = 'Farmer'
				set tmp.Anamat = IFNULL(tmp.Quality, 0) * IFNULL(max_dates.Anamat_PerLtr, 0);
                
                Update temp_Farmer_Data_Main tmp
                INNER JOIN 
				temp_freight_farmer_1 max_dates ON tmp.Org_Id = max_dates.Org_Id 
				AND tmp.MCC_Id = max_dates.MCC_Id 
				and max_dates.Freight_Applicable_To = 'Farmer'
				set tmp.Freight = IFNULL(tmp.Quality, 0) * IFNULL(max_dates.Freight_PerLtr, 0);
                     
				select 
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Quality,
                MusterCycle,StartDate,EndDate,
                ifnull(Milk_Deposit,0.000) as Milk_Deposit,
                ifnull(Bank_Loan,0.000) as Bank_Loan,
                ifnull(Dairy_Advance,0.000) as Dairy_Advance,
                ifnull(MCC_Advance,0.000) as MCC_Advance,
                ifnull(Product_Sales,0.000) as Product_Sales,
                ifnull(Trading_Material,0.000) as Trading_Material,
				ifnull(Freight,0.000) as Freight,
                ifnull(Anamat,0.000) as Anamat
                from temp_Farmer_Data_Main;
            end;
	elseif (var_Method_Name = 'Get_GenerateSum_3') then  
			begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
                
                
				SET SQL_SAFE_UPDATES = 0;
                
                select MCCType_Id,MCCWorkType_Id 
				into @MCCType_Id ,@MCCWorkType_Id 
				from m005_mcc where 
				Org_Id = var_Org_Id
				and MCC_Id like var_MCC_Id
				and MCCType_Id like var_MCCType_Id limit 1;
                
                SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_1;
				CREATE TEMPORARY TABLE temp_Farmer_Data_1 ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                Amount decimal(30,3),Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,Entry_Type longtext,Is_Voucher varchar(20)
                );
				/*
				Insert into temp_Farmer_Data_1 (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
				)
                SELECT 
					t005.Org_Id,
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
					ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
					t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM t005_milkcollectionfarmer t005
				Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
				and m005.MCC_Id = t005.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023002'
				and m005.MCC_Id like var_MCC_Id
				where t005.Org_Id = var_Org_Id
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and  t005.Is_InvoiceCreated = 0 
				and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
				and t005.Is_Check = 0
				group by 
                t005.Org_Id,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t005.MusterCycle_StartDate,t005.MusterCycle_EndDate
                
                union all

				SELECT 
					f010.Org_Id,
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
                f010.Org_Id,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code

				union all

				SELECT 
					f010.Org_Id,
					m005.MCC_Id as Farmer_Id,
					m005.MCC_Name as Farmer_Name,
					m005.MCC_Code as Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
					ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
					concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
					var_StartDate as StartDate,var_EndDate as EndDate,
					'Milk Deposit'  as Entry_Type,
					'0' as Is_Voucher 
				FROM f010_milkcollectionmcc_final f010
				Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
				and m005.MCC_Id = f010.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCCType_Id in('C014003')
				and m005.MCC_Id like var_MCC_Id
				where f010.Org_Id = var_Org_Id
				and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
				and  f010.Is_OutsideInvoiceCreated = 0 
				and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
				and f010.Is_OutsideCheck = 0
				group by 
                f010.Org_Id,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code;
				*/
                
                
                
				if(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023002')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,
				-- Farmer_Name,Farmer_Code,
                MCC_Id,
				-- MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                t005.Org_Id,
                t005.Farmer_Id,
				-- mu04.Farmer_Name,mu04.Farmer_Code,
                t005.MCC_Id, 
				-- m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
                ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
                t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                -- Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
                -- Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                -- and m005.MCC_Id = t005.MCC_Id
                -- and m005.MCCType_Id like var_MCCType_Id
                -- and m005.MCCType_Id in('C014001','C014002')
                -- and m005.MCCWorkType_Id = 'C023002'
                -- and m005.MCC_Id like var_MCC_Id
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
                and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and  t005.Is_InvoiceCreated = 0 
                -- and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
                and t005.Is_Check = 0
                and t005.MCC_Id like var_MCC_Id
                group by 
                t005.Org_Id,
                t005.Farmer_Id,
				-- mu04.Farmer_Name,mu04.Farmer_Code,
                t005.MCC_Id, 
                t005.MusterCycle_StartDate,t005.MusterCycle_EndDate;

                elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023002')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,
				-- Farmer_Name,Farmer_Code,
                MCC_Id,
				-- MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                t005.Org_Id,
                t005.Farmer_Id,
				-- mu04.Farmer_Name,mu04.Farmer_Code,
                t005.MCC_Id, 
				-- m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(t005.Quantity_Ltr, 0) * IFNULL(t005.ApplicableRate, 0)))as Amount,
                ROUND(sum(ifnull(t005.Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(t005.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t005.MusterCycle_EndDate, '%d %b %Y')) as MusterCycle,
                t005.MusterCycle_StartDate as StartDate,t005.MusterCycle_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM t005_milkcollectionfarmer t005
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                Inner Join t006_milkcollectionagent t006 on t006.Org_Id = t005.Org_Id and t006.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
                -- Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
                -- Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                -- and m005.MCC_Id = t005.MCC_Id
                -- and m005.MCCType_Id like var_MCCType_Id
                -- and m005.MCCType_Id in('C014001','C014002')
                -- and m005.MCCWorkType_Id = 'C023002'
                -- and m005.MCC_Id like var_MCC_Id
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
                and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and  t005.Is_InvoiceCreated = 0 
                and t005.MCC_Id like var_MCC_Id
                -- and (t005.Invoice_Id = '' or t005.Invoice_Id IS NULL)
                and t005.Is_Check = 0
                group by 
                t005.Org_Id,
                t005.Farmer_Id,
				-- mu04.Farmer_Name,mu04.Farmer_Code,
                t005.MCC_Id, 
                t005.MusterCycle_StartDate,t005.MusterCycle_EndDate;

                elseif(@MCCType_Id = 'C014001' and @MCCWorkType_Id = 'C023001')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,
				-- Farmer_Name,Farmer_Code,
                MCC_Id,
				-- MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                f010.MCC_Id as Farmer_Id,
                -- m005.MCC_Name as Farmer_Name,
                -- m005.MCC_Code as Farmer_Code,
                f010.MCC_Id, 
				-- m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                -- Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                -- and m005.MCC_Id = f010.MCC_Id
                -- and m005.MCCType_Id like var_MCCType_Id
                -- and m005.MCCType_Id in('C014001','C014002')
                -- and m005.MCCWorkType_Id = 'C023001'
                -- and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                and f010.MCC_Id like var_MCC_Id
                -- and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                group by 
                f010.Org_Id,
                f010.MCC_Id;

                elseif(@MCCType_Id = 'C014002' and @MCCWorkType_Id = 'C023001')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,
				-- Farmer_Name,Farmer_Code,
                MCC_Id,
				-- MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                f010.MCC_Id as Farmer_Id,
                -- m005.MCC_Name as Farmer_Name,
                -- m005.MCC_Code as Farmer_Code,
                f010.MCC_Id, 
				-- m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                -- Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                -- and m005.MCC_Id = f010.MCC_Id
                -- and m005.MCCType_Id like var_MCCType_Id
                -- and m005.MCCType_Id in('C014001','C014002')
                -- and m005.MCCWorkType_Id = 'C023001'
                -- and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                -- and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                and f010.MCC_Id like var_MCC_Id
                group by 
                f010.Org_Id,
                f010.MCC_Id;

                elseif(@MCCType_Id = 'C014003')then

                Insert into temp_Farmer_Data_1 (
                Org_Id,
                Farmer_Id,
				-- Farmer_Name,Farmer_Code,
                MCC_Id,
				-- MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
                )
                SELECT 
                f010.Org_Id,
                f010.MCC_Id as Farmer_Id,
                -- m005.MCC_Name as Farmer_Name,
                -- m005.MCC_Code as Farmer_Code,
                f010.MCC_Id, 
				-- m005.MCC_Name,m005.MCC_Code,
                ROUND(sum(IFNULL(f010.MilkPrice, 0)))as Amount,
                ROUND(sum(ifnull(f010.Dairy_Quantity_Ltr,0)),3) as Quality,
                concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate, '%d %b %Y')) as MusterCycle,
                var_StartDate as StartDate,var_EndDate as EndDate,
                'Milk Deposit'  as Entry_Type,
                '0' as Is_Voucher 
                FROM f010_milkcollectionmcc_final f010
                -- Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id 
                -- and m005.MCC_Id = f010.MCC_Id
                -- and m005.MCCType_Id like var_MCCType_Id
                -- and m005.MCCType_Id in('C014003')
                -- and m005.MCC_Id like var_MCC_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate
                and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and  f010.Is_OutsideInvoiceCreated = 0 
                -- and (f010.OutsideInvoice_Id = '' or f010.OutsideInvoice_Id IS NULL)
                and f010.Is_OutsideCheck = 0
                and f010.MCC_Id like var_MCC_Id
                group by 
                f010.Org_Id,
                f010.MCC_Id;

                end if;
                
                
				update temp_Farmer_Data_1 tmp
				inner join m005_mcc m005 on
				tmp.Org_Id = m005.Org_Id
				and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code;

				update temp_Farmer_Data_1 tmp
				inner join mu04_farmer mu04 on
				tmp.Org_Id = mu04.Org_Id
				and tmp.Farmer_Id = mu04.Farmer_Id
				set tmp.Farmer_Name = mu04.Farmer_Name,
				tmp.Farmer_Code = mu04.Farmer_Code;

				update temp_Farmer_Data_1 tmp
				inner join m005_mcc m005 on
				tmp.Org_Id = m005.Org_Id
				and tmp.Farmer_Id = m005.MCC_Id
				set tmp.Farmer_Name = m005.MCC_Name,
				tmp.Farmer_Code = m005.MCC_Code;


                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_2;
				CREATE TEMPORARY TABLE temp_Farmer_Data_2 ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                Amount decimal(30,3),Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,Entry_Type longtext,Is_Voucher varchar(20)
                );
				
				Insert into temp_Farmer_Data_2 (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount,Quality,MusterCycle,StartDate,EndDate,Entry_Type,Is_Voucher
				)
                SELECT 
					t033.Org_Id,
					mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
					m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
					round(sum(t0331.Deduction_Amount)) as Amount,
					0 as Quality,
					concat(DATE_FORMAT(t0331.MusterCycle_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(t0331.MusterCycle_EndDate , '%d %b %Y')) as MusterCycle,
					t0331.MusterCycle_StartDate as StartDate,t0331.MusterCycle_EndDate as EndDate,
					CASE
					WHEN t033.Request_Type = 'M020231000011' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000017' THEN 'Bank Loan'
					WHEN t033.Request_Type = 'M020231000015' THEN 'Dairy Advance'
					WHEN t033.Request_Type = 'M020231000012' THEN 'MCC Advance'
					WHEN t033.Request_Type = 'M020231000013' THEN 'Product Sales'
					WHEN t033.Request_Type = 'M020231000014' THEN 'Trading Material'
					ELSE ''
					END AS Entry_Type,
					'1' as Is_Voucher 
				FROM t033_deductions_header t033
				inner join t033_deductions_item t0331 on t0331.Org_Id = t033.Org_Id 
				and  t0331.Deductions_Id = t033.Deductions_Id 
				and  t0331.Is_Deducted = 0 
				AND date(t0331.Deduction_Date) BETWEEN var_StartDate AND var_EndDate
				and t0331.Deduction_Amount <> 0
				and t0331.Is_Check = 0
				and t0331.Is_InvoiceCreated =0
				and (t0331.Invoice_Id = '' or t0331.Invoice_Id IS NULL)
				inner join mu04_farmer mu04 on mu04.Org_Id = t033.Org_Id 
				and  mu04.Farmer_Id = t033.Request_User_Id 
				inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id 
				and  m005.MCC_Id = mu04.MCC_Id 
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
				where t033.Org_Id  = var_Org_Id
				and t033.Request_User_Type  ='Farmer'
				group by 
                t033.Org_Id,
				mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				t033.Request_Type,
				t0331.MusterCycle_StartDate,
				t0331.MusterCycle_EndDate ;
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Farmer_Data_Main;
				CREATE TEMPORARY TABLE temp_Farmer_Data_Main ( 
				Org_Id varchar(20),
				Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                -- Amount decimal(30,3),
                Quality decimal(30,3),MusterCycle longtext,
                StartDate date,EndDate date,
                -- Entry_Type longtext,
                -- Is_Voucher varchar(20),
                Milk_Deposit decimal(30,3),
                Bank_Loan decimal(30,3),
				Dairy_Advance decimal(30,3),
				MCC_Advance decimal(30,3),
				Product_Sales decimal(30,3),
				Trading_Material decimal(30,3),
                Freight decimal(30,3),
				Anamat decimal(30,3)
                );
                
                Insert into temp_Farmer_Data_Main (
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Milk_Deposit,Quality,MusterCycle,StartDate,EndDate
				)
                select 
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Amount as Milk_Deposit,
                Quality,MusterCycle,StartDate,EndDate
                from temp_Farmer_Data_1;
                
                
				Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Bank Loan'
				set tmp.Bank_Loan = Amount ;

				Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Dairy Advance'
				set tmp.Dairy_Advance = Amount ;
                
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'MCC Advance'
				set tmp.MCC_Advance = Amount ;
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Product Sales'
				set tmp.Product_Sales = Amount ;
                
                Update temp_Farmer_Data_Main tmp
				inner join temp_Farmer_Data_2 tmpc 
				on tmp.Org_Id = tmpc.Org_Id 
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmp.Farmer_Id = tmpc.Farmer_Id
				and tmp.MCC_Id = tmpc.MCC_Id
				and tmpc.Entry_Type = 'Trading Material'
				set tmp.Trading_Material = Amount ;
                
                DROP TEMPORARY TABLE IF EXISTS temp_anamat_farmer_1;
				CREATE TEMPORARY TABLE temp_anamat_farmer_1 ( 
				Org_Id varchar(20), MCC_Id varchar(20), 
				Max_Applicable_Date varchar(20),
				Anamat_Applicable_To varchar(20),
				Freight_Applicable_To varchar(20),
				Anamat_PerLtr decimal(8,2),
				Freight_PerLtr decimal(8,2)
				);
				
				Insert into temp_anamat_farmer_1 (
				Org_Id,MCC_Id,
				Max_Applicable_Date,
				Anamat_Applicable_To,
				Freight_Applicable_To,
				Anamat_PerLtr,Freight_PerLtr
				)
				SELECT 
					 m0051.Org_Id,
					 m0051.MCC_Id,
					 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr
				 FROM 
					 m005_mcc_version m0051
				Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
				and m005.MCC_Id = m0051.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
                and m0051.Is_Deleted = 0 
				 WHERE 
					 m0051.Org_Id = var_Org_Id
					 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				 GROUP BY 
					 m0051.Org_Id, m0051.MCC_Id,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
                     
				DROP TEMPORARY TABLE IF EXISTS temp_freight_farmer_1;
				CREATE TEMPORARY TABLE temp_freight_farmer_1 ( 
				Org_Id varchar(20), MCC_Id varchar(20), 
				Max_Applicable_Date varchar(20),
				Anamat_Applicable_To varchar(20),
				Freight_Applicable_To varchar(20),
				Anamat_PerLtr decimal(8,2),
				Freight_PerLtr decimal(8,2)
				);
				
				Insert into temp_freight_farmer_1 (
				Org_Id,MCC_Id,
				Max_Applicable_Date,
				Anamat_Applicable_To,
				Freight_Applicable_To,
				Anamat_PerLtr,Freight_PerLtr
				)
				SELECT 
					 m0051.Org_Id,
					 m0051.MCC_Id,
					 MAX(m0051.Applicable_Date) AS Max_Applicable_Date,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 Anamat_PerLtr,Freight_PerLtr
				 FROM 
					 m005_mcc_version m0051
				Inner Join m005_mcc m005 on m005.Org_Id = m0051.Org_Id 
				and m005.MCC_Id = m0051.MCC_Id
				and m005.MCCType_Id like var_MCCType_Id
				and m005.MCC_Id like var_MCC_Id
                and m0051.Is_Deleted = 0 
				 WHERE 
					 m0051.Org_Id = var_Org_Id
					 AND m0051.Applicable_Date <= CONVERT_TZ(var_EndDate, '+00:00', '+00:00')
				 GROUP BY 
					 m0051.Org_Id, m0051.MCC_Id,
					 m0051.Anamat_Applicable_To,
					 m0051.Freight_Applicable_To,
					 m0051.Anamat_PerLtr,m0051.Freight_PerLtr;
                     
                Update temp_Farmer_Data_Main tmp
                INNER JOIN 
				temp_anamat_farmer_1 max_dates ON tmp.Org_Id = max_dates.Org_Id 
				AND tmp.MCC_Id = max_dates.MCC_Id 
				and max_dates.Freight_Applicable_To = 'Farmer'
				set tmp.Anamat = IFNULL(tmp.Quality, 0) * IFNULL(max_dates.Anamat_PerLtr, 0);
                
                Update temp_Farmer_Data_Main tmp
                INNER JOIN 
				temp_freight_farmer_1 max_dates ON tmp.Org_Id = max_dates.Org_Id 
				AND tmp.MCC_Id = max_dates.MCC_Id 
				and max_dates.Freight_Applicable_To = 'Farmer'
				set tmp.Freight = IFNULL(tmp.Quality, 0) * IFNULL(max_dates.Freight_PerLtr, 0);
                     
				select 
                Org_Id,
				Farmer_Id,Farmer_Name,Farmer_Code,
                MCC_Id,MCC_Name,MCC_Code,
                Quality,
                MusterCycle,StartDate,EndDate,
                ifnull(Milk_Deposit,0.000) as Milk_Deposit,
                ifnull(Bank_Loan,0.000) as Bank_Loan,
                ifnull(Dairy_Advance,0.000) as Dairy_Advance,
                ifnull(MCC_Advance,0.000) as MCC_Advance,
                ifnull(Product_Sales,0.000) as Product_Sales,
                ifnull(Trading_Material,0.000) as Trading_Material,
				ifnull(Freight,0.000) as Freight,
                ifnull(Anamat,0.000) as Anamat
                from temp_Farmer_Data_Main;
            end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
