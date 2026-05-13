-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `Test_One` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `Test_One`(
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
			if (var_Report_Type = 'Get') then
				Begin
					
                    DECLARE var_StartDate DATE;
					DECLARE var_EndDate DATE;
                    DECLARE var_MusterStart DATE;
					DECLARE var_MusterEnd DATE;
                    
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
                    
                    /*
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
                    
                    */
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Collection_Date varchar(20), MilkCollectionShift_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(100), MCC_Code varchar(20),
                    CollectionShift_Id varchar(20), CollectionShift_Name varchar(20), MilkType_Id varchar(20), MilkType_Name varchar(20), 
                    MilkRate decimal(8,2), MilkPrice decimal(20,2), 
                    Farmer_Quantity_Ltr decimal(18,3), Farmer_Fat decimal(18,1), Farmer_SNF decimal(18,1), 
                    MCCType_Id varchar(20), MCCType_Name varchar(20), Is_InvoiceCreated int, MCCWorkType_Id varchar(20), 
                    Farmer_Id varchar(20), Farmer_Name varchar(100), Farmer_Code varchar(20), MCC_Farmer_Code varchar(20));
                    
                    
                    -- insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
					-- MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
										
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
					and t5.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and t5.MCC_Id in (Select MCC_Id from temp_MCC);
	
	               -- select * from temp_Report; 
                   
					-- insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
					-- MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
										
					select f010.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), '', f010.MCC_Id, f010.CollectionShift_Id,
					f010.MilkType_Id, MilkRate, MilkPrice, Dairy_Quantity_Ltr,
					Roundoff('Quality', Dairy_Fat) ,
					Roundoff('Quality', Dairy_SNF), 0, f010.MCC_Id 
					from f010_milkcollectionmcc_final f010
					inner join m005_mcc m5 on m5.Org_Id = f010.Org_Id and m5.MCC_Id = f010.MCC_Id
					where f010.Org_Id = var_org_id
					and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
					and m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003'
					and f010.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f010.MCC_Id in (Select MCC_Id from temp_MCC);

					-- select * from temp_Report;

					-- insert into temp_Report (Org_Id, Collection_Date, MilkCollectionShift_Id, MCC_Id, CollectionShift_Id,
					-- MilkType_Id, MilkRate, MilkPrice, Farmer_Quantity_Ltr, Farmer_Fat, Farmer_SNF, Is_InvoiceCreated, Farmer_Id)
										
					select f010.Org_Id, DATE_FORMAT(Collection_Date, '%d %b %Y'), '', f010.MCC_Id, f010.CollectionShift_Id,
					f010.MilkType_Id, MilkRate, MilkPrice, Dairy_Quantity_Ltr,
					Roundoff('Quality', Dairy_Fat) ,
					Roundoff('Quality', Dairy_SNF), 0, f010.MCC_Id 
					from f010_milkcollectionmcc_final f010
					inner join m005_mcc m5 on m5.Org_Id = f010.Org_Id and m5.MCC_Id = f010.MCC_Id
					where f010.Org_Id = var_org_id
					and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
					and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
					and m5.MCCType_Id = 'C014003'
					and f010.MilkType_Id in (Select MilkType_Id from temp_MilkType)
					and f010.MCC_Id in (Select MCC_Id from temp_MCC);
                    
                    
                    -- select * from temp_Report;
                    
					
				end;
			end if;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
