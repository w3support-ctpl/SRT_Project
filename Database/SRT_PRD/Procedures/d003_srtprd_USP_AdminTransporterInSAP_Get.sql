-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTransporterInSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTransporterInSAP_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_Invoice_Id varchar(20),
    var_ApprovalStatus_Id varchar(2)
)
BEGIN
	if(var_Method_Name = 'Get') then 
		begin
			select
				t029.Voucher_Id as Invoice_Id,t029.Invoice_No,
				DATE_FORMAT(t029.Invoice_Date, '%d %b %Y') AS Invoice_Date,
				m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
                ifnull(t029.SAP_Document_Id,'')  as Income_Document,
				CONCAT(
				DATE_FORMAT(t029.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t029.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				t029.Invoice_Amount as Amount,
				t029.Is_Posted as Is_Posted
				FROM t029_invoice_transpoter t029
				Inner Join m009_transporter m009 on m009.Transporter_Id = t029.Transporter_Id
                and  m009.Org_Id = t029.Org_Id
				where  t029.Org_Id = var_Org_Id
				-- and t029.Invoice_Date <= var_Date
                and t029.Invoice_Date = var_Date
				and t029.Is_Posted = var_ApprovalStatus_Id;
		end;
    elseif (var_Method_Name = 'Get_One') then
		begin
			SELECT 
					t029.Voucher_Id as Invoice_Id,t029.Invoice_No,
					t029.Invoice_Amount as Amount,
					m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code
				FROM t029_invoice_transpoter t029
				Inner Join m009_transporter m009 on m009.Transporter_Id = t029.Transporter_Id
                and  m009.Transporter_Id = t029.Org_Id
				where t029.Org_Id = var_Org_Id
                and t029.Voucher_Id = var_Invoice_Id;
		end;
	elseif (var_Method_Name = 'Get_Generate') then
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            SELECT * FROM (
            SELECT t021.TripDocument_Id as Check_Id, 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			ifnull(t021.Cost ,'' )as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Transporter' as Entry_Type,
			'0' as Is_Voucher 
			FROM t021_tripdocument_header t021
			inner join m003_vehicle m003 on  m003.Org_Id = t021.Org_Id 
				and m003.Vehicle_Id = t021.Vehicle_Id
                and m003.VehicleOwnershipType_Id = 'C021002'
			inner join m009_transporter m009 on  m003.Org_Id = m009.Org_Id 
				and m003.Transporter_Id = m009.Transporter_Id
			where t021.Org_Id = var_Org_Id 
			and t021.Is_TripDocument_Locked =1
            AND t021.Is_InvoiceCreated = 0 
			and t021.Is_Check = 0
			AND (t021.Invoice_Id = '' OR t021.Invoice_Id IS NULL)
			AND date(t021.Created_On) >= var_StartDate 
			AND date(t021.Created_On) <= var_EndDate
            union all
            
            SELECT 
			t0331.Entry_Id as Check_Id,
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
			t0331.Deduction_Amount as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			 CASE
				WHEN t033.Request_Type = 'M020231000001' THEN 'Sec Dep'
				WHEN t033.Request_Type = 'M020231000002' THEN 'Diesel Recovery'
				WHEN t033.Request_Type = 'M020231000003' THEN 'Advance'
				WHEN t033.Request_Type = 'M020231000004' THEN 'Bank Loan'
                WHEN t033.Request_Type = 'M020231000018' THEN 'Bank Loan'
				WHEN t033.Request_Type = 'M020231000005' THEN 'Can Recovery Charges'
				WHEN t033.Request_Type = 'M020231000006' THEN 'TDS'
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
			inner JOIN m009_transporter m009 ON m009.Org_Id = t033.Org_Id 
			AND t033.Request_User_Id = m009.Transporter_Id
			where t033.Org_Id  = var_Org_Id
			and t033.Request_User_Type  ='Transporter'
            
            union all
            
            SELECT 
			t0421.Entry_Id as Check_Id,
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
			t0421.Incentive_Amount as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
				CASE
				WHEN t042.Request_Type = 'M020232000001' THEN 'Cattle Feed'
				ELSE ''
				END AS Entry_Type,
				'2' as Is_Voucher 
			FROM t042_incentives_header t042
			inner join t042_incentives_item t0421 on t0421.Org_Id = t042.Org_Id 
			and  t0421.Incentives_Id = t042.Incentives_Id 
			and  t0421.Is_Paid = 0 
			AND date(t0421.Incentive_Date) BETWEEN var_StartDate AND var_EndDate
			and t0421.Incentive_Amount <> 0
			and t0421.Is_Check = 0
			and t0421.Is_InvoiceCreated =0
			and (t0421.Invoice_Id = '' or t0421.Invoice_Id IS NULL)
			inner JOIN m009_transporter m009 ON m009.Org_Id = t042.Org_Id 
			AND t042.Request_User_Id = m009.Transporter_Id
			where t042.Org_Id  = var_Org_Id
			and t042.Request_User_Type  ='Transporter'
            union all
            
            SELECT m003.Vehicle_Id as Check_Id, 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			ifnull(m003.LabourCharge ,'' )as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Labour Charges' as Entry_Type,
			'3' as Is_Voucher 
			FROM m003_vehicle m003
                -- and m003.VehicleOwnershipType_Id = 'C021002'
			inner join m009_transporter m009 on  m003.Org_Id = m009.Org_Id 
				and m003.Transporter_Id = m009.Transporter_Id
			where m003.Org_Id = var_Org_Id
            and m003.LabourCharge <> 0
            
            union all
            
            SELECT t021.Transporter_Id as Check_Id, 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			-- IFNULL(t021.Total_Freight, 0) - IFNULL(t021.Cost, 0) as Amount,
            case when t021.Average_KM <> 0 then 
			ROUND(((IFNULL(t021.FinalDistance, 0) / IFNULL(t021.Average_KM ,0)) * IFNULL(t021.Diesel_Difference,0)), 0)
			else  0 end
            as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Diesel Rate Diff' as Entry_Type,
			'4' as Is_Voucher 
			FROM t021_tripdocument_header t021
			inner join m009_transporter m009 on  t021.Org_Id = m009.Org_Id 
			and m009.Transporter_Id = t021.Transporter_Id
			where t021.Org_Id = var_Org_Id 
			and t021.FreightRateType_Id <> 'C029003'
			and t021.Is_TripDocument_Locked =1
			AND t021.Is_InvoiceCreated = 0 
			and t021.Is_Check = 0
			AND (t021.Invoice_Id = '' OR t021.Invoice_Id IS NULL)
			AND date(t021.Created_On) >= var_StartDate 
			AND date(t021.Created_On) <= var_EndDate
            
            union all
            
            SELECT 
			t043.Entry_Id as Check_Id,
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
			ifnull(t043.Amount,0) as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			 'Recovery Amount' as  Entry_Type,
			  '5' as Is_Voucher 
			FROM t043_dieselupload t043
			inner JOIN m009_transporter m009 ON m009.Org_Id = t043.Org_Id 
			AND t043.Transporter_Id = m009.Transporter_Id
			where t043.Org_Id  = var_Org_Id
			AND date(t043.Entry_Date) BETWEEN var_StartDate AND var_EndDate
			and t043.Quantity_Ltr <> 0
			and t043.Is_Check = 0
			and t043.Is_InvoiceCreated =0
			and (t043.Invoice_Id = '' or t043.Invoice_Id IS NULL)
            
			) AS subquery
			ORDER BY subquery.Transporter_Name asc;
		end;
	elseif (var_Method_Name = 'Get_GenerateSum') then
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            SELECT * FROM (
            SELECT 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			sum(ifnull(t021.Cost ,0 ))as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Transporter' as Entry_Type,
			'0' as Is_Voucher 
			FROM t021_tripdocument_header t021
			inner join m003_vehicle m003 on  m003.Org_Id = t021.Org_Id 
				and m003.Vehicle_Id = t021.Vehicle_Id
                and m003.VehicleOwnershipType_Id = 'C021002'
			inner join m009_transporter m009 on  m003.Org_Id = m009.Org_Id 
				and m003.Transporter_Id = m009.Transporter_Id
			where t021.Org_Id = var_Org_Id 
			and t021.Is_TripDocument_Locked =1
            AND t021.Is_InvoiceCreated = 0 
			and t021.Is_Check = 0
			AND (t021.Invoice_Id = '' OR t021.Invoice_Id IS NULL)
			AND date(t021.Created_On) >= var_StartDate 
			AND date(t021.Created_On) <= var_EndDate
            group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code
            union all
            
            SELECT 
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
            sum(ifnull(t0331.Deduction_Amount ,0 )) as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			 CASE
				WHEN t033.Request_Type = 'M020231000001' THEN 'Sec Dep'
				WHEN t033.Request_Type = 'M020231000002' THEN 'Diesel Recovery'
				WHEN t033.Request_Type = 'M020231000003' THEN 'Advance'
				WHEN t033.Request_Type = 'M020231000004' THEN 'Bank Loan'
                WHEN t033.Request_Type = 'M020231000018' THEN 'Bank Loan'
				WHEN t033.Request_Type = 'M020231000005' THEN 'Can Recovery Charges'
				WHEN t033.Request_Type = 'M020231000006' THEN 'TDS'
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
			inner JOIN m009_transporter m009 ON m009.Org_Id = t033.Org_Id 
			AND t033.Request_User_Id = m009.Transporter_Id
			where t033.Org_Id  = var_Org_Id
			and t033.Request_User_Type  ='Transporter'
            group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
            t033.Request_Type
            
            union all
            
            SELECT 
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
			sum(ifnull(t0421.Incentive_Amount ,0 )) as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
				CASE
				WHEN t042.Request_Type = 'M020232000001' THEN 'Cattle Feed'
				ELSE ''
				END AS Entry_Type,
				'2' as Is_Voucher 
			FROM t042_incentives_header t042
			inner join t042_incentives_item t0421 on t0421.Org_Id = t042.Org_Id 
			and  t0421.Incentives_Id = t042.Incentives_Id 
			and  t0421.Is_Paid = 0 
			AND date(t0421.Incentive_Date) BETWEEN var_StartDate AND var_EndDate
			and t0421.Incentive_Amount <> 0
			and t0421.Is_Check = 0
			and t0421.Is_InvoiceCreated =0
			and (t0421.Invoice_Id = '' or t0421.Invoice_Id IS NULL)
			inner JOIN m009_transporter m009 ON m009.Org_Id = t042.Org_Id 
			AND t042.Request_User_Id = m009.Transporter_Id
			where t042.Org_Id  = var_Org_Id
			and t042.Request_User_Type  ='Transporter'
			group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
            t042.Request_Type
            
            
            union all
            
            SELECT  
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			ifnull(m003.LabourCharge ,'' )as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Labour Charges' as Entry_Type,
			'3' as Is_Voucher 
			FROM m003_vehicle m003
                -- and m003.VehicleOwnershipType_Id = 'C021002'
			inner join m009_transporter m009 on  m003.Org_Id = m009.Org_Id 
				and m003.Transporter_Id = m009.Transporter_Id
			where m003.Org_Id = var_Org_Id
            and m003.LabourCharge <> 0
            union all
            SELECT 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			COALESCE(ROUND(SUM((IFNULL(t021.FinalDistance, 0) / IFNULL(t021.Average_KM ,0)) * IFNULL(t021.Diesel_Difference,0)), 0), 0) as Amount,
            -- COALESCE(SUM(ROUND((IFNULL(t021.FinalDistance, 0) / NULLIF(t021.Average_KM, 0)) * IFNULL(t021.Diesel_Difference, 0), 0)), 0) AS Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			'Diesel Rate Diff' as Entry_Type,
			'4' as Is_Voucher 
			FROM t021_tripdocument_header t021
			inner join m009_transporter m009 on  t021.Org_Id = m009.Org_Id 
			and m009.Transporter_Id = t021.Transporter_Id
			where t021.Org_Id = var_Org_Id
			and t021.FreightRateType_Id <> 'C029003'
			and t021.Is_TripDocument_Locked =1
			AND t021.Is_InvoiceCreated = 0 
			and t021.Is_Check = 0
			AND (t021.Invoice_Id = '' OR t021.Invoice_Id IS NULL)
			AND date(t021.Created_On) >= var_StartDate 
			AND date(t021.Created_On) <= var_EndDate
			group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code
            
            union all
            
            SELECT 
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
            sum(ifnull(t043.Amount  ,0 ))as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			 'Recovery Amount' as  Entry_Type,
			  '5' as Is_Voucher 
			FROM t043_dieselupload t043
			inner JOIN m009_transporter m009 ON m009.Org_Id = t043.Org_Id 
			AND t043.Transporter_Id = m009.Transporter_Id
			where t043.Org_Id  = var_Org_Id
			AND date(t043.Entry_Date) BETWEEN var_StartDate AND var_EndDate
			and t043.Quantity_Ltr <> 0
			and t043.Is_Check = 0
			and t043.Is_InvoiceCreated =0
			and (t043.Invoice_Id = '' or t043.Invoice_Id IS NULL)
            group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code
            
            union all
            
            SELECT 
			ifnull(m009.Transporter_Id,'') as Transporter_Id, 
			ifnull(m009.Transporter_Name,'') as Transporter_Name, 
			ifnull(m009.Transporter_Code,'') as Transporter_Code, 
            sum(ifnull(t043.Quantity_Ltr  ,0 ))as Amount,
			'' as Particulars,
			var_StartDate as StartDate,
			var_EndDate as EndDate,
			DATE_FORMAT(var_EndDate, '%d %b %Y') AS Entry_On,
			 'Recovery Ltr' as  Entry_Type,
			  '5' as Is_Voucher 
			FROM t043_dieselupload t043
			inner JOIN m009_transporter m009 ON m009.Org_Id = t043.Org_Id 
			AND t043.Transporter_Id = m009.Transporter_Id
			where t043.Org_Id  = var_Org_Id
			AND date(t043.Entry_Date) BETWEEN var_StartDate AND var_EndDate
			and t043.Quantity_Ltr <> 0
			and t043.Is_Check = 0
			and t043.Is_InvoiceCreated =0
			and (t043.Invoice_Id = '' or t043.Invoice_Id IS NULL)
            group by m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code
            
			) AS subquery
			ORDER BY subquery.Transporter_Name asc;
		end;
	
    elseif (var_Method_Name = 'Get_Voucher') then 
		begin
			
            DECLARE MilkTransportCost decimal(20,2);
			DECLARE DieselRateDifference decimal(20,2);
			DECLARE CattleFeedTransportCharges decimal(20,2);
			DECLARE DieselRecovery decimal(20,2);
			DECLARE MilkTransportPayment decimal(20,2);
			DECLARE SecurityDeposit decimal(20,2);
            DECLARE CanRecoveryCharges decimal(20,2);
			DECLARE Loan decimal(20,2);
			DECLARE AdvanceRecovered decimal(20,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE AccountingDocumentType varchar(255);
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount1 varchar(255);
			DECLARE GLAccount2 varchar(255);
			DECLARE GLAccount3 varchar(255);
			DECLARE GLAccount4 varchar(255);
            DECLARE GLAccount5 varchar(255);
            DECLARE GLAccount6 varchar(255);
            DECLARE GLAccount7 varchar(255);
            DECLARE GLAccount8 varchar(255);
            DECLARE GLAccount9 varchar(255);
            DECLARE Creditor_Debtor varchar(50);
			
			Set CattleFeedTransportCharges = 0;
			-- Set DieselRecovery = 0;
			-- Set SecurityDeposit = 0;
			-- Set Loan = 0;
			-- Set AdvanceRecovered = 0;
            -- Set CanRecoveryCharges = 0;
            
            

			
			Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
			set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
			SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'AccountingDocumentType';
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount1';
			SELECT Constant_Value into GLAccount2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount2';
			SELECT Constant_Value into GLAccount3  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount3';
			SELECT Constant_Value into GLAccount4  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount4';
			SELECT GL_Code into GLAccount5  FROM m020_deductions_head where Org_Id = var_Org_Id and User_Type ='Transporter' and DeductionHead_Name = 'Advance';
			SELECT GL_Code into GLAccount6  FROM m020_deductions_head where Org_Id = var_Org_Id and User_Type ='Transporter' and DeductionHead_Name = 'Diesel Recovery';
			SELECT GL_Code into GLAccount7  FROM m020_deductions_head where Org_Id = var_Org_Id and User_Type ='Transporter' and DeductionHead_Name = 'Sec Dep';
			SELECT GL_Code into GLAccount8  FROM m020_deductions_head where Org_Id = var_Org_Id and User_Type ='Transporter' and DeductionHead_Name = 'Bank EMI';
            SELECT GL_Code into GLAccount9  FROM m020_deductions_head where Org_Id = var_Org_Id and User_Type ='Transporter' and DeductionHead_Name = 'Can Recovery Charges';
            
            SELECT m009.Transporter_Code  into Creditor_Debtor 
			FROM t029_invoice_transpoter t029
			inner join  m009_transporter m009 on m009.Org_Id = t029.Org_Id 
				and m009.Transporter_Id = t029.Transporter_Id 
			where t029.Org_Id = var_Org_Id
			and t029.Voucher_Id = var_Invoice_Id;
            
            SELECT Invoice_Amount into MilkTransportCost  FROM t029_invoice_transpoter t029
			where t029.Org_Id = var_Org_Id
			and t029.Voucher_Id = var_Invoice_Id;
            
            SELECT SUM(Average_Liters * Diesel_Difference) into DieselRateDifference
			FROM t021_tripdocument_header 
			where Org_Id = var_Org_Id
			and Invoice_Id = var_Invoice_Id;
            
			
            select SUM(t0331.Deduction_Amount)into AdvanceRecovered from t029_invoice_transpoter t029 
			inner join t033_deductions_item t0331 on t0331.Org_Id = t029.Org_Id
				and t0331.Invoice_Id = t029.Voucher_Id
			inner join t033_deductions_header t033 on t0331.Org_Id = t033.Org_Id
				and t0331.Deductions_Id = t033.Deductions_Id
			inner join m020_deductions_head m020 on m020.Org_Id = t033.Org_Id
				and m020.DeductionHead_Id = t033.Request_Type
				and m020.User_Type ='Transporter' 
				and m020.DeductionHead_Name = 'Advance'
			where t029.Org_Id = var_Org_Id
			and Voucher_Id = var_Invoice_Id;
            
            select SUM(t0331.Deduction_Amount) into SecurityDeposit from t029_invoice_transpoter t029 
			inner join t033_deductions_item t0331 on t0331.Org_Id = t029.Org_Id
				and t0331.Invoice_Id = t029.Voucher_Id
			inner join t033_deductions_header t033 on t0331.Org_Id = t033.Org_Id
				and t0331.Deductions_Id = t033.Deductions_Id
			inner join m020_deductions_head m020 on m020.Org_Id = t033.Org_Id
				and m020.DeductionHead_Id = t033.Request_Type
				and m020.User_Type ='Transporter' 
				and m020.DeductionHead_Name = 'Sec Dep'
			where t029.Org_Id = var_Org_Id
			and Voucher_Id = var_Invoice_Id;
            
            select SUM(t0331.Deduction_Amount) into DieselRecovery from t029_invoice_transpoter t029 
			inner join t033_deductions_item t0331 on t0331.Org_Id = t029.Org_Id
				and t0331.Invoice_Id = t029.Voucher_Id
			inner join t033_deductions_header t033 on t0331.Org_Id = t033.Org_Id
				and t0331.Deductions_Id = t033.Deductions_Id
			inner join m020_deductions_head m020 on m020.Org_Id = t033.Org_Id
				and m020.DeductionHead_Id = t033.Request_Type
				and m020.User_Type ='Transporter' 
				and m020.DeductionHead_Name = 'Diesel Recovery'
			where t029.Org_Id = var_Org_Id
			and Voucher_Id = var_Invoice_Id;
            
            select SUM(t0331.Deduction_Amount) into Loan from t029_invoice_transpoter t029 
			inner join t033_deductions_item t0331 on t0331.Org_Id = t029.Org_Id
				and t0331.Invoice_Id = t029.Voucher_Id
			inner join t033_deductions_header t033 on t0331.Org_Id = t033.Org_Id
				and t0331.Deductions_Id = t033.Deductions_Id
			inner join m020_deductions_head m020 on m020.Org_Id = t033.Org_Id
				and m020.DeductionHead_Id = t033.Request_Type
				and m020.User_Type ='Transporter' 
				and m020.DeductionHead_Name = 'Bank EMI'
			where t029.Org_Id = var_Org_Id
			and Voucher_Id = var_Invoice_Id;
            
            select SUM(t0331.Deduction_Amount) into CanRecoveryCharges from t029_invoice_transpoter t029 
			inner join t033_deductions_item t0331 on t0331.Org_Id = t029.Org_Id
				and t0331.Invoice_Id = t029.Voucher_Id
			inner join t033_deductions_header t033 on t0331.Org_Id = t033.Org_Id
				and t0331.Deductions_Id = t033.Deductions_Id
			inner join m020_deductions_head m020 on m020.Org_Id = t033.Org_Id
				and m020.DeductionHead_Id = t033.Request_Type
				and m020.User_Type ='Transporter' 
				and m020.DeductionHead_Name = 'Can Recovery Charges'
			where t029.Org_Id = var_Org_Id
			and Voucher_Id = var_Invoice_Id;
            
            set MilkTransportPayment =  (
            ifnull(abs(MilkTransportCost),0) + 
            ifnull(DieselRateDifference,0)
             + 
            ifnull(CattleFeedTransportCharges,0)
             +
            ifnull(DieselRecovery,0)
			  + 
            ifnull(SecurityDeposit,0)
             + 
            ifnull(Loan,0)
             + 
            ifnull(AdvanceRecovered,0)
             + 
            ifnull(CanRecoveryCharges,0)
            ) ;
            
                    
  SET xmlData  = concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
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
					<!--Zero or more repetitions:-->\n                \n                
				</MessageHeader>\n                
				<JournalEntry>\n                    
					<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
					<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
					<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
					<AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n                    
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

			IF MilkTransportCost IS NOT NULL AND MilkTransportCost != '' AND MilkTransportCost <> 0 THEN
				if(MilkTransportCost < 0)then
				SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',GLAccount1,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',MilkTransportCost,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter></CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                elseif(MilkTransportCost > 0)then
                SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',GLAccount1,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',MilkTransportCost,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter></CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                end if;
                
				SET Counter = Counter + 1;
				END IF;  

			IF DieselRateDifference IS NOT NULL AND DieselRateDifference != '' AND DieselRateDifference <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',GLAccount2,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',DieselRateDifference,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Rate Difference </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF;
			
			IF CattleFeedTransportCharges IS NOT NULL AND CattleFeedTransportCharges != '' AND CattleFeedTransportCharges <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',GLAccount3,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',CattleFeedTransportCharges,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Cattlefeed Transport Charges </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
				SET Counter = Counter + 1;
				END IF; 

			IF DieselRecovery IS NOT NULL AND DieselRecovery != '' AND DieselRecovery <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',GLAccount6,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',DieselRecovery,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Recovery </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

			IF MilkTransportPayment IS NOT NULL AND MilkTransportPayment != '' AND MilkTransportPayment <> 0 THEN
				SET xmlData = CONCAT(xmlData,'         
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',MilkTransportPayment,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
						<DocumentItemText>Milk Transport Payment </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF;    

			IF SecurityDeposit IS NOT NULL AND SecurityDeposit != '' AND SecurityDeposit <> 0 THEN
				SET xmlData = CONCAT(xmlData,'                
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',SecurityDeposit,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',GLAccount7,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Security Deposit </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF;   

			IF Loan IS NOT NULL AND Loan != '' AND Loan <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',Loan,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',GLAccount8,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Loan </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

			IF AdvanceRecovered IS NOT NULL AND AdvanceRecovered != '' AND AdvanceRecovered <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',AdvanceRecovered,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',GLAccount5,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Advance Recovered </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF; 
                
                IF CanRecoveryCharges IS NOT NULL AND CanRecoveryCharges != '' AND CanRecoveryCharges <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',CanRecoveryCharges,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',GLAccount9,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Can Recovery Charges </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;

				SET xmlData = CONCAT(xmlData,' 

					<!--Zero or more repetitons:-->\n                    
					<!--Zero or more repetitions:-->\n                \n                
				</JournalEntry>\n            
			</JournalEntryCreateRequest>\n        
		</sfin:JournalEntryBulkCreateRequest>\n    
	</soapenv:Body>\n
</soapenv:Envelope>');
SELECT xmlData;
                    
                    
        end;
    elseif (var_Method_Name = 'Get_Voucher_Deductions') then 
    begin
    
    DECLARE DieselRateDifferenceAmount decimal(30,2);
    DECLARE BankAdvanceAmount decimal(30,2);
    DECLARE DieselRecoveryAmount decimal(30,2);
    DECLARE SecurityDepositAmount decimal(30,2);
    DECLARE BankLoanAmount decimal(30,2);
    DECLARE CanRecoveryChargesAmount decimal(30,2);
    DECLARE TDSAmount decimal(30,2);
    DECLARE DieselRateDifference_GLCode varchar(255);
    DECLARE BankAdvance_GLCode varchar(255);
    DECLARE DieselRecovery_GLCode varchar(255);
    DECLARE SecurityDeposit_GLCode varchar(255);
    DECLARE BankLoan_GLCode varchar(255);
    DECLARE CanRecoveryCharges_GLCode varchar(255);
    DECLARE TDS_GLCode varchar(255);
    DECLARE DateTime varchar(255);
    DECLARE Date varchar(255);
    DECLARE MusterCycle varchar(255);
    DECLARE xmlData longtext;
    DECLARE Counter INT DEFAULT 1;
    DECLARE AccountingDocumentType varchar(255);
    DECLARE CompanyCode varchar(255);
    DECLARE Creditor_Debtor varchar(50);
    DECLARE TotalAmount decimal(30,2);


    Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
	set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
    SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'AccountingDocumentType';
	SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'CompanyCode';
    SELECT Constant_Value into DieselRateDifference_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount2';
    
    SELECT GL_Code into SecurityDeposit_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id ='M020231000001';
    
    SELECT GL_Code into DieselRecovery_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000002';
    
    SELECT GL_Code into BankAdvance_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id ='M020231000003';
    
    SELECT GL_Code into BankLoan_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000004';
    
    SELECT GL_Code into CanRecoveryCharges_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000005';
    
    SELECT GL_Code into TDS_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000006';
    
    SELECT m009.Transporter_Code  into Creditor_Debtor 
    FROM t029_invoice_transpoter t029
    inner join  m009_transporter m009 on m009.Org_Id = t029.Org_Id 
        and m009.Transporter_Id = t029.Transporter_Id 
    where t029.Org_Id = var_Org_Id
    and t029.Voucher_Id = var_Invoice_Id;

    SELECT 
        CONCAT(DATE_FORMAT(t029.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t029.MusterCycle_EndDate, '%d.%m.%y')),
        DATE_FORMAT(CONVERT_TZ(t029.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
        into 
        MusterCycle,
        Date
    FROM t029_invoice_transpoter t029
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id
    GROUP BY
        t029.MusterCycle_StartDate,t029.MusterCycle_EndDate;

    -- DieselRateDifferenceAmount

    SELECT 
    COALESCE(ROUND(SUM(IFNULL(Average_Liters, 0) * IFNULL(Diesel_Difference, 0)), 2), 0)
    into DieselRateDifferenceAmount
    FROM t021_tripdocument_header 
    where Org_Id = var_Org_Id
    and Invoice_Id = var_Invoice_Id;

    -- SecurityDepositAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  SecurityDepositAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000001'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- DieselRecoveryAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  DieselRecoveryAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000002'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankAdvanceAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankAdvanceAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000003'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankLoanAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoanAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000004'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- CanRecoveryChargesAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  CanRecoveryChargesAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000005'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    
    -- TDSAmount

     SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  TDSAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000006'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

     set TotalAmount =   round(DieselRateDifferenceAmount) + round(SecurityDepositAmount)
									+ round(DieselRecoveryAmount) + round(BankAdvanceAmount) 
									+ round(BankLoanAmount) + round(CanRecoveryChargesAmount)
									+ round(TDSAmount);
                                    
    if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
        UPDATE t029_invoice_transpoter t029
        SET t029.Is_DeductionPosted = 4
        WHERE t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    end if;

      SET xmlData  = concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
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
                            <!--Zero or more repetitions:-->\n                \n                
                        </MessageHeader>\n                
                        <JournalEntry>\n                    
                            <OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
                            <OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
                            <BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
                            <AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n                    
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

                IF DieselRateDifferenceAmount IS NOT NULL AND DieselRateDifferenceAmount != '' AND DieselRateDifferenceAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRateDifference_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(DieselRateDifference),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Rate Difference from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                IF DieselRecoveryAmount IS NOT NULL AND DieselRecoveryAmount != '' AND DieselRecoveryAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRecovery_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(DieselRecoveryAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Recovery from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

                IF TotalAmount IS NOT NULL AND TotalAmount != '' AND TotalAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'         
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(TotalAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
						<DocumentItemText>Milk Transport Payment from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF;   

            IF SecurityDepositAmount IS NOT NULL AND SecurityDepositAmount != '' AND SecurityDepositAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'                
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(SecurityDepositAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',SecurityDeposit_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Security Deposit from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF; 

                IF BankLoanAmount IS NOT NULL AND BankLoanAmount != '' AND BankLoanAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankLoanAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',BankLoan_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Loan from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

                IF BankAdvanceAmount IS NOT NULL AND BankAdvanceAmount != '' AND BankAdvanceAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankAdvanceAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',BankAdvance_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Advance Recovered from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                IF CanRecoveryChargesAmount IS NOT NULL AND CanRecoveryChargesAmount != '' AND CanRecoveryChargesAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(CanRecoveryChargesAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',CanRecoveryCharges_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Can Recovery Charges from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                SET xmlData = CONCAT(xmlData,' 

                                    <!--Zero or more repetitons:-->\n                    
                                    <!--Zero or more repetitions:-->\n                \n                
                                </JournalEntry>\n            
                            </JournalEntryCreateRequest>\n        
                        </sfin:JournalEntryBulkCreateRequest>\n    
                    </soapenv:Body>\n
                </soapenv:Envelope>');
                SELECT xmlData;

    end;        
	
    /*
    elseif (var_Method_Name = 'Get_Voucher_IncomeDeductions') then 
    begin
    DECLARE MilkTransportAmount decimal(30,2);
    DECLARE CattleFeedAmount decimal(30,2);
    DECLARE LabourChargesAmount decimal(30,2);

    DECLARE DieselRateDifferenceAmount decimal(30,2);
    DECLARE BankAdvanceAmount decimal(30,2);
    DECLARE DieselRecoveryAmount decimal(30,2);
    DECLARE SecurityDepositAmount decimal(30,2);
    DECLARE BankLoanAmount decimal(30,2);
    DECLARE CanRecoveryChargesAmount decimal(30,2);
    DECLARE TDSAmount decimal(30,2);

    DECLARE MilkTransport_GLCode varchar(255);
    DECLARE CattleFeed_GLCode varchar(255);
    DECLARE LabourCharges_GLCode varchar(255);

    DECLARE DieselRateDifference_GLCode varchar(255);
    DECLARE BankAdvance_GLCode varchar(255);
    DECLARE DieselRecovery_GLCode varchar(255);
    DECLARE SecurityDeposit_GLCode varchar(255);
    DECLARE BankLoan_GLCode varchar(255);
    DECLARE CanRecoveryCharges_GLCode varchar(255);
    DECLARE TDS_GLCode varchar(255);
    
    DECLARE DateTime varchar(255);
    DECLARE Date varchar(255);
    DECLARE MusterCycle varchar(255);
    DECLARE xmlData longtext;
    DECLARE Counter INT DEFAULT 1;
    DECLARE AccountingDocumentType varchar(255);
    DECLARE CompanyCode varchar(255);
    DECLARE Creditor_Debtor varchar(50);
    DECLARE TotalAmount decimal(30,2);


    Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
	set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
    SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'AccountingDocumentType';
	SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'CompanyCode';
    SELECT Constant_Value into DieselRateDifference_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount2';
    SELECT Constant_Value into MilkTransport_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount1';
    
    SELECT GL_Code into CattleFeed_GLCode 
    FROM m020_incentives_head 
    where Org_Id = var_Org_Id
    and IncentiveHead_Id ='M020232000001';

    SELECT GL_Code into SecurityDeposit_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id  ='M020231000001';
    
    SELECT GL_Code into DieselRecovery_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000002';
    
    SELECT GL_Code into BankAdvance_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id ='M020231000003';
    
    SELECT GL_Code into BankLoan_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000004';
    
    SELECT GL_Code into CanRecoveryCharges_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000005';
    
    SELECT GL_Code into TDS_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000006';
    
    


    SELECT m009.Transporter_Code  into Creditor_Debtor 
    FROM t029_invoice_transpoter t029
    inner join  m009_transporter m009 on m009.Org_Id = t029.Org_Id 
        and m009.Transporter_Id = t029.Transporter_Id 
    where t029.Org_Id = var_Org_Id
    and t029.Voucher_Id = var_Invoice_Id;

    SELECT 
        CONCAT(DATE_FORMAT(t029.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t029.MusterCycle_EndDate, '%d.%m.%y')),
        DATE_FORMAT(CONVERT_TZ(t029.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
        into 
        MusterCycle,
        Date
    FROM t029_invoice_transpoter t029
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id
    GROUP BY
        t029.MusterCycle_StartDate,t029.MusterCycle_EndDate;

    -- MilkTransportAmount

    SELECT 
    COALESCE(ROUND(SUM(IFNULL(Total_Freight,0)), 2), 0)
    into MilkTransportAmount
    FROM t021_tripdocument_header 
    where Org_Id = var_Org_Id
    and Invoice_Id = var_Invoice_Id;
    
    -- LabourChargesAmount
    
    SELECT  
    COALESCE(ROUND(SUM(IFNULL(m003.LabourCharge, 0)), 2), 0)
    into LabourChargesAmount
    FROM t029_invoice_transpoter  t029
    inner join m009_transporter m009 on
    m009.Org_Id = t029.Org_Id 
    and m009.Transporter_Id = t029.Transporter_Id 
    inner join m003_vehicle m003 on
    m003.Org_Id = t029.Org_Id 
    and m009.Transporter_Id = m003.Transporter_Id 
    where t029.Org_Id = var_Org_Id
    and t029.Voucher_Id = var_Invoice_Id
    limit 1;

    -- CattleFeedAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t042.Incentive_Amount, 0)), 0) into  CattleFeedAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t042_incentives_item t042 ON t042.Org_Id = t029.Org_Id 
    AND t042.Invoice_Id = t029.Voucher_Id
    INNER JOIN t042_incentives_header t0421 ON t042.Org_Id = t0421.Org_Id 
    AND t042.Incentives_Id = t0421.Incentives_Id
    AND t0421.Request_Type = 'M020232000001'
    WHERE 
		t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- DieselRateDifferenceAmount

    SELECT 
    COALESCE(ROUND(SUM(IFNULL(Average_Liters, 0) * IFNULL(Diesel_Difference, 0)), 2), 0)
    into DieselRateDifferenceAmount
    FROM t021_tripdocument_header 
    where Org_Id = var_Org_Id
    and FreightRateType_Id = 'C029002'
    and Invoice_Id = var_Invoice_Id;

    -- SecurityDepositAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  SecurityDepositAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000001'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- DieselRecoveryAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  DieselRecoveryAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000002'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankAdvanceAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankAdvanceAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000003'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankLoanAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoanAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000004'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- CanRecoveryChargesAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  CanRecoveryChargesAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000005'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    
    -- TDSAmount

     SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  TDSAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000006'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
        
      

     set TotalAmount =   round(DieselRateDifferenceAmount) + round(SecurityDepositAmount)
									+ round(DieselRecoveryAmount) + round(BankAdvanceAmount) 
									+ round(BankLoanAmount) + round(CanRecoveryChargesAmount)
									+ round(MilkTransportAmount) + round(CattleFeedAmount);
	  
    if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
        UPDATE t029_invoice_transpoter t029
        SET t029.Is_DeductionPosted = 4
        WHERE t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    end if;

      SET xmlData  = concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
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
                            <!--Zero or more repetitions:-->\n                \n                
                        </MessageHeader>\n                
                        <JournalEntry>\n                    
                            <OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
                            <OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
                            <BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
                            <AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n                    
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


                IF MilkTransportAmount IS NOT NULL AND MilkTransportAmount != '' AND MilkTransportAmount <> 0 THEN
				if(MilkTransportAmount < 0)then
				SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',MilkTransport_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',MilkTransportAmount,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter></CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                elseif(MilkTransportAmount > 0)then
                SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',MilkTransport_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(MilkTransportAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter></CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                end if;
                
				SET Counter = Counter + 1;
				END IF;  

                IF CattleFeedAmount IS NOT NULL AND CattleFeedAmount != '' AND CattleFeedAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',CattleFeed_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(CattleFeedAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Cattlefeed Transport Charges </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
				SET Counter = Counter + 1;
				END IF; 

				IF LabourChargesAmount IS NOT NULL AND LabourChargesAmount != '' AND LabourChargesAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',LabourCharges_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(LabourChargesAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Cattlefeed Transport Charges </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
				SET Counter = Counter + 1;
				END IF; 
                
                IF DieselRateDifferenceAmount IS NOT NULL AND DieselRateDifferenceAmount != '' AND DieselRateDifferenceAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRateDifference_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(DieselRateDifference),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Rate Difference from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                IF DieselRecoveryAmount IS NOT NULL AND DieselRecoveryAmount != '' AND DieselRecoveryAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRecovery_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(DieselRecoveryAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Recovery from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

                IF TotalAmount IS NOT NULL AND TotalAmount != '' AND TotalAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'         
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(TotalAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
						<DocumentItemText>Milk Transport Payment from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF;   

            IF SecurityDepositAmount IS NOT NULL AND SecurityDepositAmount != '' AND SecurityDepositAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'                
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(SecurityDepositAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',SecurityDeposit_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Security Deposit from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF; 

                IF BankLoanAmount IS NOT NULL AND BankLoanAmount != '' AND BankLoanAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankLoanAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',BankLoan_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Loan from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF; 

                IF BankAdvanceAmount IS NOT NULL AND BankAdvanceAmount != '' AND BankAdvanceAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(BankAdvanceAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',BankAdvance_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Advance Recovered from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                IF CanRecoveryChargesAmount IS NOT NULL AND CanRecoveryChargesAmount != '' AND CanRecoveryChargesAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(CanRecoveryChargesAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',CanRecoveryCharges_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Can Recovery Charges from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;

                SET xmlData = CONCAT(xmlData,' 

                                    <!--Zero or more repetitons:-->\n                    
                                    <!--Zero or more repetitions:-->\n                \n                
                                </JournalEntry>\n            
                            </JournalEntryCreateRequest>\n        
                        </sfin:JournalEntryBulkCreateRequest>\n    
                    </soapenv:Body>\n
                </soapenv:Envelope>');
                SELECT xmlData;

    end;    
    */
    
    elseif (var_Method_Name = 'Get_Voucher_IncomeDeductions') then 
    begin
    DECLARE MilkTransportAmount decimal(30,2);
    DECLARE CattleFeedAmount decimal(30,2);
    DECLARE LabourChargesAmount decimal(30,2);

    DECLARE DieselRateDifferenceAmount decimal(30,2);
    DECLARE DairyAdvanceAmount decimal(30,2);
    DECLARE DieselRecoveryAmount decimal(30,2);
    DECLARE SecurityDepositAmount decimal(30,2);
    DECLARE BankLoan_ICICI decimal(30,2);
    DECLARE BankLoan_Society decimal(30,2);

    DECLARE CanRecoveryChargesAmount decimal(30,2);
    DECLARE TDSAmount decimal(30,2);

    DECLARE MilkTransport_GLCode varchar(255);
    DECLARE CattleFeed_GLCode varchar(255);
    DECLARE LabourCharges_GLCode varchar(255);

    DECLARE DieselRateDifference_GLCode varchar(255);
    DECLARE DairyAdvance_GLCode varchar(255);
    DECLARE DieselRecovery_GLCode varchar(255);
    DECLARE SecurityDeposit_GLCode varchar(255);
    DECLARE ICICI_GLCode varchar(255);
	DECLARE Society__GLCode varchar(255);

    DECLARE CanRecoveryCharges_GLCode varchar(255);
    DECLARE TDS_GLCode varchar(255);
    
    DECLARE DateTime varchar(255);
    DECLARE Date varchar(255);
    DECLARE MusterCycle varchar(255);
    DECLARE xmlData longtext;
    DECLARE Counter INT DEFAULT 1;
    DECLARE AccountingDocumentType varchar(255);
    DECLARE CompanyCode varchar(255);
    DECLARE Creditor_Debtor varchar(50);
    DECLARE TotalAmount decimal(30,2);


    Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
	set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			
    SELECT Constant_Value into AccountingDocumentType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'AccountingDocumentType';
	SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'CompanyCode';
    SELECT Constant_Value into DieselRateDifference_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount2';
    SELECT Constant_Value into MilkTransport_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount1';
    SELECT Constant_Value into LabourCharges_GLCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterVoucher' and Constant_Name = 'GLAccount5';
    

    SELECT GL_Code into CattleFeed_GLCode 
    FROM m020_incentives_head 
    where Org_Id = var_Org_Id
    and IncentiveHead_Id ='M020232000001';

    SELECT GL_Code into SecurityDeposit_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id  ='M020231000001';
    
    SELECT GL_Code into DieselRecovery_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000002';
    
    SELECT GL_Code into DairyAdvance_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id
    and DeductionHead_Id ='M020231000003';
    

    SELECT GL_Code into ICICI_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000004';
    
    SELECT GL_Code into Society__GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000018';
    
    SELECT GL_Code into CanRecoveryCharges_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000005';
    
    SELECT GL_Code into TDS_GLCode 
    FROM m020_deductions_head 
    where Org_Id = var_Org_Id 
    and DeductionHead_Id ='M020231000006';
    
    
    

    SELECT m009.Transporter_Code  into Creditor_Debtor 
    FROM t029_invoice_transpoter t029
    inner join  m009_transporter m009 on m009.Org_Id = t029.Org_Id 
        and m009.Transporter_Id = t029.Transporter_Id 
    where t029.Org_Id = var_Org_Id
    and t029.Voucher_Id = var_Invoice_Id;

    SELECT 
        CONCAT(DATE_FORMAT(t029.MusterCycle_StartDate, '%d.%m.%y'), ' to ', DATE_FORMAT(t029.MusterCycle_EndDate, '%d.%m.%y')),
        DATE_FORMAT(CONVERT_TZ(t029.MusterCycle_EndDate, '+00:00', '+00:00'), '%Y-%m-%d')
        into 
        MusterCycle,
        Date
    FROM t029_invoice_transpoter t029
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id
    GROUP BY
        t029.MusterCycle_StartDate,t029.MusterCycle_EndDate;
        
	

    -- MilkTransportAmount

    SELECT 
    COALESCE(ROUND(SUM(IFNULL(Cost,0)), 2), 0)
    into MilkTransportAmount
    FROM t021_tripdocument_header 
    where Org_Id = var_Org_Id
    and Invoice_Id = var_Invoice_Id;
    
    -- LabourChargesAmount
    
    SELECT  
    COALESCE(ROUND(SUM(IFNULL(m003.LabourCharge, 0)), 2), 0)
    into LabourChargesAmount
    FROM t029_invoice_transpoter  t029
    inner join m009_transporter m009 on
    m009.Org_Id = t029.Org_Id 
    and m009.Transporter_Id = t029.Transporter_Id 
    inner join m003_vehicle m003 on
    m003.Org_Id = t029.Org_Id 
    and m009.Transporter_Id = m003.Transporter_Id 
    where t029.Org_Id = var_Org_Id
    and t029.Voucher_Id = var_Invoice_Id
    limit 1;

    -- CattleFeedAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t042.Incentive_Amount, 0)), 0) into  CattleFeedAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t042_incentives_item t042 ON t042.Org_Id = t029.Org_Id 
    AND t042.Invoice_Id = t029.Voucher_Id
    INNER JOIN t042_incentives_header t0421 ON t042.Org_Id = t0421.Org_Id 
    AND t042.Incentives_Id = t0421.Incentives_Id
    AND t0421.Request_Type = 'M020232000001'
    WHERE 
		t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- DieselRateDifferenceAmount

    SELECT 
    COALESCE(ROUND(SUM((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0)), 2), 0)
    into DieselRateDifferenceAmount
    FROM t021_tripdocument_header 
    where Org_Id = var_Org_Id
    and FreightRateType_Id <> 'C029003'
    and Invoice_Id = var_Invoice_Id;

    -- SecurityDepositAmount
    
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  SecurityDepositAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000001'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- DieselRecoveryAmount
    
		select 
		COALESCE(ROUND(SUM(IFNULL(Amount, 0)), 2), 0) into  DieselRecoveryAmount
		from t043_dieselupload
		WHERE 
		Org_Id = var_Org_Id
		AND Invoice_Id = var_Invoice_Id;
    
    /*
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  DieselRecoveryAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000002'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
*/
    -- DairyAdvanceAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  DairyAdvanceAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000003'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankLoanAmount - ICICI
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_ICICI
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000004'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- BankLoanAmount - Society
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  BankLoan_Society
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000018'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;

    -- CanRecoveryChargesAmount
                
    SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  CanRecoveryChargesAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000005'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    
    -- TDSAmount

     SELECT 
        COALESCE(SUM(IFNULL(t033.Deduction_Amount, 0)), 0) into  TDSAmount
    FROM t029_invoice_transpoter t029
    INNER JOIN t033_deductions_item t033 ON t033.Org_Id = t029.Org_Id 
    AND t033.Invoice_Id = t029.Voucher_Id
    INNER JOIN t033_deductions_header t0331 ON t033.Org_Id = t0331.Org_Id 
    AND t033.Deductions_Id = t0331.Deductions_Id
    AND t0331.Request_Type = 'M020231000006'
    WHERE 
        t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
        
      

	/*
     set TotalAmount =   round(DieselRateDifferenceAmount) + round(SecurityDepositAmount)
									-- + round(DieselRecoveryAmount) 
                                    + round(LabourChargesAmount)
                                    + round(DairyAdvanceAmount) 
									+ round(BankLoan_ICICI) + round(BankLoan_Society) 
                                    + round(CanRecoveryChargesAmount)
									+ round(MilkTransportAmount) + round(CattleFeedAmount);
                                    
                                    
	*/
	if(MilkTransportAmount IS NULL AND MilkTransportAmount = '' AND MilkTransportAmount = 0) then
		set LabourChargesAmount = 0;
    end if;
    
     set TotalAmount =   round(DieselRateDifferenceAmount) - round(SecurityDepositAmount)
									- round(DieselRecoveryAmount) 
                                    + round(LabourChargesAmount)
                                    - round(DairyAdvanceAmount) 
									- round(BankLoan_ICICI) - round(BankLoan_Society) 
                                    - round(CanRecoveryChargesAmount)
									+ round(MilkTransportAmount) + round(CattleFeedAmount);
                                    
      
    if(TotalAmount is null or TotalAmount = '' or TotalAmount = 0)then
        UPDATE t029_invoice_transpoter t029
        SET t029.Is_Posted = 4
        WHERE t029.Org_Id = var_Org_Id
        AND t029.Voucher_Id = var_Invoice_Id;
    end if;
    
      SET xmlData  = concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
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
                            <!--Zero or more repetitions:-->\n                \n                
                        </MessageHeader>\n                
                        <JournalEntry>\n                    
                            <OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
                            <OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
                            <BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
                            <AccountingDocumentType>',AccountingDocumentType,'</AccountingDocumentType>\n                    
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


                IF MilkTransportAmount IS NOT NULL AND MilkTransportAmount != '' AND MilkTransportAmount <> 0 THEN
				if(MilkTransportAmount < 0)then
				SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',MilkTransport_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',MilkTransportAmount,'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost ',MusterCycle,'</DocumentItemText>\n   
						 <Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
                        <BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                elseif(MilkTransportAmount > 0)then
                SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',MilkTransport_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(MilkTransportAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Milk Transport Cost from ',MusterCycle,'</DocumentItemText>\n                        
						<Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
                        <BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
                end if;
                
				SET Counter = Counter + 1;
				END IF;  

                IF CattleFeedAmount IS NOT NULL AND CattleFeedAmount != '' AND CattleFeedAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',CattleFeed_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(CattleFeedAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Cattlefeed Transport Charges ',MusterCycle,'</DocumentItemText>\n                        
						<Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
                        <BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
				SET Counter = Counter + 1;
				END IF; 
                
				
                -- <GLAccount></GLAccount>\n  GL Code
				IF LabourChargesAmount IS NOT NULL AND LabourChargesAmount != '' AND LabourChargesAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'  

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',LabourCharges_GLCode,'</GLAccount>\n                         
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(LabourChargesAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Labour Charges ',MusterCycle,'</DocumentItemText>\n                        
						<Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
                        <BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n  
				');
				SET Counter = Counter + 1;
				END IF; 
                
                
          
                IF DieselRateDifferenceAmount IS NOT NULL AND DieselRateDifferenceAmount != '' AND DieselRateDifferenceAmount <> 0 THEN
				
                
                if(DieselRateDifferenceAmount < 0)then
				SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRateDifference_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(DieselRateDifferenceAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Rate Difference from ',MusterCycle,' </DocumentItemText>\n                        
						<Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
                        <BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n 
				');
                elseif(DieselRateDifferenceAmount > 0)then
                SET xmlData = CONCAT(xmlData,'           
					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRateDifference_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">',round(DieselRateDifferenceAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>S</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Rate Difference from ',MusterCycle,' </DocumentItemText>\n
                        <Tax>\n 
                            <TaxCode>0C</TaxCode>\n 
                            <TaxItemGroup>000001</TaxItemGroup>\n 
                        </Tax>\n
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n 
				');
                end if;
				SET Counter = Counter + 1;
				END IF;
    
                IF DieselRecoveryAmount IS NOT NULL AND DieselRecoveryAmount != '' AND DieselRecoveryAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<Item>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
						<GLAccount>',DieselRecovery_GLCode,'</GLAccount>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(DieselRecoveryAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<DocumentItemText>Diesel Recovery from ',MusterCycle,' </DocumentItemText>\n                        
						<BusinessPlace></BusinessPlace>\n                        
						<AccountAssignment>\n                            
							<CostCenter>11001002</CostCenter>\n                        
						</AccountAssignment>\n                    
					</Item>\n   
				');
				SET Counter = Counter + 1;
				END IF; 
                
                
				/*
                IF TotalAmount IS NOT NULL AND TotalAmount != '' AND TotalAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'         
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(TotalAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
						<DocumentItemText>Milk Transport Payment from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
				SET Counter = Counter + 1;
				END IF;   
			*/
            IF TotalAmount IS NOT NULL AND TotalAmount != '' AND TotalAmount <> 0 THEN

			if(TotalAmount > 0)then

			SET xmlData = CONCAT(xmlData,'         
				<CreditorItem>\n                        
					<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
					<Creditor>',Creditor_Debtor,'</Creditor>\n                        
					<AmountInTransactionCurrency currencyCode=\"INR\">-',round(TotalAmount),'</AmountInTransactionCurrency>\n                        
					<DebitCreditCode>H</DebitCreditCode>\n                        
					<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
					<DocumentItemText>Milk Transport Payment from ',MusterCycle,' </DocumentItemText>\n                        
					<AssignmentReference></AssignmentReference>\n                        
					<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
					<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
					<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
					<DownPaymentTerms>\n                            
						<SpecialGLCode></SpecialGLCode>\n                        
					</DownPaymentTerms>\n                    
				</CreditorItem>\n  
			');

			elseif(TotalAmount < 0)then

			SET xmlData = CONCAT(xmlData,'         
				<CreditorItem>\n                        
					<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
					<Creditor>',Creditor_Debtor,'</Creditor>\n                        
					<AmountInTransactionCurrency currencyCode=\"INR\">',round(abs(TotalAmount)),'</AmountInTransactionCurrency>\n                        
					<DebitCreditCode>S</DebitCreditCode>\n                        
					<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
					<DocumentItemText>Milk Transport Payment from ',MusterCycle,' </DocumentItemText>\n                        
					<AssignmentReference></AssignmentReference>\n                        
					<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
					<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
					<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
					<DownPaymentTerms>\n                            
						<SpecialGLCode></SpecialGLCode>\n                        
					</DownPaymentTerms>\n                    
				</CreditorItem>\n  
			');

			end if;


			SET Counter = Counter + 1;
			END IF;  

            IF SecurityDepositAmount IS NOT NULL AND SecurityDepositAmount != '' AND SecurityDepositAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,'                
					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(SecurityDepositAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',SecurityDeposit_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Security Deposit from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n  
				');
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

                IF DairyAdvanceAmount IS NOT NULL AND DairyAdvanceAmount != '' AND DairyAdvanceAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(DairyAdvanceAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts>',DairyAdvance_GLCode,'</AltvRecnclnAccts>\n                        
						<DocumentItemText>Advance Recovered from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;
 
                IF CanRecoveryChargesAmount IS NOT NULL AND CanRecoveryChargesAmount != '' AND CanRecoveryChargesAmount <> 0 THEN
				SET xmlData = CONCAT(xmlData,' 

					<CreditorItem>\n                        
						<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
						<Creditor>',Creditor_Debtor,'</Creditor>\n                        
						<AmountInTransactionCurrency currencyCode=\"INR\">-',round(CanRecoveryChargesAmount),'</AmountInTransactionCurrency>\n                        
						<DebitCreditCode>H</DebitCreditCode>\n                        
						<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
						<DocumentItemText>Can Recovery Charges from ',MusterCycle,' </DocumentItemText>\n                        
						<AssignmentReference></AssignmentReference>\n                        
						<Reference1IDByBusinessPartner></Reference1IDByBusinessPartner>\n                        
						<Reference2IDByBusinessPartner></Reference2IDByBusinessPartner>\n                        
						<Reference3IDByBusinessPartner></Reference3IDByBusinessPartner>\n                        
						<DownPaymentTerms>\n                            
							<SpecialGLCode></SpecialGLCode>\n                        
						</DownPaymentTerms>\n                    
					</CreditorItem>\n   
				');
				SET Counter = Counter + 1;
				END IF;
                
              

                SET xmlData = CONCAT(xmlData,' 

                                    <!--Zero or more repetitons:-->\n                    
                                    <!--Zero or more repetitions:-->\n                \n                
                                </JournalEntry>\n            
                            </JournalEntryCreateRequest>\n        
                        </sfin:JournalEntryBulkCreateRequest>\n    
                    </soapenv:Body>\n
                </soapenv:Envelope>');
                
                SELECT xmlData;

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
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
