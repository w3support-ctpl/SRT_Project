-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_Test` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_Test`(
	IN `var_org_id` VARCHAR(10),
	IN `var_Method_Name` VARCHAR(20),
	IN `var_Report_Type` VARCHAR(50),
	IN `var_MCCType_Id` text,
	IN `var_ReportPeriod` VARCHAR(50),
	IN `var_MCCCollectionShift_Id` text,
	IN `var_MilkType_Id` text,
	IN `var_MCC_Id` text,
    IN var_MCCWorkType_Id text
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id and Is_Active = 1
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
                    inner join t009_milkcollectiondairy_posting t009 on tmp.Org_Id = t009.Org_Id and tmp.MCC_Id = t009.MCC_Id
                    and t009.MilkCollectionPosting_Id = tmp.MilkCollectionPosting_Id
                    set tmp.MilkRate = t009.Rate,
                    tmp.MilkPrice = t009.MilkPrice,
                    tmp.AgentCost = t009.AgentCost
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
                    set tmp.MPPIRate = t9.BaseRate ;
                    
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id and Is_Active = 1;
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
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionShift_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), 
                    MilkRate decimal(8,2), MilkPrice decimal(20,2), 
                    Farmer_Quantity_Ltr decimal(18,3), Farmer_Fat decimal(18,1), Farmer_SNF decimal(18,1), 
                    MCCType_Id varchar(20), MCCType_Name varchar(20), Is_InvoiceCreated int, MCCWorkType_Id varchar(20), 
                    Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20), MCC_Farmer_Code varchar(20));
                    
                    insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
                    MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
                    
                    select t5.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), t5.MCCCollectionShift_Id, t5.MCC_Id, t4.CollectionShift_Id,
					t5.MilkType_Id, ApplicableRate, Amount, Quantity_Ltr,
                    Roundoff('Quality', Fat) ,
                    Roundoff('Quality', SNF), Is_InvoiceCreated, Farmer_Id 
					from t005_milkcollectionfarmer t5 
                    inner join t004_mcccollectionshift t4 on t5.Org_Id = t4.Org_Id and t5.MCCCollectionShift_Id = t4.MCCCollectionShift_Id 
                    inner join m005_mcc m5 on m5.Org_Id = t5.Org_Id and m5.MCC_Id = t5.MCC_Id
                    where t5.Org_Id = var_org_id
                    and CAST(t4.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(t4.Collection_Date  AS DATE)  <= var_EndDate
                    and MilkStatus_Id = 'C016001'
                    and m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003'
                    and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType)
                    and t5.MCC_Id in (Select MCC_Id from temp_MCC);
					
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
                    Is_PostedInSAP, 
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
					VehicleAverage_KM decimal(18,2)
                    );
                    
                    insert into temp_Report (Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    Trip_Date, FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    TripAmount, DieselRateDiff, FinalAmount, Is_PostedInSAP, Liters,
                    Average_KM,Diesel_Difference,Driver_Id)
                    select Org_Id, TripDocument_Id, Route_Trip_Id, Transporter_Id, Vehicle_Id, 
                    -- DATE_FORMAT(Created_On, '%d %b %Y') as Created_On
                    Created_On
                    , FreightRateType_Id, Rate, FinalDistance, DieselBaseRate, CurrentDieselRate,
                    Cost, 
                    case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end as DieselRateDiff, 
                    Cost + (case when Average_KM <> 0 then ROUND((((IFNULL(FinalDistance, 0) / IFNULL(Average_KM ,0)) * IFNULL(Diesel_Difference,0))), 2) else 0 end) as Total_Freight,  
                    Is_PostedInSAP, 
                    Roundoff('QuantityForDairy', (ifnull(Liters,0))) as Liters ,
                    Average_KM,Diesel_Difference,Driver_Id
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
                    'Average Diff' as  Average_Diff
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
                    round((Average_KM - VehicleAverage_KM),2) as  Average_Diff
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id and Is_Active = 1;
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
                        select MCC_Id from m005_mcc where Org_Id = var_org_id and Is_Active = 1
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


					select * from temp_MilkType;
                    select * from temp_CollectionShift;
                    select * from temp_MCC;

		drop temporary table if exists tbldate;
		create temporary table tbldate( 
		date text,
        id int 
		);
        
        set @id = 0;
        
        
insert into tbldate(date , id)

SELECT DATE_ADD(  @var_StartDate , INTERVAL n DAY) AS date , @id:=  @id + 1
FROM (
    SELECT n FROM (
        SELECT 
            @row := @row + 1 AS n
        FROM
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t,
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
            (SELECT @row := 0) r
    ) n
) dates
WHERE DATE_ADD(  @var_StartDate , INTERVAL n DAY) <=  @var_EndDate;
        
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
        from m005_mcc WHERE Is_Active = 1
		and MCCType_Id in (Select MCCType_Id from temp_MCCType)
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
             
					SET @row_number1 = 0;

					SET @sql1 = '';
                    
					set @COUNT1 = (select COUNT(*) FROM tbldate );

					while  @row_number1 < @COUNT1 DO
					set @row_number1 = @row_number1 + 1;

					set @Ndate = (select date from tbldate where id =  @row_number1 );
                    
                    select 1;
                    
			if ( @mcc_type in ('C014001' , 'C014002 ') and @mcc_worktype = 'C023002' ) then
			            
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
			
			ELSE 
				
                set @collection = (select sum(Agent_Quantity_Ltr) from f010_milkcollectionmcc_final where 
				MCC_Id =  @MccId  and date(Collection_Date) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  ifnull(CollectionShift_Id , 'C015003') in (select CollectionShift_Id from temp_CollectionShift ));
            
              set @avgcollection = (select avg(Agent_Quantity_Ltr) from f010_milkcollectionmcc_final where 
				MCC_Id =  @MccId  and date(Collection_Date) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  ifnull(CollectionShift_Id , 'C015003') in (select CollectionShift_Id from temp_CollectionShift )
                and Agent_Quantity_Ltr > 0);
	
            
			End if ;
                    
                    
                   if( @collection is null or  @collection = '') then
					
                    set  @collection = 0;
                    
                   end if ;
                   
	
				if exists (select 1 from tbldate1 where mccid = @mccid  ) then 
				
				SET @sql = CONCAT('update tbldate1 set ' , '`' , @Ndate , '`' , ' = ' ,  @collection , 
				' where mccid = ''' , @MccId , '''' );
                
                update tbldate1
                set average = @avgcollection 
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
                    
					END WHILE ;


			END WHILE ;
		
			
            set @mccrank = 0;
            
            update tbldate1
           set average = @mccrank := @mccrank + 1
           order by average desc;
            
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
	
	END if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
