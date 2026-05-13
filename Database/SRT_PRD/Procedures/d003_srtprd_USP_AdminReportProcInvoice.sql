-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminReportProcInvoice` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminReportProcInvoice`(
	IN `var_org_id` VARCHAR(10),
	IN `var_Method_Name` VARCHAR(20),
	IN `var_Report_Type` VARCHAR(50),
	IN `var_MCCType_Id` text,
	IN `var_ReportPeriod` VARCHAR(50),
	IN `var_MCCCollectionShift_Id` text,
	IN `var_MilkType_Id` text,
	IN `var_MCC_Id` text,
    IN var_MCCWorkType_Id text,
    IN var_MusterStartDate text,
    IN var_MusterEndDate text
)
BEGIN
	SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Get') then
		if (var_Report_Type = 'C048004') then	-- Procurement Invoice Report 
			Begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
                Declare var_Destination_Name varchar(20);
                Declare var_BaseURL varchar(200);
                DECLARE var_MusterStart DATE;
				DECLARE var_MusterEnd DATE;
                

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                SET var_MusterStart = CONVERT_TZ(var_MusterStartDate, '+00:00', '+00:00');
				SET var_MusterEnd = CONVERT_TZ(var_MusterEndDate, '+00:00', '+00:00');
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                
                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC_11;
				create temporary table temp_MCC_11(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_11 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                
                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC_12;
				create temporary table temp_MCC_12(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_12 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), Invoice_Date varchar(20), Invoice_Id varchar(20),  Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20),
                MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20), MCCType_Id varchar(20), MCCType_Name varchar(50), Invoice_No varchar(20), MusterCycle_StartDate varchar(20), MusterCycle_EndDate varchar(20), 
                TotalMilk_QtyLtr decimal(18,3), MilkPayment_Amount decimal(18,2), DairyAnamat_Amount decimal(18,2), BankEMI_Amount decimal(18,2),
				ProductSales_Amount decimal(18,2), TMSales_Amount decimal(18,2), Transport_Amount decimal(18,2), 
				MCCAdvance_Amount decimal(18,2), DairyAdvance_Amount decimal(18,2), TotalDecution_Amount decimal(18,2), 
				TotalIncentive_Amount decimal(18,2), NetPayable_Amount decimal(18,2), IFSC_Code varchar(50), Account_No varchar(50), 
                Account_Name varchar(100), MCCWorkType_Id varchar(20), TDS_Amount decimal(18,2), Amount_Paid decimal(18,2),
                Gov_Farmer_Id varchar(50), Gov_Farmer_Name varchar(50), FarmerBank_Name varchar(50), FarmerBankBranch_Name varchar(50), FarmerAadhar_No varchar(20), 
                FarmerMobile_No varchar(20), Bank_Id varchar(20), Branch_Id varchar(20), 
                District_Id varchar(20), Taluka_Id varchar(20), Village_Id varchar(20), District_Name varchar(50), Taluka_Name varchar(50), Village_Name varchar(50),
                Avg_FAT decimal(8,2), Avg_SNF decimal(8,2),
                Is_InvoicePosted int);
				
				IF ((var_MusterStartDate is not null or var_MusterStartDate <> '') 
						and (var_MusterEndDate is not null or var_MusterEndDate <> ''))THEN
                        
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, Farmer_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MilkPayment_Amount, DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, Transport_Amount, MCCAdvance_Amount, DairyAdvance_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid, Avg_FAT, Avg_SNF)
				select Org_Id, Invoice_Date, Invoice_Id, Farmer_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MilkPayment_Amount, DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, Transport_Amount, MCCAdvance_Amount, DairyAdvance_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0)),
                ifnull(Avg_FAT, 0) as Avg_FAT, ifnull(Avg_SNF, 0) as Avg_SNF
				from f012_farmer_invoice f012
				where f012.Org_Id = var_Org_Id
                and CAST(f012.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f012.Invoice_Date  AS DATE)  <= var_EndDate
                and f012.MCC_Id in (Select MCC_Id from temp_MCC)
                and f012.MusterCycle_StartDate = var_MusterStart
				and f012.MusterCycle_EndDate = var_MusterEnd;
                
                else
                
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, Farmer_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MilkPayment_Amount, DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, Transport_Amount, MCCAdvance_Amount, DairyAdvance_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid, Avg_FAT, Avg_SNF)
				select Org_Id, Invoice_Date, Invoice_Id, Farmer_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MilkPayment_Amount, DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, Transport_Amount, MCCAdvance_Amount, DairyAdvance_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0)),
                ifnull(Avg_FAT, 0) as Avg_FAT, ifnull(Avg_SNF, 0) as Avg_SNF
				from f012_farmer_invoice f012
				where f012.Org_Id = var_Org_Id
                and CAST(f012.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f012.Invoice_Date  AS DATE)  <= var_EndDate
                and f012.MCC_Id in (Select MCC_Id from temp_MCC);
                
                end if;
                
                -- Update MCCName and MCCCode
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id,
                tmp.District_Id = m005.District_Id, tmp.Taluka_Id = m005.Taluka_Id, tmp.Village_Id = m005.Village_Id;

                -- Update Account Details
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set 
                -- tmp.IFSC_Code = m005.IFSC_Code,
                tmp.Account_No = m005.Account_No,
                tmp.Account_Name = m005.Account_Name,
                tmp.Bank_Id = m005.Bank_Id, 
                tmp.Branch_Id = m005.Branch_Id
                where m005.MCCWorkType_Id = 'C023001';
            
				-- Update MCCType Name
				Update temp_Report tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
                
                -- Update Farmer Name & Farmer Code
				Update temp_Report tmp
				inner join mu04_farmer mu04 on tmp.Org_Id = mu04.Org_Id and tmp.Farmer_Id = mu04.Farmer_Id
				set tmp.Farmer_Name = mu04.Farmer_Name,
				tmp.Farmer_Code = mu04.Farmer_Code,
                tmp.Gov_Farmer_Id = mu04.Gov_Farmer_Id,
                tmp.Gov_Farmer_Name = mu04.Gov_Farmer_Name, 
                tmp.FarmerMobile_No = mu04.Mobile_No,
                tmp.FarmerAadhar_No = mu04.Aadhar_No;
				
                -- Update Account Details
				Update temp_Report tmp
				inner join mu04_farmer mu04 on tmp.Org_Id = mu04.Org_Id and tmp.Farmer_Id = mu04.Farmer_Id
				set 
                -- tmp.IFSC_Code = mu04.IFSC_Code,
                tmp.Account_No = mu04.Account_No,
                tmp.Account_Name = mu04.Account_Name,
                tmp.Bank_Id = mu04.Bank_Id, 
                tmp.Branch_Id = mu04.Branch_Id
                where tmp.MCCWorkType_Id = 'C023002';
                
                -- Update Bank Name
				Update temp_Report tmp
				inner join m015_bank m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id
				set tmp.FarmerBank_Name = m15.Bank_Name;
                
                -- Update Branch Name
				Update temp_Report tmp
				inner join m016_branch m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id and tmp.Branch_Id = m15.Branch_Id
				set tmp.FarmerBankBranch_Name = m15.Branch_Name,
					tmp.IFSC_Code = m15.IFSC_Code;
                
                -- Update District Name
                Update temp_Report tmp
				inner join ml03_district ml03 on tmp.Org_Id = ml03.Org_Id and tmp.District_Id = ml03.District_Id
				set tmp.District_Name = ml03.District_Name;
                
                -- Update Taluka Name
                Update temp_Report tmp
				inner join ml04_taluka ml04 on tmp.Org_Id = ml04.Org_Id and tmp.Taluka_Id = ml04.Taluka_Id
				set tmp.Taluka_Name = ml04.Taluka_Name;
                
                Update temp_Report tmp
				set tmp.Is_InvoicePosted = 1;
                
                -- Update Village Name
                Update temp_Report tmp
				inner join ml05_village ml05 on tmp.Org_Id = ml05.Org_Id and tmp.Taluka_Id = ml05.Taluka_Id and tmp.Village_Id = ml05.Village_Id
				set tmp.Village_Name = ml05.Village_Name;
                
                set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_org_id);
                if (var_Destination_Name = 'PRD') then
					set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
				else 
					set var_BaseURL = 'https://uatdoc.srthoratmilk.in/';
				end if;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
				CREATE TEMPORARY TABLE temp_Report_1 ( 
				Org_Id varchar(20), Farmer_Id varchar(20), MCC_Id varchar(20), Invoice_Date datetime);

				insert into temp_Report_1(Org_Id,Farmer_Id,MCC_Id,Invoice_Date)
                
                select Org_Id,Farmer_Id,MCC_Id,Invoice_Date FROM (
				select Org_Id,Farmer_Id,MCC_Id,Invoice_Date
				from t027_invoice_farmer
				where Org_Id = var_org_id
				and  MCC_Id in (Select MCC_Id from temp_MCC_11)
				and date(Invoice_Date) >= date(var_StartDate)
				and date(Invoice_Date) <= date(var_EndDate)
				and Is_IncomePosted not in ('2','4')
				group by Org_Id,Farmer_Id,MCC_Id,Invoice_Date
                
                union all
                
                select Org_Id,Farmer_Id,MCC_Id,Invoice_Date
				from t027_invoice_farmer
				where Org_Id = var_org_id
				and  MCC_Id in (Select MCC_Id from temp_MCC_12)
				and date(Invoice_Date) >= date(var_StartDate)
				and date(Invoice_Date) <= date(var_EndDate)
				and Is_DeductionPosted not in ('2','4')
				group by Org_Id,Farmer_Id,MCC_Id,Invoice_Date
                ) subquery 
				GROUP BY 
					Org_Id,Farmer_Id,MCC_Id,Invoice_Date;
                    
                
                Update temp_Report tmp
                inner join temp_Report_1 tmp1 on
                tmp1.Org_Id = tmp.Org_Id
                and tmp1.MCC_Id = tmp.MCC_Id
                and tmp1.Farmer_Id = tmp.Farmer_Id
                and date(tmp1.Invoice_Date) >= date(tmp.MusterCycle_StartDate)
				and date(tmp1.Invoice_Date) <= date(tmp.MusterCycle_EndDate)
				set tmp.Is_InvoicePosted = 0;
                
                
                -- Generate final output
				select 'TH' as RowType, 'Date' as Invoice_Date, 'Farmer Name' as Farmer_Name, 'Farmer Code' as Farmer_Code, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
                'MCC Type' as MCCType_Name, 'Invoice No' as Invoice_No, 'Muster Cycle' as Muster_Cycle, 'Qty (Ltr)' as TotalMilk_QtyLtr, 
                'Avg FAT' as Avg_Fat, 'Avg SNF' as Avg_SNF, 'Avg Rate' as Avg_Rate, 'Milk Payment' as MilkPayment_Amount, 
				'Dairy Anamat' as DairyAnamat_Amount, 'Bank EMI' as BankEMI_Amount, 'Product Sales' as ProductSales_Amount,
				'TM Sales' as TMSales_Amount, 'Milk Transport' as Transport_Amount, 'MCC Advance' as MCCAdvance_Amount,
				'Dairy Adance' as DairyAdvance_Amount, 'Net Deduction' as TotalDecution_Amount, 'Net Payable' as NetPayable_Amount,
                'TDS' as TDS_Amount, 'Amount Paid' as Amount_Paid,
                'Bank Name' as FarmerBank_Name, 'Branch Name' as FarmerBankBranch_Name,
                'Account Name' as Account_Name, 'Account No' as Account_No, 'IFSC Code' as IFSC_Code,
                'Gov Farmer Id' as Gov_Farmer_Id, 'Gov Farmer Name' as Gov_Farmer_Name, 'Aadhar No' as FarmerAadhar_No, 'Mobile No' as FarmerMobile_No,
                'District' as District_Name, 'Taluka' as Taluka_Name, 'Village' as Village_Name,
                'Invoice Status' as InvoiceStatus,
                'Invoice Link' as Invoice_Link
				union
				
				select 'TR' as RowType, DATE_FORMAT(Invoice_Date, '%d %b %Y') as Invoice_Date, Farmer_Name, Farmer_Code, MCC_Name, MCC_Code, MCCType_Name,
				Invoice_No, concat(DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' - ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) as Muster_Cycle, 
                ifnull(TotalMilk_QtyLtr,0) as TotalMilk_QtyLtr, Avg_Fat, Avg_SNF,
                case when ifnull(TotalMilk_QtyLtr,0) > 0 then round((ifnull(MilkPayment_Amount, 0)/ ifnull(TotalMilk_QtyLtr,0)),1) else 0 end as Avg_Rate,
                ifnull(MilkPayment_Amount, 0) as MilkPayment_Amount,
				ifnull(DairyAnamat_Amount,0) as DairyAnamat_Amount, ifnull(BankEMI_Amount,0) as BankEMI_Amount, ifnull(ProductSales_Amount,0) as ProductSales_Amount, 
				ifnull(TMSales_Amount,0) as TMSales_Amount, ifnull(Transport_Amount,0) as Transport_Amount, ifnull(MCCAdvance_Amount,0) as MCCAdvance_Amount,
                ifnull(DairyAdvance_Amount,0) as DairyAdvance_Amount, ifnull(TotalDecution_Amount,0) as TotalDecution_Amount, ifnull(NetPayable_Amount,0) as NetPayable_Amount,
				ifnull(TDS_Amount,0) as TDS_Amount, ifnull(Amount_Paid,0) as Amount_Paid,
                ifnull(FarmerBank_Name, '') as FarmerBank_Name, ifnull(FarmerBankBranch_Name, '') as FarmerBankBranch_Name,
                ifnull(Account_Name,'') as Account_Name, concat('''',ifnull(Account_No,'')) as Account_No, ifnull(IFSC_Code, '') as IFSC_Code,
                ifnull(Gov_Farmer_Id,'') as Gov_Farmer_Id, ifnull(Gov_Farmer_Name, '') as Gov_Farmer_Name,  ifnull(FarmerAadhar_No, '') as FarmerAadhar_No,
                ifnull(FarmerMobile_No, '') as FarmerMobile_No, ifnull(District_Name, '') as District_Name, ifnull(Taluka_Name, '') as Taluka_Name, ifnull(Village_Name, '') as Village_Name,
                case when Is_InvoicePosted = 1 then 'Posted' else 'Pending' end as InvoiceStatus,
                concat('<a href="', var_BaseURL ,'VendorInvoices/FI', Org_Id, Invoice_No ,'.pdf" target="_blank">View</a>') as Invoice_Link
				from temp_Report
                where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                    
			end;
        elseif (var_Report_Type = 'C048005') then	-- MPPI Invoice Report
			Begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
				Declare var_Destination_Name varchar(20);
                Declare var_BaseURL varchar(200);
                DECLARE var_MusterStart DATE;
				DECLARE var_MusterEnd DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                SET var_MusterStart = CONVERT_TZ(var_MusterStartDate, '+00:00', '+00:00');
				SET var_MusterEnd = CONVERT_TZ(var_MusterEndDate, '+00:00', '+00:00');
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC_1;
				create temporary table temp_MCC_1(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_1 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_1 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                /*
                DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), Invoice_Date varchar(20), Invoice_Id varchar(20), 
                MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20), MCCType_Id varchar(20), MCCType_Name varchar(50), Invoice_No varchar(20), MusterCycle_StartDate varchar(20), MusterCycle_EndDate varchar(20), 
                TotalMilk_QtyLtr decimal(18,3), MPPI_Amount decimal(18,2), MCCAdvance_Amount decimal(18,2), OtherIncentive_Amount decimal(18,2),
                DairyAnamat_Amount decimal(18,2), BankEMI_Amount decimal(18,2),
				ProductSales_Amount decimal(18,2), TMSales_Amount decimal(18,2), 
				DairyAdvance_Amount decimal(18,2), GainLoss_Amount decimal(18,2),  TotalDecution_Amount decimal(18,2), 
				TotalIncentive_Amount decimal(18,2), NetPayable_Amount decimal(18,2),
                TDS_Amount decimal(18,2), Amount_Paid decimal(18,2), MCCWorkType_Id varchar(20), IFSC_Code varchar(50), Account_No varchar(50), 
                Account_Name varchar(100), Bank_Id varchar(20), Branch_Id varchar(20), Bank_Name varchar(50), BankBranch_Name varchar(50),
                Transport_Amount decimal(18,2), DairyAnamat_Amount decimal(18,2));
                  
				IF ((var_MusterStartDate is not null or var_MusterStartDate <> '') 
						and (var_MusterEndDate is not null or var_MusterEndDate <> ''))THEN
                        
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid,
                Transport_Amount,DairyAnamat_Amount)
				
                select Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0) ),
                Transport_Amount,DairyAnamat_Amount
				from f013_mcc_invoice f013
				where f013.Org_Id = var_Org_Id
                and CAST(f013.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f013.Invoice_Date  AS DATE)  <= var_EndDate
                and f013.MCC_Id in (Select MCC_Id from temp_MCC)
                and f013.MusterCycle_StartDate = var_MusterStart
				and f013.MusterCycle_EndDate = var_MusterEnd;
                
                else
                
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid,
                Transport_Amount,DairyAnamat_Amount)
				
                select Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0) ),
                Transport_Amount,DairyAnamat_Amount
				from f013_mcc_invoice f013
				where f013.Org_Id = var_Org_Id
                and CAST(f013.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f013.Invoice_Date  AS DATE)  <= var_EndDate
                and f013.MCC_Id in (Select MCC_Id from temp_MCC);
                
                end if;
                
                -- Update MCCName and MCCCode
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
            
				-- Update MCCType Name
				Update temp_Report tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
				
                -- Update Account Details
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.IFSC_Code = m005.IFSC_Code,
                tmp.Account_No = m005.Account_No,
                tmp.Account_Name = m005.Account_Name,
                tmp.Bank_Id = m005.Bank_Id, 
                tmp.Branch_Id = m005.Branch_Id;
                
                -- Update Bank Name
				Update temp_Report tmp
				inner join m015_bank m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id
				set tmp.Bank_Name = m15.Bank_Name;
                
                -- Update Branch Name
				Update temp_Report tmp
				inner join m016_branch m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id and tmp.Branch_Id = m15.Branch_Id
				set tmp.BankBranch_Name = m15.Branch_Name;
                
                set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_org_id);
                if (var_Destination_Name = 'PRD') then
					set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
				else 
					set var_BaseURL = 'https://uatdoc.srthoratmilk.in/';
				end if;
                
                -- Generate final output
				select 'TH' as RowType, 'Date' as Invoice_Date, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
                'MCC Type' as MCCType_Name, 'Invoice No' as Invoice_No, 'Muster Cycle' as Muster_Cycle, 'Qty (Ltr)' as TotalMilk_QtyLtr, 'Milk Incentive' as MPPI_Amount, 
                'MCC Advance Rcvd' as MCCAdvance_Amount, 'Gain Incentive' as OtherIncentive_Amount,
				'Dairy Anamat' as DairyAnamat_Amount, 'Bank EMI' as BankEMI_Amount, 'Product Sales' as ProductSales_Amount,
				'TM Sales' as TMSales_Amount, 'Dairy Advance' as DairyAdvance_Amount, 'Loss Recovery' as GainLoss_Amount, 'Net Deduction' as TotalDecution_Amount,
                'Net Payable' as NetPayable_Amount, 'TDS' as TDS_Amount, 'Amount Paid' as Amount_Paid,
                'Bank Name' as Bank_Name, 'Branch Name' as BankBranch_Name,
                'Account Name' as Account_Name, 'Account No' as Account_No, 'IFSC Code' as IFSC_Code,
                'Invoice Link' as Invoice_Link
				union
				
				select 'TR' as RowType, DATE_FORMAT(Invoice_Date, '%d %b %Y') as Invoice_Date, MCC_Name, MCC_Code, MCCType_Name,
				Invoice_No, concat(DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' - ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) as Muster_Cycle, 
                ifnull(TotalMilk_QtyLtr,0) as TotalMilk_QtyLtr, ifnull(MPPI_Amount, 0) as MPPI_Amount,
                ifnull(MCCAdvance_Amount,0) as MCCAdvance_Amount, ifnull(OtherIncentive_Amount, 0) as OtherIncentive_Amount,
				ifnull(DairyAnamat_Amount,0) as DairyAnamat_Amount, ifnull(BankEMI_Amount,0) as BankEMI_Amount, ifnull(ProductSales_Amount,0) as ProductSales_Amount, 
				ifnull(TMSales_Amount,0) as TMSales_Amount, 
                ifnull(DairyAdvance_Amount,0) as DairyAdvance_Amount, ifnull(GainLoss_Amount,0) as GainLoss_Amount, ifnull(TotalDecution_Amount,0) as TotalDecution_Amount, ifnull(NetPayable_Amount,0) as NetPayable_Amount,
                ifnull(TDS_Amount,0) as TDS_Amount, ifnull(Amount_Paid,0) as Amount_Paid,
                Bank_Name, BankBranch_Name, Account_Name, Account_No, IFSC_Code,
                concat('<a href="', var_BaseURL ,'VendorInvoices/MI', Org_Id, Invoice_No ,'.pdf" target="_blank">View</a>') as Invoice_Link
				from temp_Report
                where MCCType_Id in (Select MCCType_Id from temp_MCCType) 
                and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                */
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), Invoice_Date varchar(20), Invoice_Id varchar(20), 
                MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20), MCCType_Id varchar(20), MCCType_Name varchar(50), Invoice_No varchar(20), MusterCycle_StartDate varchar(20), MusterCycle_EndDate varchar(20), 
                TotalMilk_QtyLtr decimal(18,3), MPPI_Amount decimal(18,2), MCCAdvance_Amount decimal(18,2), OtherIncentive_Amount decimal(18,2),
                DairyAnamat_Amount decimal(18,2), BankEMI_Amount decimal(18,2),
				ProductSales_Amount decimal(18,2), TMSales_Amount decimal(18,2), 
				DairyAdvance_Amount decimal(18,2), GainLoss_Amount decimal(18,2),  TotalDecution_Amount decimal(18,2), 
				TotalIncentive_Amount decimal(18,2), NetPayable_Amount decimal(18,2),
                TDS_Amount decimal(18,2), Amount_Paid decimal(18,2), MCCWorkType_Id varchar(20), IFSC_Code varchar(50), Account_No varchar(50), 
                Account_Name varchar(100), Bank_Id varchar(20), Branch_Id varchar(20), Bank_Name varchar(50), BankBranch_Name varchar(50),
                Transport_Amount decimal(18,2),
                Is_InvoicePosted int,
                Protein_Amount decimal(18,2), 
                Ash_Amount decimal(18,2), 
                Sodium_Amount decimal(18,2), 
                Incentive_Amount decimal(18,2));
                  
				IF ((var_MusterStartDate is not null or var_MusterStartDate <> '') 
						and (var_MusterEndDate is not null or var_MusterEndDate <> ''))THEN
                        
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid,
                Transport_Amount,
                Protein_Amount,Ash_Amount,Sodium_Amount,Incentive_Amount)
				
                select Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0) ),
                Transport_Amount,
                Protein_Amount,Ash_Amount,Sodium_Amount,Incentive_Amount
				from f013_mcc_invoice f013
				where f013.Org_Id = var_Org_Id
                and CAST(f013.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f013.Invoice_Date  AS DATE)  <= var_EndDate
                and f013.MCC_Id in (Select MCC_Id from temp_MCC)
                and f013.MusterCycle_StartDate = var_MusterStart
				and f013.MusterCycle_EndDate = var_MusterEnd;
                
                else
                
                Insert into temp_Report (Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, TDS_Amount, Amount_Paid,
                Transport_Amount,
                Protein_Amount,Ash_Amount,Sodium_Amount,Incentive_Amount)
				
                select Org_Id, Invoice_Date, Invoice_Id, MCC_Id, Invoice_No, MusterCycle_StartDate,
				MusterCycle_EndDate, TotalMilk_QtyLtr, MPPI_Amount, MCCAdvance_Amount, OtherIncentive_Amount, 
                DairyAnamat_Amount, BankEMI_Amount,
				ProductSales_Amount, TMSales_Amount, DairyAdvance_Amount, GainLoss_Amount,
				TotalDecution_Amount, TotalIncentive_Amount, NetPayable_Amount, abs(TDS_Amount), (NetPayable_Amount - ifnull(abs(TDS_Amount),0) ),
                Transport_Amount,
                Protein_Amount,Ash_Amount,Sodium_Amount,Incentive_Amount
				from f013_mcc_invoice f013
				where f013.Org_Id = var_Org_Id
                and CAST(f013.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f013.Invoice_Date  AS DATE)  <= var_EndDate
                and f013.MCC_Id in (Select MCC_Id from temp_MCC);
                
                end if;
                
                -- Update MCCName and MCCCode
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
            
				-- Update MCCType Name
				Update temp_Report tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
				
                -- Update Account Details
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.IFSC_Code = m005.IFSC_Code,
                tmp.Account_No = m005.Account_No,
                tmp.Account_Name = m005.Account_Name,
                tmp.Bank_Id = m005.Bank_Id, 
                tmp.Branch_Id = m005.Branch_Id;
                
                -- Update Bank Name
				Update temp_Report tmp
				inner join m015_bank m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id
				set tmp.Bank_Name = m15.Bank_Name;
                
                -- Update Branch Name
				Update temp_Report tmp
				inner join m016_branch m15 on tmp.Org_Id = m15.Org_Id and tmp.Bank_Id = m15.Bank_Id and tmp.Branch_Id = m15.Branch_Id
				set tmp.BankBranch_Name = m15.Branch_Name;
                
                Update temp_Report tmp
				set tmp.Is_InvoicePosted = 1;
                
                set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_org_id);
                if (var_Destination_Name = 'PRD') then
					set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
				else 
					set var_BaseURL = 'https://uatdoc.srthoratmilk.in/';
				end if;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
				CREATE TEMPORARY TABLE temp_Report_1 ( 
				Org_Id varchar(20), MCC_Id varchar(20), Invoice_Date datetime);

				insert into temp_Report_1(Org_Id,MCC_Id,Invoice_Date)
				select Org_Id,MCC_Id,Invoice_Date
				from t028_invoice_mcc
				where Org_Id = var_org_id
				and  MCC_Id in (Select MCC_Id from temp_MCC_1)
				and date(Invoice_Date) >= date(var_StartDate)
				and date(Invoice_Date) <= date(var_EndDate)
				and Is_Posted not in ('2','4')
				group by Org_Id,MCC_Id,Invoice_Date;
                
                
                Update temp_Report tmp
                inner join temp_Report_1 tmp1 on
                tmp1.Org_Id = tmp.Org_Id
                and tmp1.MCC_Id = tmp.MCC_Id
                and date(tmp1.Invoice_Date) >= date(tmp.MusterCycle_StartDate)
				and date(tmp1.Invoice_Date) <= date(tmp.MusterCycle_EndDate)
				set tmp.Is_InvoicePosted = 0;
                
                
                -- Generate final output
				select 'TH' as RowType, 'Date' as Invoice_Date, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
                'MCC Type' as MCCType_Name, 'Invoice No' as Invoice_No, 'Muster Cycle' as Muster_Cycle, 'Qty (Ltr)' as TotalMilk_QtyLtr, 'Milk Incentive' as MPPI_Amount, 
                'MCC Advance Rcvd' as MCCAdvance_Amount, 'Gain Incentive' as OtherIncentive_Amount,
				'Dairy Anamat' as DairyAnamat_Amount, 
				'Dairy Transport' as Transport_Amount, 
				'Bank EMI' as BankEMI_Amount, 'Product Sales' as ProductSales_Amount,
				'TM Sales' as TMSales_Amount, 'Dairy Advance' as DairyAdvance_Amount, 'Loss Recovery' as GainLoss_Amount, 'Net Deduction' as TotalDecution_Amount,
                'Net Payable' as NetPayable_Amount, 'TDS' as TDS_Amount,
                'Protein' as Protein_Amount,
                'Ash' as Ash_Amount,
                'Sodium' as Sodium_Amount,
                'Incentive' as Incentive_Amount,
                'Amount Paid' as Amount_Paid,
                'Bank Name' as Bank_Name, 'Branch Name' as BankBranch_Name,
                'Account Name' as Account_Name, 'Account No' as Account_No, 'IFSC Code' as IFSC_Code,
                'Invoice Status' as InvoiceStatus,
                'Invoice Link' as Invoice_Link
				union
				
				select 'TR' as RowType, DATE_FORMAT(Invoice_Date, '%d %b %Y') as Invoice_Date, MCC_Name, MCC_Code, MCCType_Name,
				Invoice_No, concat(DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y'), ' - ', DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y')) as Muster_Cycle, 
                ifnull(TotalMilk_QtyLtr,0) as TotalMilk_QtyLtr, ifnull(MPPI_Amount, 0) as MPPI_Amount,
                ifnull(MCCAdvance_Amount,0) as MCCAdvance_Amount, ifnull(OtherIncentive_Amount, 0) as OtherIncentive_Amount,
				ifnull(DairyAnamat_Amount,0) as DairyAnamat_Amount, 
				ifnull(Transport_Amount,0) as Transport_Amount, 
				ifnull(BankEMI_Amount,0) as BankEMI_Amount, ifnull(ProductSales_Amount,0) as ProductSales_Amount, 
				ifnull(TMSales_Amount,0) as TMSales_Amount, 
                ifnull(DairyAdvance_Amount,0) as DairyAdvance_Amount, ifnull(GainLoss_Amount,0) as GainLoss_Amount, ifnull(TotalDecution_Amount,0) as TotalDecution_Amount, ifnull(NetPayable_Amount,0) as NetPayable_Amount,
                ifnull(TDS_Amount,0) as TDS_Amount,
                ifnull(Protein_Amount,0) as Protein_Amount,
                ifnull(Ash_Amount,0) as Ash_Amount,
                ifnull(Sodium_Amount,0) as Sodium_Amount,
                ifnull(Incentive_Amount,0) as Incentive_Amount,
                ifnull(Amount_Paid,0) as Amount_Paid,
                Bank_Name, BankBranch_Name, Account_Name, Account_No, IFSC_Code,
                case when Is_InvoicePosted = 1 then 'Posted' else 'Pending' end as InvoiceStatus,
                concat('<a href="', var_BaseURL ,'VendorInvoices/MI', Org_Id, Invoice_No ,'.pdf" target="_blank">View</a>') as Invoice_Link
				from temp_Report
                where MCCType_Id in (Select MCCType_Id from temp_MCCType) 
                and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
			end;
        elseif (var_Report_Type = 'C048006') then	-- Anamat Register Report
			Begin
				/*
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
               

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                set sql_mode = '';
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
                
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id 
                    and MCCType_Id in (Select MCCType_Id from temp_MCCType) 
					and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                    
				end if;
                
                
                
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20),
                MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20), MCCType_Id varchar(20), MCCType_Name varchar(50), 
                OpenBal_Amount decimal(60,2), Credit_Amount decimal(60,2), Debit_Amount decimal(60,2), CloseBal_Amount decimal(60,2), MCCWorkType_Id varchar(20));
				
                insert into temp_Report(Org_Id, Farmer_Id, MCC_Id, Farmer_Name, Farmer_Code)
                select Org_Id, Farmer_Id, MCC_Id, Farmer_Name, Farmer_Code 
                from mu04_farmer 
                where Org_Id = var_Org_Id 
                and MCC_Id in (Select MCC_Id from temp_MCC)
                order by Farmer_Name;
                
                
                
                -- Update MCCName and MCCCode
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                
              
				-- Update MCCType Name
				Update temp_Report tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
                
				-- Update Opening Balance
                UPDATE temp_Report tmp
				JOIN (
					SELECT 
						Org_Id, 
						Farmer_Id, 
						IFNULL(Balance, 0) AS Balance
					FROM 
						f014_farmer_anamat
					WHERE 
						Type = 'cr' AND CAST(Date AS DATE) < var_StartDate
					GROUP BY Org_Id, Farmer_Id
					HAVING MAX(Date)
				) AS f014 ON tmp.Org_Id = f014.Org_Id AND tmp.Farmer_Id = f014.Farmer_Id
				SET tmp.OpenBal_Amount = f014.Balance;


                 -- Update Credit Amount
                UPDATE temp_Report tmp
				JOIN (
					SELECT 
						fa.Org_Id, 
						fa.Farmer_Id, 
						IFNULL(SUM(IFNULL(fa.Amount, 0)), 0) AS TotalCredit
					FROM 
						f014_farmer_anamat fa
					WHERE 
						fa.Type = 'cr' 
						AND CAST(fa.Date AS DATE) >= var_StartDate 
						AND CAST(fa.Date AS DATE) <= var_EndDate
					GROUP BY 
						fa.Org_Id, 
						fa.Farmer_Id
				) AS f014 ON tmp.Org_Id = f014.Org_Id AND tmp.Farmer_Id = f014.Farmer_Id
				SET tmp.Credit_Amount = f014.TotalCredit;

                
                
                -- Update Debit Amount
                UPDATE temp_Report tmp
				JOIN (
					SELECT 
						fa.Org_Id, 
						fa.Farmer_Id, 
						IFNULL(SUM(IFNULL(fa.Amount, 0)), 0) AS TotalDebit
					FROM 
						f014_farmer_anamat fa
					WHERE 
						fa.Type = 'dr' 
						AND CAST(fa.Date AS DATE) >= var_StartDate 
						AND CAST(fa.Date AS DATE) <= var_EndDate
					GROUP BY 
						fa.Org_Id, 
						fa.Farmer_Id
				) AS f014 ON tmp.Org_Id = f014.Org_Id AND tmp.Farmer_Id = f014.Farmer_Id
				SET tmp.Debit_Amount = f014.TotalDebit;

                
               
                -- Update Closing Balance
                 Update temp_Report tmp
                 set tmp.CloseBal_Amount = ifnull(OpenBal_Amount,0) + ifnull(Credit_Amount,0) - ifnull(Debit_Amount,0);
               
                -- Generate final output
				select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
                'MCC Type' as MCCType_Name, 'Farmer Name' as Farmer_Name, 'Farmer Code' as Farmer_Code, 
                'Opening Bal' as OpenBal_Amount, 'Credit' as Credit_Amount, 'Debit' as Debit_Amount, 'Closing Bal' as CloseBal_Amount
				union
				
				select 'TR' as RowType, MCC_Name, MCC_Code, MCCType_Name,
				Farmer_Name, Farmer_Code,
                ifnull(OpenBal_Amount,0) as OpenBal_Amount, ifnull(Credit_Amount, 0) as Credit_Amount,
                ifnull(Debit_Amount,0) as Debit_Amount, ifnull(CloseBal_Amount, 0) as CloseBal_Amount
				from temp_Report
                where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                
                
                */
                
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
		   

			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
			
			set sql_mode = '';
			SET SQL_SAFE_UPDATES=0;
			
			-- Split MCCType
			drop temporary table if exists t;
			create temporary table t( txt text );
			insert into t values(ifnull(var_MCCType_Id, ''));

			drop temporary table if exists temp_MCCType;
			create temporary table temp_MCCType(MCCType_Id char(255) );
			set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
			prepare stmt1 from @sql;
			execute stmt1;
			
			
			drop temporary table if exists temp_MCCType_1;
			create temporary table temp_MCCType_1(MCCType_Id char(255) );
			set @sql = concat('insert into temp_MCCType_1 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
			prepare stmt1 from @sql;
			execute stmt1;
			
			-- Split MCCWorkType
			drop temporary table if exists t;
			create temporary table t( txt text );
			insert into t values(ifnull(var_MCCWorkType_Id, ''));

			drop temporary table if exists temp_MCCWorkType;
			create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
			set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
			prepare stmt1 from @sql;
			execute stmt1;
			
			drop temporary table if exists temp_MCCWorkType_1;
			create temporary table temp_MCCWorkType_1(MCCWorkType_Id char(255) );
			set @sql = concat('insert into temp_MCCWorkType_1 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
			prepare stmt1 from @sql;
			execute stmt1;
			
			-- Split MCCWorkType
			drop temporary table if exists t;
			create temporary table t( txt text );
			insert into t values(ifnull(var_MCC_Id, ''));
			
			drop temporary table if exists temp_MCC;
			create temporary table temp_MCC(MCC_Id char(255) );
			if (ifnull(var_MCC_Id, '') <> '') then
				set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt4 from @sql4;
				execute stmt4;
			else
				insert into temp_MCC (MCC_Id)
				select MCC_Id from m005_mcc where Org_Id = var_org_id 
				and MCCType_Id in (Select MCCType_Id from temp_MCCType) 
				and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
				
			end if;
			
			
			
			drop temporary table if exists temp_MCC_1;
			create temporary table temp_MCC_1(MCC_Id char(255) );
			if (ifnull(var_MCC_Id, '') <> '') then
				set @sql4 = concat('insert into temp_MCC_1 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt4 from @sql4;
				execute stmt4;
			else
				insert into temp_MCC_1 (MCC_Id)
				select MCC_Id from m005_mcc where Org_Id = var_org_id 
				and MCCType_Id in (Select MCCType_Id from temp_MCCType) 
				and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
				
			end if;
			
			
			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20),
			MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20), MCCType_Id varchar(20), MCCType_Name varchar(50), 
			Total_Amount decimal(60,2));
			
			
			insert into temp_Report(Org_Id, Farmer_Id, MCC_Id, Total_Amount)
			select 
			f012.Org_Id,f012.Farmer_Id,f012.MCC_Id,
			sum(ifnull(f012.DairyAnamat_Amount,0)) as Total_Amount
			FROM f012_farmer_invoice f012
			INNER JOIN temp_MCC tm ON tm.MCC_Id = f012.MCC_Id
			WHERE f012.Org_Id = var_org_id
			and CAST(f012.Invoice_Date  AS DATE) >= var_StartDate 
			and CAST(f012.Invoice_Date  AS DATE)  <= var_EndDate
			group by f012.Org_Id,f012.Farmer_Id,f012.MCC_Id;
			
			
			update temp_Report tm
			inner join mu04_farmer mu04 on
			mu04.Org_Id = tm.Org_Id
			and mu04.Farmer_Id = tm.Farmer_Id
			and mu04.MCC_Id = tm.MCC_Id
			set tm.Farmer_Name = mu04.Farmer_Name,
				tm.Farmer_Code = mu04.Farmer_Code;
				
			update temp_Report tm
			inner join m005_mcc m005 on
			m005.Org_Id = tm.Org_Id
			and m005.MCC_Id = tm.MCC_Id
			set tm.MCC_Name = m005.MCC_Name,
				tm.MCC_Code = m005.MCC_Code,
				tm.MCCType_Id = m005.MCCType_Id;
				
			update temp_Report tm
			inner join c014_mcctype c014 on
			tm.MCCType_Id = c014.MCCType_Id
			set tm.MCCType_Name = c014.MCCType_Name;
			
			
			

			select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
			'MCC Type' as MCCType_Name, 'Farmer Name' as Farmer_Name, 'Farmer Code' as Farmer_Code, 
			'Total' as Total_Amount
			union
			select 'TR' as RowType,
			MCC_Name,MCC_Code,
			MCCType_Name,
			Farmer_Name,Farmer_Code,
			Total_Amount as Total_Amount
			from temp_Report;
                
            end;
        elseif (var_Report_Type = 'C048007') then	-- Transporter Invoice Report
			Begin
				
                -- Generate final output
				select 'TH' as RowType, 'Date' as Invoice_Date, 'Transporter Code' as Transporter_Code, 'Transporter Name' as Transporter_Name, 
                'Invoice No' as Invoice_No, 'Gross Amount' as Gross_Amount, 
                'Recovery Amount' as Recovery_Amount, 'Security Amount' as Security_Amount,
				'Labour Charges' as LabourCharge_Amount, 'Cattle Feed' as CattleFeed_Amount, 'Diesel Rate Diff' as DieselRateDiff_Amount,
				'Diesel Recovery' as DieselRecovery_Amount, 'Dairy Advance' as DairyAdvance_Amount, 'Bank Loan Deduction' as BankLoan_Amount,
                'Can Recovery' as CanRecovery_Amount,
                'Net Payable' as NetPayable_Amount, 'Invoice Link' as Invoice_Link;
                
            end;
		elseif (var_Report_Type = 'C048008') then	-- Milk Payment Vs Dairy Collection Report
			Begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), Muster_Cycle varchar(40),
                MilkPayment_Amount decimal(18,2), MilkPayment_QtyLtr decimal(18,2), Dairy_QtyLtr decimal(18,2), Dairy_Fat decimal(18,2),
				Dairy_SNF decimal(18,2), MCC_Code varchar(40), MCCType_Id varchar(20), MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(40) );
                
                insert into temp_Report (Org_Id, MCC_Id, 
                MilkPayment_QtyLtr, MilkPayment_Amount, 
                Dairy_QtyLtr, Dairy_Fat, Dairy_SNF )
                
                Select Org_Id, MCC_Id, 0, 0, 
                sum(Dairy_Quantity_Ltr), 
                Roundoff('Quality',(IFNULL((SUM(Dairy_Quantity_Ltr * Dairy_Fat)) / SUM(Dairy_Quantity_Ltr), 0))) AS FAT,
				Roundoff('Quality',(IFNULL((SUM(Dairy_Quantity_Ltr * Dairy_SNF)) / SUM(Dairy_Quantity_Ltr), 0))) AS SNF
                from f010_milkcollectionmcc_final f010 
                where Org_Id = var_Org_Id  
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and f010.MCC_Id in (Select MCC_Id from temp_MCC)
                group by Org_Id, MCC_Id;
                
                
                drop temporary table if exists temp_MilkPayment;
				create temporary table temp_MilkPayment(Org_Id char(20), MCC_Id char(20), MilkPayment_QtyLtr decimal(30,2), MilkPayment_Amount decimal(30,2));

                insert into temp_MilkPayment (Org_Id, MCC_Id, 
                MilkPayment_QtyLtr, MilkPayment_Amount)
                select Org_Id, MCC_Id, 
                sum(TotalMilk_QtyLtr) as MilkPayment_QtyLtr, sum(MilkPayment_Amount) as MilkPayment_Amount
				from f012_farmer_invoice f012
				where f012.Org_Id = var_Org_Id
                and CAST(f012.Invoice_Date  AS DATE) >= var_StartDate 
				and CAST(f012.Invoice_Date  AS DATE)  <= var_EndDate
                and f012.MCC_Id in (Select MCC_Id from temp_MCC)
                group by  Org_Id, MCC_Id; 
                
                Update temp_Report tmp
				inner join temp_MilkPayment f010 on tmp.MCC_Id = f010.MCC_Id
				set tmp.MilkPayment_QtyLtr = f010.MilkPayment_QtyLtr,
				tmp.MilkPayment_Amount = f010.MilkPayment_Amount;
                
                -- Update MCCName and MCCCode
				Update temp_Report tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                
                Update temp_Report tmp
                inner join c023_mccworktype c23 on tmp.MCCWorkType_Id = c23.MCCWorkType_Id
                set tmp.MCCWorkType_Name = c23.MCCWorkType_Name;
                
                -- Generate final output
				select 'TH' as RowType, 'MCC Code' as MCC_Code, 'MCC Name' as MCC_Name, 'Work Type' as MCCWorkType_Name,
                'Dairy Qty (Ltr)' as Dairy_QtyLtr,
				'Dairy Fat%' as Dairy_Fat, 'Dairy SNF%' as Dairy_SNF, 
                'Milk Payment Qty (Ltr)' as MilkPayment_QtyLtr, 'Milk Payment Amount' as MilkPayment_Amount
                
				union
                
                select 'TR' as RowType, MCC_Code, MCC_Name, MCCWorkType_Name,
                Dairy_QtyLtr, Dairy_Fat, Dairy_SNF, MilkPayment_QtyLtr, MilkPayment_Amount
				from temp_Report
                where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                
            end;
		elseif (var_Report_Type = 'C048019') then	-- Procurement Invoice Report 
			Begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
                Declare var_Destination_Name varchar(20);
                Declare var_BaseURL varchar(200);

				
                SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
               

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_1;
				create temporary table temp_MCCType_1(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_1 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_2;
				create temporary table temp_MCCType_2(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_2 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_3;
				create temporary table temp_MCCType_3(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_3 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                
                drop temporary table if exists temp_MCC_1;
				create temporary table temp_MCC_1(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_1 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_1 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_1;
				create temporary table temp_MCCWorkType_1(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_1 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_2;
				create temporary table temp_MCCWorkType_2(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_2 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_3;
				create temporary table temp_MCCWorkType_3(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_3 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;


				SET SQL_SAFE_UPDATES = 0;
                set sql_mode= "";

                DROP TEMPORARY TABLE IF EXISTS temp_Report_1;

                CREATE TEMPORARY TABLE temp_Report_1 ( 
                Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
                TripDocument_Id varchar(20),MCCCollectionShift_Id varchar(20),
                Pay_MilkPrice decimal(30,2),
				MCC_Name varchar(100), MCC_Code varchar(20), 
				MCCType_Id varchar(20), MCCType_Name varchar(50),
                MCCWorkType_Id varchar(20),MCCWorkType_Name varchar(20),
                CollectionShift_Name varchar(20), Is_Check varchar(20),
                GRN_Quantity_Ltr decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_1 (
                Org_Id , MilkCollectionDairy_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date , MilkCollectionPosting_Id , 
                GRN_Quantity_Ltr,
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,Is_Check
                )
                select 
                f010.Org_Id,
                f010.MilkCollectionDairy_Id, 
                f010.MCC_Id,
                ifnull(f010.CollectionShift_Id,'C015003') as CollectionShift_Id,
                f010.Collection_Date,
                f010.MilkCollectionPosting_Id,
                IFNULL(COALESCE(bk_f010.Dairy_Quantity_Ltr, f010.Dairy_Quantity_Ltr), 0.00) AS GRN_Quantity_Ltr,
                IFNULL(COALESCE(bk_f010.AgentCost, f010.AgentCost), 0.00) AS GRN_AgentCost,
                IFNULL(COALESCE(bk_f010.TransporterCost, f010.TransporterCost), 0.00) AS GRN_TransporterCost,
                IFNULL(COALESCE(bk_f010.MilkPrice, f010.MilkPrice), 0.00) AS GRN_MilkPrice,
                f010.Is_OutsideCheck as Is_Check
                from f010_milkcollectionmcc_final f010
                
                inner join m005_mcc m005 on 
                m005.Org_Id = f010.Org_Id
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
                
                left join bk_f010_milkcollectionmcc_final bk_f010 on
                bk_f010.Org_Id = f010.Org_Id
                and bk_f010.Entry_Id = f010.Entry_Id
                and bk_f010.MCC_Id = f010.MCC_Id
                and bk_f010.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                
              
                DROP TEMPORARY TABLE IF EXISTS temp_Report_2;

                CREATE TEMPORARY TABLE temp_Report_2 ( 
                Org_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
				GRN_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_2 (
                Org_Id , MilkCollectionPosting_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date  , 
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,GRN_Quantity_Ltr
                )
                select 
                f010.Org_Id,
                f010.MilkCollectionPosting_Id, 
                ifnull(f010.MCC_Id, '') as MCC_Id,
                ifnull(f010.CollectionShift_Id,'C015003') as CollectionShift_Id,
                f010.Created_On as Collection_Date,
                IFNULL(f010.AgentCost, 0.00) AS GRN_AgentCost,
                IFNULL(f010.TransporterCost, 0.00) AS GRN_TransporterCost,
                IFNULL(f010.MilkPrice, 0.00) AS GRN_MilkPrice,
				IFNULL(f010.Liters, 0.00) AS GRN_Quantity_Ltr
                from t009_milkcollectiondairy_posting f010
                inner join m005_mcc m005 on 
                m005.Org_Id = f010.Org_Id
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_1)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_1)
                
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Created_On  AS DATE) >= var_StartDate 
				and CAST(f010.Created_On  AS DATE)  <= var_EndDate
                and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                
                

                update temp_Report_1 tmp1 
                left join t009_milkcollectiondairy_header t009 on
                t009.Org_Id = tmp1.Org_Id
                and t009.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                set tmp1.TripDocument_Id = IFNULL(t009.TripDocument_Id,'');

                update temp_Report_1 tmp1 
                left join t022_tripdocument_item t022 on
                t022.Org_Id = tmp1.Org_Id
                and t022.MCC_Id = tmp1.MCC_Id
                and t022.TripDocument_Id = tmp1.TripDocument_Id
                set tmp1.MCCCollectionShift_Id = ifnull(t022.MCC_CollectionShift_Id,'');

                update temp_Report_1 tmp1
                inner join temp_Report_2 tmp2 on
                tmp1.Org_Id = tmp2.Org_Id
                and tmp1.MCC_Id = tmp2.MCC_Id
                and tmp1.CollectionShift_Id = tmp2.CollectionShift_Id
                and date(tmp1.Collection_Date) = date(tmp2.Collection_Date)
                and tmp1.MilkCollectionPosting_Id = tmp2.MilkCollectionPosting_Id
                and tmp1.CollectionShift_Id = 'C015003'
                set tmp1.GRN_AgentCost = IFNULL(tmp2.GRN_AgentCost, 0.00),
                tmp1.GRN_TransporterCost = IFNULL(tmp2.GRN_TransporterCost, 0.00),
                tmp1.GRN_MilkPrice = IFNULL(tmp2.GRN_MilkPrice, 0.00),
				tmp1.GRN_Quantity_Ltr = IFNULL(tmp2.GRN_Quantity_Ltr, 0.00);


                DROP TEMPORARY TABLE IF EXISTS temp_Report_3;

                CREATE TEMPORARY TABLE temp_Report_3 ( 
                Org_Id varchar(20), MCC_Id varchar(20),
                Collection_Date datetime, MCCCollectionShift_Id varchar(20), Pay_MilkPrice decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_3 (
                Org_Id , MCC_Id,MCCCollectionShift_Id,Collection_Date,Pay_MilkPrice,Pay_Quantity_Ltr
                )
                select 
                t005.Org_Id,t005.MCC_Id,t005.MCCCollectionShift_Id,
                date(t005.Created_On) as Collection_Date,
                sum(ifnull(t005.Amount,0.00)) as Pay_MilkPrice,
				sum(ifnull(t005.Quantity_Ltr,0.00)) as Pay_Quantity_Ltr
                from t005_milkcollectionfarmer t005
                
                inner join m005_mcc m005 on 
                m005.Org_Id = t005.Org_Id
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_3)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_3)
                
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and t005.MCC_Id  not in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and t005.MCC_Id in (Select MCC_Id from temp_MCC)
                and ifnull(t005.Invoice_Id,'') <> '' 
                group by MCC_Id,MCCCollectionShift_Id,date(Created_On)
                
                union all
                
                select 
                t006.Org_Id,t006.MCC_Id,t006.MCCCollectionShift_Id,
                date(t006.Created_On) as Collection_Date,
                ifnull(sum(ifnull(t006.Final_Amout_Cow,0.00) + ifnull(t006.Final_Amout_Buf,0.00)),0.00) as Pay_MilkPrice,
				ifnull(sum(ifnull(t006.Final_Qty_Cow_Ltr,0.00) + ifnull(t006.Final_Qty_Buf_Ltr,0.00)),0.00) as Pay_Quantity_Ltr
                from t006_milkcollectionagent t006
                
                inner join m005_mcc m005 on 
                m005.Org_Id = t006.Org_Id
                and m005.MCC_Id = t006.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_2)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_2)
                
                where t006.Org_Id = var_Org_Id
                and CAST(t006.Created_On  AS DATE) >= var_StartDate
				and CAST(t006.Created_On  AS DATE)  <= var_EndDate
                and t006.MCC_Id  in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and t006.MCCCollectionShift_Id in (
                select t005.MCCCollectionShift_Id from  t005_milkcollectionfarmer t005
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and t005.MCC_Id in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and ifnull(t005.Invoice_Id,'') <> '' 
                group by t005.MCCCollectionShift_Id
                )
                and t006.MCC_Id in (Select MCC_Id from temp_MCC_1)
                group by t006.MCC_Id,t006.MCCCollectionShift_Id,date(t006.Created_On);
                

                update temp_Report_1 tmp1 
                left join temp_Report_3 tmp3 on
                tmp3.Org_Id = tmp1.Org_Id
                and tmp3.MCC_Id = tmp1.MCC_Id
                and tmp3.MCCCollectionShift_Id = tmp1.MCCCollectionShift_Id
                set tmp1.Pay_MilkPrice = ifnull(tmp3.Pay_MilkPrice,0.00),
					tmp1.Pay_Quantity_Ltr = ifnull(tmp3.Pay_Quantity_Ltr,0.00);
                
                update temp_Report_1 tmp1
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = tmp1.Org_Id
                and f010.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                and f010.MCC_Id = tmp1.MCC_Id
				inner join m005_mcc m005 on
				m005.Org_Id = tmp1.Org_Id
				and m005.MCC_Id = tmp1.MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                set tmp1.Pay_MilkPrice = IFNULL(f010.MilkPrice, 0.00),
					tmp1.Pay_Quantity_Ltr = IFNULL(f010.Dairy_Quantity_Ltr, 0.00)
                where tmp1.Is_Check = 1;


				update temp_Report_1 tmp1
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = tmp1.Org_Id
                and f010.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                and f010.MCC_Id = tmp1.MCC_Id
				inner join m005_mcc m005 on
				m005.Org_Id = tmp1.Org_Id
				and m005.MCC_Id = tmp1.MCC_Id
				and m005.MCCType_Id in('C014003')
				set tmp1.Pay_MilkPrice = IFNULL(f010.MilkPrice, 0.00),
					tmp1.Pay_Quantity_Ltr = IFNULL(f010.Dairy_Quantity_Ltr, 0.00)
                where tmp1.Is_Check = 1;
                
                
                -- Update MCCName and MCCCode
				Update temp_Report_1 tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                
                Update temp_Report_1 tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
                
                Update temp_Report_1 tmp
				inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
				set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;
                
                Update temp_Report_1 tmp
				inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
				set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_4;

                CREATE TEMPORARY TABLE temp_Report_4 ( 
                Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
                TripDocument_Id varchar(20),MCCCollectionShift_Id varchar(20),
                Pay_MilkPrice decimal(30,2),
				MCC_Name varchar(100), MCC_Code varchar(20), 
				MCCType_Id varchar(20), MCCType_Name varchar(50),
                MCCWorkType_Id varchar(20),MCCWorkType_Name varchar(20),
                CollectionShift_Name varchar(20),
				GRN_Quantity_Ltr decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2)
                );
                
                Insert into temp_Report_4 (
                Org_Id , MilkCollectionDairy_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date , MilkCollectionPosting_Id , 
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,
                TripDocument_Id ,MCCCollectionShift_Id ,
                Pay_MilkPrice ,
				MCC_Name, MCC_Code , 
				MCCType_Id , MCCType_Name ,
                MCCWorkType_Id ,MCCWorkType_Name ,
                CollectionShift_Name ,
				GRN_Quantity_Ltr,
				Pay_Quantity_Ltr
                )
                select 
                Org_Id , MilkCollectionDairy_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date , MilkCollectionPosting_Id , 
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,
                TripDocument_Id ,MCCCollectionShift_Id ,
                Pay_MilkPrice ,
				MCC_Name, MCC_Code , 
				MCCType_Id , MCCType_Name ,
                MCCWorkType_Id ,MCCWorkType_Name ,
                CollectionShift_Name,
				GRN_Quantity_Ltr,
				Pay_Quantity_Ltr
                from temp_Report_1 order by  MCC_Name asc,Collection_Date asc;
                
                
				select 'TH' as RowType, 
				'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
				'MCC Type Name' as MCCType_Name, 'MCC Work Type Name' as MCCWorkType_Name, 
				'Date' as Collection_Date,
				'Collection Shift' as CollectionShift_Name,
				'Quantity Ltr (GRN)' as GRN_Quantity_Ltr,
				'Milk Price (GRN)' as GRN_MilkPrice,
				'Agent Cost (GRN)' as GRN_AgentCost,
				'Transporter Cost (GRN)' as GRN_TransporterCost,
				'Quantity Ltr (Payment)' as Pay_Quantity_Ltr,
				'Milk Price (Payment)' as Pay_MilkPrice
				union all
				select 'TR' as RowType, 
				MCC_Name, MCC_Code, MCCType_Name,MCCWorkType_Name,
				DATE_FORMAT(Collection_Date, '%d %b %Y') as Collection_Date,
				CollectionShift_Name,
				round(ifnull(GRN_Quantity_Ltr,0)) as GRN_Quantity_Ltr,
				round(ifnull(GRN_MilkPrice,0)) as GRN_MilkPrice,
				round(ifnull(GRN_AgentCost,0)) as GRN_AgentCost,
				round(ifnull(GRN_TransporterCost,0)) as GRN_TransporterCost,
				round(ifnull(Pay_Quantity_Ltr,0)) as Pay_Quantity_Ltr,
				round(ifnull(Pay_MilkPrice,0)) as Pay_MilkPrice
				from temp_Report_4;
                
            end; 
		elseif (var_Report_Type = 'C048027') then	-- Procurement Invoice Report 
			Begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
                Declare var_Destination_Name varchar(20);
                Declare var_BaseURL varchar(200);

				
                SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                
                -- Split MCCType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType;
				create temporary table temp_MCCType(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
               

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_1;
				create temporary table temp_MCCType_1(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_1 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_2;
				create temporary table temp_MCCType_2(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_2 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_3;
				create temporary table temp_MCCType_3(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_3 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCType_Id, ''));

				drop temporary table if exists temp_MCCType_4;
				create temporary table temp_MCCType_4(MCCType_Id char(255) );
				set @sql = concat('insert into temp_MCCType_4 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                
                -- Split MCC Name
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCC_Id, ''));
				
				drop temporary table if exists temp_MCC;
				create temporary table temp_MCC(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                
                drop temporary table if exists temp_MCC_1;
				create temporary table temp_MCC_1(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_1 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_1 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                drop temporary table if exists temp_MCC_2;
				create temporary table temp_MCC_2(MCC_Id char(255) );
				if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_2 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
				else
					insert into temp_MCC_2 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
				end if;
                
                -- Split MCCWorkType
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType;
				create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_1;
				create temporary table temp_MCCWorkType_1(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_1 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_2;
				create temporary table temp_MCCWorkType_2(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_2 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;

                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_3;
				create temporary table temp_MCCWorkType_3(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_3 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;
                
                
                drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCWorkType_Id, ''));

				drop temporary table if exists temp_MCCWorkType_4;
				create temporary table temp_MCCWorkType_4(MCCWorkType_Id char(255) );
				set @sql = concat('insert into temp_MCCWorkType_4 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt1 from @sql;
				execute stmt1;


				SET SQL_SAFE_UPDATES = 0;
                set sql_mode= "";

                DROP TEMPORARY TABLE IF EXISTS temp_Report_1;

                CREATE TEMPORARY TABLE temp_Report_1 ( 
                Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
                TripDocument_Id varchar(20),MCCCollectionShift_Id varchar(20),
                Pay_MilkPrice decimal(30,2),
				MCC_Name varchar(100), MCC_Code varchar(20), 
				MCCType_Id varchar(20), MCCType_Name varchar(50),
                MCCWorkType_Id varchar(20),MCCWorkType_Name varchar(20),
                CollectionShift_Name varchar(20), Is_Check varchar(20),
                GRN_Quantity_Ltr decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_1 (
                Org_Id , MilkCollectionDairy_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date , MilkCollectionPosting_Id , 
                GRN_Quantity_Ltr,
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,Is_Check
                )
                select 
                f010.Org_Id,
                f010.MilkCollectionDairy_Id, 
                f010.MCC_Id,
                ifnull(f010.CollectionShift_Id,'C015003') as CollectionShift_Id,
                f010.Collection_Date,
                f010.MilkCollectionPosting_Id,
                IFNULL(COALESCE(bk_f010.Dairy_Quantity_Ltr, f010.Dairy_Quantity_Ltr), 0.00) AS GRN_Quantity_Ltr,
                IFNULL(COALESCE(bk_f010.AgentCost, f010.AgentCost), 0.00) AS GRN_AgentCost,
                IFNULL(COALESCE(bk_f010.TransporterCost, f010.TransporterCost), 0.00) AS GRN_TransporterCost,
                IFNULL(COALESCE(bk_f010.MilkPrice, f010.MilkPrice), 0.00) AS GRN_MilkPrice,
                f010.Is_OutsideCheck as Is_Check
                from f010_milkcollectionmcc_final f010
                
                inner join m005_mcc m005 on 
                m005.Org_Id = f010.Org_Id
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
                
                left join bk_f010_milkcollectionmcc_final bk_f010 on
                bk_f010.Org_Id = f010.Org_Id
                and bk_f010.Entry_Id = f010.Entry_Id
                and bk_f010.MCC_Id = f010.MCC_Id
                and bk_f010.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
				and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                
              
                DROP TEMPORARY TABLE IF EXISTS temp_Report_2;

                CREATE TEMPORARY TABLE temp_Report_2 ( 
                Org_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
				GRN_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_2 (
                Org_Id , MilkCollectionPosting_Id , MCC_Id , CollectionShift_Id ,
                Collection_Date  , 
                GRN_AgentCost ,  GRN_TransporterCost ,  GRN_MilkPrice ,GRN_Quantity_Ltr
                )
                select 
                f010.Org_Id,
                f010.MilkCollectionPosting_Id, 
                ifnull(f010.MCC_Id, '') as MCC_Id,
                ifnull(f010.CollectionShift_Id,'C015003') as CollectionShift_Id,
                f010.Created_On as Collection_Date,
                IFNULL(f010.AgentCost, 0.00) AS GRN_AgentCost,
                IFNULL(f010.TransporterCost, 0.00) AS GRN_TransporterCost,
                IFNULL(f010.MilkPrice, 0.00) AS GRN_MilkPrice,
				IFNULL(f010.Liters, 0.00) AS GRN_Quantity_Ltr
                from t009_milkcollectiondairy_posting f010
                inner join m005_mcc m005 on 
                m005.Org_Id = f010.Org_Id
                and m005.MCC_Id = f010.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_1)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_1)
                
                where f010.Org_Id = var_Org_Id
                and CAST(f010.Created_On  AS DATE) >= var_StartDate 
				and CAST(f010.Created_On  AS DATE)  <= var_EndDate
                and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                
                

                update temp_Report_1 tmp1 
                left join t009_milkcollectiondairy_header t009 on
                t009.Org_Id = tmp1.Org_Id
                and t009.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                set tmp1.TripDocument_Id = IFNULL(t009.TripDocument_Id,'');

                update temp_Report_1 tmp1 
                left join t022_tripdocument_item t022 on
                t022.Org_Id = tmp1.Org_Id
                and t022.MCC_Id = tmp1.MCC_Id
                and t022.TripDocument_Id = tmp1.TripDocument_Id
                set tmp1.MCCCollectionShift_Id = ifnull(t022.MCC_CollectionShift_Id,'');

                update temp_Report_1 tmp1
                inner join temp_Report_2 tmp2 on
                tmp1.Org_Id = tmp2.Org_Id
                and tmp1.MCC_Id = tmp2.MCC_Id
                and tmp1.CollectionShift_Id = tmp2.CollectionShift_Id
                and date(tmp1.Collection_Date) = date(tmp2.Collection_Date)
                and tmp1.MilkCollectionPosting_Id = tmp2.MilkCollectionPosting_Id
                and tmp1.CollectionShift_Id = 'C015003'
                set tmp1.GRN_AgentCost = IFNULL(tmp2.GRN_AgentCost, 0.00),
                tmp1.GRN_TransporterCost = IFNULL(tmp2.GRN_TransporterCost, 0.00),
                tmp1.GRN_MilkPrice = IFNULL(tmp2.GRN_MilkPrice, 0.00),
				tmp1.GRN_Quantity_Ltr = IFNULL(tmp2.GRN_Quantity_Ltr, 0.00);


                DROP TEMPORARY TABLE IF EXISTS temp_Report_3;

                CREATE TEMPORARY TABLE temp_Report_3 ( 
                Org_Id varchar(20), MCC_Id varchar(20),
                Collection_Date datetime, MCCCollectionShift_Id varchar(20), Pay_MilkPrice decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2)
                );

                Insert into temp_Report_3 (
                Org_Id , MCC_Id,MCCCollectionShift_Id,Collection_Date,Pay_MilkPrice,Pay_Quantity_Ltr
                )
                select 
                t005.Org_Id,t005.MCC_Id,t005.MCCCollectionShift_Id,
                date(t005.Created_On) as Collection_Date,
                sum(ifnull(t005.Amount,0.00)) as Pay_MilkPrice,
				sum(ifnull(t005.Quantity_Ltr,0.00)) as Pay_Quantity_Ltr
                from t005_milkcollectionfarmer t005
                
                inner join m005_mcc m005 on 
                m005.Org_Id = t005.Org_Id
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_3)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_3)
                
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and t005.MCC_Id  not in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and t005.MCC_Id in (Select MCC_Id from temp_MCC)
                and ifnull(t005.Invoice_Id,'') <> '' 
                group by MCC_Id,MCCCollectionShift_Id,date(Created_On)
                
                union all
                
                select 
                t006.Org_Id,t006.MCC_Id,t006.MCCCollectionShift_Id,
                date(t006.Created_On) as Collection_Date,
                ifnull(sum(ifnull(t006.Final_Amout_Cow,0.00) + ifnull(t006.Final_Amout_Buf,0.00)),0.00) as Pay_MilkPrice,
				ifnull(sum(ifnull(t006.Final_Qty_Cow_Ltr,0.00) + ifnull(t006.Final_Qty_Buf_Ltr,0.00)),0.00) as Pay_Quantity_Ltr
                from t006_milkcollectionagent t006
                
                inner join m005_mcc m005 on 
                m005.Org_Id = t006.Org_Id
                and m005.MCC_Id = t006.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_2)
                and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_2)
                
                where t006.Org_Id = var_Org_Id
                and CAST(t006.Created_On  AS DATE) >= var_StartDate
				and CAST(t006.Created_On  AS DATE)  <= var_EndDate
                and t006.MCC_Id in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and t006.MCCCollectionShift_Id in (
                select t005.MCCCollectionShift_Id from  t005_milkcollectionfarmer t005
                where t005.Org_Id = var_Org_Id
                and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
                and t005.MCC_Id in (select MCC_Id from m005_mcc where Is_Alternate = 1)
                and ifnull(t005.Invoice_Id,'') <> '' 
                group by t005.MCCCollectionShift_Id
                )
                and t006.MCC_Id in (Select MCC_Id from temp_MCC_1)
                group by t006.MCC_Id,t006.MCCCollectionShift_Id,date(t006.Created_On);
                

                update temp_Report_1 tmp1 
                left join temp_Report_3 tmp3 on
                tmp3.Org_Id = tmp1.Org_Id
                and tmp3.MCC_Id = tmp1.MCC_Id
                and tmp3.MCCCollectionShift_Id = tmp1.MCCCollectionShift_Id
                set tmp1.Pay_MilkPrice = ifnull(tmp3.Pay_MilkPrice,0.00),
					tmp1.Pay_Quantity_Ltr = ifnull(tmp3.Pay_Quantity_Ltr,0.00);
                
                update temp_Report_1 tmp1
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = tmp1.Org_Id
                and f010.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                and f010.MCC_Id = tmp1.MCC_Id
				inner join m005_mcc m005 on
				m005.Org_Id = tmp1.Org_Id
				and m005.MCC_Id = tmp1.MCC_Id
				and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                set tmp1.Pay_MilkPrice = IFNULL(f010.MilkPrice, 0.00),
					tmp1.Pay_Quantity_Ltr = IFNULL(f010.Dairy_Quantity_Ltr, 0.00)
                where tmp1.Is_Check = 1;


				update temp_Report_1 tmp1
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = tmp1.Org_Id
                and f010.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
                and f010.MCC_Id = tmp1.MCC_Id
				inner join m005_mcc m005 on
				m005.Org_Id = tmp1.Org_Id
				and m005.MCC_Id = tmp1.MCC_Id
				and m005.MCCType_Id in('C014003')
				set tmp1.Pay_MilkPrice = IFNULL(f010.MilkPrice, 0.00),
					tmp1.Pay_Quantity_Ltr = IFNULL(f010.Dairy_Quantity_Ltr, 0.00)
                where tmp1.Is_Check = 1;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_4;

                CREATE TEMPORARY TABLE temp_Report_4 ( 
                Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), MCC_Id varchar(20), CollectionShift_Id varchar(20),
                Collection_Date datetime, MilkCollectionPosting_Id varchar(20), 
                GRN_AgentCost decimal(30,2),  GRN_TransporterCost decimal(30,2),  GRN_MilkPrice decimal(30,2),
                TripDocument_Id varchar(20),MCCCollectionShift_Id varchar(20),
                Pay_MilkPrice decimal(30,2),
				MCC_Name varchar(100), MCC_Code varchar(20), 
				MCCType_Id varchar(20), MCCType_Name varchar(50),
                MCCWorkType_Id varchar(20),MCCWorkType_Name varchar(20),
                CollectionShift_Name varchar(20),
				GRN_Quantity_Ltr decimal(30,2),
				Pay_Quantity_Ltr decimal(30,2),
                MusterCycle_StartDate datetime,
                MusterCycle_EndDate datetime
                );
                
                Insert into temp_Report_4 (
                Org_Id,MCC_Id,MusterCycle_StartDate,MusterCycle_EndDate
                )
                select t0091.Org_Id,t0091.MCC_Id,t0091.MusterCycle_StartDate,t0091.MusterCycle_EndDate 
				from t009_milkcollectiondairy_mcccommission t0091
				inner join t009_milkcollectiondairy_header t009 on
				t009.Org_Id = t0091.Org_Id
				and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				and CAST(t009.Created_On  AS DATE) >= var_StartDate
				and CAST(t009.Created_On  AS DATE)  <= var_EndDate
				inner join m005_mcc m005 on
				m005.Org_Id = t0091.Org_Id
				and m005.MCC_Id = t0091.MCC_Id
                and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_4)
				and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_4)
				where 
				t0091.Org_Id = var_Org_Id
				and t0091.MCC_Id in (Select MCC_Id from temp_MCC_2)
				group by t0091.Org_Id, t0091.MCC_Id,t0091.MusterCycle_StartDate,t0091.MusterCycle_EndDate
				order by m005.MCC_Name asc,t0091.MusterCycle_StartDate asc,t0091.MusterCycle_EndDate asc;
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_5;

                CREATE TEMPORARY TABLE temp_Report_5 ( 
				Org_Id varchar(20),MCC_Id varchar(20), 
                MusterCycle_StartDate datetime,
                MusterCycle_EndDate datetime
                )
                select Org_Id,MCC_Id,MusterCycle_StartDate,MusterCycle_EndDate from temp_Report_4;
                 

                
                UPDATE temp_Report_4 tmp4
				JOIN (
					SELECT 
						tmp1.Org_Id,
						tmp1.MCC_Id,
						tmp4.MusterCycle_StartDate,
						tmp4.MusterCycle_EndDate,
						SUM(IFNULL(tmp1.GRN_AgentCost, 0)) AS total_GRN_AgentCost,
						SUM(IFNULL(tmp1.GRN_TransporterCost, 0)) AS total_GRN_TransporterCost,
						SUM(IFNULL(tmp1.GRN_MilkPrice, 0)) AS total_GRN_MilkPrice,
						SUM(IFNULL(tmp1.Pay_MilkPrice, 0)) AS total_Pay_MilkPrice,
						SUM(IFNULL(tmp1.GRN_Quantity_Ltr, 0)) AS total_GRN_Quantity_Ltr,
						SUM(IFNULL(tmp1.Pay_Quantity_Ltr, 0)) AS total_Pay_Quantity_Ltr
					FROM temp_Report_1 tmp1
					inner JOIN temp_Report_5 tmp4 ON 
						tmp1.Org_Id = tmp4.Org_Id 
						AND tmp1.MCC_Id = tmp4.MCC_Id
					WHERE 
						date(tmp1.Collection_Date) >= date(tmp4.MusterCycle_StartDate)
						AND date(tmp1.Collection_Date) <= date(tmp4.MusterCycle_EndDate)
					GROUP BY tmp1.Org_Id, tmp1.MCC_Id, tmp4.MusterCycle_StartDate, tmp4.MusterCycle_EndDate
				) AS aggregates
				ON tmp4.Org_Id = aggregates.Org_Id
				AND tmp4.MCC_Id = aggregates.MCC_Id
				AND tmp4.MusterCycle_StartDate = aggregates.MusterCycle_StartDate
				AND tmp4.MusterCycle_EndDate = aggregates.MusterCycle_EndDate
				SET 
					tmp4.GRN_AgentCost = aggregates.total_GRN_AgentCost,
					tmp4.GRN_TransporterCost = aggregates.total_GRN_TransporterCost,
					tmp4.GRN_MilkPrice = aggregates.total_GRN_MilkPrice,
					tmp4.Pay_MilkPrice = aggregates.total_Pay_MilkPrice,
					tmp4.GRN_Quantity_Ltr = aggregates.total_GRN_Quantity_Ltr,
					tmp4.Pay_Quantity_Ltr = aggregates.total_Pay_Quantity_Ltr;
                    
                    
                    
				 -- Update MCCName and MCCCode
				Update temp_Report_4 tmp
				inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
				set tmp.MCC_Name = m005.MCC_Name,
				tmp.MCC_Code = m005.MCC_Code,
				tmp.MCCType_Id = m005.MCCType_Id,
                tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                
                Update temp_Report_4 tmp
				inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
				set tmp.MCCType_Name = c014.MCCType_Name;
                
                Update temp_Report_4 tmp
				inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
				set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;
                
                
                
				select 'TH' as RowType, 
				'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 
				'MCC Type Name' as MCCType_Name, 'MCC Work Type Name' as MCCWorkType_Name, 
				'Muster Cycle' as Collection_Date,
				'Quantity Ltr (GRN)' as GRN_Quantity_Ltr,
				'Milk Price (GRN)' as GRN_MilkPrice,
				'Agent Cost (GRN)' as GRN_AgentCost,
				'Transporter Cost (GRN)' as GRN_TransporterCost,
				'Quantity Ltr (Payment)' as Pay_Quantity_Ltr,
				'Milk Price (Payment)' as Pay_MilkPrice
				union all
				select 'TR' as RowType, 
				MCC_Name, MCC_Code, MCCType_Name,MCCWorkType_Name,
				concat( DATE_FORMAT(MusterCycle_StartDate, '%d %b %Y') ,' - ' ,DATE_FORMAT(MusterCycle_EndDate, '%d %b %Y'))as Collection_Date,
				round(ifnull(GRN_Quantity_Ltr,0)) as GRN_Quantity_Ltr,
				round(ifnull(GRN_MilkPrice,0)) as GRN_MilkPrice,
				round(ifnull(GRN_AgentCost,0)) as GRN_AgentCost,
				round(ifnull(GRN_TransporterCost,0)) as GRN_TransporterCost,
				round(ifnull(Pay_Quantity_Ltr,0)) as Pay_Quantity_Ltr,
				round(ifnull(Pay_MilkPrice,0)) as Pay_MilkPrice
				from temp_Report_4;
                
                
                
                
            end; 
        end if;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
