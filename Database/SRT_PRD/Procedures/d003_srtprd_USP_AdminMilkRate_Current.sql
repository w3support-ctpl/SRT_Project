-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate_Current` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate_Current`(
Var_Org_Id varchar(10)
)
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	delete from f002_milk_rate_current where Org_Id = Var_Org_Id;
    
	insert into f002_milk_rate_current (Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id,Chart_Id,MilkRateEntryType_Id,Slab_Id,
    Item_Version_No, Header_Version_No,  Amount,  Base_FAT , Base_SNF , Item_Applicable_Date , Header_Applicable_Date)
    select f001.Org_Id, f001.MCC_Id, f001.MilkType_Id, f001.CollectionShift_Id, f001.Chart_Id,
     f001.MilkRateEntryType_Id, f001.Slab_Id,
	f001.Item_Version_No,  f001.Header_Version_No,   f001.Amount, 
	 f001.Base_FAT ,  f001.Base_SNF ,  f001.Item_Applicable_Date ,  f001.Header_Applicable_Date
    from f001_milk_rate f001 inner join (
	select tbl_1.Org_Id , tbl_1.MCC_Id , tbl_1.MilkType_Id, tbl_2.CollectionShift_Id , tbl_2.Chart_Id , tbl_1.MilkRateEntryType_Id , 
    tbl_2.Slab_Id , tbl_2.Item_Applicable_Date as Item_Applicable_Date, tbl_1.Header_Applicable_Date as Header_Applicable_Date
    from (select Org_Id ,
	MCC_Id , MilkType_Id ,CollectionShift_Id ,Chart_Id ,MilkRateEntryType_Id ,Slab_Id , max(Header_Applicable_Date)  as Header_Applicable_Date
	from f001_milk_rate  where Header_Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
	group by Org_Id ,
	MCC_Id , MilkType_Id ,CollectionShift_Id ,Chart_Id ,MilkRateEntryType_Id ,Slab_Id ) tbl_1 inner join 
	( select Org_Id ,
	MCC_Id , MilkType_Id ,CollectionShift_Id ,Chart_Id ,MilkRateEntryType_Id ,Slab_Id , max(Item_Applicable_Date)  as Item_Applicable_Date
	from f001_milk_rate  where Item_Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
	group by Org_Id ,
	MCC_Id , MilkType_Id ,CollectionShift_Id ,Chart_Id ,MilkRateEntryType_Id ,Slab_Id ) tbl_2 on 
    tbl_1.Org_Id = tbl_2.Org_Id and tbl_1.MCC_Id = tbl_2.MCC_Id and tbl_1.MilkType_Id = tbl_2.MilkType_Id and
    tbl_1.CollectionShift_Id= tbl_2.CollectionShift_Id and tbl_1.Chart_Id = tbl_2.Chart_Id and tbl_1.MilkRateEntryType_Id = tbl_1.MilkRateEntryType_Id and
    ifnull(tbl_1.Slab_Id, 0) = ifnull(tbl_2.Slab_Id,0) ) f001_a on 
	f001.Org_Id = f001_a.Org_Id and f001.MCC_Id = f001_a.MCC_Id and f001.MilkType_Id = f001_a.MilkType_Id and
    f001.CollectionShift_Id= f001_a.CollectionShift_Id and f001.Chart_Id = f001_a.Chart_Id and f001.MilkRateEntryType_Id = f001.MilkRateEntryType_Id and
    ifnull(f001.Slab_Id,0) = ifnull(f001_a.Slab_Id,0) and f001.Item_Applicable_Date = f001_a.Item_Applicable_Date and
    f001.Header_Applicable_Date = f001_a.Header_Applicable_Date 
    where f001_a.Org_Id = Var_Org_Id;
    
    
    
    /*
    update f002_milk_rate_current f002 
    inner join m005_mcc m005 on f002.MCC_Id = m005.MCC_Id
    set f002.CollectionShift_Id = 'C015003' 
    where m005.MCCType_Id = 'C014003' and  m005.Org_Id  = Var_Org_Id ;
    */
    
   if ( (select minute(now())) % 5 < 2 ) then 
	
	drop temporary table if exists temp_tbl;

	create Temporary table temp_tbl(
	id int AUTO_INCREMENT PRIMARY KEY,
	Chart_id varchar(20) 
    );
    
    insert into temp_tbl(Chart_id)
    select Chart_Id from m001_milkrate
    where Org_Id = Var_Org_Id;
    
    
	set @k = 1 ;
    set @chartidcount = (select count(*) from m001_milkrate);
    
    while @k <= @chartidcount do 
        
	set @chart_id = (select Chart_id from temp_tbl where id = @k);
    
    call USP_AdminUpdateMilkRate_Chart('Update_MilkRateChart', Var_Org_Id, @chart_id);
    
	set @k = @k + 1;
    
    end while ;
    
 end if ;
        
    

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
