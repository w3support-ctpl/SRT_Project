-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `new_procedure_1` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `new_procedure_1`(
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
                    Route_Id varchar(20), Route_Name varchar(50),  FreightRateType_Id varchar(20), FreightRateType_Name varchar(50), 
                    Rate decimal(18,2), FinalDistance decimal(18,2),
                    Average_KM decimal(18,2), 
                    Diesel_Difference decimal(18,2),
                    DieselBaseRate decimal(18,2), 
                    CurrentDieselRate decimal(18,2), TripAmount decimal(18,2), Is_PostedInSAP int, VehicleOwnershipType_Id varchar(20),
                    VehicleOwnershipType_Name varchar(50), Liters decimal(8,3), 
                    DieselRateDiff decimal(18,2), 
                    FinalAmount decimal(18,2))
                    ;
                    
                    insert into temp_Report (Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    Trip_Date, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    TripAmount, DieselRateDiff, FinalAmount, Is_PostedInSAP, Liters,
                    Average_KM,Diesel_Difference)
                    select Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    DATE_FORMAT(Created_On, '%d %b %Y') as Created_On, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    Cost, 
                    case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end as DieselRateDiff, 
                    Cost + (case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end) as Total_Freight,  
                    CASE 
						WHEN Invoice_Id IS NULL OR Invoice_Id = '' THEN 0
						ELSE 1
					END AS Is_PostedInSAP, 
                    Roundoff('QuantityForDairy', (ifnull(Liters,0))) as Liters ,
                    Average_KM,Diesel_Difference
                    from t021_tripdocument_header t021
                    where t021.Org_Id = var_org_id
                    and CAST(t021.Created_On  AS DATE) >= var_StartDate 
					and CAST(t021.Created_On  AS DATE)  <= var_EndDate
                    -- and t021.Vehicle_Id ='M003241000002' 
                    and t021.Transporter_Id in (Select Transporter_Id from temp_Transporter);
                    
                    -- Update Transporter Name
                    update temp_Report tmp
                    inner join m009_transporter m9 on tmp.Org_Id = m9.Org_Id 
                    and tmp.Transporter_Id = m9.Transporter_Id
                    set tmp.Transporter_Name = m9.Transporter_Name,
                    tmp.Transporter_Code = m9.Transporter_Code;
                    
                    -- Update Vehicle No
                    update temp_Report tmp
                    inner join m003_vehicle m3 on tmp.Org_Id = m3.Org_Id 
                    and tmp.Vehicle_Id = m3.Vehicle_Id
                    and tmp.Transporter_Id = m3.Transporter_Id
                    set tmp.Vehicle_No = m3.Vehicle_No,
                    tmp.VehicleType_Id = m3.VehicleType_Id,
                    tmp.VehicleOwnershipType_Id = m3.VehicleOwnershipType_Id,
                    tmp.VehicleMake_Id = m3.VehicleMake_Id;
                    
                    -- Update Route Details
					update temp_Report tmp
                    inner join m008_route_vehicle m8 on tmp.Org_Id = m8.Org_Id 
                    and tmp.Route_Trip_Id = m8.Entry_Id
                    set tmp.Route_Id = m8.Route_Id;
                    
                    -- Update Route Name
                    update temp_Report tmp
                    inner join m006_route m6 on tmp.Org_Id = m6.Org_Id 
                    and tmp.Route_Id = m6.Route_Id
                    set tmp.Route_Name = m6.Route_Name;
                    
                    -- Update Rate Type
                    update temp_Report tmp
                    inner join c029_freightratetype c29 on
                    tmp.FreightRateType_Id = c29.FreightRateType_Id
                    set tmp.FreightRateType_Name = c29.FreightRateType_Name;
                    
                    -- Update Vehicle Type
                    update temp_Report tmp
                    inner join c020_vehicletype c20 on
                    tmp.VehicleType_Id = c20.VehicleType_Id
                    set tmp.VehicleType_Name = c20.VehicleType_Name;
                    
                    -- Update Vehicle Ownership Type
                    update temp_Report tmp
                    inner join c021_vehicleownershiptype c21 on
                    tmp.VehicleOwnershipType_Id = c21.VehicleOwnershipType_Id
                    set tmp.VehicleOwnershipType_Name = c21.VehicleOwnershipType_Name;
                    
                    
                    update temp_Report tmp
                    inner join c032_vehiclemake c032 on
                    tmp.VehicleMake_Id = c032.VehicleMake_Id
                    set tmp.VehicleMake_Name = c032.VehicleMake_Name;
                    
                    /*
                    -- Generate final output
                    select 'TH' as RowType, 'Transporter Name' as Transporter_Name, 'Transporter Code' as Transporter_Code,
                    'Vehicle No' as Vehicle_No, 
                    'Vehicle Type' as VehicleType_Name, 
                    'Vehicle Make' as VehicleMake_Name, 
                    'Ownershp Type' as VehicleOwnershipType_Name,
                    'Trip Date' as Trip_Date, 
                    'Route Name' as Route_Name, 'Rate Type' as FreightRateType_Name,
                    'Rate' as Rate,  
                    'Distance (KM)' as FinalDistance, 
                    'Average (KM)' as Average_KM, 
                    'Diesel Diff' as Diesel_Difference, 
                    'Diesel Base Rate' as DieselBaseRate, 'Milk Qty (Liters)' as Liters,
                    'Current Diesel Rate' as CurrentDieselRate, 'Trip Amount' as TripAmount, 'Diesel Rate Diff' as DieselRateDiff,
                    'Final Amount' as FinalAmount, 
                    'Invoice Status' as Is_PostedInSAP
                    
                    union
                    
                    select 'TR' as RowType, Transporter_Name as Transporter_Name, Transporter_Code as Transporter_Code,
                    ifnull(Vehicle_No,'') as Vehicle_No, 
                    ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
                    ifnull(VehicleOwnershipType_Name,''),
                    Trip_Date as Trip_Date, 
                    Route_Name, FreightRateType_Name as FreightRateType_Name,
                    Rate, FinalDistance,
                    Average_KM, 
                    Diesel_Difference, 
                    DieselBaseRate, Liters, CurrentDieselRate, TripAmount, 
                    DieselRateDiff, FinalAmount,
                    case when Is_PostedInSAP = 0 then 'Not Posted' else 'Posted' end as Is_PostedInSAP
                    from temp_Report;
                    
                    */
                    
                    select 
                    Transporter_Name as Transporter_Name, 
                    Transporter_Code as Transporter_Code,
                    ifnull(Vehicle_No,'') as Vehicle_No, 
                    ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
                    ifnull(VehicleOwnershipType_Name,''),
                    Trip_Date as Trip_Date, 
                    Route_Name, FreightRateType_Name as FreightRateType_Name,
                    Rate, FinalDistance,
                    Average_KM, 
                    Diesel_Difference, 
                    DieselBaseRate, Liters, CurrentDieselRate, TripAmount, 
                    DieselRateDiff, FinalAmount,
                    case when Is_PostedInSAP = 0 then 'Not Posted' else 'Posted' end as Is_PostedInSAP
                    from temp_Report
                    where ifnull(FreightRateType_Name,'') <>  '';
                    
                    select 
					Transporter_Name as Transporter_Name, 
					Transporter_Code as Transporter_Code,
					ifnull(Vehicle_No,'') as Vehicle_No, 
					ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
					ifnull(VehicleOwnershipType_Name,'') as VehicleOwnershipType_Name,
					-- Trip_Date as Trip_Date, 
					-- Route_Name, 
					ifnull(FreightRateType_Name,'') as FreightRateType_Name,
					avg(ifnull(Rate,0)) as Rate, 
					avg(ifnull(FinalDistance,0)) as FinalDistance,
					avg(ifnull(Average_KM, 0)) as Average_KM,
					avg(ifnull(Diesel_Difference, 0)) as Diesel_Difference,
					avg(ifnull(DieselBaseRate,0)) as DieselBaseRate, 
					sum(ifnull(Liters, 0)) as Liters,
					avg(ifnull(CurrentDieselRate,0)) as CurrentDieselRate, 
					avg(ifnull(TripAmount, 0)) as TripAmount,
					sum(ifnull(DieselRateDiff, 0)) as DieselRateDiff, -- Diesel Rate Diff
					sum(ifnull(FinalAmount,0)) as FinalAmount -- Trip Amount
					from temp_Report
                    where ifnull(FreightRateType_Name,'') <>  ''
                    group by
                    Transporter_Name, 
					Transporter_Code,
					Vehicle_No, 
					VehicleType_Name, 
					VehicleMake_Name, 
					VehicleOwnershipType_Name,
					FreightRateType_Name;
										
                    
                    
                    
                    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
