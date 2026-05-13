-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminReportMilkCollection` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminReportMilkCollection`(
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
	SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Get') then
		Begin
			if (var_Report_Type = 'R1' or var_Report_Type = 'R2') then	
				Begin
					Declare var_CollectionShift_Id varchar(20);
                    Declare var_VehicleType_Id varchar(20);
                    
                    if (var_Report_Type = 'R1') then
						set var_CollectionShift_Id = 'C015001';
                        set var_VehicleType_Id = 'C020001';
					elseif (var_Report_Type = 'R2') then
						set var_CollectionShift_Id = 'C015002';
                        set var_VehicleType_Id = 'C020001';
                    end if;
                    
					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionDairy_Id varchar(20),  TripDocument_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), Route_Name varchar(50), VehicleType_Id varchar(20), VehicleType_Name varchar(50),
                    DairyQtyLtr decimal(18,3), DairyFAT decimal(18,3), DairySNF decimal(18,3), 
                    FinalQtyLtr decimal(18,3), FinalFAT decimal(18,3), FinalSNF decimal(18,3), 
                    GRNBatchNo varchar(50), SAPDocumentNo varchar(50), MCCType_Id varchar(20), MCCType_Name varchar(20), MilkStatus_Id varchar(20));
                    
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, MilkType_Id, TripDocument_Id, Route_Name, VehicleType_Id, MilkStatus_Id, DairyQtyLtr, DairyFAT, DairySNF)
					select t021.Org_Id, DATE_FORMAT(t009.Created_On, '%d %b %Y'), t009.MilkCollectionDairy_Id, t0091.MCC_Id, m006.CollectionShift_Id, t0091.MilkType_Id, t009.TripDocument_Id, m006.Route_Name, m006.VehicleType_Id, t0091.MilkStatus_Id,
                    sum(t0091.Liters) as Dairy_Ltr, -- sum(t0091.Weight) as Dairy_Kg,
					Roundoff('Quality', sum(t009Q.Fat * t0091.Weight)/ sum(t0091.Weight)) as Dairy_FAT,
                    Roundoff('Quality', sum(t009Q.SNF * t0091.Weight )/ sum(t0091.Weight)) as Dairy_SNF 
					from t009_milkcollectiondairy_header t009
					inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
						and t009.TripDocument_Id = t021.TripDocument_Id
					inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id
						and m008.Entry_Id = t021.Route_Trip_Id
					inner join m006_route m006 on m008.Org_Id = m006.Org_Id
						and m008.Route_Id = m006.Route_Id
						and m006.CollectionShift_Id = var_CollectionShift_Id 
					inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
						and m003.Vehicle_Id = t009.Vehicle_Id
						and m003.VehicleType_Id = var_VehicleType_Id
					inner join t009_milkcollectiondairy_quantity t0091 on t009.Org_Id = t0091.Org_Id
						and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
						and t0091.TripDocument_Id = t009.TripDocument_Id
						and t0091.MilkStatus_Id = 'C016001'
					inner join t009_milkcollectiondairy_quality t009Q on t0091.Org_Id = t009Q.Org_Id
						and t0091.MilkCollectionDairy_Id = t009Q.MilkCollectionDairy_Id
						and t0091.TripDocument_Id = t009Q.TripDocument_Id
						and t0091.Batch_Id = t009Q.Batch_Id 
					where t009.Org_Id = var_org_id
					and date(t009.Created_On) = date(now())  
					group by Org_Id, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, t0091.MilkType_Id, Route_Name, m006.VehicleType_Id, TripDocument_Id, t0091.MilkStatus_Id;
                    
                    
                    -- Read Final Collection Data
                    UPdate temp_Report tmp
                    inner join f010_milkcollectionmcc_final f010 on tmp.Org_Id = f010.Org_Id and tmp.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
                    and tmp.MCC_Id = f010.MCC_Id
                    set tmp.FinalQtyLtr = f010.Dairy_Quantity_Ltr,
                    tmp.FinalFAT = f010.Dairy_Fat,
                    tmp.FinalSNF = f010.Dairy_SNF;
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id;
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update VehicleType Name
                    Update temp_Report tmp
                    inner join c020_vehicletype c020 on tmp.VehicleType_Id = c020.VehicleType_Id
                    set tmp.VehicleType_Name = c020.VehicleType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;
                    
                    -- Generate final output
                    select 'TH' as RowType, 'Date' as Collection_Date, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 'MCC Type' as MCCType_Name, 
                    'Collection Shift' as CollectionShift_Name, 'Milk Type' as MilkType_Name, 'Route Name' as Route_Name, 'Vehicle Type' as VehicleType_Name, 
                    'Received Qty (Ltr)' as DairyQtyLtr, 'Received FAT%' as DairyFAT, 'Received SNF%' as DairySNF,
                    'Final Qty (Ltr)' as FinalQtyLtr, 'Final FAT%' as FinalFAT, 'Final SNF%' as FinalSNF
                    
                    union
                    
                    select 'TR' as RowType, Collection_Date, MCC_Name, MCC_Code, MCCType_Name,
                    CollectionShift_Name, MilkType_Name, Route_Name, VehicleType_Name,
                    ifnull(DairyQtyLtr,0) as DairyQtyLtr, ifnull(DairyFAT,0) as DairyFAT, ifnull(DairySNF,0) as DairySNF, 
                    ifnull(FinalQtyLtr,0) as FinalQtyLtr, ifnull(FinalFAT,0) as FinalFAT, ifnull(FinalSNF,0) as FinalSNF
                    from temp_Report;

				end;
			elseif (var_Report_Type = 'R3') then
				Begin
                    Declare var_VehicleType_Id varchar(20);
                    set var_VehicleType_Id = 'C020002';
                    
					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionDairy_Id varchar(20),  TripDocument_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), Route_Name varchar(50), VehicleType_Id varchar(20), VehicleType_Name varchar(50),
                    DairyQtyLtr decimal(18,3), DairyFAT decimal(18,3), DairySNF decimal(18,3), 
                    FinalQtyLtr decimal(18,3), FinalFAT decimal(18,3), FinalSNF decimal(18,3), 
                    GRNBatchNo varchar(50), SAPDocumentNo varchar(50), MCCType_Id varchar(20), MCCType_Name varchar(20), MilkStatus_Id varchar(20));
                    
                    -- BMC
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, MilkType_Id, TripDocument_Id, Route_Name, VehicleType_Id, MilkStatus_Id, DairyQtyLtr, DairyFAT, DairySNF)
					select t021.Org_Id, DATE_FORMAT(t009.Created_On, '%d %b %Y'), t009.MilkCollectionDairy_Id, t0091.MCC_Id, m006.CollectionShift_Id, t0091.MilkType_Id, t009.TripDocument_Id, m006.Route_Name, m006.VehicleType_Id, t0091.MilkStatus_Id,
                    sum(t0091.Liters) as Dairy_Ltr, -- sum(t0091.Weight) as Dairy_Kg,
					Roundoff('Quality', sum(t009Q.Fat * t0091.Weight)/ sum(t0091.Weight)) as Dairy_FAT,
                    Roundoff('Quality', sum(t009Q.SNF * t0091.Weight )/ sum(t0091.Weight)) as Dairy_SNF 
					from t009_milkcollectiondairy_header t009
					inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
						and t009.TripDocument_Id = t021.TripDocument_Id
					inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id
						and m008.Entry_Id = t021.Route_Trip_Id
					inner join m006_route m006 on m008.Org_Id = m006.Org_Id
						and m008.Route_Id = m006.Route_Id
					inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
						and m003.Vehicle_Id = t009.Vehicle_Id
						and m003.VehicleType_Id = var_VehicleType_Id
					inner join t009_milkcollectiondairy_quantity t0091 on t009.Org_Id = t0091.Org_Id
						and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
						and t0091.TripDocument_Id = t009.TripDocument_Id
						and t0091.MilkStatus_Id = 'C016001'
					inner join t009_milkcollectiondairy_quality t009Q on t0091.Org_Id = t009Q.Org_Id
						and t0091.MilkCollectionDairy_Id = t009Q.MilkCollectionDairy_Id
						and t0091.TripDocument_Id = t009Q.TripDocument_Id
						and t0091.CellNo = t009Q.CellNo
					where t009.Org_Id = var_org_id
					and date(t009.Created_On) =  date(now())  -- date('2024-02-14') -- 
					group by Org_Id, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, t0091.MilkType_Id, Route_Name, m006.VehicleType_Id, TripDocument_Id, t0091.MilkStatus_Id;
                    
                    -- Bulk Supplier
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Name, MilkType_Id, TripDocument_Id, Route_Name, VehicleType_Id, MilkStatus_Id, DairyQtyLtr, DairyFAT, DairySNF)
                    select t009.Org_Id, DATE_FORMAT(t009.Created_On, '%d %b %Y'), t009.MilkCollectionDairy_Id, MCC_Id,  
					'All Day', MilkType_Id, t009.TripDocument_Id, '' as Route_Name, 'C020002' as VehicleType_Id, MilkStatus_Id, Liters, FAT, SNF
					from t009_milkcollectiondairy_header t009
					inner join t009_milkcollectiondairy_quantity t0091 on
					t0091.Org_Id = t009.Org_Id
					and t0091.MilkStatus_Id = 'C016001'
					and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					where date(t009.Created_On) = date(now())
					and t009.Org_Id = var_org_id
					and t009.Is_OutsideVehicle = 1;
                    
                    -- Read Final Collection Data
                    UPdate temp_Report tmp
                    inner join f010_milkcollectionmcc_final f010 on tmp.Org_Id = f010.Org_Id and tmp.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
                    and tmp.MCC_Id = f010.MCC_Id
                    set tmp.FinalQtyLtr = f010.Dairy_Quantity_Ltr,
                    tmp.FinalFAT = f010.Dairy_Fat,
                    tmp.FinalSNF = f010.Dairy_SNF;
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id;
                    
                    Update temp_Report tmp
                    set tmp.Route_Name =  concat('Bulk - ', tmp.MCC_Name)
                    where Route_Name = '';
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update VehicleType Name
                    Update temp_Report tmp
                    inner join c020_vehicletype c020 on tmp.VehicleType_Id = c020.VehicleType_Id
                    set tmp.VehicleType_Name = c020.VehicleType_Name;
                    
                    -- Generate final output
                    select 'TH' as RowType, 'Date' as Collection_Date, 
                    'Collection Shift' as CollectionShift_Name, 'Milk Type' as MilkType_Name, 'Route Name' as Route_Name, 'Vehicle Type' as VehicleType_Name, 
                    'Received Qty (Ltr)' as DairyQtyLtr, 'Received FAT%' as DairyFAT, 'Received SNF%' as DairySNF,
                    'Final Qty (Ltr)' as FinalQtyLtr, 'Final FAT%' as FinalFAT, 'Final SNF%' as FinalSNF
                    
                    union
                    
                    select 'TR' as RowType, Collection_Date, 
                    CollectionShift_Name, MilkType_Name, Route_Name, VehicleType_Name,
                    ifnull(DairyQtyLtr,0) as DairyQtyLtr, ifnull(DairyFAT,0) as DairyFAT, ifnull(DairySNF,0) as DairySNF, 
                    ifnull(FinalQtyLtr,0) as FinalQtyLtr, ifnull(FinalFAT,0) as FinalFAT, ifnull(FinalSNF,0) as FinalSNF
                    from temp_Report;
                end;
			elseif (var_Report_Type = 'C048001' or var_Report_Type = 'C048002' or var_Report_Type = 'C048012') then
				begin
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

                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id
                        and MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
						-- and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                    end if;
                    
                    
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionDairy_Id varchar(20),  TripDocument_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), Route_Name varchar(50), VehicleType_Id varchar(20), VehicleType_Name varchar(50),
                    MilkRate decimal(8,2), MilkPrice decimal(20,2), AgentCost decimal(20,2), 
                    Agent_Quantity_Ltr decimal(18,3), Agent_Fat decimal(18,1), Agent_SNF decimal(18,1), 
                    FinalQtyLtr decimal(18,3), FinalFAT decimal(18,1), FinalSNF decimal(18,1), 
                    MCCType_Id varchar(20), MCCType_Name varchar(20), MilkCollectionPosting_Id varchar(20), Total_GainLoss decimal(20,2),
                    MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(50), MPPIRate decimal(8,2),
                    Agent_Fat_Kg decimal(18,3), Agent_SNF_Kg decimal(18,3), Dairy_Fat_Kg decimal(18,3), Dairy_SNF_Kg decimal(18,3),
                    FatKG_GainLoss decimal(18,2), SNFKG_GainLoss decimal(18,2), FatKG_Rate decimal(18,2), SNFKG_Rate decimal(18,2)
                    );
                    
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, AgentCost, FinalQtyLtr, FinalFAT, FinalSNF, MilkCollectionPosting_Id, Total_GainLoss,
                    Agent_Quantity_Ltr, Agent_Fat, Agent_SNF, Agent_Fat_Kg, Agent_SNF_Kg, Dairy_Fat_Kg, Dairy_SNF_Kg, 
                    FatKG_GainLoss, SNFKG_GainLoss, FatKG_Rate, SNFKG_Rate)
                    
                    select Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, 
                    MilkType_Id, MilkRate, MilkPrice, AgentCost, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF, MilkCollectionPosting_Id, Total_GainLoss,
                    Agent_Quantity_Ltr, Roundoff('Quality', Agent_Fat) as Agent_Fat, Roundoff('Quality', Agent_SNF) as Agent_SNF,
                    Agent_Fat_Kg, Agent_SNF_Kg, Dairy_Fat_Kg, Dairy_SNF_Kg, FatKG_GainLoss, SNFKG_GainLoss, FatKG_Rate, SNFKG_Rate
                    from f010_milkcollectionmcc_final f010
                    where Org_Id = var_org_id
                    and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and MCC_Id in (Select MCC_Id from temp_MCC)
                    order by Collection_Date, CollectionShift_Id;
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                    
                    -- Update MilkRate, MilkPrice and MPPI for BMC Chiller
                    Update temp_Report tmp
                    -- inner join t009_milkcollectiondairy_posting t009 on tmp.Org_Id = t009.Org_Id and tmp.MCC_Id = t009.MCC_Id
                    -- and t009.MilkCollectionPosting_Id = tmp.MilkCollectionPosting_Id
                    inner join f010_milkcollectionmcc_final f010 on tmp.Org_Id = f010.Org_Id 
                    and tmp.MCC_Id = f010.MCC_Id
                    and f010.MilkCollectionDairy_Id = tmp.MilkCollectionDairy_Id
                    set 
                    -- tmp.MilkRate = f010.Rate,
                    tmp.MilkRate = f010.MilkRate,
                    tmp.MilkPrice = f010.MilkPrice,
                    tmp.AgentCost = f010.AgentCost
                    where tmp.MCCType_Id = 'C014002';
                    
                    -- Update MilkRate, MilkPrice and MPPI for Bulk Supplier
                    Update temp_Report tmp
                    inner join t009_milkcollectiondairy_posting t009 on tmp.Org_Id = t009.Org_Id and tmp.MCC_Id = t009.MCC_Id
                    and t009.MilkCollectionPosting_Id = tmp.MilkCollectionPosting_Id
                    set tmp.AgentCost = t009.AgentCost,
                    tmp.Total_GainLoss = 0,
                    tmp.Agent_Quantity_Ltr = tmp.FinalQtyLtr,
                    tmp.Agent_Fat = tmp.FinalFAT,
                    tmp.Agent_SNF = tmp.FinalSNF
                    where tmp.MCCType_Id  = 'C014003';
                    
                    Update temp_Report tmp
                    set 
                    tmp.Total_GainLoss = 0,
                    tmp.Agent_Quantity_Ltr = tmp.FinalQtyLtr,
                    tmp.Agent_Fat = tmp.FinalFAT,
                    tmp.Agent_SNF = tmp.FinalSNF
                    where tmp.MCCWorkType_Id  = 'C023001';
                    
                    -- Update MPPI Rate
                    Update temp_Report tmp
                    inner join t009_milkcollectiondairy_mcccommission t9 on tmp.Org_Id = t9.Org_Id 
                    and tmp.MCC_Id = t9.MCC_Id
                    and tmp.MilkCollectionDairy_Id = t9.MilkCollectionDairy_Id and MPPIType_Id = 'C047001'
                    set tmp.MPPIRate = t9.BaseRate ,
                    tmp.AgentCost = CASE 
										WHEN tmp.AgentCost IS NULL OR tmp.AgentCost = 0 THEN IFNULL(t9.Amount, 0)
										ELSE tmp.AgentCost
									END;
                    
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    Update temp_Report tmp
                    set tmp.CollectionShift_Name =  'All Day',
                    tmp.CollectionShift_Id = 'C015003'
                    where ifnull(CollectionShift_Name,'') = '';
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
                    set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;
                    
                    -- Generate final output
                    if (var_Report_Type = 'C048001') then
						select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Type' as MCCType_Name, 'MCC WorkType' as MCCWorkType_Name, 'Date' as Collection_Date, 
						'Milk Type' as MilkType_Name, 'Collection Shift' as CollectionShift_Name,  
						'MCC Qty (Ltr)' as MCCQtyLtr, 'MCC FAT%' as MCCFAT, 'MCC SNF%' as MCCSNF,
						'Rate' as MilkRate, 'Amount' as MilkPrice,
						'Dairy Qty (Ltr)' as FinalQtyLtr, 'Dairy FAT%' as FinalFAT, 'Dairy SNF%' as FinalSNF,
						'MPPI Rate' as MPPIRate, 'MPPI' as AgentCost, 
						'MCC FAT KG' as Agent_Fat_Kg, 'Dairy FAT KG' as Dairy_Fat_Kg, 'FAT KG Gain' as FatKG_GainLoss,
                        'MCC SNF KG' as Agent_SNF_Kg, 'Diary SNF KG' as Dairy_SNF_Kg, 'SNF KG Gain' as SNFKG_GainLoss,
						'FAT KG Rate' as FatKG_Rate, 'SNF KG Rate' as SNFKG_Rate, 'Gain' as GainLoss
                        
						union
						
						select 'TR' as RowType, MCC_Name, MCCType_Name, MCCWorkType_Name, Collection_Date, 
						MilkType_Name, CollectionShift_Name,
						Agent_Quantity_Ltr as MCCQtyLtr, Agent_Fat as MCCFAT, Agent_SNF as MCCSNF,
						ifnull(MilkRate,0) as MilkRate, ifnull(MilkPrice,0) as MilkPrice, 
						ifnull(FinalQtyLtr,0) as FinalQtyLtr, ifnull(FinalFAT,0) as FinalFAT, ifnull(FinalSNF,0) as FinalSNF,
						ifnull(MPPIRate,0) as MPPIRate, ifnull(AgentCost,0) as AgentCost,
                        ifnull(Agent_Fat_Kg,0) as Agent_Fat_Kg, ifnull(Dairy_Fat_Kg,0) as Dairy_Fat_Kg, ifnull(FatKG_GainLoss,0) as FatKG_GainLoss,
                        ifnull(Agent_SNF_Kg,0) as Agent_SNF_Kg, ifnull(Dairy_SNF_Kg,0) as Dairy_SNF_Kg, ifnull(SNFKG_GainLoss,0) as SNFKG_GainLoss,
						ifnull(FatKG_Rate,0) as FatKG_Rate, ifnull(SNFKG_Rate,0) as SNFKG_Rate,
                        ifnull(Total_GainLoss,0) as GainLoss
						from temp_Report
						where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
						and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                        
					elseif (var_Report_Type = 'C048002') then	-- Summary Report
						select 'TH' as RowType, 'MCC Type' as MCCType_Name, 'MCC WorkType' as MCCWorkType_Name, 'Date' as Collection_Date, 
						'Milk Type' as MilkType_Name, 'Collection Shift' as CollectionShift_Name,  
						'MCC Qty (Ltr)' as MCCQtyLtr, 'MCC FAT%' as MCCFAT, 'MCC SNF%' as MCCSNF,
						'Amount' as MilkPrice,
						'Dairy Qty (Ltr)' as FinalQtyLtr, 'Dairy FAT%' as FinalFAT, 'Dairy SNF%' as FinalSNF,
						'Gain-Loss' as GainLoss, 'MPPI' as AgentCost
						
						union
						
						select 'TR' as RowType, MCCType_Name, MCCWorkType_Name, Collection_Date, 
						MilkType_Name, CollectionShift_Name,
						sum(Agent_Quantity_Ltr) as MCCQtyLtr, 
                        Roundoff('Quality', sum(Agent_Quantity_Ltr * Agent_Fat)/sum(Agent_Quantity_Ltr)) as MCCFAT, 
                        Roundoff('Quality', sum(Agent_Quantity_Ltr * Agent_SNF)/sum(Agent_Quantity_Ltr)) as MCCSNF,
						ifnull(sum(MilkPrice),0) as MilkPrice, 
						ifnull(sum(FinalQtyLtr),0) as FinalQtyLtr, 
                        Roundoff('Quality', sum(FinalQtyLtr * FinalFAT)/sum(FinalQtyLtr)) as FinalFAT, 
                        Roundoff('Quality', sum(FinalQtyLtr * FinalSNF)/sum(FinalQtyLtr)) as FinalSNF,
						ifnull(sum(Total_GainLoss),0) as GainLoss, ifnull(sum(AgentCost),0) as AgentCost
						from temp_Report
						where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
						and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
                        group by RowType, MCCType_Name, Collection_Date, MilkType_Name, CollectionShift_Name, MCCWorkType_Name;
                        
					elseif (var_Report_Type = 'C048012') then	-- MCC Report 
						
                        select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Type' as MCCType_Name, 'MCC WorkType' as MCCWorkType_Name,
						'Milk Type' as MilkType_Name, 
						'MCC Qty (Ltr)' as MCCQtyLtr, 'MCC FAT%' as MCCFAT, 'MCC SNF%' as MCCSNF,
						'Amount' as MilkPrice,
						'Dairy Qty (Ltr)' as FinalQtyLtr, 'Dairy FAT%' as FinalFAT, 'Dairy SNF%' as FinalSNF,
						'Gain-Loss' as GainLoss, 'MPPI' as AgentCost
						
						union
						
						select 'TR' as RowType, MCC_Name, MCCType_Name, MCCWorkType_Name,
						MilkType_Name, 
						sum(Agent_Quantity_Ltr) as MCCQtyLtr, 
                        Roundoff('Quality', sum(Agent_Quantity_Ltr * Agent_Fat)/sum(Agent_Quantity_Ltr)) as MCCFAT, 
                        Roundoff('Quality', sum(Agent_Quantity_Ltr * Agent_SNF)/sum(Agent_Quantity_Ltr)) as MCCSNF,
						ifnull(sum(MilkPrice),0) as MilkPrice, 
						ifnull(sum(FinalQtyLtr),0) as FinalQtyLtr,
                        Roundoff('Quality', sum(FinalQtyLtr * FinalFAT)/sum(FinalQtyLtr)) as FinalFAT, 
                        Roundoff('Quality', sum(FinalQtyLtr * FinalSNF)/sum(FinalQtyLtr)) as FinalSNF,
						ifnull(sum(Total_GainLoss),0) as GainLoss, ifnull(sum(AgentCost),0) as AgentCost
						from temp_Report
						where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
						and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
                        group by RowType, MCC_Name, MCCType_Name, MilkType_Name, MCCWorkType_Name;
                        
                    end if;
                    
                end;
			elseif (var_Report_Type = 'C048003') then	-- Farmer wise detail report
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;
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

                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
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
                    
                    -- Yogeshwar DSK Undirwadi
                    
                    -- Split MCCType
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCType_Id, ''));

					drop temporary table if exists temp_MCCType_2;
					create temporary table temp_MCCType_2(MCCType_Id char(255) );
					set @sql = concat('insert into temp_MCCType_2 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;

                    -- Split Milk Type
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType_2;
					create temporary table temp_MilkType_2(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType_2 (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift_2;
					create temporary table temp_CollectionShift_2(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift_2 (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift_2 (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
                    -- Split MCC Name
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCC_Id, ''));
                    
					drop temporary table if exists temp_MCC_2;
					create temporary table temp_MCC_2(MCC_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_MCC_2 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_MCC_2 (MCC_Id)
                        select MCC_Id from m005_mcc where Org_Id = var_org_id ;
                    end if;
                    
                    -- Split MCCWorkType
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCWorkType_Id, ''));

					drop temporary table if exists temp_MCCWorkType_2;
					create temporary table temp_MCCWorkType_2(MCCWorkType_Id char(255) );
					set @sql = concat('insert into temp_MCCWorkType_2 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionShift_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), 
                    MilkRate decimal(8,2), MilkPrice decimal(20,2), 
                    Farmer_Quantity_Ltr decimal(18,3), Farmer_Fat decimal(18,1), Farmer_SNF decimal(18,1), 
                    MCCType_Id varchar(20), MCCType_Name varchar(20), Is_InvoiceCreated int, MCCWorkType_Id varchar(20), 
                    Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20), MCC_Farmer_Code varchar(20));
                    
                    IF ((var_MusterStartDate is not null or var_MusterStartDate <> '') 
						and (var_MusterEndDate is not null or var_MusterEndDate <> ''))THEN
                        
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    inner join t006_milkcollectionagent t6 on t5.Org_Id = t6.Org_Id 
					and t5.MCC_Id = t6.MCC_Id 
                    and t5.MCCCollectionShift_Id = t6.MCCCollectionShift_Id 
                    and t6.MCC_Id not in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC)
                    and t5.MusterCycle_StartDate = var_MusterStart
                    and t5.MusterCycle_EndDate = var_MusterEnd
                    
                    
                    UNION ALL
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    and t5.MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType_2)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC_2)
                    and t5.MusterCycle_StartDate = var_MusterStart
                    and t5.MusterCycle_EndDate = var_MusterEnd
                    ;
                        
						
					ELSE
                    
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    inner join t006_milkcollectionagent t6 on t5.Org_Id = t6.Org_Id 
					and t5.MCC_Id = t6.MCC_Id 
                    and t5.MCCCollectionShift_Id = t6.MCCCollectionShift_Id 
                    and t6.MCC_Id not in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC)
                    
                    
                    UNION ALL
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    and t5.MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType_2)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC_2)
                    ;
					END IF;
                    
                    
                    
                    		
                    -- Update data in case of bulk supplier or offline supplier
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    select f010.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), '', f010.MCC_Id, f010.CollectionShift_Id,
					f010.MilkType_Id, MilkRate, MilkPrice, Dairy_Quantity_Ltr,
                    Roundoff('Quality', Dairy_Fat) ,
                    Roundoff('Quality', Dairy_SNF), 0, f010.MCC_Id 
					from f010_milkcollectionmcc_final f010
                    inner join m005_mcc m5 on m5.Org_Id = f010.Org_Id and m5.MCC_Id = f010.MCC_Id
                    where f010.Org_Id = var_org_id
                    and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                    and ((m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003') or (m5.MCCType_Id = 'C014003'))
                    and f010.MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                    
                    -- Update Farmer Name & Farmer Code
                    Update temp_Report tmp
                    inner join mu04_farmer mu04 on tmp.Org_Id = mu04.Org_Id and tmp.Farmer_Id = mu04.Farmer_Id
                    set tmp.Farmer_Name = mu04.Farmer_Name,
                    tmp.Farmer_Code = mu04.Farmer_Code,
                    tmp.MCC_Farmer_Code = mu04.MCC_Farmer_Code;
                    
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    Update temp_Report tmp
                    set tmp.CollectionShift_Name =  'All Day',
                    tmp.CollectionShift_Id = 'C015003'
                    where ifnull(CollectionShift_Name,'') = '';
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;
                    
                    -- Generate final output
                    select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Type' as MCCType_Name, 'MCC Code' as MCC_Code, 'Date' as Collection_Date, 
                    'Farmer Name' as Farmer_Name, 'Farmer Code' as Farmer_Code, 'MCC Farmer Code' as MCC_Farmer_Code,
                    'Milk Type' as MilkType_Name, 'Collection Shift' as CollectionShift_Name,  
                    'Qty (Ltr)' as QtyLtr, 'FAT%' as FAT, 'SNF%' as SNF,
                    'Rate' as MilkRate, 'Amount' as MilkPrice,
                    'Invoice Status' as InvoiceStatus
                    
                    union all
                    
                    select 'TR' as RowType, MCC_Name, MCCType_Name, MCC_Code, Collection_Date, 
                    ifnull(Farmer_Name, MCC_Name) as Farmer_Name, ifnull(Farmer_Code, MCC_Code) as Farmer_Code, 
                    ifnull(MCC_Farmer_Code, '') as MCC_Farmer_Code,
                    MilkType_Name, CollectionShift_Name,
                    Farmer_Quantity_Ltr as QtyLtr, Farmer_Fat as FAT, Farmer_SNF as SNF,
                    ifnull(MilkRate,0) as MilkRate, ifnull(MilkPrice,0) as MilkPrice, 
					case when Is_InvoiceCreated = 1 then 'Posted' else 'Pending' end as InvoiceStatus
                    from temp_Report
                    where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                    and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
                    and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                end;
			elseif (var_Report_Type = 'C048026') then	-- Farmer wise detail report
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;
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

                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
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
                    
                    -- Yogeshwar DSK Undirwadi
                    
                    -- Split MCCType
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCType_Id, ''));

					drop temporary table if exists temp_MCCType_2;
					create temporary table temp_MCCType_2(MCCType_Id char(255) );
					set @sql = concat('insert into temp_MCCType_2 (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;

                    -- Split Milk Type
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType_2;
					create temporary table temp_MilkType_2(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType_2 (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift_2;
					create temporary table temp_CollectionShift_2(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift_2 (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift_2 (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
                    -- Split MCC Name
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCC_Id, ''));
                    
					drop temporary table if exists temp_MCC_2;
					create temporary table temp_MCC_2(MCC_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_MCC_2 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_MCC_2 (MCC_Id)
                        select MCC_Id from m005_mcc where Org_Id = var_org_id ;
                    end if;
                    
                    -- Split MCCWorkType
                    drop temporary table if exists t1;
					create temporary table t1( txt text );
					insert into t1 values(ifnull(var_MCCWorkType_Id, ''));

					drop temporary table if exists temp_MCCWorkType_2;
					create temporary table temp_MCCWorkType_2(MCCWorkType_Id char(255) );
					set @sql = concat('insert into temp_MCCWorkType_2 (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t1), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionShift_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), 
                    MilkRate decimal(8,2), MilkPrice decimal(20,2), 
                    Farmer_Quantity_Ltr decimal(18,3), Farmer_Fat decimal(18,1), Farmer_SNF decimal(18,1), 
                    MCCType_Id varchar(20), MCCType_Name varchar(20), Is_InvoiceCreated int, MCCWorkType_Id varchar(20), 
                    Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20), MCC_Farmer_Code varchar(20));
                    
                    IF ((var_MusterStartDate is not null or var_MusterStartDate <> '') 
						and (var_MusterEndDate is not null or var_MusterEndDate <> ''))THEN
                        
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType_2)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC_2)
                    and t5.MusterCycle_StartDate = var_MusterStart
                    and t5.MusterCycle_EndDate = var_MusterEnd
                    ;
                        
						
					ELSE
                    
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), t5.Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id 
                    and t5.MCC_Id = t4.MCC_Id 
                    and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType_2)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC_2)
                    ;
					END IF;
                    
                    
                    
                    		
                    -- Update data in case of bulk supplier or offline supplier
					insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    select f010.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), '', f010.MCC_Id, f010.CollectionShift_Id,
					f010.MilkType_Id, MilkRate, MilkPrice, Dairy_Quantity_Ltr,
                    Roundoff('Quality', Dairy_Fat) ,
                    Roundoff('Quality', Dairy_SNF), 0, f010.MCC_Id 
					from f010_milkcollectionmcc_final f010
                    inner join m005_mcc m5 on m5.Org_Id = f010.Org_Id and m5.MCC_Id = f010.MCC_Id
                    where f010.Org_Id = var_org_id
                    and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                    and ((m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003') or (m5.MCCType_Id = 'C014003'))
                    and f010.MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                    
                    -- Update Farmer Name & Farmer Code
                    Update temp_Report tmp
                    inner join mu04_farmer mu04 on tmp.Org_Id = mu04.Org_Id and tmp.Farmer_Id = mu04.Farmer_Id
                    set tmp.Farmer_Name = mu04.Farmer_Name,
                    tmp.Farmer_Code = mu04.Farmer_Code,
                    tmp.MCC_Farmer_Code = mu04.MCC_Farmer_Code;
                    
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    Update temp_Report tmp
                    set tmp.CollectionShift_Name =  'All Day',
                    tmp.CollectionShift_Id = 'C015003'
                    where ifnull(CollectionShift_Name,'') = '';
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;
                    
                    -- Generate final output
                    select 'TH' as RowType, 'MCC Name' as MCC_Name, 'MCC Type' as MCCType_Name, 'MCC Code' as MCC_Code, 'Date' as Collection_Date, 
                    'Farmer Name' as Farmer_Name, 'Farmer Code' as Farmer_Code, 'MCC Farmer Code' as MCC_Farmer_Code,
                    'Milk Type' as MilkType_Name, 'Collection Shift' as CollectionShift_Name,  
                    'Qty (Ltr)' as QtyLtr, 'FAT%' as FAT, 'SNF%' as SNF,
                    'Rate' as MilkRate, 'Amount' as MilkPrice,
                    'Invoice Status' as InvoiceStatus
                    
                    union
                    
                    select 'TR' as RowType, MCC_Name, MCCType_Name, MCC_Code, Collection_Date, 
                    ifnull(Farmer_Name, MCC_Name) as Farmer_Name, ifnull(Farmer_Code, MCC_Code) as Farmer_Code, 
                    ifnull(MCC_Farmer_Code, '') as MCC_Farmer_Code,
                    MilkType_Name, CollectionShift_Name,
                    Farmer_Quantity_Ltr as QtyLtr, Farmer_Fat as FAT, Farmer_SNF as SNF,
                    ifnull(MilkRate,0) as MilkRate, ifnull(MilkPrice,0) as MilkPrice, 
					case when Is_InvoiceCreated = 1 then 'Posted' else 'Pending' end as InvoiceStatus
                    from temp_Report
                    where MCCType_Id in (Select MCCType_Id from temp_MCCType)
                    and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
                    and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                end;
			elseif (var_Report_Type = 'C048016') then
				begin
					set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
					
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id ;
                    end if;
                    
                    SET SQL_SAFE_UPDATES = 0;

					DROP TEMPORARY TABLE IF EXISTS Main_Rate;
					CREATE TEMPORARY TABLE Main_Rate (
					Chart_Id varchar(20));

					insert into Main_Rate (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;
                    
                    
					DROP TEMPORARY TABLE IF EXISTS Base_Rate;
					CREATE TEMPORARY TABLE Base_Rate (
					Chart_Id varchar(20));

					insert into Base_Rate (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;

					DROP TEMPORARY TABLE IF EXISTS Fat_Deduction;
					CREATE TEMPORARY TABLE Fat_Deduction (
					Chart_Id varchar(20));

					insert into Fat_Deduction (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;

					DROP TEMPORARY TABLE IF EXISTS SNF_Deduction;
					CREATE TEMPORARY TABLE SNF_Deduction (
					Chart_Id varchar(20));

					insert into SNF_Deduction (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;

					DROP TEMPORARY TABLE IF EXISTS Fat_High;
					CREATE TEMPORARY TABLE Fat_High (
					Chart_Id varchar(20));

					insert into Fat_High (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;
                    
                    DROP TEMPORARY TABLE IF EXISTS SNF_High;
					CREATE TEMPORARY TABLE SNF_High (
					Chart_Id varchar(20));

					insert into SNF_High (Chart_Id)
					select 
					f001.Chart_Id
					from f001_milk_rate  f001
					where f001.Org_Id =var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					-- and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
					group by f001.Chart_Id;

					
					set sql_mode = '';

					DROP TEMPORARY TABLE IF EXISTS Chart_Table;
					CREATE TEMPORARY TABLE Chart_Table (
					Chart_Id varchar(20),Slab_Name longtext,MilkRateEntryType_Id varchar(20),Applicable_Date date
                    -- Set_Slab_Name longtext
                    );

					insert into Chart_Table (Chart_Id,Slab_Name,MilkRateEntryType_Id,Applicable_Date)
                    
                    
                    select  
					Chart_Id,
					GROUP_CONCAT( concat(BaseFat , ' - ' ,  BaseSNF, ' = ', Amount )  ) AS Slab_Name ,
					'C012001' as  MilkRateEntryType_Id,
                    Applicable_Date
					from (
					select 
					m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
					BaseFat, BaseSNF, Version_No, Amount ,
					date(m001a.Applicable_Date) as Applicable_Date
					from m001_milkrate_item m001a 
					left join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
					left join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
					where m001a.Org_Id = var_org_id and m001a.Is_Deleted = 0 
					and Chart_Id in (select Chart_Id from Base_Rate)
					and m001a.MilkRateEntryType_Id  = 'C012001'
					and date(m001a.Applicable_Date) <= date(@Current_Datetime)
					group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id,m001a.Applicable_Date
					) slab 
					group by slab.Chart_Id,slab.Applicable_Date
                    
					UNION ALL
                    
                    select  
					Chart_Id,
					GROUP_CONCAT( concat(slab.SlabName , ' = ', Amount ) , '</br>'  ) AS Slab_Name ,
					'C012002' as  MilkRateEntryType_Id,
                    Applicable_Date
					from (
					select 
					m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
					BaseFat, BaseSNF, Version_No, Amount ,
					date(m001a.Applicable_Date) as Applicable_Date
					from m001_milkrate_item m001a 
					inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
					inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
					where m001a.Org_Id = var_org_id and m001a.Is_Deleted = 0 
					and Chart_Id in (select Chart_Id from Fat_Deduction)
					and m001a.MilkRateEntryType_Id  = 'C012002'
					and date(m001a.Applicable_Date) <= date(@Current_Datetime)
					group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id,m001a.Applicable_Date
					) slab 
					group by slab.Chart_Id,slab.Applicable_Date
                    
					UNION ALL
                    
                    select  
					Chart_Id,
					GROUP_CONCAT( concat(slab.SlabName , ' = ', Amount ) , '</br>'  ) AS Slab_Name ,
					'C012003' as  MilkRateEntryType_Id,
                    Applicable_Date
					from (
					select 
					m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
					BaseFat, BaseSNF, Version_No, Amount ,
					date(m001a.Applicable_Date) as Applicable_Date
					from m001_milkrate_item m001a 
					inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
					inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
					where m001a.Org_Id = var_org_id and m001a.Is_Deleted = 0 
					and Chart_Id in (select Chart_Id from SNF_Deduction)
					and m001a.MilkRateEntryType_Id  = 'C012003'
					and date(m001a.Applicable_Date) <= date(@Current_Datetime)
					group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id,m001a.Applicable_Date
					) slab 
					group by slab.Chart_Id,slab.Applicable_Date
                    
					UNION ALL
                    
                    select  
					Chart_Id,
					GROUP_CONCAT( concat(slab.SlabName , ' = ', Amount ) , '</br>'  ) AS Slab_Name ,
					'C012004' as  MilkRateEntryType_Id,
                    Applicable_Date
					from (
					select 
					m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
					BaseFat, BaseSNF, Version_No, Amount ,
					date(m001a.Applicable_Date) as Applicable_Date
					from m001_milkrate_item m001a 
					inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
					inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
					where m001a.Org_Id = var_org_id and m001a.Is_Deleted = 0 
					and Chart_Id in (select Chart_Id from Fat_High)
					and m001a.MilkRateEntryType_Id  = 'C012004'
					and date(m001a.Applicable_Date) <= date(@Current_Datetime)
					group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id,m001a.Applicable_Date
					) slab 
					group by slab.Chart_Id,slab.Applicable_Date
                    
					UNION ALL
                    
					select  
					Chart_Id,
					GROUP_CONCAT( concat(slab.SlabName , ' = ', Amount ) , '</br>'  ) AS Slab_Name ,
					'C012005' as  MilkRateEntryType_Id,
                    Applicable_Date
					from (
					select 
					m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
					BaseFat, BaseSNF, Version_No, Amount ,
					date(m001a.Applicable_Date) as Applicable_Date
					from m001_milkrate_item m001a 
					inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
					inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
					where m001a.Org_Id = var_org_id and m001a.Is_Deleted = 0 
					and Chart_Id in (select Chart_Id from SNF_High)
					and m001a.MilkRateEntryType_Id  = 'C012005'
					and date(m001a.Applicable_Date) <= date(@Current_Datetime)
					group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id,m001a.Applicable_Date
					) slab 
					group by slab.Chart_Id,slab.Applicable_Date

					;
                    
                    
                    DROP TEMPORARY TABLE IF EXISTS Chart_Table_2;
					CREATE TEMPORARY TABLE Chart_Table_2 (
					Chart_Id varchar(20),Slab_Name longtext,MilkRateEntryType_Id varchar(20),Applicable_Date date);

					insert into Chart_Table_2 (Chart_Id,Slab_Name,MilkRateEntryType_Id,Applicable_Date)
                    select Chart_Id,Slab_Name,MilkRateEntryType_Id,Applicable_Date from Chart_Table;
                    
                    update  Chart_Table tm1
                    inner join Chart_Table_2 tm2 on
                    tm1.Chart_Id = tm2.Chart_Id
                    and tm1.MilkRateEntryType_Id = tm2.MilkRateEntryType_Id
                    and tm1.MilkRateEntryType_Id <> 'C012001'
                    and date(tm1.Applicable_Date) > date(tm2.Applicable_Date)
                    set tm1.Slab_Name = concat(tm1.Slab_Name ,',' ,tm2.Slab_Name);
                    
                    DROP TEMPORARY TABLE IF EXISTS Chart_Main_Table;
					CREATE TEMPORARY TABLE Chart_Main_Table (
					Org_Id varchar(20),MCC_Id varchar(20),MilkType_Id varchar(20),CollectionShift_Id varchar(20),Chart_Id varchar(20),
					MCC_Name varchar(255), MCC_Code varchar(20),
					MCCType_Id varchar(20), MCCType_Name varchar(255),
					MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(255),
					MilkType_Name varchar(255),
					Chart_Name varchar(255),
					CollectionShift_Name varchar(255),
					Base_Rate longtext,
					Fat_Deduction longtext,
					SNF_Deduction longtext,
					Fat_High longtext,
					SNF_High longtext,
					MPPI_Id varchar(20),MPPI_Name varchar(255),
                    Item_Applicable_Date datetime
					);

					insert into Chart_Main_Table (Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id,Chart_Id,Item_Applicable_Date
					)
                    select  
					Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id,Chart_Id,Item_Applicable_Date
					from (
					select 
					f001.Org_Id,f001.MCC_Id,f001.MilkType_Id,f001.CollectionShift_Id,f001.Chart_Id,date(f001.Item_Applicable_Date) as Item_Applicable_Date
					from f001_milk_rate  f001
					where f001.Org_Id = var_org_id
					and f001.CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift)
					and f001.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f001.MCC_Id in (Select MCC_Id from temp_MCC)
					and date(f001.Item_Applicable_Date) <= date(@Current_Datetime)
					and date(f001.Header_Applicable_Date) <= date(@Current_Datetime)
                    and f001.Chart_Id in (select Chart_Id from Main_Rate)
					group by 
					f001.Org_Id,f001.MCC_Id,f001.MilkType_Id,f001.CollectionShift_Id,f001.Chart_Id,date(f001.Item_Applicable_Date)
					) rate 
					group by rate.Org_Id,rate.MCC_Id,rate.MilkType_Id,rate.CollectionShift_Id,rate.Chart_Id,rate.Item_Applicable_Date;
                    
                    
                    -- Update Slab_Name
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012001'
                    and date(tmp.Applicable_Date) = date(main_tmp.Item_Applicable_Date)
					set main_tmp.Base_Rate = tmp.Slab_Name;

					-- Update Slab_Name
                    
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012002'
                    and date(tmp.Applicable_Date) = date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name;
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012002'
                    and date(tmp.Applicable_Date) < date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
                    
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012002'
                    and date(tmp.Applicable_Date) <= date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';

					-- Update Slab_Name
                    
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012003'
                    and date(tmp.Applicable_Date) = date(main_tmp.Item_Applicable_Date)
					set main_tmp.SNF_Deduction = tmp.Slab_Name;
                    
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012003'
                    and date(tmp.Applicable_Date) < date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012003'
                    and date(tmp.Applicable_Date) <= date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';

					-- Update Slab_Name
                    
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012004'
                    and date(tmp.Applicable_Date) = date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_High = tmp.Slab_Name;
                    
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012004'
                    and date(tmp.Applicable_Date) < date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012004'
                    and date(tmp.Applicable_Date) <= date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
					-- Update Slab_Name
					Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012005'
                    and date(tmp.Applicable_Date) = date(main_tmp.Item_Applicable_Date)
					set main_tmp.SNF_High = tmp.Slab_Name;
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012005'
                    and date(tmp.Applicable_Date) < date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
                    Update Chart_Main_Table main_tmp
					inner join Chart_Table tmp on tmp.Chart_Id = main_tmp.Chart_Id 
					and tmp.MilkRateEntryType_Id = 'C012005'
                    and date(tmp.Applicable_Date) <= date(main_tmp.Item_Applicable_Date)
					set main_tmp.Fat_Deduction = tmp.Slab_Name
                    where ifnull(main_tmp.Fat_Deduction,'') = '';
                    
                    -- Update MCCName and MCCCode
					Update Chart_Main_Table tmp
					inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
					set tmp.MCC_Name = m005.MCC_Name,
					tmp.MCC_Code = m005.MCC_Code,
					tmp.MCCType_Id = m005.MCCType_Id,
					tmp.MCCWorkType_Id = m005.MCCWorkType_Id;

					-- Update CollectionShift Name
					Update Chart_Main_Table tmp
					inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
					set tmp.CollectionShift_Name = c015.CollectionShift_Name;

					Update Chart_Main_Table tmp
					set tmp.CollectionShift_Name =  'All Day',
					tmp.CollectionShift_Id = 'C015003'
					where ifnull(CollectionShift_Name,'') = '';

					-- Update MilkType Name
					Update Chart_Main_Table tmp
					inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
					set tmp.MilkType_Name = c011.MilkType_Name;

					-- Update MCCType Name
					Update Chart_Main_Table tmp
					inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
					set tmp.MCCType_Name = c014.MCCType_Name;

					-- Update MCCWorkType Name
					Update Chart_Main_Table tmp
					inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
					set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;

					-- Update MCCName and MCCCode
					Update Chart_Main_Table tmp
					inner join m001_milkrate m001 on tmp.Org_Id = m001.Org_Id and tmp.Chart_Id = m001.Chart_Id
					set tmp.Chart_Name = m001.Chart_Name;
                    
                    DROP TEMPORARY TABLE IF EXISTS Commission_Rate;
					CREATE TEMPORARY TABLE Commission_Rate (
					Org_Id varchar(20),MCC_Id varchar(20),MPPI_Id varchar(20),MPPI_Name varchar(255) , Applicable_Date datetime);

					insert into Commission_Rate (Org_Id,MCC_Id,MPPI_Id,MPPI_Name,Applicable_Date)
					select  
					Org_Id,MCC_Id,MPPI_Id,MPPI_Name,Applicable_Date
					from (
					select 
					m0021.Org_Id,m0021.MCC_Id,m0021.MPPI_Id,m002.MPPI_Name ,date(m0021.Applicable_Date) as Applicable_Date,max(m0021.Applicable_Date)
					from m002_commission_mcc  m0021
					inner join m002_commission m002 on m002.Org_Id = m0021.Org_Id 
					and m002.MPPI_Id = m0021.MPPI_Id 
					and m002.MPPIType_Id = m0021.MPPIType_Id 
					and m002.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					where m0021.Org_Id =var_org_id
					and m0021.MCC_Id in (Select MCC_Id from temp_MCC)
					and m0021.MPPIType_Id = 'C047001'
					and date(m0021.Applicable_Date) <= date(@Current_Datetime)
					group by m0021.Org_Id,m0021.MCC_Id,m0021.MPPI_Id,m002.MPPI_Name,date(m0021.Applicable_Date)
					) commission 
					group by commission.Org_Id,commission.MCC_Id,commission.MPPI_Id,commission.MPPI_Name,commission.Applicable_Date;
				
					
                    Update Chart_Main_Table main_tmp
					inner join Commission_Rate tmp on tmp.MCC_Id = main_tmp.MCC_Id 
					-- and date(main_tmp.Item_Applicable_Date) < date(tmp.Applicable_Date)
                    and date(tmp.Applicable_Date) <=  date(main_tmp.Item_Applicable_Date)
					set main_tmp.MPPI_Id = tmp.MPPI_Id,
					main_tmp.MPPI_Name = tmp.MPPI_Name;
                    
                    
                    DROP TEMPORARY TABLE IF EXISTS Chart_Main_Table_Data;
					CREATE TEMPORARY TABLE Chart_Main_Table_Data (
					MCC_Name varchar(255),
					MCCType_Name varchar(255),
					MCCWorkType_Name varchar(255),
					MilkType_Name varchar(255),
					Chart_Name varchar(255),
					CollectionShift_Name varchar(255),
					Base_Rate longtext,
					Fat_Deduction longtext,
					SNF_Deduction longtext,
					Fat_High longtext,
					SNF_High longtext,
					MPPI_Name varchar(255),
					Item_Applicable_Date varchar(255)
					);
                    insert into Chart_Main_Table_Data (
                    MCC_Name ,
					MCCType_Name ,
					MCCWorkType_Name ,
					MilkType_Name ,
					Chart_Name ,
					CollectionShift_Name ,
					Base_Rate ,
					Fat_Deduction ,
					SNF_Deduction ,
					Fat_High ,
					SNF_High ,
                    Item_Applicable_Date,
					MPPI_Name
					)
                    select 
					MCC_Name ,
					MCCType_Name ,
					MCCWorkType_Name ,
					MilkType_Name ,
					Chart_Name ,
					CollectionShift_Name ,
					Base_Rate ,
					Fat_Deduction ,
					SNF_Deduction ,
					Fat_High ,
					SNF_High ,
					DATE_FORMAT(Item_Applicable_Date, '%d %b %Y') AS Item_Applicable_Date,
					MPPI_Name 
					from Chart_Main_Table order by MCC_Name asc,Chart_Name asc, Item_Applicable_Date desc, CollectionShift_Name desc; 
                 
                    
					select 'TH' as RowType, 
                    'MCC Name' as MCC_Name,
                    'Centre Type' as MCCType_Name,
                    'OFF Line / Online' as MCCWorkType_Name,
                    'Milk Type' as MilkType_Name,
                    'Chart Name' as Chart_Name,
                    'CollectionShift Name' as CollectionShift_Name,
					'Base Rate' as Base_Rate,'Fat Ded' as Fat_Deduction,'Snf Ded' as SNF_Deduction,
					'Fat Inc' as Fat_High,'Snf Inc' as SNF_High,
                    'Chart Date' as Item_Applicable_Date,
                    'MPPI' as MPPI_Name
					
					union
					select 'TR' as RowType,
                    MCC_Name ,
					MCCType_Name ,
					MCCWorkType_Name ,
					MilkType_Name ,
					Chart_Name ,
					CollectionShift_Name ,
					ifnull(Base_Rate,'') as Base_Rate ,
					ifnull(Fat_Deduction,'') as Fat_Deduction,
                    ifnull(SNF_Deduction,'') as SNF_Deduction,
                    ifnull(Fat_High,'') as Fat_High,
                    ifnull(SNF_High,'') as SNF_High,
					Item_Applicable_Date,
                    ifnull(MPPI_Name,'') as MPPI_Name
					from Chart_Main_Table_Data;
					-- Ganesh DSK Mirzapur
				end;
            
            elseif (var_Report_Type = 'C048028') then
				begin
					set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
					
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;

                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;

                    -- Split MCC
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

                    SET SQL_SAFE_UPDATES = 0;

                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
                    CREATE TEMPORARY TABLE temp_Report ( 
                    Org_Id varchar(20), MCC_Id varchar(20),MilkType_Id varchar(20),CollectionShift_Id varchar(20),
                    Plant_Code varchar(20),MCC_Code varchar(20),MCC_Name longtext,MCCType_Id varchar(20),MCCWorkType_Id varchar(20),
                    MCCType_Name longtext,MCCWorkType_Name longtext,
                    CollectionShift_Name longtext,MilkType_Name longtext
                    );

                    insert into temp_Report (
                    Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id 
                    )
                    select Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id 
                    from f001_milk_rate 
                    where Org_Id = var_org_id
                    and MilkType_Id in (select MilkType_Id from temp_MilkType )
                    and CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
                    and MCC_Id in (Select MCC_Id from temp_MCC)
                    and date(Item_Applicable_Date) <= date(@Current_Datetime)
					and date(Header_Applicable_Date) <= date(@Current_Datetime)
                    group by Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id;

                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.Plant_Code = m005.Plant_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;

                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;

                    Update temp_Report tmp
                    inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
                    set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;

                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;

                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;

                    DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;
                    CREATE TEMPORARY TABLE temp_Report_Main ( 
                    Org_Id varchar(20), MCC_Id varchar(20),MilkType_Id varchar(20),CollectionShift_Id varchar(20),
                    Plant_Code varchar(20),MCC_Code varchar(20),MCC_Name longtext,MCCType_Id varchar(20),MCCWorkType_Id varchar(20),
                    MCCType_Name longtext,MCCWorkType_Name longtext,
                    CollectionShift_Name longtext,MilkType_Name longtext
                    );
                    insert into temp_Report_Main select * from temp_Report;

                    select 'TH' as RowType, 
                    'MCC Name' as MCC_Name,'MCC Code' as MCC_Code,'Plant Code' as Plant_Code,
                    'MCC Type' as MCCType_Name,'MCC Work Type' as MCCWorkType_Name,'Collection Shift' as CollectionShift_Name,'Milk Type' as MilkType_Name,
                    'Current Rate Chart' as Current_Rate_Chart,
                    'Base Rate' as Base_Rate,'Fat Deduction' as Fat_Deduction,'SNF Deduction' as SNF_Deduction,'High Fat' as High_Fat,'High SNF' as High_SNF,
					'MPPI' as MPPI,'Protein' as Protein,'Ash' as Ash
 
                    union all

                    select 'TR' as RowType,
                    MCC_Name,MCC_Code,ifnull(Plant_Code,'') as Plant_Code ,
                    MCCType_Name,MCCWorkType_Name,CollectionShift_Name,MilkType_Name,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetCurrentMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''')">Current Rate Chart</a>') AS Current_Rate_Chart,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''', ''C012001'')">Base Rate</a>') AS Base_Rate,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''', ''C012002'')">Fat Deduction</a>') AS Fat_Deduction,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''', ''C012003'')">SNF Deduction</a>') AS SNF_Deduction,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''', ''C012004'')">High Fat</a>') AS High_Fat,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetMilkRateEntryList(''',MCC_Id, ''', ''',MilkType_Id, ''', ''',CollectionShift_Id, ''', ''C012005'')">High SNF</a>') AS High_SNF,
                    CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetCommissionEntryList(''',MCC_Id,''', ''',MilkType_Id, ''',''C047001'')">MPPI</a>') AS MPPI,
					CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetCommissionEntryList(''',MCC_Id,''', ''',MilkType_Id, ''',''C047006'')">Protein</a>') AS Protein,
					CONCAT('<a href="javascript: void(0)" class="btn btn-sm btn-link mr-2" onclick="GetCommissionEntryList(''',MCC_Id,''', ''',MilkType_Id, ''',''C047007'')">Ash</a>') AS Ash
                    from temp_Report_Main
                    where Org_Id = var_org_id
                    and MCCType_Id in (Select MCCType_Id from temp_MCCType)
                    and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
                    
                end;
            elseif (var_Report_Type = 'C048017') then
				begin
										DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    -- Split Route Name
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCC_Id, ''));
                    
					drop temporary table if exists temp_Route;
					create temporary table temp_Route(Route_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_Route (Route_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_Route (Route_Id)
                        select Route_Id from m006_route where Org_Id = var_org_id and Is_Active = 1;
                    end if;


					SET SQL_SAFE_UPDATES = 0;

					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report (
					Org_Id varchar(20),TripDocument_Id varchar(20),Route_Id varchar(20),MCC_Id varchar(20),Expected_Time datetime,Arrival_At datetime,
					Route_Trip_Id varchar(20),Driver_Id varchar(20),Vehicle_Id varchar(20),Transporter_Id varchar(20),Created_On datetime,
					MCC_Name varchar(255), MCC_Code varchar(20),
					MCCType_Id varchar(20), MCCType_Name varchar(255),
					MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(255),
					Route_Name varchar(255),
					CollectionShift_Id varchar(255),CollectionShift_Name varchar(255),
					Transporter_Name varchar(255), Transporter_Code varchar(20),
					Vehicle_No varchar(45), 
					VehicleType_Id varchar(20), VehicleType_Name varchar(45), 
					VehicleMake_Id varchar(20), VehicleMake_Name varchar(45),
					VehicleOwnershipType_Id varchar(20),VehicleOwnershipType_Name varchar(50),
					Driver_Name varchar(255),
					Chemist_Id varchar(20), Chemist_Name varchar(255)
					);
					insert into temp_Report (Org_Id,TripDocument_Id,Route_Id,MCC_Id,Expected_Time,Arrival_At 
					)
					select Org_Id,TripDocument_Id,Route_Id,MCC_Id,Expected_Time,Arrival_At 
					from t022_tripdocument_item 
					where 
					Org_Id = var_org_id
					and Route_Id in (Select Route_Id from temp_Route)
                    and CAST(Created_On  AS DATE) >= var_StartDate 
					and CAST(Created_On  AS DATE)  <= var_EndDate;

					-- Update Route_Trip_Id , Driver_Id , Vehicle_Id, Transporter_Id
					Update temp_Report tmp
					inner join t021_tripdocument_header t021 on tmp.Org_Id = t021.Org_Id 
					and tmp.TripDocument_Id = t021.TripDocument_Id
					set tmp.Route_Trip_Id = t021.Route_Trip_Id,
					tmp.Driver_Id = t021.Driver_Id,
					tmp.Vehicle_Id = t021.Vehicle_Id,
					tmp.Transporter_Id = t021.Transporter_Id,
					tmp.Created_On = t021.Created_On;


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

					-- Update MCCWorkType Name
					Update temp_Report tmp
					inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
					set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;


					-- Update Route_Name and CollectionShift_Id
					Update temp_Report tmp
					inner join m006_route m006 on tmp.Org_Id = m006.Org_Id and tmp.Route_Id = m006.Route_Id
					set tmp.Route_Name = m006.Route_Name,
					tmp.CollectionShift_Id = m006.CollectionShift_Id;

					-- Update CollectionShift Name
					Update temp_Report tmp
					inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
					set tmp.CollectionShift_Name = c015.CollectionShift_Name;

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
					set tmp.Vehicle_No = m3.Vehicle_No,
					tmp.VehicleType_Id = m3.VehicleType_Id,
					tmp.VehicleOwnershipType_Id = m3.VehicleOwnershipType_Id,
					tmp.VehicleMake_Id = m3.VehicleMake_Id;

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

					-- Update Vehicle Make
					update temp_Report tmp
					inner join c032_vehiclemake c032 on
					tmp.VehicleMake_Id = c032.VehicleMake_Id
					set tmp.VehicleMake_Name = c032.VehicleMake_Name;

					-- Update Vehicle No
					update temp_Report tmp
					inner join mu06_driver m6 on tmp.Org_Id = m6.Org_Id 
					and tmp.Driver_Id = m6.Driver_Id
					set tmp.Driver_Name = m6.Driver_Name;

					-- Update Transporter Name
					update temp_Report tmp
					inner join m008_route_vehicle m8 on tmp.Org_Id = m8.Org_Id 
					and tmp.Route_Trip_Id = m8.Entry_Id
					set tmp.Chemist_Id = m8.Chemist_Id;


					-- Update Vehicle No
					update temp_Report tmp
					inner join mu07_routechemist m7 on tmp.Org_Id = m7.Org_Id 
					and tmp.Chemist_Id = m7.Chemist_Id
					set tmp.Chemist_Name = m7.Chemist_Name;

					select 'TH' as RowType, 'Route' as Route_Name, 'Driver' as Driver_Name,
					'Vehicle No.' as Vehicle_No,'Vehicle Type' as VehicleType_Name,
                    'Vehicle Make' as VehicleMake_Name,
					'Collection Shift' as CollectionShift_Name,
                    'Chemist' as Chemist_Name,
					'MCC Code' as MCC_Code,
					'MCC Name' as MCC_Name,
					'Centre Type' as MCCType_Name,
					'OFF Line / Online' as MCCWorkType_Name,
					'Expected Time' as Expected_Time,
					'Arrival At' as Arrival_At,
					'Date' as Created_On

					union

					select 'TR' as RowType, 
					ifnull(Route_Name,'') as Route_Name,
					ifnull(Driver_Name,'') as Driver_Name,
					ifnull(Vehicle_No,'') as Vehicle_No,
					ifnull(VehicleType_Name,'') as VehicleType_Name,
					ifnull(VehicleMake_Name,'') as VehicleMake_Name,
					ifnull(CollectionShift_Name,'') as CollectionShift_Name,
					ifnull(Chemist_Name,'')as Chemist_Name,
					ifnull(MCC_Code,'')as MCC_Code,
					ifnull(MCC_Name,'')as MCC_Name,
					ifnull(MCCType_Name,'')as MCCType_Name,
					ifnull(MCCWorkType_Name,'')as MCCWorkType_Name,
					ifnull(DATE_FORMAT(Expected_Time, '%h:%i %p'),'') as Expected_Time,
					ifnull(DATE_FORMAT(Arrival_At, '%h:%i %p'),'') as Arrival_At,
					ifnull(DATE_FORMAT(Created_On, '%d %b %Y'),'') AS Created_On
					from temp_Report;
                end;
			elseif (var_Report_Type = 'C048018') then
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    -- Split Route Name
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


					SET SQL_SAFE_UPDATES = 0;

					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report (
					Org_Id varchar(20),
                    Transporter_Id  varchar(20),Transporter_Name  varchar(255),Transporter_Code  varchar(20),
                    Vehicle_Id  varchar(20),Vehicle_No  varchar(255),
                    Entry_Date datetime ,Quantity_Ltr decimal(30,3),Amount decimal(30,3),
                    Is_Posted varchar(10),
                    DieselUpload_Id varchar(20),
                    File_Name longtext,
                    Upload_Date datetime
					);
					insert into temp_Report (Org_Id,Transporter_Id,Vehicle_Id,Entry_Date,Quantity_Ltr,Amount ,Is_Posted,DieselUpload_Id
					)
					select Org_Id,Transporter_Id,Vehicle_Id,Entry_Date,Quantity_Ltr,Amount ,Is_InvoiceCreated,DieselUpload_Id
					from t043_dieselupload 
					where 
					Org_Id = var_org_id
					and Transporter_Id in (Select Transporter_Id from temp_Transporter)
                    and CAST(Entry_Date  AS DATE) >= var_StartDate 
					and CAST(Entry_Date  AS DATE)  <= var_EndDate;

					
                    -- Update Diesel upload File Name
					update temp_Report tmp
					inner join l004_dieselupload l004 on tmp.Org_Id = l004.Org_Id 
					and tmp.DieselUpload_Id = l004.DieselUpload_Id
					set tmp.File_Name = l004.File_Name,
					tmp.Upload_Date = l004.Upload_Date;
                    

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
					set tmp.Vehicle_No = m3.Vehicle_No;



					select 
                    'TH' as RowType, 
                    'Transporter Code' as Transporter_Code,
                    'Transporter Name' as Transporter_Name,
					'Vehicle No.' as Vehicle_No,
                    'Date' as Entry_Date,
                    'Diesel Qty' as Quantity_Ltr,
                    'Diesel Amount' as Amount,
                    'File Name' as File_Name,
                    'File Upload Date' as Upload_Date,
                    'Status' as STATUS

					union all

					select 'TR' as RowType, 
					ifnull(Transporter_Code,'') as Transporter_Code,
                    ifnull(Transporter_Name,'') as Transporter_Name,
					ifnull(Vehicle_No,'') as Vehicle_No,
                    ifnull(DATE_FORMAT(Entry_Date, '%d %b %Y'),'') as Entry_Date,
                    ifnull(Quantity_Ltr,0) as Quantity_Ltr,
                    ifnull(Amount,0) as Amount,
                    ifnull(File_Name,0) as File_Name,
                    ifnull(DATE_FORMAT(Upload_Date, '%d %b %Y'),'') as Upload_Date,
                    CASE 
					   WHEN Is_Posted = 1 THEN 'Posted'
					   WHEN Is_Posted = 0 THEN 'Pending'
					   ELSE ''
				   END as Status
					from temp_Report;
                end;
            elseif (var_Report_Type = 'C048009') then -- Inward Freight Report (Date | Transporter | Vehicle | Trip)
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

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
                    from temp_Report
                    
                    ;
                    
                end;
			elseif (var_Report_Type = 'C048013') then -- ZRTDRS
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

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
                    Trip_Date datetime, 
                    Route_Id varchar(20), Route_Name varchar(50),  FreightRateType_Id varchar(20), FreightRateType_Name varchar(50), 
                    Rate decimal(18,2), FinalDistance decimal(18,2),
                    Average_KM decimal(18,2), 
                    Diesel_Difference decimal(18,2),
                    DieselBaseRate decimal(18,2), 
                    CurrentDieselRate decimal(18,2), TripAmount decimal(18,2), Is_PostedInSAP int, VehicleOwnershipType_Id varchar(20),
                    VehicleOwnershipType_Name varchar(50), Liters decimal(8,3), 
                    DieselRateDiff decimal(18,2), 
                    FinalAmount decimal(18,2),
                    Driver_Id varchar(20), 
                    Driver_Name varchar(100),
                    Start_Time Time,
                    End_Time Time,
					Total_Distance decimal(18,2),
                    Diesel_Top_Up decimal(18,2),
					VehicleAverage_KM decimal(18,2),
                    Out_KM varchar(100),
                    IN_KM varchar(100)
                    );
                    
                    insert into temp_Report (Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    Trip_Date, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    TripAmount, DieselRateDiff, FinalAmount, Is_PostedInSAP, Liters,
                    Average_KM,Diesel_Difference,Driver_Id,Out_KM,IN_KM)
                    select Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    -- DATE_FORMAT(Created_On, '%d %b %Y') as Created_On
                    Created_On
                    , FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    Cost, 
                    case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end as DieselRateDiff, 
                    Cost + (case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end) as Total_Freight,  
                    Is_PostedInSAP, 
                    Roundoff('QuantityForDairy', (ifnull(Liters,0))) as Liters ,
                    Average_KM,Diesel_Difference,Driver_Id,
                    ifnull(Out_KM,'') as Out_KM,
                    ifnull(IN_KM,'') as IN_KM
                    from t021_tripdocument_header t021
                    where t021.Org_Id = var_org_id
                    and CAST(t021.Created_On  AS DATE) >= var_StartDate 
					and CAST(t021.Created_On  AS DATE)  <= var_EndDate
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
                    tmp.VehicleMake_Id = m3.VehicleMake_Id,
                    tmp.VehicleAverage_KM = m3.VehicleAverage;
                    
                    -- Update Driver Name
                    update temp_Report tmp
                    inner join mu06_driver mu06 on tmp.Org_Id = mu06.Org_Id 
                    and tmp.Driver_Id = mu06.Driver_Id
                    set tmp.Driver_Name = mu06.Driver_Name;
                    
                    -- Update Route Details
					update temp_Report tmp
                    inner join m008_route_vehicle m8 on tmp.Org_Id = m8.Org_Id 
                    and tmp.Route_Trip_Id = m8.Entry_Id
                    set tmp.Route_Id = m8.Route_Id;
                    
                    -- Update Route Name
                    update temp_Report tmp
                    inner join m006_route m6 on tmp.Org_Id = m6.Org_Id 
                    and tmp.Route_Id = m6.Route_Id
                    set tmp.Route_Name = m6.Route_Name,
                    tmp.Start_Time = m6.Start_Time,
                    tmp.End_Time = m6.End_Time,
                    tmp.Total_Distance = m6.Total_Distance;
                    
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
                    
                    -- Upddte Diesel Top Up(Ltr)

					update temp_Report tmp
					set tmp.Diesel_Top_Up = 0;

					update temp_Report tmp
					inner join t043_dieselupload t043 on tmp.Org_Id = t043.Org_Id 
					and tmp.Transporter_Id = t043.Transporter_Id
					and tmp.Vehicle_Id = t043.Vehicle_Id
					and date(tmp.Trip_Date) = date(t043.Entry_Date)
					set tmp.Diesel_Top_Up = t043.Quantity_Ltr;
                    
                    -- Update Vehicle Make
                    
                    update temp_Report tmp
                    inner join c032_vehiclemake c032 on
                    tmp.VehicleMake_Id = c032.VehicleMake_Id
                    set tmp.VehicleMake_Name = c032.VehicleMake_Name;
                    
                    -- Generate final output
                    select 'TH' as RowType,
                    'Date' as Trip_Date, 
                    'Vehicle No.' as Vehicle_No, 
                    'Name Of Driver' as Driver_Name,
                    'Collection Route' as Route_Name,
                    'Standard Time' as Standard_Time,
                    'Total Running KM' as FinalDistance, 
                    'Standard KM' as Total_Distance, 
                    'Diff in KM' as Diff_In_KM,
                    'Diesel Top Up(Ltr)' as Diesel_Top_Up, 
                    'Vehicle Avg' as  Average_KM, 
                    'Standard Avg' as  VehicleAverage_KM,
                    'Average Diff' as  Average_Diff,
                    'Out KM Reading' as  Out_KM,
                    'In KM Reading' as  IN_KM
                    /*
                    ,
                    'Transporter Name' as Transporter_Name, 
                    'Transporter Code' as Transporter_Code,
                    'Vehicle Type' as VehicleType_Name, 
                    'Vehicle Make' as VehicleMake_Name, 
                    'Ownershp Type' as VehicleOwnershipType_Name,
                     'Rate Type' as FreightRateType_Name,
                    'Rate' as Rate,  
                    
                    'Average (KM)' as Average_KM, 
                    'Diesel Diff' as Diesel_Difference, 
                    'Diesel Base Rate' as DieselBaseRate, 'Milk Qty (Liters)' as Liters,
                    'Current Diesel Rate' as CurrentDieselRate, 'Trip Amount' as TripAmount, 'Diesel Rate Diff' as DieselRateDiff,
                    'Final Amount' as FinalAmount, 
                    'Invoice Status' as Is_PostedInSAP
                    */
                    union
                    
                    select 'TR' as RowType,
                     DATE_FORMAT(Trip_Date, '%d %b %Y') as Trip_Date, 
                    ifnull(Vehicle_No,'') as Vehicle_No, 
                    ifnull(Driver_Name,'') as Driver_Name, 
                    Route_Name,
                    concat(TIME_FORMAT(Start_Time, '%h:%i %p'),' - ',TIME_FORMAT(End_Time, '%h:%i %p')) as Standard_Time,
                    FinalDistance,
                    Total_Distance,
                   round((Total_Distance - FinalDistance),2) as Diff_In_KM,
                    Diesel_Top_Up,
					VehicleAverage_KM, 
					Average_KM,
                    round((Average_KM - VehicleAverage_KM),2) as  Average_Diff,
                    /*
                    , 
                    
                    Transporter_Name as Transporter_Name, Transporter_Code as Transporter_Code,
                    ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
                    ifnull(VehicleOwnershipType_Name,''),
					FreightRateType_Name as FreightRateType_Name,
                    Rate, 
                    Average_KM, 
                    Diesel_Difference, 
                    DieselBaseRate, Liters, CurrentDieselRate, TripAmount, 
                    DieselRateDiff, FinalAmount,
                    
                    case when Is_PostedInSAP = 0 then 'Not Posted' else 'Posted' end as Is_PostedInSAP
                    */
                    Out_KM,
                    IN_KM
                    from temp_Report
                    
                    ;
                    
                end;
			
            elseif (var_Report_Type = 'C048011') then	-- RMRD Sour Milk Report (Date | MCC | Shift)
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

                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
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
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionDairy_Id varchar(20), MilkCollectionShift_Id varchar(20), 
                    MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), 
                    SourQtyLtr decimal(18,3), MCCType_Id varchar(20), MCCType_Name varchar(20), MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(50));
                    
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, SourQtyLtr)
                    
                    select Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, 
                    MilkType_Id, Dairy_Sour_Ltr
                    from f010_milkcollectionmcc_final f010
                    where Org_Id = var_org_id
                    and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
                    and Dairy_Sour_Ltr > 0
                    and MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and MCC_Id in (Select MCC_Id from temp_MCC);
                    
                    -- Update MCCName and MCCCode
                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
                    
                    -- Update CollectionShift Name
                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                    
                    Update temp_Report tmp
                    set tmp.CollectionShift_Name =  'All Day',
                    tmp.CollectionShift_Id = 'C015003'
                    where ifnull(CollectionShift_Name,'') = '';
                    
                    -- Update MilkType Name
                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;
                    
                    -- Update MCCType Name
                    Update temp_Report tmp
                    inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
                    set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;
                    
					-- Generate final output
					select 'TH' as RowType, 'Date' as Collection_Date, 'MCC Name' as MCC_Name, 'MCC Code' as MCC_Code, 'MCC Type' as MCCType_Name, 
                    'MCC Work Type' as MCCWorkType_Name, 'Collection Shift' as CollectionShift_Name, 'Milk Type' as MilkType_Name,  
                    'Sour Qty (Ltr)' as SourQtyLtr
					
                    union
						
					select 'TR' as RowType, Collection_Date, MCC_Name, MCC_Code, MCCType_Name, MCCWorkType_Name, 
					CollectionShift_Name, MilkType_Name, ifnull(SourQtyLtr, 0)
					from temp_Report
					where MCCType_Id = 'C014001' -- in (Select MCCType_Id from temp_MCCType)
					and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
					and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                        
				End;
                elseif (var_Report_Type = 'C048030') then
				begin
					
                    DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    SET SQL_SAFE_UPDATES = 0;
                    
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
                    
                    select 'TH' as RowType, 
					'MCC Code' as MCC_Code, 
					'MCC Name' as MCC_Name, 
					'Date' as Date, 
					'Document No.' as MaterialDocument, 
					'Document Year' as MaterialDocumentYear, 
					'Material Code' as Material,
                    'Material Description' as Material_Description,
					'Quantity' as Quantity,
					'UOM' as UOM,
					'Status' as Status

					union all

					select 'TR' as RowType, 
					m005.MCC_Code,
					m005.MCC_Name,
					DATE_FORMAT(f017.Date, '%d %b %Y') as Date,
					ifnull(f017.MaterialDocument,'') as MaterialDocument,
					ifnull(f017.MaterialDocumentYear,'') as MaterialDocumentYear,
					ifnull(f017.Material,'') as Material,
                    case 
						when f017.Material = '860021' then 'Aluminium Can With Lid' 
						when f017.Material = '100033' then 'Bulk Milk Cooler - 5000 LTR'
						when f017.Material = '100034' then 'Bulk Milk Cooler - 1000 LTR'
						when f017.Material = '100035' then 'Bulk Milk Cooler - 2000 LTR'
						when f017.Material = '100036' then 'Bulk Milk Cooler - 3000 LTR'
						when f017.Material = '100038' then 'Dg Set - 15 KVA'
						when f017.Material = '100039' then 'Dg Set - 30 KVA'
						when f017.Material = '100040' then 'Stabilizer 12.5 KVA'
						when f017.Material = '100041' then 'Stabilizer 15 KVA'
						when f017.Material = '100042' then 'Stabilizer 25 KVA'
					else '' 
					end as Material_Description,
					ifnull(f017.QuantityInBaseUnit,'') as Quantity,
					ifnull(f017.MaterialBaseUnit,'') as UOM,
					case 
						when f017.GoodsMovementType = '541' then 'Issued to MCC' 
						when f017.GoodsMovementType = '542' then 'Return from MCC'
					else '' 
					end as Status
					FROM f017_materials_issues f017 
					inner join m005_mcc m005 on
					m005.Org_Id = f017.Org_Id
					and m005.MCC_Code = f017.Supplier
					and m005.MCC_Id in (Select MCC_Id from temp_MCC)
                    and CAST(f017.Date  AS DATE) >= var_StartDate 
					and CAST(f017.Date  AS DATE)  <= var_EndDate
					and f017.Org_Id = var_org_id;
					
                end;
			
			elseif (var_Report_Type = 'C048033') then
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    
					drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;

                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;

                    -- Split MCC
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

                    SET SQL_SAFE_UPDATES = 0;
                    
                    select 
                    'TH' as RowType,
                    'Farmer Name' as Farmer_Name,  
                    'MCC Farmer Code' as MCC_Farmer_Code, 
                    'Farmer Code' as Farmer_Code,
                    'MCC Name' as MCC_Name,  
                    'MCC Code' as MCC_Code,
                    'Advance Type' as AdvanceType_Name, 
                    'Amount' as Advance_Amount, 
                    'Date' as Date

                    union all
                    
                    select 
                    'TR' as RowType, 
					ifnull(mu04.Farmer_Name,'') as Farmer_Name,
                     ifnull(mu04.MCC_Farmer_Code,'') as MCC_Farmer_Code,
					ifnull(mu04.Farmer_Code,'') as Farmer_Code,
					ifnull(m005.MCC_Name,'') as MCC_Name,
					ifnull(m005.MCC_Code,'') as MCC_Code,
					ifnull(c040.AdvanceType_Name,'') as AdvanceType_Name,
					ifnull(t015.Advance_Amount,0) as Advance_Amount,
                    DATE_FORMAT(t015.Created_On, '%d %b %Y %h:%i %p') AS Date
					from t015_advance t015 
					inner join m005_mcc m005 on
					m005.Org_Id = t015.Org_Id
					and m005.MCC_Id = t015.MCC_Id
					and m005.MCC_Id in (select MCC_Id from temp_MCC )
					and m005.MCCType_Id in (select MCCType_Id from temp_MCCType )
					and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType )
					inner join mu04_farmer mu04 on
					mu04.Org_Id = t015.Org_Id
					and mu04.Farmer_Id = t015.Request_For_User_Id
					inner join c040_advancetype c040 on
					c040.AdvanceType_Id = t015.AdvanceType_Id
					where t015.Org_Id = var_org_id
                    and DATE(t015.Created_On) >= DATE(var_StartDate) 
					and DATE(t015.Created_On)  <= DATE(var_EndDate);
                    
                    
                end;
			elseif (var_Report_Type = 'C048034') then
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
                    
                    

                    -- Split MCC
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

                    
                    
                    
					
                    SET SQL_SAFE_UPDATES = 0;
                    
                    select 
					'TH' as RowType,
					'Name' as Name,  
					'Code' as Code, 
					'MCC Name' as MCC_Name,  
					'MCC Code' as MCC_Code,
					'Order For' as Order_For, 
					'Order Date' as Order_Date, 
					'Requested Quantity' as Quantity,
					'Approved Quantity' as Approved_Quantity, 
					'Status' as Is_Approved, 
					'Approved Date' as Approved_On

					union all

					
					select 
					'TR' as RowType, 
					ifnull(mu04.Farmer_Name,'') as Name,
					ifnull(mu04.Farmer_Code,'') as Code,
					ifnull(m005.MCC_Name,'') as MCC_Name,
					ifnull(m005.MCC_Code,'') as MCC_Code,
					ifnull(t023.Order_For,'') as Order_For,
					DATE_FORMAT(t023.Order_Date, '%d %b %Y %h:%i %p') AS Order_Date,
					ifnull(t023i.Quantity,'') as Quantity,
					ifnull(t023i.Approved_Quantity,'') as Approved_Quantity,
					CASE 
						WHEN t023.Is_Approved = 1 THEN 'Approved' 
						WHEN t023.Is_Approved = 0 THEN 'Pending' 
						WHEN t023.Is_Approved = -1 THEN 'Rejected' 
						ELSE ''
					END AS  Is_Approved,
					ifnull(DATE_FORMAT(t023.Approved_On, '%d %b %Y %h:%i %p'),'') AS Approved_On
					from t023_order_item t023i
					inner join t023_order_header t023 on
					t023.Org_Id = t023i.Org_Id
					and t023.Order_Id = t023i.Order_Id
					and t023.Order_For = 'Farmer'
					inner join m005_mcc m005 on
					m005.Org_Id = t023.Org_Id
					and m005.MCC_Id = t023.MCC_Id
					and m005.MCC_Id in (select MCC_Id from temp_MCC )
					and m005.MCCType_Id in (select MCCType_Id from temp_MCCType )
					and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType )
					inner join mu04_farmer mu04 on
					mu04.Org_Id = t023.Org_Id
					and mu04.Farmer_Id = t023.Order_For_User_Id
					-- and CAST(t023.Order_Date  AS DATE) >= var_StartDate 
					-- and CAST(t023.Order_Date  AS DATE)  <= var_EndDate
					where t023.Org_Id = var_org_id

					union all

					select 
					'TR' as RowType, 
					ifnull(mu05.Agent_Name,'') as Name,
					ifnull(m005.MCC_Code,'') as Code,
					ifnull(m005.MCC_Name,'') as MCC_Name,
					ifnull(m005.MCC_Code,'') as MCC_Code,
					ifnull(t023.Order_For,'') as Order_For,
					DATE_FORMAT(t023.Order_Date, '%d %b %Y %h:%i %p') AS Order_Date,
					ifnull(t023i.Quantity,'') as Quantity,
					ifnull(t023i.Approved_Quantity,'') as Approved_Quantity,
					CASE 
						WHEN t023.Is_Approved = 1 THEN 'Approved' 
						WHEN t023.Is_Approved = 0 THEN 'Pending' 
						WHEN t023.Is_Approved = -1 THEN 'Rejected' 
						ELSE ''
					END AS  Is_Approved,
					ifnull(DATE_FORMAT(t023.Approved_On, '%d %b %Y %h:%i %p'),'') AS Approved_On
					from t023_order_item t023i
					inner join t023_order_header t023 on
					t023.Org_Id = t023i.Org_Id
					and t023.Order_Id = t023i.Order_Id
					and t023.Order_For = 'Agent'
					inner join m005_mcc m005 on
					m005.Org_Id = t023.Org_Id
					and m005.MCC_Id = t023.MCC_Id
					and m005.MCC_Id in (select MCC_Id from temp_MCC_1 )
					and m005.MCCType_Id in (select MCCType_Id from temp_MCCType_1 )
					and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType_1 )
					inner join mu05_agent mu05 on
					mu05.Org_Id = t023.Org_Id
					and mu05.Agent_Id = t023.Order_For_User_Id
					-- and CAST(t023.Order_Date  AS DATE) >= var_StartDate 
					-- and CAST(t023.Order_Date  AS DATE)  <= var_EndDate
					where t023.Org_Id = var_org_id;
                    
                    
                    
                end;
                elseif (var_Report_Type = 'C048032') then
				begin
					set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
					
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    
                    
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType_1;
					create temporary table temp_MilkType_1(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType_1 (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;
                    

                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;
                    
                    drop temporary table if exists temp_CollectionShift_1;
					create temporary table temp_CollectionShift_1(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift_1 (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift_1 (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;

                    -- Split MCC
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

                    SET SQL_SAFE_UPDATES = 0;
                    
                    
                    
                     select 
                    'TH' as RowType,
                    'MCC Name' as MCC_Name,  
                    'MCC Code' as MCC_Code,
                    'MCC Type' as MCCType_Name,
                    'MCC Work Type' as MCCWorkType_Name,
                    'MCC Status' as Is_Active,
                    'Chart Name' as Route_Name, 
                    'Collection Shift' as CollectionShift_Name, 
                    'Date' as Date

                    union all
                    
                    select 
                    'TR' as RowType, 
					m005.MCC_Name,
                    m005.MCC_Code,
                    c014.MCCType_Name,
                    c023.MCCWorkType_Name,
                    case when m005.Is_Active = 1 then 'Active' else 'In-Active' end as Is_Active,
                    m0011.Chart_Name,
                    c015.CollectionShift_Name as CollectionShift_Name,
                    DATE_FORMAT(m001.Applicable_Date, '%d %b %Y %h:%i %p') AS Date
					from m001_milkrate_mcc_header m001
					inner join m001_milkrate_mcc_item m001i on
					m001.Org_Id = m001i.Org_Id
					and m001.Chart_Id = m001i.Chart_Id
					and m001.Version_No = m001i.Version_No
                    INNER JOIN (
                        select 
                        m001i.MCC_Id,
                        m001ii.CollectionShift_Id,
                        MAX(m001.Applicable_Date) AS Applicable_Date
                        from m001_milkrate_mcc_header m001
                        inner join m001_milkrate_mcc_item m001i on
                        m001.Org_Id = m001i.Org_Id
                        and m001.Chart_Id = m001i.Chart_Id
                        and m001.Version_No = m001i.Version_No
                        inner join m001_milkrate m001ii on
                        m001.Org_Id = m001ii.Org_Id
                        and m001.Chart_Id = m001ii.Chart_Id
                        and m001ii.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift_1 )
                        and m001ii.MilkType_Id in (select MilkType_Id from temp_MilkType_1 )
                        and date(m001.Applicable_Date)  <= date(@Current_Datetime)
                        group by m001i.MCC_Id,m001ii.CollectionShift_Id
                    ) AS MaxDates 
                    ON 
                        m001i.MCC_Id = MaxDates.MCC_Id
                        AND m001.Applicable_Date = MaxDates.Applicable_Date
                        
                    inner join m001_milkrate m0011 on
                    m0011.Org_Id = m001.Org_Id
                    and m0011.Chart_Id = m001.Chart_Id
                     AND m0011.CollectionShift_Id = MaxDates.CollectionShift_Id
                    and m0011.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
                    and m0011.MilkType_Id in (select MilkType_Id from temp_MilkType )
                    inner join m005_mcc m005 on
                    m005.Org_Id = m001i.Org_Id
                    and m005.MCC_Id = m001i.MCC_Id
                    and m005.Is_Active = 1
                    and m005.MCC_Id in (select MCC_Id from temp_MCC )
                    and m005.MCCType_Id in (select MCCType_Id from temp_MCCType )
                    and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType )
                    inner join c014_mcctype c014 on
                    c014.MCCType_Id = m005.MCCType_Id
                    inner join c023_mccworktype c023 on
                    c023.MCCWorkType_Id = m005.MCCWorkType_Id
                    inner join c015_collectionshift c015 on
                    c015.CollectionShift_Id = m0011.CollectionShift_Id
					where m001.Org_Id = var_org_id
					and date(m001.Applicable_Date)  <= date(@Current_Datetime);
                    
                    
				end;
				elseif (var_Report_Type = 'C048035') then
				begin
                
                -- MPPIType_Id cloume add in UI and Backend
				set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
				
				 -- Split Milk Type
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MilkType_Id, ''));

				drop temporary table if exists temp_MilkType;
				create temporary table temp_MilkType(MilkType_Id char(255) );
				set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt2 from @sql2;
				execute stmt2;
				
				
				-- Split Milk Type
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MilkType_Id, ''));

				drop temporary table if exists temp_MilkType_1;
				create temporary table temp_MilkType_1(MilkType_Id char(255) );
				set @sql2 = concat('insert into temp_MilkType_1 (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt2 from @sql2;
				execute stmt2;

				-- Split MCC
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
				
				-- Split MPPI Type
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCCollectionShift_Id, ''));

				drop temporary table if exists temp_MPPIType;
				create temporary table temp_MPPIType(MPPIType_Id char(255) );
				set @sql2 = concat('insert into temp_MPPIType (MPPIType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt2 from @sql2;
				execute stmt2;
                
                
                -- Split MPPI Type
				drop temporary table if exists t;
				create temporary table t( txt text );
				insert into t values(ifnull(var_MCCCollectionShift_Id, ''));

				drop temporary table if exists temp_MPPIType_1;
				create temporary table temp_MPPIType_1(MPPIType_Id char(255) );
				set @sql2 = concat('insert into temp_MPPIType_1 (MPPIType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
				prepare stmt2 from @sql2;
				execute stmt2;

				SET SQL_SAFE_UPDATES = 0;
				
				drop temporary table if exists temp_mcc_max_date;
				-- Step 2: Create a temporary table
				CREATE TEMPORARY TABLE temp_mcc_max_date (
					Org_Id VARCHAR(50),	
					MCC_Id VARCHAR(50),
					Applicable_Date VARCHAR(255)
				);

				-- Step 3: Insert the filtered data into the temporary table
				INSERT INTO temp_mcc_max_date (Org_Id,MCC_Id, Applicable_Date)
				SELECT 
					m002i.Org_Id, 
					m002i.MCC_Id, 
					MAX(m002i.Applicable_Date) 
				FROM 
					m002_commission_mcc m002i
				INNER JOIN 
					m002_commission m002 ON
					m002.Org_Id = m002i.Org_Id
					AND m002.MPPI_Id = m002i.MPPI_Id
					AND m002.MilkType_Id in (select MilkType_Id from temp_MilkType )
                    AND m002.MPPIType_Id in (select MPPIType_Id from temp_MPPIType_1 )
				WHERE 
					m002i.Org_Id = var_org_id
					AND DATE(m002i.Applicable_Date) <= DATE(@Current_Datetime)
				GROUP BY 
					m002i.Org_Id,
					m002i.MCC_Id;
				
				
				-- Step 4: Now use the temporary table to filter the final data
				select 
					'TH' as RowType,
					'MCC Name' as MCC_Name,  
					'MCC Code' as MCC_Code,
					'MCC Type' as MCCType_Name,
					'MCC Work Type' as MCCWorkType_Name,
					'MCC Status' as Is_Active,
					'MPPI Name' as MPPI_Name, 
					'MPPI Type' as MPPIType_Name, 
					'Date' as Date

				union all
							
				SELECT 
					'TR' as RowType,
					m005.MCC_Name,
					m005.MCC_Code,
					c014.MCCType_Name,
					c023.MCCWorkType_Name,
					case when m005.Is_Active = 1 then 'Active' else 'In-Active' end as Is_Active,
					m002.MPPI_Name,
					c047.MPPIType_Name,
					DATE_FORMAT(m002i.Applicable_Date, '%d %b %Y %h:%i %p') AS Date
				FROM 
					m002_commission_mcc m002i
				inner JOIN 
					m002_commission m002 ON
					m002.Org_Id = m002i.Org_Id
					AND m002.MPPI_Id = m002i.MPPI_Id
					AND m002.MPPIType_Id in (select MPPIType_Id from temp_MPPIType )
					AND m002.MilkType_Id in (select MilkType_Id from temp_MilkType_1 )
				inner JOIN 
					temp_mcc_max_date temp ON
					temp.Org_Id = m002i.Org_Id
					and temp.MCC_Id = m002i.MCC_Id
					AND temp.Applicable_Date = m002i.Applicable_Date
				inner join m005_mcc m005 on
					m005.Org_Id = m002i.Org_Id
					and m005.MCC_Id = m002i.MCC_Id
					and m005.MCC_Id in (select MCC_Id from temp_MCC )
					and m005.MCCType_Id in (select MCCType_Id from temp_MCCType )
					and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType )
					inner join c014_mcctype c014 on
					c014.MCCType_Id = m005.MCCType_Id
					inner join c023_mccworktype c023 on
					c023.MCCWorkType_Id = m005.MCCWorkType_Id
					inner join c047_mppitype c047 on
					c047.MPPIType_Id = m002.MPPIType_Id
				WHERE 
					m002i.Org_Id = var_org_id
					AND DATE(m002i.Applicable_Date) <= DATE(@Current_Datetime);
				end;
			elseif (var_Report_Type = 'C048036') then -- Inward Freight Report (Date | Transporter | Vehicle | Trip)
				begin
					
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
                    
                    
                    
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCC_Id, ''));
                    
                    drop temporary table if exists temp_Transporter_1;
					create temporary table temp_Transporter_1(Transporter_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_Transporter_1 (Transporter_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_Transporter_1 (Transporter_Id)
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
                    NetPayable decimal(18,2),
                    Vehicle_Count varchar(255)
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
                    sum(ifnull(FinalDistance,0)) as FinalDistance, 
                    avg(ifnull(Average_KM, 0)) as Average_KM, 
                    avg(ifnull(Diesel_Difference, 0)) as Diesel_Difference,
                    avg(ifnull(DieselBaseRate,0)) as DieselBaseRate, 
                    avg(ifnull(CurrentDieselRate,0)) as CurrentDieselRate, 
                    sum(ifnull(TripAmount, 0)) as TripAmount,
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
                    
                    UPDATE temp_Report_1 tmp
					JOIN (
						SELECT 
							t021.Vehicle_Id,
							COUNT(*) AS Vehicle_Count
						FROM t021_tripdocument_header t021
						WHERE t021.Org_Id = var_org_id
						  AND CAST(t021.Created_On AS DATE) >= var_StartDate
						  AND CAST(t021.Created_On AS DATE) <= var_EndDate
						  AND t021.Transporter_Id IN (SELECT Transporter_Id FROM temp_Transporter_1)
						GROUP BY t021.Vehicle_Id
					) AS t
					ON tmp.Vehicle_Id = t.Vehicle_Id
					SET tmp.Vehicle_Count = t.Vehicle_Count;

                    
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
						 ifnull(tmp.FinalAmount,0) + ifnull(tmp.LabourCharge,0)+ ifnull(tmp.CattleFeed,0);
                    
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
                    'Trip Days' as Vehicle_Count,
                    'Rate (avg)' as Rate,
                    -- 'Distance (KM) (sum)' as FinalDistance,
                    'Average (KM) (avg)' as Average_KM,
                    'Diesel Base Rate (avg)' as DieselBaseRate,
                    -- 'Diesel Diff (avg)' as Diesel_Difference,
                    -- 'Diesel Rate Diff (avg)' as DieselBaseRate,
                    'Current Diesel Rate (avg)' as CurrentDieselRate,
                    -- 'Diesel Base Rate (avg)' as DieselBaseRate,
                    'Diesel Rate Diff (avg)' as Diesel_Difference,
                    'Distance (KM) (sum)' as FinalDistance,
                    'Diesel In Ltr (sum)' as RecoveryLtr,
                    'Trip Amount (sum)' as TripAmount,
                    
                    'Diesel Rate Diff Amount (sum)' as DieselRateDiff,
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
                    'Diesel Advance (sum)' as RecoveryAmount,
                    'Total Deduction' as TotalDeduction,
                    'Net Payable' as NetPayable,
                    'Milk Qty (sum)' as Liters,
                    'Date'  as Date
                    
                    union
                    
                    select 'TR' as RowType, 
					Transporter_Name as Transporter_Name, 
                    Transporter_Code as Transporter_Code,
                    ifnull(Vehicle_No,'') as Vehicle_No, 
                    ifnull(VehicleType_Name,'') as VehicleType_Name, 
					ifnull(VehicleMake_Name,'') as VehicleMake_Name, 
                    ifnull(VehicleOwnershipType_Name,'') as VehicleOwnershipType_Name,
                    ifnull(FreightRateType_Name,'') as FreightRateType_Name,
                    Vehicle_Count,
                    Rate,
                    -- FinalDistance,
                    Average_KM,
                    DieselBaseRate,
                    -- DieselBaseRate,
                    CurrentDieselRate,
                    Diesel_Difference,
                    FinalDistance,
                    RecoveryLtr,
                    TripAmount,
                    
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
                    TotalDeduction,
                    NetPayable,
                    Liters,
                    concat(DATE_FORMAT(var_StartDate, '%d %b %Y') , ' - ',DATE_FORMAT(var_EndDate , '%d %b %Y')) as Date
                    from temp_Report_1;
					
                end;
            elseif (var_Report_Type = 'C048031') then
				begin
					set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
					
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;

                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;

                    -- Split MCC
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

                    SET SQL_SAFE_UPDATES = 0;
                    
                    select 
                    'TH' as RowType,
                    'MCC Name' as MCC_Name,  
                    'MCC Code' as MCC_Code,
                    'MCC Type' as MCCType_Name,
                    'MCC Work Type' as MCCWorkType_Name,
					'MCC Status' as Is_Active,
                    'Chart Name' as Chart_Name, 
					'Collection Shift' as CollectionShift_Name, 
                    'Date' as Date

                    union all
                    
                    select 
                    'TR' as RowType, 
					m005.MCC_Name as MCC_Name,
                    m005.MCC_Code as MCC_Code,
                    c014.MCCType_Name  as MCCType_Name, 
                    c023.MCCWorkType_Name as MCCWorkType_Name,
                    case when m005.Is_Active = 1 then 'Active' else 'In-Active' end as Is_Active,
                    m0011.Chart_Name as Chart_Name,
					c015.CollectionShift_Name as CollectionShift_Name,
                    DATE_FORMAT(m001.Applicable_Date, '%d %b %Y %h:%i %p') AS Date
					from m001_milkrate_mcc_header m001
					inner join m001_milkrate_mcc_item m001i on
					m001.Org_Id = m001i.Org_Id
					and m001.Chart_Id = m001i.Chart_Id
					and m001.Version_No = m001i.Version_No
                    inner join m001_milkrate m0011 on
                    m0011.Org_Id = m001.Org_Id
                    and m0011.Chart_Id = m001.Chart_Id
                    and m0011.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
                    and m0011.MilkType_Id in (select MilkType_Id from temp_MilkType )
                    inner join m005_mcc m005 on
                    m005.Org_Id = m001i.Org_Id
                    and m005.MCC_Id = m001i.MCC_Id
                    and m005.Is_Active = 1
                    and m005.MCC_Id in (select MCC_Id from temp_MCC )
                    and m005.MCCType_Id in (select MCCType_Id from temp_MCCType )
                    and m005.MCCWorkType_Id in (select MCCWorkType_Id from temp_MCCWorkType )
                    inner join c014_mcctype c014 on
                    c014.MCCType_Id = m005.MCCType_Id
                    inner join c023_mccworktype c023 on
                    c023.MCCWorkType_Id = m005.MCCWorkType_Id
                     inner join c015_collectionshift c015 on
                    c015.CollectionShift_Id = m0011.CollectionShift_Id
					where m001.Org_Id = var_org_id
					and date(m001.Applicable_Date)  <= date(@Current_Datetime);
                    
                    
                    
                    
				end;
				elseif (var_Report_Type = 'C048029') then
				begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
					
                    -- Split Milk Type
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MilkType_Id, ''));

					drop temporary table if exists temp_MilkType;
					create temporary table temp_MilkType(MilkType_Id char(255) );
					set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt2 from @sql2;
					execute stmt2;

                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;

                    -- Split MCC
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

                    SET SQL_SAFE_UPDATES = 0;

                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
                    CREATE TEMPORARY TABLE temp_Report ( 
                    Org_Id varchar(20),MilkCollectionDairy_Id varchar(20),TripDocument_Id varchar(20),
                    MCCCollectionShift_Id varchar(20),MCC_Id varchar(20),CellNo varchar(20),
                    MilkType_Id varchar(20),MilkStatus_Id varchar(20),
                    Vehicle_Id varchar(20),Is_OutsideVehicle varchar(20),Created_On datetime,Route_Id varchar(20),
                    MCC_Name varchar(100), MCC_Code varchar(20),
                    MCCType_Id varchar(20), MCCType_Name varchar(20),
                    MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(50),
                    Route_Name varchar(255),
                    CollectionShift_Id varchar(255),CollectionShift_Name varchar(255),
                    VehicleType_Id varchar(255),VehicleType_Name varchar(255),Vehicle_No varchar(255),
                    MilkType_Name varchar(255),
                    Weight decimal(20,3) ,
                    Liters decimal(20,3)
                    );

                    insert into temp_Report (
                    Org_Id,
                    MilkCollectionDairy_Id,
                    TripDocument_Id,
                    Vehicle_Id,
                    Is_OutsideVehicle,
                    Created_On,
                    MCCCollectionShift_Id,
                    MCC_Id,
                    CellNo,
                    MilkType_Id,
                    MilkStatus_Id,
                    Weight,
                    Liters
                    )
                    SELECT
                        Org_Id,
                        MilkCollectionDairy_Id,
                        TripDocument_Id,
                        Vehicle_Id,
                        Is_OutsideVehicle,
                        Created_On,
                        MCCCollectionShift_Id,
                        MCC_Id,
                        CellNo,
                        MilkType_Id,
                        MilkStatus_Id,
                        sum(ifnull(Weight,0)) as Weight,
                        sum(ifnull(Liters,0)) as Liters
                    FROM (
                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,t0091.Weight,t0091.Liters
                            from t009_milkcollectiondairy_quantity t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') <> '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') <> '' 
                            and ifnull(t0091.CellNo ,'') = ''

                            union all

                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,t0091.Weight,t0091.Liters
                            from t009_milkcollectiondairy_quantity t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') = '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') = '' 
                            and ifnull(t0091.CellNo ,'') <> ''

                            union all
                            
                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,t0091.Weight,t0091.Liters
                            from t009_milkcollectiondairy_quantity t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') <> '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') = '' 
                            and ifnull(t0091.CellNo ,'') <> ''

                            union all

                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,'0' as Weight,'0' as Liters
                            from t009_milkcollectiondairy_quality t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') <> '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') <> '' 
                            and ifnull(t0091.CellNo ,'') = ''

                            union all

                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,'0' as Weight,'0' as Liters
                            from t009_milkcollectiondairy_quality t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') = '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') = '' 
                            and ifnull(t0091.CellNo ,'') <> ''

                            union all
                            
                            select 
                            t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.TripDocument_Id,t009.Vehicle_Id,t009.Is_OutsideVehicle,t009.Created_On,t0091.MCCCollectionShift_Id,t0091.MCC_Id,t0091.CellNo,t0091.MilkType_Id,t0091.MilkStatus_Id
                            ,'0' as Weight,'0' as Liters
                            from t009_milkcollectiondairy_quality t0091
                            inner join t009_milkcollectiondairy_header t009 on
                            t009.Org_Id = t0091.Org_Id
                            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
                            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
                            where t0091.Org_Id =var_org_id
                            and t0091.MilkStatus_Id ='C016002'
                            and ifnull(t0091.MCC_Id ,'') <> '' 
                            and ifnull(t0091.MCCCollectionShift_Id ,'') = '' 
                            and ifnull(t0091.CellNo ,'') <> ''

                    ) AS combined_results
                    GROUP BY 
                        Org_Id,
                        MilkCollectionDairy_Id,
                        TripDocument_Id,
                        Vehicle_Id,
                        Is_OutsideVehicle,
                        MCCCollectionShift_Id,
                        MCC_Id,
                        CellNo,
                        MilkType_Id,
                        MilkStatus_Id,
                        Created_On;
                        
                    Update temp_Report tmp
                    inner join t022_tripdocument_item t022 on
                    t022.Org_Id = tmp.Org_Id
                    and t022.TripDocument_Id = tmp.TripDocument_Id
                    set 
                    tmp.Route_Id = t022.Route_Id
                    where tmp.Is_OutsideVehicle = 0;

                    Update temp_Report tmp
                    inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
                    set tmp.MCC_Name = m005.MCC_Name,
                    tmp.MCC_Code = m005.MCC_Code,
                    tmp.MCCType_Id = m005.MCCType_Id,
                    tmp.MCCWorkType_Id = m005.MCCWorkType_Id;

                    -- Update Route_Name and CollectionShift_Id
                    Update temp_Report tmp
                    inner join m006_route m006 on tmp.Org_Id = m006.Org_Id and tmp.Route_Id = m006.Route_Id
                    set tmp.Route_Name = m006.Route_Name,
                    tmp.CollectionShift_Id = m006.CollectionShift_Id;

                    Update temp_Report tmp
                    inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
                    set tmp.MCCType_Name = c014.MCCType_Name;

                    Update temp_Report tmp
                    inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
                    set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;


                    Update temp_Report tmp
                    inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
                    set tmp.CollectionShift_Name = c015.CollectionShift_Name;

                    update temp_Report tmp
                    inner join m003_vehicle m3 on tmp.Org_Id = m3.Org_Id 
                    and tmp.Vehicle_Id = m3.Vehicle_Id
                    set tmp.Vehicle_No = m3.Vehicle_No,
                    tmp.VehicleType_Id = m3.VehicleType_Id;

                    update temp_Report tmp
                    inner join c020_vehicletype c20 on
                    tmp.VehicleType_Id = c20.VehicleType_Id
                    set tmp.VehicleType_Name = c20.VehicleType_Name;

                    update temp_Report tmp
                    set tmp.VehicleType_Name ='Bulk Supplier'
                    where ifnull(tmp.VehicleType_Name,'') ='';

                    Update temp_Report tmp
                    inner join c011_milktype c011 on tmp.MilkType_Id = c011.MilkType_Id
                    set tmp.MilkType_Name = c011.MilkType_Name;



                    select 
                    'TH' as RowType,
                    'MCC Name' as MCC_Name,  'MCC Code' as MCC_Code,'MCC Type' as MCCType_Name,'MCC Work Type' as MCCWorkType_Name,
                    'Route Name' as Route_Name,  'Collection Shift' as CollectionShift_Name,'Vehicle No' as Vehicle_No,'Vehicle Type' as VehicleType_Name,
                    'Milk Type' as MilkType_Name,
                    'Qty (Kg)' as Weight,'Qty (Ltr)' as Liters,
                    'Date' as Created_On

                    union all
                    
                    select 
                    'TR' as RowType, 
                    ifnull(MCC_Name,' - ') as MCC_Name,ifnull(MCC_Code,' - ') as MCC_Code,ifnull(MCCType_Name,' - ') as MCCType_Name,
                    ifnull(MCCWorkType_Name,' - ') as MCCWorkType_Name,ifnull(Route_Name,' - ') as Route_Name,
                    ifnull(CollectionShift_Name,' - ') as CollectionShift_Name,ifnull(Vehicle_No,' - ') as Vehicle_No,ifnull(VehicleType_Name,'') as VehicleType_Name,
                    ifnull(MilkType_Name,' - ')as MilkType_Name,
                    ifnull(Weight,0)as Weight,ifnull(Liters,0)as Liters,
                    DATE_FORMAT(Created_On, '%d %b %Y') as Created_On
                    from temp_Report
                    where Org_Id = var_org_id
                    -- and MCC_Id in (Select MCC_Id from temp_MCC)
                    -- and MCCType_Id in (Select MCCType_Id from temp_MCCType)
                    -- and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
                    -- and CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
                    ;
                    
                end;
            
            
            elseif (var_Report_Type = 'C048015') then -- ZRTDRS
				begin
					SET SQL_SAFE_UPDATES = 0;
					SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');


					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), TripDocument_Id varchar(20),Vehicle_Id varchar(20),  
					MCC_Id varchar(20), MCCCollectionShift_Id varchar(20), Batch_Id varchar(20),CellNo varchar(20),Created_On varchar(100),
					Weight decimal(30,3), Liters decimal(30,3),Check_Id varchar(20),
					MCC_Code varchar(20), MCC_Name varchar(255),MCCType_Id varchar(20),MCCWorkType_Id varchar(20),
					Sample_No varchar(20),SNF decimal(30,3), Fat decimal(30,3),
					Route_Trip_Id varchar(20),Route_Id varchar(20),Route_Name  varchar(255),CollectionShift_Id varchar(20),CollectionShift_Name varchar(255),
					Vehicle_No varchar(255),VehicleType_Id varchar(20),VehicleMake_Id varchar(20),
					VehicleType_Name varchar(255),VehicleMake_Name varchar(255), Protein decimal(8,2), Ash decimal(8,2), Sodium decimal(8,2)
					);
                    
					insert into temp_Report (
					Org_Id , MilkCollectionDairy_Id , TripDocument_Id ,Vehicle_Id ,  
					MCC_Id , MCCCollectionShift_Id , Batch_Id ,CellNo ,Created_On,
					Weight , Liters ,Check_Id 
					)
					select 
					t0091.Org_Id,
					t0091.MilkCollectionDairy_Id,
					t009.TripDocument_Id,
					t009.Vehicle_Id,
					t0091.MCC_Id,
					t0091.MCCCollectionShift_Id,
					t0091.Batch_Id,
					t0091.CellNo,
					DATE_FORMAT(t009.Created_On, '%d %b %Y') as Created_On,
					t0091.Weight,
					t0091.Liters,
					'1' as Check_Id
					from t009_milkcollectiondairy_header t009
					inner join t009_milkcollectiondairy_quantity t0091 on
					t0091.Org_Id = t009.Org_Id
					and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					and ifnull(t0091.MCCCollectionShift_Id,'') <> ''
					and ifnull(t0091.MCC_Id,'') <> ''
                    and t0091.MilkStatus_Id = 'C016001'
					where t009.Org_Id = var_org_id
					and date(t009.Created_On) >= date(@var_StartDate)
					and date(t009.Created_On) <= date(@var_EndDate)
					and t009.Is_OutsideVehicle = 0

					UNION ALL

					select 
					t0091.Org_Id,
					t0091.MilkCollectionDairy_Id,
					t009.TripDocument_Id,
					t009.Vehicle_Id,
					t0091.MCC_Id,
					t0091.MCCCollectionShift_Id,
					t0091.Batch_Id,
					t0091.CellNo,
					DATE_FORMAT(t009.Created_On, '%d %b %Y') as Created_On,
					t0091.Weight,
					t0091.Liters,
					'2' as Check_Id
					from t009_milkcollectiondairy_header t009
					inner join t009_milkcollectiondairy_quantity t0091 on
					t0091.Org_Id = t009.Org_Id
					and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					and ifnull(t0091.MCCCollectionShift_Id,'') = ''
					and ifnull(t0091.MCC_Id,'') = ''
                    and t0091.MilkStatus_Id = 'C016001'
					where t009.Org_Id = var_org_id
					and date(t009.Created_On) >= date(@var_StartDate)
					and date(t009.Created_On) <= date(@var_EndDate)
					and t009.Is_OutsideVehicle = 0

					UNION ALL

					select 
					t0091.Org_Id,
					t0091.MilkCollectionDairy_Id,
					t009.TripDocument_Id,
					t009.Vehicle_Id,
					t0091.MCC_Id,
					t0091.MCCCollectionShift_Id,
					t0091.Batch_Id,
					t0091.CellNo,
					DATE_FORMAT(t009.Created_On, '%d %b %Y') as Created_On,
					t0091.Weight,
					t0091.Liters,
					'3' as Check_Id
					from t009_milkcollectiondairy_header t009
					inner join t009_milkcollectiondairy_quantity t0091 on
					t0091.Org_Id = t009.Org_Id
					and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                    and t0091.MilkStatus_Id = 'C016001'
					where t009.Org_Id = var_org_id
					and date(t009.Created_On) >= date(@var_StartDate)
					and date(t009.Created_On) <= date(@var_EndDate)
					and t009.Is_OutsideVehicle = 1;



					-- Update MCCName and MCCCode
					Update temp_Report tmp
					inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id 
					and tmp.MCC_Id = m005.MCC_Id
					and tmp.Check_Id in ('1','3')
					set tmp.MCC_Name = m005.MCC_Name,
					tmp.MCC_Code = m005.MCC_Code,
					tmp.MCCType_Id = m005.MCCType_Id,
					tmp.MCCWorkType_Id = m005.MCCWorkType_Id;


					-- Update Sample_No, SNF and Fat
					Update temp_Report tmp
					inner join t009_milkcollectiondairy_quality t009 on 
					tmp.Org_Id = t009.Org_Id 
					and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					and tmp.MCC_Id = t009.MCC_Id
					and tmp.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
					and tmp.Batch_Id = t009.Batch_Id
					set tmp.Sample_No = t009.Sample_No,
					tmp.SNF = t009.SNF,
					tmp.Fat = t009.Fat,
                    tmp.Protein = t009.Protein
					where tmp.Check_Id = '1'
					and ifnull(t009.Sample_No,'') <> ''
					and ifnull(t009.SNF,'') <> ''
					and ifnull(t009.Fat,'') <> '';


					Update temp_Report tmp
					inner join t009_milkcollectiondairy_quality t009 on 
					tmp.Org_Id = t009.Org_Id 
					and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					and tmp.CellNo = t009.CellNo
					set tmp.Sample_No = t009.Sample_No,
					tmp.SNF = t009.SNF,
					tmp.Fat = t009.Fat,
                    tmp.Protein = t009.Protein
					where tmp.Check_Id = '2'
					and ifnull(t009.Sample_No,'') <> ''
					and ifnull(t009.SNF,'') <> ''
					and ifnull(t009.Fat,'') <> '';


					Update temp_Report tmp
					inner join t009_milkcollectiondairy_quality t009 on 
					tmp.Org_Id = t009.Org_Id 
					and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
					and tmp.CellNo = t009.CellNo
					and ifnull(t009.Sample_No,'') <> ''
					and ifnull(t009.SNF,'') <> ''
					and ifnull(t009.Fat,'') <> ''
					set tmp.Sample_No = t009.Sample_No,
					tmp.SNF = t009.SNF,
					tmp.Fat = t009.Fat,
                    tmp.Protein = t009.Protein
					where tmp.Check_Id = '3'
					and ifnull(t009.Sample_No,'') <> ''
					and ifnull(t009.SNF,'') <> ''
					and ifnull(t009.Fat,'') <> '';


					-- Update Route_Trip_Id
					Update temp_Report tmp
					inner join t021_tripdocument_header t021 on tmp.Org_Id = t021.Org_Id 
					and tmp.TripDocument_Id = t021.TripDocument_Id
					and tmp.Check_Id in ('1','2')
					set tmp.Route_Trip_Id = t021.Route_Trip_Id;


					-- Update Route_Id
					Update temp_Report tmp
					inner join m008_route_vehicle m008 on tmp.Org_Id = m008.Org_Id 
					and tmp.Route_Trip_Id = m008.Entry_Id
					and tmp.Check_Id in ('1','2')
					set tmp.Route_Id = m008.Route_Id;

					-- Update Route_Id
					Update temp_Report tmp
					inner join m006_route m006 on tmp.Org_Id = m006.Org_Id 
					and tmp.Route_Id = m006.Route_Id
					and tmp.Check_Id in ('1','2')
					set tmp.CollectionShift_Id = m006.CollectionShift_Id,
						tmp.Route_Name = m006.Route_Name;

					-- Update Vehicle_No
					Update temp_Report tmp
					inner join m003_vehicle m003 on tmp.Org_Id = m003.Org_Id 
					and tmp.Vehicle_Id = m003.Vehicle_Id
					and tmp.Check_Id in ('1','2')
					set tmp.VehicleType_Id = m003.VehicleType_Id,
						tmp.VehicleMake_Id = m003.VehicleMake_Id,
						tmp.Vehicle_No = m003.Vehicle_No;

					-- Update CollectionShift_Name
					Update temp_Report tmp
					inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id 
					and tmp.Check_Id in ('1','2')
					set tmp.CollectionShift_Name = c015.CollectionShift_Name;

					-- Update CollectionShift_Name
					Update temp_Report tmp
					inner join c020_vehicletype c020 on tmp.VehicleType_Id = c020.VehicleType_Id 
					and tmp.Check_Id in ('1','2')
					set tmp.VehicleType_Name = c020.VehicleType_Name;

					-- Update CollectionShift_Name
					Update temp_Report tmp
					inner join c032_vehiclemake c032 on tmp.VehicleMake_Id = c032.VehicleMake_Id 
					and tmp.Check_Id in ('1','2')
					set tmp.VehicleMake_Name = c032.VehicleMake_Name;

					 -- Generate final output
					select 'TH' as RowType,
					'DATE' as Created_On,
					'Sample No' as Sample_No,
					'Collection Shift' as CollectionShift_Name,
					'MCC Code' as MCC_Code,
					'MCC Name' as MCC_Name,
					'Quantity (kg)' as Weight,
					'Quantity (ltr)' as Liters,
					'Fat' as Fat,
					'SNF' as SNF,
                    'Protein' as Protein

					union

					select 
					'TR' as RowType,
					Created_On ,
					ifnull(Sample_No,'') as Sample_No,
					ifnull(CollectionShift_Name,concat(Vehicle_Id,' Outside Vehicle All Day')) as CollectionShift_Name,
					ifnull(MCC_Code,'') as MCC_Code,
					CASE
						WHEN ( MCC_Name = '' or MCC_Name is null ) and Check_Id = '2' 
						THEN concat( CollectionShift_Name , ' ', Vehicle_No,' ', VehicleType_Name) 
						ELSE MCC_Name
					END as MCC_Name,
					ifnull(Weight,'') as Weight,
					ifnull(Liters,'') as Liters,
					ifnull(Fat,'') as Fat,
					ifnull(SNF,'') as SNF,
                    ifnull(Protein,'') as Protein
					from temp_Report;
                end;
			elseif (var_Report_Type = 'C048020') then
				begin

					set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
                    
                    -- Split Route Name
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCC_Id, ''));
                    
					drop temporary table if exists temp_Route;
					create temporary table temp_Route(Route_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_Route (Route_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_Route (Route_Id)
                        select Route_Id from m006_route where Org_Id = var_org_id and Is_Active = 1;
                    end if;


					
				SET SQL_SAFE_UPDATES = 0;
                
				DROP TEMPORARY TABLE IF EXISTS temp_Report_1;

                CREATE TEMPORARY TABLE temp_Report_1 ( 
                Org_Id varchar(20), TripDocument_Id varchar(20), Driver_Id varchar(20),Vehicle_Id varchar(20),
                Created_On datetime, Route_Id varchar(20),MCC_Id varchar(20),MCCCollectionShift_Id varchar(20),
                Is_Dispatch varchar(20),CollectionShift_Id varchar(255),
                Driver_Name varchar(255),Route_Name varchar(255),Vehicle_No varchar(255),CollectionShift_Name varchar(255),
                MCC_Name varchar(255), MCC_Code varchar(20),
				MCCType_Id varchar(20), MCCType_Name varchar(255),
				MCCWorkType_Id varchar(20), MCCWorkType_Name varchar(255)
                );
                
                Insert into temp_Report_1 (
                Org_Id,TripDocument_Id,Route_Id,MCC_Id,MCCCollectionShift_Id,Created_On,Is_Dispatch,Driver_Id,Vehicle_Id
                )
                select ifnull(Org_Id,'') as Org_Id,ifnull(TripDocument_Id,'') as TripDocument_Id,ifnull(Route_Id,'') as Route_Id,
                ifnull(MCC_Id,'') as MCC_Id,ifnull(MCC_CollectionShift_Id,'') as MCC_CollectionShift_Id,ifnull(Created_On,'') as Created_On ,0,'',''
                from t022_tripdocument_item
                where Org_Id = var_org_id
                and date(Created_On) = date(@Current_Datetime)
                and Route_Id in (Select Route_Id from temp_Route)
                ;
                
                
                update temp_Report_1 tmp1 
                inner join t021_tripdocument_header t021 on
                tmp1.Org_Id = t021.Org_Id
                and date(t021.Created_On) = date(@Current_Datetime)
                and tmp1.TripDocument_Id = t021.TripDocument_Id
                set tmp1.Driver_Id = ifnull(t021.Driver_Id,''),
					tmp1.Vehicle_Id = ifnull(t021.Vehicle_Id,'');
                    
				update temp_Report_1 tmp1 
                inner join t006_milkcollectionagent t006 on
                tmp1.Org_Id = t006.Org_Id
                and tmp1.MCC_Id = t006.MCC_Id
                and tmp1.MCCCollectionShift_Id = t006.MCCCollectionShift_Id
                and date(t006.Created_On) = date(@Current_Datetime)
                inner join t006_milkcollectionagent_item t0061 on
                t0061.Org_Id = t006.Org_Id
                and t0061.AgentCollection_Id = t006.AgentCollection_Id
                set tmp1.Is_Dispatch = '1';
                
                
                update temp_Report_1 tmp
				inner join mu06_driver m6 on tmp.Org_Id = m6.Org_Id 
				and tmp.Driver_Id = m6.Driver_Id
				set tmp.Driver_Name = m6.Driver_Name;
                
                update temp_Report_1 tmp
				inner join m003_vehicle m3 on tmp.Org_Id = m3.Org_Id 
				and tmp.Vehicle_Id = m3.Vehicle_Id
				set tmp.Vehicle_No = m3.Vehicle_No;
                
				Update temp_Report_1 tmp
				inner join m006_route m006 on tmp.Org_Id = m006.Org_Id and tmp.Route_Id = m006.Route_Id
				set tmp.Route_Name = m006.Route_Name,
				tmp.CollectionShift_Id = m006.CollectionShift_Id;
                
                Update temp_Report_1 tmp
				inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
				set tmp.CollectionShift_Name = c015.CollectionShift_Name;
                
                
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
                    
				-- select * from temp_Report_1;
                
                select 'TH' as RowType, 'Route' as Route_Name, 
					'Driver' as Driver_Name,
					'Vehicle No.' as Vehicle_No,
					'Collection Shift' as CollectionShift_Name,
					'MCC Code' as MCC_Code,
					'MCC Name' as MCC_Name,
					'Centre Type' as MCCType_Name,
					'OFF Line / Online' as MCCWorkType_Name,
					'Date' as Created_On,
                    'Status' as Is_Dispatch
                    union all
                    select 'TR' as RowType, 
					ifnull(Route_Name,'') as Route_Name,
					ifnull(Driver_Name,'') as Driver_Name,
					ifnull(Vehicle_No,'') as Vehicle_No,
					ifnull(CollectionShift_Name,'') as CollectionShift_Name,
					ifnull(MCC_Code,'')as MCC_Code,
					ifnull(MCC_Name,'')as MCC_Name,
					ifnull(MCCType_Name,'')as MCCType_Name,
					ifnull(MCCWorkType_Name,'')as MCCWorkType_Name,
					ifnull(DATE_FORMAT(Created_On, '%d %b %Y'),'') AS Created_On,
                    CASE 
						WHEN Is_Dispatch = 1 THEN 'Dispatch' 
						WHEN Is_Dispatch = 0 THEN 'Not Dispatch' 
						ELSE ''
					END AS Is_Dispatch
					from temp_Report_1;
                
                

				end;
            elseif (var_Report_Type = 'C048021') then	
			Begin
					DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;

					SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

					SET SQL_SAFE_UPDATES = 0;


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
					select MCC_Id from m005_mcc where Org_Id = var_org_id ;
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

					drop temporary table if exists temp_MCC_3;
					create temporary table temp_MCC_3(MCC_Id char(255) );
					if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_3 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
					else
					insert into temp_MCC_3 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id ;
					end if;

					drop temporary table if exists temp_MCC_4;
					create temporary table temp_MCC_4(MCC_Id char(255) );
					if (ifnull(var_MCC_Id, '') <> '') then
					set @sql4 = concat('insert into temp_MCC_4 (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt4 from @sql4;
					execute stmt4;
					else
					insert into temp_MCC_4 (MCC_Id)
					select MCC_Id from m005_mcc where Org_Id = var_org_id;
					end if;
                    
                    -- Split Collection Shift
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;


					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),CollectionShift_Id varchar(20),
					MCC_Id varchar(20),Created_On datetime,
					Is_MPPI  varchar(20),Is_GainLoss  varchar(20),Is_Anamat varchar(20),Is_Freight varchar(20),
					Invoice_Id_MPPI  varchar(20),Invoice_Id_GainLoss  varchar(20),Invoice_Id_Anamat varchar(20),Invoice_Id_Freight varchar(20),
					MCC_Name varchar(255),MCC_Code varchar(20),CollectionShift_Name varchar(20),
					MCCType_Id varchar(20), MCCType_Name varchar(50),
					MCCWorkType_Id varchar(20),MCCWorkType_Name varchar(20));

					Insert into temp_Report (Org_Id , MilkCollectionDairy_Id ,CollectionShift_Id ,MCC_Id ,Created_On,
					Is_MPPI  ,Is_GainLoss  ,Is_Anamat ,Is_Freight,
					Invoice_Id_MPPI  ,Invoice_Id_GainLoss  ,Invoice_Id_Anamat ,Invoice_Id_Freight  )				
					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,date(t009.Created_On) as Created_On,
					' - '  ,' - '  ,' - ' ,' - ' ,
					''  ,''  ,'' ,''
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					and m005.MCC_Id in (Select MCC_Id from temp_MCC_4)
					and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_4)
					and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_4)
					group by t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,date(t009.Created_On);


					DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
					CREATE TEMPORARY TABLE temp_Report_1 ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),CollectionShift_Id varchar(20),
					MCC_Id varchar(20),Invoice_Id varchar(20),Created_On datetime);

					Insert into temp_Report_1 (Org_Id , MilkCollectionDairy_Id ,CollectionShift_Id ,MCC_Id ,Invoice_Id,Created_On )	
					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate 
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					and m005.MCC_Id in (Select MCC_Id from temp_MCC)
					and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType)
					and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType)
					and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023002'
					where 
					t0091.MPPIType_Id  in('C047001')

					union all

					select
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate 
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					and m005.MCC_Id in (Select MCC_Id from temp_MCC_1)
					and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_1)
					and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_1)
					and m005.MCCType_Id in('C014003')
					where 
					t0091.MPPIType_Id  in('C047001')

					union all

					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate 
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					and m005.MCC_Id in (Select MCC_Id from temp_MCC_2)
					and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_2)
					and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_2)
					and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023001'
					where 
					t0091.MPPIType_Id  in('C047001')
					and t0091.Org_Id  = var_org_id;


					DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
					CREATE TEMPORARY TABLE temp_Report_2 ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),CollectionShift_Id varchar(20),
					MCC_Id varchar(20),Invoice_Id varchar(20),Created_On datetime);

					Insert into temp_Report_2 (Org_Id , MilkCollectionDairy_Id ,CollectionShift_Id ,MCC_Id ,Invoice_Id,Created_On )	
					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					and m005.MCC_Id in (Select MCC_Id from temp_MCC_3)
					and m005.MCCType_Id in (Select MCCType_Id from temp_MCCType_3)
					and m005.MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType_3)
					and m005.MCCType_Id in('C014001','C014002')
					and m005.MCCWorkType_Id = 'C023002'
					where 
					t0091.MPPIType_Id  in('C047003')
					and t0091.Org_Id  = var_org_id;


					DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
					CREATE TEMPORARY TABLE temp_Report_3 ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),CollectionShift_Id varchar(20),
					MCC_Id varchar(20),Invoice_Id varchar(20),Created_On datetime);

					Insert into temp_Report_3 (Org_Id , MilkCollectionDairy_Id ,CollectionShift_Id ,MCC_Id ,Invoice_Id,Created_On )	
					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate 
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					where 
					t0091.MPPIType_Id  in('C047004')
					and t0091.Org_Id  = var_org_id;


					DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
					CREATE TEMPORARY TABLE temp_Report_4 ( 
					Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),CollectionShift_Id varchar(20),
					MCC_Id varchar(20),Invoice_Id varchar(20),Created_On datetime);

					Insert into temp_Report_4 (Org_Id , MilkCollectionDairy_Id ,CollectionShift_Id ,MCC_Id ,Invoice_Id,Created_On )	
					select 
					t0091.Org_Id,t0091.MilkCollectionDairy_Id,t0091.CollectionShift_Id,t0091.MCC_Id,t0091.Invoice_Id,date(t009.Created_On) as Created_On
					from t009_milkcollectiondairy_mcccommission t0091
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id 
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id 
					AND CAST(t009.Created_On AS DATE) >= var_StartDate
					AND CAST(t009.Created_On AS DATE) <= var_EndDate 
					inner join m005_mcc m005 on m005.MCC_Id = t0091.MCC_Id
					and m005.Org_Id = t0091.Org_Id 
					where 
					t0091.MPPIType_Id  in('C047005')
					and t0091.Org_Id  = var_org_id;

					update temp_Report tmp
					inner join temp_Report_1 tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					and date(tmp.Created_On) = date(tmp.Created_On)
					set Invoice_Id_MPPI = ifnull(tmp1.Invoice_Id,'');

					update temp_Report tmp
					inner join temp_Report_2 tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					and date(tmp.Created_On) = date(tmp.Created_On)
					set Invoice_Id_GainLoss = ifnull(tmp1.Invoice_Id,'');

					update temp_Report tmp
					inner join temp_Report_3 tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					and date(tmp.Created_On) = date(tmp.Created_On)
					set Invoice_Id_Anamat = ifnull(tmp1.Invoice_Id,'');

					update temp_Report tmp
					inner join temp_Report_4 tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.MilkCollectionDairy_Id = tmp1.MilkCollectionDairy_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					and date(tmp.Created_On) = date(tmp.Created_On)
					set Invoice_Id_Freight = ifnull(tmp1.Invoice_Id,'');


					update temp_Report tmp
					inner join t028_invoice_mcc tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.Invoice_Id_MPPI = tmp1.Voucher_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					set tmp.Is_MPPI = CASE 
									WHEN tmp1.SAP_Document_Id IS NULL OR tmp1.SAP_Document_Id = '' THEN 0
									ELSE 1
								END;
								
					update temp_Report tmp
					inner join t028_invoice_mcc tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.Invoice_Id_GainLoss = tmp1.Voucher_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					set tmp.Is_GainLoss = CASE 
									WHEN tmp1.SAP_Document_Id IS NULL OR tmp1.SAP_Document_Id = '' THEN 0
									ELSE 1
								END;
								
					update temp_Report tmp
					inner join t028_invoice_mcc tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.Invoice_Id_Anamat = tmp1.Voucher_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					set tmp.Is_Anamat = CASE 
									WHEN tmp1.SAP_Document_Id IS NULL OR tmp1.SAP_Document_Id = '' THEN 0
									ELSE 1
								END;
								
					update temp_Report tmp
					inner join t028_invoice_mcc tmp1 on
					tmp.Org_Id = tmp1.Org_Id
					and tmp.Invoice_Id_Freight = tmp1.Voucher_Id
					and tmp.MCC_Id = tmp1.MCC_Id
					set tmp.Is_Freight = CASE 
									WHEN tmp1.SAP_Document_Id IS NULL OR tmp1.SAP_Document_Id = '' THEN 0
									ELSE 1
								END;

					-- Update MCCName and MCCCode
					Update temp_Report tmp
					inner join m005_mcc m005 on tmp.Org_Id = m005.Org_Id and tmp.MCC_Id = m005.MCC_Id
					set tmp.MCC_Name = m005.MCC_Name,
					tmp.MCC_Code = m005.MCC_Code,
					tmp.MCCType_Id = m005.MCCType_Id,
					tmp.MCCWorkType_Id = m005.MCCWorkType_Id;


					Update temp_Report tmp
					inner join c014_mcctype c014 on tmp.MCCType_Id = c014.MCCType_Id
					set tmp.MCCType_Name = c014.MCCType_Name;

					Update temp_Report tmp
					inner join c023_mccworktype c023 on tmp.MCCWorkType_Id = c023.MCCWorkType_Id
					set tmp.MCCWorkType_Name = c023.MCCWorkType_Name;

					Update temp_Report tmp
					set tmp.CollectionShift_Id = 'C015003' 
					where tmp.CollectionShift_Id not in ('C015001','C015002');

					Update temp_Report tmp
					inner join c015_collectionshift c015 on tmp.CollectionShift_Id = c015.CollectionShift_Id
					set tmp.CollectionShift_Name = c015.CollectionShift_Name;

					Update temp_Report tmp
					set tmp.Is_MPPI = 'Posted'
					where tmp.Is_MPPI = '1';

					Update temp_Report tmp
					set tmp.Is_MPPI = 'Pending'
					where tmp.Is_MPPI = '0';

					Update temp_Report tmp
					set tmp.Is_GainLoss = 'Posted'
					where tmp.Is_GainLoss = '1';

					Update temp_Report tmp
					set tmp.Is_GainLoss = 'Pending'
					where tmp.Is_GainLoss = '0';

					Update temp_Report tmp
					set tmp.Is_Anamat = 'Posted'
					where tmp.Is_Anamat = '1';

					Update temp_Report tmp
					set tmp.Is_Anamat = 'Pending'
					where tmp.Is_Anamat = '0';

					Update temp_Report tmp
					set tmp.Is_Freight = 'Posted'
					where tmp.Is_Freight = '1';

					Update temp_Report tmp
					set tmp.Is_Freight = 'Pending'
					where tmp.Is_Freight = '0';


					DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;
					CREATE TEMPORARY TABLE temp_Report_Main ( 
					MCC_Code varchar(20),MCC_Name varchar(255),CollectionShift_Name varchar(255),Created_On varchar(255),
					Is_MPPI  varchar(20),Is_GainLoss  varchar(20),Is_Anamat varchar(20),Is_Freight varchar(20),
					MCCType_Name varchar(50),
					MCCWorkType_Name varchar(20),
                    CollectionShift_Id varchar(20));

					Insert into temp_Report_Main (MCC_Code ,MCC_Name ,CollectionShift_Name ,Created_On ,
					Is_MPPI  ,Is_GainLoss  ,Is_Anamat ,Is_Freight,MCCType_Name,MCCWorkType_Name,CollectionShift_Id)	
					select 
					MCC_Code,MCC_Name,CollectionShift_Name, 
					DATE_FORMAT(Created_On, '%d %b %Y') as Created_On,
					Is_MPPI,Is_GainLoss,Is_Anamat,Is_Freight,MCCType_Name,MCCWorkType_Name,CollectionShift_Id
					from temp_Report order by  MCC_Name asc,Created_On asc;

					select 'TH' as RowType, 
					'MCC Code' as MCC_Code, 
					'MCC Name' as MCC_Name,
					'MCC Type Name' as MCCType_Name, 'MCC Work Type Name' as MCCWorkType_Name, 
					'Date' as Created_On,
					'Collection Shift' as CollectionShift_Name,
					'MPPI' as Is_MPPI,'Gain Loss' as Is_GainLoss,'Anamat' as Is_Anamat,'Freight' as Is_Freight
					union all
					select 'TR' as RowType, 
					MCC_Code,MCC_Name, MCCType_Name,MCCWorkType_Name,
					Created_On,
					CollectionShift_Name,
					Is_MPPI,Is_GainLoss,Is_Anamat,Is_Freight
					from temp_Report_Main
                    where CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);

            end;
           
            elseif (var_Report_Type = 'C048014') then 
            
				
				SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id
                        and MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
						-- and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                    end if;
                    
                    
					drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;


						drop temporary table if exists t;
						create temporary table t( txt text );
						insert into t values(ifnull(var_MilkType_Id, ''));

						drop temporary table if exists temp_MilkType;
						create temporary table temp_MilkType(MilkType_Id char(255) );
						set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt2 from @sql2;
						execute stmt2;








		drop temporary table if exists tbldate;
		create temporary table tbldate( 
		date text,
        id int 
		);
        
        set @id = 0;
        
        
insert into tbldate(date , id)
SELECT DATE_ADD(date(@var_StartDate), INTERVAL n DAY) AS date, @id := @id + 1
FROM (
    SELECT n FROM (
        SELECT 
            @row := @row + 1 AS n
        FROM
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t,
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
            (SELECT @row := -1) r  -- Start from -1 to include '2024-12-01'
    ) n
) dates
WHERE DATE_ADD(date(@var_StartDate), INTERVAL n DAY) <= date(@var_EndDate);


/*
SELECT 
    DATE_ADD( @var_StartDate, INTERVAL n DAY) AS date, @id:=@id + 1
FROM
    (SELECT 
        n
    FROM
        (SELECT 
        @row:=@row + 1 AS n
    FROM
        (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t, (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2, (SELECT @row:=- 1) r) n) dates
WHERE
    DATE_ADD( @var_StartDate, INTERVAL n DAY) <=   @var_EndDate;

*/


/*

		IF NOT EXISTS (SELECT 1 FROM tbldate WHERE date = @var_StartDate) THEN

			set @maxid =(select max(id) as id from  tbldate);
			
			INSERT INTO tbldate(date, id)
			VALUES (@var_StartDate, @maxid);
		END IF;

*/




        
		drop temporary table if exists tbldate1;
		create temporary table tbldate1( 
		mcc_code text , 
        average text,
        mcc_rank text,
		mcc_name text,
		mccid text,
		RowType text
		);
            
		insert into tbldate1 ( mcc_code ,  mcc_name , RowType , average , mcc_rank) value ('MCC_CODE' , 'Mcc_Name' , 'TH',
        'Average' , 'MCC_Rank'
        );
        
	
       SET @row_number = 0;
       
        set @COUNT = (select COUNT(*) FROM tbldate );
                    
			while  @row_number < @COUNT DO
             
			set @cname = (select date from tbldate where id = ( @COUNT - @row_number));
                        
			SET @sql = CONCAT('ALTER TABLE tbldate1 ADD COLUMN ', '`' ,  @cname , '`', ' VARCHAR(255)');
            
            
                        
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
            
           
            -- replace((select date from tbldate where id = @row_number ), '''' , '"')
             set @row_number = @row_number + 1;
			
             set @MCC_CODE = 'MCC_CODE';
                          
             SET @sqla = CONCAT('update tbldate1 set ' , '`' , @cname  , '`' , ' = ''' ,  @cname , 
				''' where mcc_code = ''' , @MCC_CODE , '''' );
                
                
			PREPARE stmta FROM @sqla;
			EXECUTE stmta;
			DEALLOCATE PREPARE stmta;

			END WHILE ;
        
          
          
        
        
		drop temporary table if exists T;
		create temporary table T( 
		mcc_id text ,
        id int ,
        mcc_code text,
        mcc_name text ,
        mcc_type text ,
        mcc_worktype text
      
		);
		
       set @idz= 0;
	
 
        insert into T(mcc_id , id , mcc_name , mcc_code , mcc_type ,  mcc_worktype ) 
        select MCC_Id , @idz:=  @idz + 1  , MCC_Name , MCC_Code , MCCType_Id , MCCWorkType_Id
        from m005_mcc WHERE MCCType_Id in (Select MCCType_Id from temp_MCCType)
       and MCC_Id in  (select MCC_ID FROM temp_MCC ) 
		and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType) ;
        

        SET @row_number = 0;
       
       SET @sql = '';
       
        set @COUNT = (select COUNT(*) FROM T );
        
            
			while  @row_number < @COUNT DO
             set @row_number = @row_number + 1;
             
				set @mccid = (select mcc_id from T where id = @row_number );
                set @mcc_type = (select mcc_type from T where id = @row_number );
                set @mcc_worktype = (select mcc_worktype from T where id = @row_number );
             set  @avgcollection =0;
             set  @avgcount = 0 ;
					SET @row_number1 = 0;

					SET @sql1 = '';
                    
					set @COUNT1 = (select COUNT(*) FROM tbldate );

					while  @row_number1 < @COUNT1 DO
					set @row_number1 = @row_number1 + 1;
				--	SET  @avgcount =  @avgcount + 1;

					set @Ndate = (select date from tbldate where id =  @row_number1);
					
                    
			if ( @mcc_type in ('C014001' , 'C014002 ') and @mcc_worktype = 'C023002' ) then
			         
				
                /*
				set @collection = (select sum(Quantity_Ltr) from t005_milkcollectionfarmer a
                inner join t004_mcccollectionshift b on a.MCCCollectionShift_Id = b.MCCCollectionShift_Id where 
				a.MCC_Id =  @MccId  and date(a.Created_On) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  b.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
				);
                
                set @avgcollection = (select avg(a.Quantity_Ltr) from t005_milkcollectionfarmer a
                inner join t004_mcccollectionshift b on a.MCCCollectionShift_Id = b.MCCCollectionShift_Id where 
				a.MCC_Id =  @MccId  and date(a.Created_On) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  b.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
                and a.Quantity_Ltr > 0
				);
                
                
                */
                
                set @collection = (select sum(Dairy_Quantity_Ltr) from f010_milkcollectionmcc_final where 
				MCC_Id =  @MccId  and date(Collection_Date) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  ifnull(CollectionShift_Id , 'C015003') in (select CollectionShift_Id from temp_CollectionShift ));
            
            set @avgcollection =  @avgcollection +  IFNULL(@collection, 0);
	   
		
			ELSE 
				
                set @collection =  (select sum(Dairy_Quantity_Ltr) from f010_milkcollectionmcc_final where 
				MCC_Id =  @MccId  and date(Collection_Date) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  ifnull(CollectionShift_Id , 'C015003') in (select CollectionShift_Id from temp_CollectionShift ));
            
               set @avgcollection =  @avgcollection +  IFNULL(@collection, 0);
	
            
			End if ;
                    
                    
                   if( @collection is null or  @collection = '') then
					
                    set  @collection = 0;
                    
                   end if ;
                   
                   
					
					if ( @collection <> 0) then
					SET @avgcount = @avgcount + 1;
					END if;
 
	
				if exists (select 1 from tbldate1 where mccid = @mccid  ) then
				
				
				
				SET @sql = CONCAT('update tbldate1 set ' , '`' , @Ndate , '`' , ' = ' ,  @collection , 
				' where mccid = ''' , @MccId , '''' );
				
                
                update tbldate1
                set average = ROUND(IFNULL(@avgcollection, 0), 2) / if(@avgcount=0 , 1 , @avgcount) 
                where mccid = @MccId; 
                
                
					
            else 
                    
                    set @mcc_code = (select mcc_code  from T where mcc_id = @MccId ) ;
                    set @mcc_name = (select mcc_name  from T where mcc_id = @MccId ) ;
                    
					SET @sql = CONCAT('insert into tbldate1 ( mcc_code , RowType ,  mcc_name ,  mccid , `' ,  @Ndate , '` ) value ' , '( ''' , 
					@mcc_code , ''' , '''  , 'TR' , ''' , ''' ,  @mcc_name , ''' , ''' , 
					@MccId  , '''' , ' , ''' ,'' ,  @collection , ''' )' );
                     
                    
					
                     end if;
                     
				
					PREPARE stmt FROM @sql;
					EXECUTE stmt;
					DEALLOCATE PREPARE stmt;
                    
					
					 update tbldate1
                set average = ROUND(IFNULL(@avgcollection, 0), 2)/if(@avgcount=0 , 1 , @avgcount) 
                where mccid = @MccId;
					
    
					END WHILE ;


			END WHILE ;
			
			drop temporary table if exists tbldate12;
			create temporary table tbldate12 LIKE tbldate1;
			ALTER TABLE tbldate12 MODIFY COLUMN average DECIMAL(30,2);
				ALTER TABLE tbldate12 MODIFY COLUMN mcc_rank int;
		
		
			INSERT INTO  tbldate12 SELECT * FROM tbldate1 WHERE mcc_code <> 'mcc_code';
		
			
            set @mccrank = 0;
            
            update tbldate12
           set mcc_rank = @mccrank := @mccrank + 1
           order by average desc;
            
            delete FROM tbldate1 WHERE mcc_code <> 'mcc_code';
            
            
            
            INSERT INTO  tbldate1 SELECT * FROM tbldate12 ORDER BY mcc_rank asc;
		 
            
			ALTER TABLE tbldate1
			DROP COLUMN MCCID;
		
        select * from tbldate1;
		
        drop temporary table if exists tbldate1;
                
            else
            
				begin
                
					SELECT var_Org_Id AS Org_Id, var_Method_Name AS Method_Name, var_Report_Type AS Report_Type, var_MCCType_Id AS MCCType_Id, var_ReportPeriod AS ReportPeriod,
					var_MCCCollectionShift_Id AS MCCCollectionShift_Id, var_MilkType_Id AS MilkType_Id, var_MCC_Id AS MCC_Id, var_Report_Type as Report_Type;
                end;
                
			END if;

		END;
	
	elseif (var_Method_Name = 'GetRate') then
		begin
			
            set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
			
            select 'TH' as RowType, 
            'Chart Name' as Chart_Name,
            'Base FAT' as Base_FAT,'Base SNF' as Base_SNF,'Rate' as Amount,
			'Rate Assgin Date' as Item_Applicable_Date,
            'MCC Assgin Date' as Header_Applicable_Date 
			union all
						
			select 'TR' as RowType,
			m001.Chart_Name,f001.Base_FAT,f001.Base_SNF,f001.Amount,
			DATE_FORMAT(f001.Item_Applicable_Date, '%d %b %Y %h:%i %p') as Item_Applicable_Date,
			DATE_FORMAT(f001.Header_Applicable_Date, '%d %b %Y %h:%i %p') as Header_Applicable_Date
			from f001_milk_rate f001
			inner join m001_milkrate m001 on
			m001.Org_Id = f001.Org_Id
			and m001.Chart_Id = f001.Chart_Id
			where f001.Org_Id = var_org_id
			and f001.MCC_Id = var_MCC_Id
			and f001.CollectionShift_Id = var_MCCCollectionShift_Id
			and f001.MilkType_Id = var_MilkType_Id
			and f001.MilkRateEntryType_Id = var_Report_Type
            and date(Item_Applicable_Date) <= date(@Current_Datetime)
			and date(Header_Applicable_Date) <= date(@Current_Datetime);
            
        end;
	elseif (var_Method_Name = 'GetSlab') then
		begin
			
            set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
        
			select 'TH' as RowType, 
            'Chart Name' as Chart_Name,
            'Slab' as Slab_Name,'Rate' as Amount,
			'Rate Assgin Date' as Item_Applicable_Date,
            'MCC Assgin Date' as Header_Applicable_Date 
			union all
						
			select 'TR' as RowType,
			m001.Chart_Name,
			m014.Slab_Name,f001.Amount,
			DATE_FORMAT(f001.Item_Applicable_Date, '%d %b %Y %h:%i %p') as Item_Applicable_Date,
			DATE_FORMAT(f001.Header_Applicable_Date, '%d %b %Y %h:%i %p') as Header_Applicable_Date
			from f001_milk_rate f001
			inner join m001_milkrate m001 on
			m001.Org_Id = f001.Org_Id
			and m001.Chart_Id = f001.Chart_Id
			inner join m014_slab m014 on
			m014.Org_Id = f001.Org_Id
			and m014.Slab_Id = f001.Slab_Id
			where f001.Org_Id = var_org_id
			and f001.MCC_Id = var_MCC_Id
			and f001.CollectionShift_Id = var_MCCCollectionShift_Id
			and f001.MilkType_Id = var_MilkType_Id
			and f001.MilkRateEntryType_Id = var_Report_Type
            and date(Item_Applicable_Date) <= date(@Current_Datetime)
			and date(Header_Applicable_Date) <= date(@Current_Datetime);

        end;
	elseif (var_Method_Name = 'GetCommission') then
		begin
			
            set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
        
			select 'TH' as RowType, 
            'MPPI Name' as Chart_Name,
            'MCC Assgin Date' as Applicable_Date 
			union all
						
			select 'TR' as RowType,
            m002.MPPI_Name,DATE_FORMAT(m0021.Applicable_Date, '%d %b %Y %h:%i %p') as Applicable_Date 
			from m002_commission_mcc m0021
			inner join m002_commission m002 on
			m002.Org_Id = m0021.Org_Id
			and m002.MPPI_Id = m0021.MPPI_Id
			and m002.MPPIType_Id = m0021.MPPIType_Id
            and m002.MilkType_Id = var_MilkType_Id
			where m0021.Org_Id = var_org_id
			and m0021.MCC_Id = var_MCC_Id
			and m0021.MPPIType_Id = var_Report_Type
			and date(m0021.Applicable_Date) <= date(@Current_Datetime);

        end;
	elseif (var_Method_Name = 'CurrentGetRate') then
		begin
			
            SET SQL_SAFE_UPDATES = 0;


			set @Current_Datetime = (SELECT CONVERT_TZ(var_ReportPeriod, '+00:00', '+00:00'));
			set @Chart_Id =(select Chart_Id from f001_milk_rate 
							where Org_Id= var_org_id
							and date(Item_Applicable_Date) <= date(@Current_Datetime)
							and date(Header_Applicable_Date) <= date(@Current_Datetime)
							and MCC_Id = var_MCC_Id
							and MilkType_Id = var_MilkType_Id
							and CollectionShift_Id = var_MCCCollectionShift_Id
							order by Item_Applicable_Date desc ,Header_Applicable_Date desc
							limit 1);

			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkRateEntryType_Id varchar(20),Slab_Id varchar(20),
			BaseFat decimal(30,2), BaseSNF decimal(30,2), Version_No varchar(20), Amount decimal(30,2),
			MilkRateEntryType_Name longtext,Slab_Name longtext);

			insert into temp_Report (Org_Id,MilkRateEntryType_Id,Slab_Id,BaseFat,BaseSNF,Version_No)
			select 
			Org_Id,
			MilkRateEntryType_Id,
			ifnull(Slab_Id,'') as Slab_Id,
			BaseFat,
			BaseSNF,
			max(Version_No) as Version_No 
			from m001_milkrate_item
			where Org_Id= var_org_id
			and Chart_Id = @Chart_Id
			and date(Applicable_Date) <= date(@Current_Datetime)
			group by Org_Id,MilkRateEntryType_Id,Slab_Id,BaseFat,BaseSNF
			order by MilkRateEntryType_Id;

			Update temp_Report tmp
			inner join m001_milkrate_item m001 
			on tmp.Org_Id = m001.Org_Id
			and m001.Chart_Id = @Chart_Id
			and tmp.MilkRateEntryType_Id = m001.MilkRateEntryType_Id
			and ifnull(tmp.Slab_Id,'') = ifnull(m001.Slab_Id,'')
			and tmp.Version_No = m001.Version_No
			set tmp.Amount = m001.Amount;

			Update temp_Report tmp
			inner join c012_milkrateentrytype c012 on
			c012.MilkRateEntryType_Id = tmp.MilkRateEntryType_Id
			set tmp.MilkRateEntryType_Name = c012.MilkRateEntryType_Name;

			Update temp_Report tmp
			inner join m014_slab m014 on
			m014.Org_Id = tmp.Org_Id
			and m014.Slab_Id = tmp.Slab_Id
			set tmp.Slab_Name = m014.Slab_Name;
            
            set @Chart_Name  = (select Chart_Name from m001_milkrate where Org_Id = var_org_id
					and Chart_Id = @Chart_Id limit 1);

			select 'TH' as RowType, 
            'Chart Name' as Chart_Name,
			'Rate Type' as MilkRateEntryType_Name,
			'Slab Name' as Slab_Name,
			'Base Fat' as BaseFat,
			'Base SNF' as BaseSNF,
			'Amount' as Amount

			union all
					
			select 'TR' as RowType,
            @Chart_Name as Chart_Name,
			MilkRateEntryType_Name,
			ifnull(Slab_Name,'') as Slab_Name,
			ifnull(BaseFat,'') as BaseFat,
			ifnull(BaseSNF,'') as BaseSNF,
			Amount
			from temp_Report;
            
        end;
	END if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
