-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `test_2` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `test_2`(
    IN `var_org_id` VARCHAR(10),
    IN `var_MCCType_Id` TEXT,
    IN `var_ReportPeriod` VARCHAR(50),
    IN `var_MCC_Id` TEXT,
    IN `var_MCCWorkType_Id` TEXT
)
BEGIN
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
    
    
    
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
