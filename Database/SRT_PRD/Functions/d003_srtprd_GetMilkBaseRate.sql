-- Function Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP FUNCTION IF EXISTS `GetMilkBaseRate` ;;
CREATE DEFINER=`appuser`@`%` FUNCTION `GetMilkBaseRate`(
	var_Org_Id varchar(20),
	var_MCC_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_Date varchar(50), 
    var_MilkType_Id varchar(20)
) RETURNS varchar(45) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	declare var_Chart_Id varchar(20);
	set @MCCType_Id = (select MCCType_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id);


	if(@MCCType_Id = 'C014001') then
		set var_Chart_Id = (select m0011.Chart_Id from m001_milkrate_mcc_header m0011 
		inner join m001_milkrate_mcc_item m0012 on
			m0011.Org_Id = m0012.Org_Id 
			and m0011.Chart_Id = m0012.Chart_Id 
            and m0011.Version_No = m0012.Version_No 
			and m0012.MCC_Id = var_MCC_Id
		inner join m001_milkrate m001 on
			m0011.Org_Id = m001.Org_Id 
			and m0011.Chart_Id = m001.Chart_Id
            and m001.MilkType_Id = var_MilkType_Id
            and m001.CollectionShift_Id = var_CollectionShift_Id
		where m0011.Org_Id =  var_Org_Id
		and m0011.Applicable_Date <= var_Date
		-- group by  m0011.Chart_Id
		order by m0011.Applicable_Date desc, m0011.Version_No desc,m0012.Version_No desc
		limit 1);
    else
		set var_Chart_Id = (select m0011.Chart_Id from m001_milkrate_mcc_header m0011 
		inner join m001_milkrate_mcc_item m0012 on
			m0011.Org_Id = m0012.Org_Id 
			and m0011.Chart_Id = m0012.Chart_Id
            and m0011.Version_No = m0012.Version_No 
			and m0012.MCC_Id = var_MCC_Id
		inner join m001_milkrate m001 on
			m0011.Org_Id = m001.Org_Id 
			and m0011.Chart_Id = m001.Chart_Id
            and m001.MilkType_Id = var_MilkType_Id
		where m0011.Org_Id =  var_Org_Id
		and m0011.Applicable_Date <= var_Date
		-- group by  m0011.Chart_Id
		order by m0011.Applicable_Date desc, m0011.Version_No desc,m0012.Version_No desc
		limit 1);
    end if;
    
	
RETURN var_Chart_Id;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
