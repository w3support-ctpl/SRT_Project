-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `new_procedure_2` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `new_procedure_2`(
	IN `var_org_id` VARCHAR(10),
	IN `var_Method_Name` VARCHAR(20),
	IN `var_Report_Type` VARCHAR(50),
	IN `var_MCCType_Id` text,
	IN `var_ReportPeriod` VARCHAR(50),
	IN `var_MCCCollectionShift_Id` text,
	IN `var_MilkType_Id` text,
	IN `var_MCC_Id` text,
	IN `var_MCCWorkType_Id` text,
	IN `var_MusterStartDate` text,
	IN `var_MusterEndDate` text
)
BEGIN
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;
					SET SQL_SAFE_UPDATES=0;
					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCC_Id, ''));
                    
                    drop temporary table if exists temp_Transporter;
					create temporary table temp_Transporter(Transporter_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_Transporter (Transporter_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_Transporter (Transporter_Id)
                        select Transporter_Id from m009_transporter where Org_Id = var_org_id and Is_Active = 1;
                    end if;
                    
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), TripDocument_Id varchar(45), Route_Trip_Id varchar(45), Transporter_Id varchar(20), 
                    Transporter_Name varchar(100), Transporter_Code varchar(20), Vehicle_Id varchar(45),
                    Vehicle_No varchar(45), 
                    VehicleType_Id varchar(20), VehicleType_Name varchar(45), 
                    VehicleMake_Id varchar(20), VehicleMake_Name varchar(45), 
                    Trip_Date varchar(20), 
                     FreightRateType_Id varchar(20), FreightRateType_Name varchar(50), 
                    Rate decimal(18,2), FinalDistance decimal(18,2),
                    Average_KM decimal(18,2), 
                    Diesel_Difference decimal(18,2),
                    DieselBaseRate decimal(18,2), 
                    CurrentDieselRate decimal(18,2), TripAmount decimal(18,2),  VehicleOwnershipType_Id varchar(20),
                    VehicleOwnershipType_Name varchar(50), Liters decimal(18,3), 
                    DieselRateDiff decimal(18,2), 
                    FinalAmount decimal(18,2))
                    ;
                    
                    insert into temp_Report (Org_Id, TripDocument_Id, Transporter_Id, Vehicle_Id, 
                    Trip_Date, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    TripAmount, DieselRateDiff, FinalAmount, Liters,
                    Average_KM,Diesel_Difference)
                    select Org_Id, TripDocument_Id, Transporter_Id, Vehicle_Id, 
                    DATE_FORMAT(Created_On, '%d %b %Y') as Created_On, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    Cost, 
                    case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end as DieselRateDiff, 
                    Cost + (case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end) as Total_Freight,  
                    Roundoff('QuantityForDairy', (ifnull(Liters,0))) as Liters ,
                    Average_KM,Diesel_Difference
                    from t021_tripdocument_header t021
                    where t021.Org_Id = var_org_id
                    and CAST(t021.Created_On  AS DATE) >= var_StartDate 
					and CAST(t021.Created_On  AS DATE)  <= var_EndDate
                    -- and t021.Vehicle_Id ='M003241000002' 
                    and t021.Transporter_Id in (Select Transporter_Id from temp_Transporter);
                    
                    
                    
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
					CREATE TEMPORARY TABLE temp_Report_1 ( 
					Org_Id varchar(20), TripDocument_Id varchar(45), Route_Trip_Id varchar(45), Transporter_Id varchar(20), 
                    Transporter_Name varchar(100), Transporter_Code varchar(20), Vehicle_Id varchar(45),
                    Vehicle_No varchar(45), 
                    VehicleType_Id varchar(20), VehicleType_Name varchar(45), 
                    VehicleMake_Id varchar(20), VehicleMake_Name varchar(45), 
                    Trip_Date varchar(20), 
                     FreightRateType_Id varchar(20), FreightRateType_Name varchar(50), 
                    Rate decimal(18,2), FinalDistance decimal(18,2),
                    Average_KM decimal(18,2), 
                    Diesel_Difference decimal(18,2),
                    DieselBaseRate decimal(18,2), 
                    CurrentDieselRate decimal(18,2), TripAmount decimal(18,2),  VehicleOwnershipType_Id varchar(20),
                    VehicleOwnershipType_Name varchar(50), Liters decimal(18,3), 
                    DieselRateDiff decimal(18,2), 
                    FinalAmount decimal(18,2),
                    LabourCharge decimal(18,2),
                    CattleFeed decimal(18,2),
                    GrossAmount decimal(18,2),
                    
                    
                    SecurityDeposit decimal(18,2), 
                    DieselRecovery decimal(18,2),
                    Advance decimal(18,2),
                    BankLoan_ICICI decimal(18,2),
                    BankLoan_Society decimal(18,2),
                    CanRecoveryCharges decimal(18,2),
                    TDS decimal(18,2),
                    
                    RecoveryAmount decimal(18,2),
                    RecoveryLtr decimal(18,2),
                    
                    TotalDeduction decimal(18,2),
                    NetPayable decimal(18,2)
                    );
                    
                    insert into temp_Report_1 (
                    Org_Id, 
                    Transporter_Id, 
                    Vehicle_Id, 
                    FreightRateType_Id, 
                    Rate,
                    FinalDistance,
                    Average_KM,
                    Diesel_Difference,
                    DieselBaseRate,
                    CurrentDieselRate,
                    TripAmount,
                    Liters,
                    DieselRateDiff,
                    FinalAmount)
                    
                    select 
                    Org_Id, 
                    Transporter_Id, 
                    Vehicle_Id, 
                    FreightRateType_Id, 
                    avg(ifnull(Rate,0)) as Rate, 
                    avg(ifnull(FinalDistance,0)) as FinalDistance, 
                    avg(ifnull(Average_KM, 0)) as Average_KM, 
                    avg(ifnull(Diesel_Difference, 0)) as Diesel_Difference,
                    avg(ifnull(DieselBaseRate,0)) as DieselBaseRate, 
                    avg(ifnull(CurrentDieselRate,0)) as CurrentDieselRate, 
                    avg(ifnull(TripAmount, 0)) as TripAmount,
                    sum(ifnull(Liters, 0)) as Liters, 
                    sum(ifnull(DieselRateDiff, 0)) as DieselRateDiff, -- Diesel Rate Diff
                    sum(ifnull(FinalAmount,0)) as FinalAmount -- Trip Amount
					-- sum(ifnull(FinalAmount,0)) - sum(ifnull(DieselRateDiff, 0)) as FinalAmount  -- gross half amount
                    from temp_Report
                    where ifnull(FreightRateType_Id,'') <> ''
                    group by 
                    Org_Id, 
                    Transporter_Id, 
                    Vehicle_Id, 
                    FreightRateType_Id;
                    
                    
                    
                     -- Update Transporter Name
                    update temp_Report_1 tmp
                    inner join m009_transporter m9 on tmp.Org_Id = m9.Org_Id 
                    and tmp.Transporter_Id = m9.Transporter_Id
                    set tmp.Transporter_Name = m9.Transporter_Name,
                    tmp.Transporter_Code = m9.Transporter_Code;
                    
                    -- Update Vehicle No
                    update temp_Report_1 tmp
                    inner join m003_vehicle m3 on tmp.Org_Id = m3.Org_Id 
                    and tmp.Vehicle_Id = m3.Vehicle_Id
                    and tmp.Transporter_Id = m3.Transporter_Id
                    set tmp.Vehicle_No = m3.Vehicle_No,
                    tmp.VehicleType_Id = m3.VehicleType_Id,
                    tmp.VehicleOwnershipType_Id = m3.VehicleOwnershipType_Id,
                    tmp.VehicleMake_Id = m3.VehicleMake_Id,
                    tmp.LabourCharge = ifnull(m3.LabourCharge,0);
                    
                    -- Update Rate Type
                    update temp_Report_1 tmp
                    inner join c029_freightratetype c29 on
                    tmp.FreightRateType_Id = c29.FreightRateType_Id
                    set tmp.FreightRateType_Name = c29.FreightRateType_Name;
                    
                    -- Update Vehicle Type
                    update temp_Report_1 tmp
                    inner join c020_vehicletype c20 on
                    tmp.VehicleType_Id = c20.VehicleType_Id
                    set tmp.VehicleType_Name = c20.VehicleType_Name;
                    
                    -- Update Vehicle Ownership Type
                    update temp_Report_1 tmp
                    inner join c021_vehicleownershiptype c21 on
                    tmp.VehicleOwnershipType_Id = c21.VehicleOwnershipType_Id
                    set tmp.VehicleOwnershipType_Name = c21.VehicleOwnershipType_Name;
                    
                    update temp_Report_1 tmp
                    inner join c032_vehiclemake c032 on
                    tmp.VehicleMake_Id = c032.VehicleMake_Id
                    set tmp.VehicleMake_Name = c032.VehicleMake_Name;
                    
                    update temp_Report_1 tmp
                    set tmp.LabourCharge = 0
                    where ifnull(tmp.LabourCharge,'') = '';
                    
                    UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t042.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0421.Incentive_Amount), 0) AS TotalIncentive
						FROM t042_incentives_header t042
						INNER JOIN t042_incentives_item t0421 
							ON t0421.Org_Id = t042.Org_Id 
							AND t0421.Incentives_Id = t042.Incentives_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t042.Org_Id 
							AND t042.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0421.Incentive_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t042.Request_User_Type = 'Transporter'
						GROUP BY t042.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.CattleFeed = inc.TotalIncentive;

                    
                    update temp_Report_1 tmp
                    set tmp.CattleFeed = 0
                    where ifnull(tmp.CattleFeed,'') = '';
                    
                    update temp_Report_1 tmp
                    set tmp.GrossAmount = 
						ifnull(tmp.DieselRateDiff,0) + ifnull(tmp.FinalAmount,0) + ifnull(tmp.LabourCharge,0)+ ifnull(tmp.CattleFeed,0);
                    
                    update temp_Report_1 tmp
                    set tmp.GrossAmount = 0
                    where ifnull(tmp.GrossAmount,'') = '';
                    
					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000001'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.SecurityDeposit = inc.Deduction_Amount;
                    
                    
                    update temp_Report_1 tmp
                    set tmp.SecurityDeposit = 0
                    where ifnull(tmp.SecurityDeposit,'') = '';

					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000002'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.DieselRecovery = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.DieselRecovery = 0
                    where ifnull(tmp.DieselRecovery,'') = '';


					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000003'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.Advance = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.Advance = 0
                    where ifnull(tmp.Advance,'') = '';

					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000004'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.BankLoan_ICICI = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.BankLoan_ICICI = 0
                    where ifnull(tmp.BankLoan_ICICI,'') = '';

					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000018'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.BankLoan_Society = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.BankLoan_Society = 0
                    where ifnull(tmp.BankLoan_Society,'') = '';

					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000005'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.CanRecoveryCharges = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.CanRecoveryCharges = 0
                    where ifnull(tmp.CanRecoveryCharges,'') = '';

					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t033.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t0331.Deduction_Amount), 0) AS Deduction_Amount
						FROM t033_deductions_header t033
						INNER JOIN t033_deductions_item t0331 
							ON t0331.Org_Id = t033.Org_Id 
							AND t0331.Deductions_Id = t033.Deductions_Id 
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t033.Org_Id 
							AND t033.Request_User_Id = m009.Transporter_Id
						WHERE DATE(t0331.Deduction_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t033.Request_User_Type = 'Transporter'
						  and t033.Request_Type = 'M020231000006'
						GROUP BY t033.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.TDS = inc.Deduction_Amount;
                    
                    update temp_Report_1 tmp
                    set tmp.TDS = 0
                    where ifnull(tmp.TDS,'') = '';
                    
                    
                    UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t043.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t043.Amount), 0) AS RecoveryAmount
						FROM t043_dieselupload t043
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t043.Org_Id 
							AND t043.Transporter_Id = m009.Transporter_Id
						WHERE DATE(t043.Entry_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t043.Quantity_Ltr  <> 0
						GROUP BY t043.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.RecoveryAmount = inc.RecoveryAmount;
                    
                    update temp_Report_1 tmp
                    set tmp.RecoveryAmount = 0
                    where ifnull(tmp.RecoveryAmount,'') = '';


					UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t043.Org_Id,
							m009.Transporter_Id,
							IFNULL(SUM(t043.Quantity_Ltr), 0) AS RecoveryLtr
						FROM t043_dieselupload t043
						INNER JOIN m009_transporter m009 
							ON m009.Org_Id = t043.Org_Id 
							AND t043.Transporter_Id = m009.Transporter_Id
						WHERE DATE(t043.Entry_Date) 
							  BETWEEN var_StartDate AND var_EndDate
						  AND t043.Quantity_Ltr  <> 0
						GROUP BY t043.Org_Id, m009.Transporter_Id
					) AS inc 
						ON tmp.Org_Id = inc.Org_Id
					   AND tmp.Transporter_Id = inc.Transporter_Id
					SET tmp.RecoveryLtr = inc.RecoveryLtr;
                    
                    
                    update temp_Report_1 tmp
                    set tmp.RecoveryLtr = 0
                    where ifnull(tmp.RecoveryLtr,'') = '';
                    
                    update temp_Report_1 tmp
                    set tmp.TotalDeduction = 
						ifnull(tmp.SecurityDeposit,0) + ifnull(tmp.DieselRecovery,0) + ifnull(tmp.Advance,0)+ ifnull(tmp.BankLoan_ICICI,0)+ ifnull(tmp.BankLoan_Society,0) + ifnull(tmp.CanRecoveryCharges,0) + ifnull(tmp.TDS,0) + ifnull(tmp.RecoveryAmount,0);
                    
                    update temp_Report_1 tmp
                    set tmp.TotalDeduction = 0
                    where ifnull(tmp.TotalDeduction,'') = '';
                    
                    update temp_Report_1 tmp
                    set tmp.NetPayable = 
						ifnull(tmp.GrossAmount,0) - ifnull(tmp.TotalDeduction,0);
					
                    select 'TH' as RowType, 
					'Transporter Name' as Transporter_Name, 
                    'Transporter Code' as Transporter_Code,
                    'Vehicle No' as Vehicle_No, 
                    'Vehicle Type' as VehicleType_Name, 
					'Vehicle Make' as VehicleMake_Name, 
                    'Ownershp Type' as VehicleOwnershipType_Name,
                    'Freight Rate Type' as FreightRateType_Name,
                    'Rate (avg)' as Rate,
                    'Distance (KM) (avg)' as FinalDistance,
                    'Average (KM) (avg)' as Average_KM,
                    'Diesel Diff (avg)' as Diesel_Difference,
                    'Diesel Rate Diff (avg)' as DieselBaseRate,
                    'Current Diesel Rate (avg)' as CurrentDieselRate,
                    'Trip Amount (avg)' as TripAmount,
                    'Milk Qty (sum)' as Liters,
                    'Diesel Base Rate (sum)' as DieselRateDiff,
                    'Final Amount (sum)' as FinalAmount,
                    'Labour Charge (fixed as muster)' as LabourCharge,
                    'Cattle Feed (sum)' as CattleFeed,
                    'Gross Amount' as GrossAmount,
                    'Security Deposit (sum)' as SecurityDeposit,
                    'Diesel Recovery (sum)' as DieselRecovery,
                    'Advance' as Advance,
                    'Bank Loan ( ICICI ) (sum)' as BankLoan_ICICI,
                    'Bank Loan ( Society ) (sum)' as BankLoan_Society,
                    'Can Recovery Charges (sum)' as CanRecoveryCharges,
                    'TDS (sum)' as TDS,
                    'Recovery Amount (sum)' as RecoveryAmount,
                    'Recovery Ltr (sum)' as RecoveryLtr,
                    'Total Deduction' as TotalDeduction,
                    'Net Payable' as NetPayable
                    
                    union
                    
                    select 'TR' as RowType, 
					Transporter_Name as Transporter_Name, 
                    Transporter_Code as Transporter_Code,
                    ifnull(Vehicle_No,'') as Vehicle_No, 
                    ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
                    ifnull(VehicleOwnershipType_Name,'') as VehicleOwnershipType_Name,
                    ifnull(FreightRateType_Name,'') as FreightRateType_Name,
                    Rate,
                    FinalDistance,
                    Average_KM,
                    Diesel_Difference,
                    DieselBaseRate,
                    CurrentDieselRate,
                    TripAmount,
                    Liters,
                    DieselRateDiff,
                    FinalAmount,
                    LabourCharge,
                    CattleFeed,
                    GrossAmount,
                    SecurityDeposit,
                    DieselRecovery,
                    Advance,
                    BankLoan_ICICI,
                    BankLoan_Society,
                    CanRecoveryCharges,
                    TDS,
                    RecoveryAmount,
                    RecoveryLtr,
                    TotalDeduction,
                    NetPayable
                    from temp_Report_1;
                    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
