-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate_Auto` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate_Auto`(
Var_Org_Id varchar(10)
)
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	drop temporary table if exists temp_tbl;
    
	create Temporary table temp_tbl(
    Org_Id varchar(20) ,   
    CollectionShift_Id varchar(20) ,
    MilkType_Id varchar(20) ,
    Chart_Id varchar(20) not null ,
    MilkRateEntryType_Id varchar(20), 
    Slab_Id varchar(20),
    Applicable_Date varchar(20));


	-- Is_Lived add karayacha ahe where madhe 
    
	insert into temp_tbl(Org_Id ,CollectionShift_Id,MilkType_Id ,Chart_Id, MilkRateEntryType_Id ,  Slab_Id , Applicable_Date  ) 
	select m0012.Org_Id ,  CollectionShift_Id ,MilkType_Id , m0012.Chart_Id , MilkRateEntryType_Id, Slab_Id ,  Applicable_Date
    from m001_milkrate m001 inner join m001_milkrate_item m0012 on m001.Org_Id = m0012.Org_Id and m001.Chart_Id = m0012.Chart_Id 
    where m001.Org_Id = Var_Org_Id and m001.Is_Lived = 1 and m001.Is_Active = 1;
    
	delete from f001_milk_rate where Org_Id = Var_Org_Id;

    insert into f001_milk_rate (Org_Id,MCC_Id,MilkType_Id,CollectionShift_Id,Chart_Id,MilkRateEntryType_Id,Slab_Id,
    Item_Version_No, Header_Version_No,  Amount, Item_Applicable_Date , Header_Applicable_Date, Base_FAT , Base_SNF)
	select Var_Org_Id , m002_mci.MCC_Id , temp.MilkType_Id, temp.CollectionShift_Id, m001_mi.Chart_Id, m001_mi.MilkRateEntryType_Id, 
    m001_mi.Slab_Id , m001_mi.Version_No, m001_mch.Version_No,  m001_mi.Amount ,m001_mi.Applicable_Date , m001_mch.Applicable_Date, 
    m001_mi.BaseFat , m001_mi.BaseSNF from temp_tbl temp     
    inner join m001_milkrate_item m001_mi on temp.Org_Id = m001_mi.Org_Id and temp.Chart_Id = m001_mi.Chart_Id and     
    temp.MilkRateEntryType_Id = m001_mi.MilkRateEntryType_Id and ifnull(temp.Slab_Id,1) = ifnull(m001_mi.Slab_Id,1)    
    and temp.Applicable_Date = m001_mi.Applicable_Date     
    inner join m001_milkrate_mcc_header m001_mch 
    on m001_mch.Org_Id = m001_mi.Org_Id and m001_mch.Chart_Id = m001_mi.Chart_Id 
    inner join m001_milkrate_mcc_item m002_mci on m002_mci.Org_Id = m001_mch.Org_Id and m002_mci.Chart_Id = m001_mch.Chart_Id and 
    m002_mci.Version_No = m001_mch.Version_No 
	where temp.Org_Id = Var_Org_Id and m001_mi.Is_Deleted = 0;
    
    
    call USP_AdminMilkRate_Current(Var_Org_Id);
	

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
