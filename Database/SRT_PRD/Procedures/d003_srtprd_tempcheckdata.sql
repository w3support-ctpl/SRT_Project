-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `tempcheckdata` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `tempcheckdata`()
BEGIN
		DROP TEMPORARY TABLE IF EXISTS temp_Report;
		CREATE TEMPORARY TABLE temp_Report ( 
		Org_Id varchar(20), Farmer_Id varchar(20), MCC_Id varchar(20),  
        Quantity_Ltr_Not_In decimal(30,3),Amount_Not_In decimal(30,3),
        Quantity_Ltr_In decimal(30,3),Amount_In decimal(30,3),
        MusterCycle_StartDate varchar(50), MusterCycle_EndDate varchar(50)
        );
		  
		Insert into temp_Report (
         Org_Id,Farmer_Id,MCC_Id,Quantity_Ltr_Not_In,Amount_Not_In,
         MusterCycle_StartDate,MusterCycle_EndDate)
		select 
        t005.Org_Id,
		t005.Farmer_Id, 
		t005.MCC_Id,
		sum(t005.Quantity_Ltr),
		sum(t005.Amount),
		t005.MusterCycle_StartDate,
		t005.MusterCycle_EndDate
		from t005_milkcollectionfarmer t005
		inner join m005_mcc m005 on
		m005.Org_Id = t005.Org_Id
		and m005.MCC_Id = t005.MCC_Id
		and m005.MCCType_Id  in ('C014001','C014002')
		and m005.MCCWorkType_Id in ('C023002')
		where t005.Org_Id ='C005'
		and t005.MCCCollectionShift_Id not in (select t004.MCCCollectionShift_Id from t004_mcccollectionshift t004 where t004.MCC_Id = t005.MCC_Id)
		group by 
		t005.Farmer_Id, 
		t005.MCC_Id,
		t005.MusterCycle_StartDate,
		t005.MusterCycle_EndDate;
        
        
        Update temp_Report tmp
		set tmp.Quantity_Ltr_In = (
									select 
									sum(t005.Quantity_Ltr)
									from t005_milkcollectionfarmer t005
									where t005.MCCCollectionShift_Id in (select t004.MCCCollectionShift_Id from t004_mcccollectionshift t004 where t004.MCC_Id = t005.MCC_Id)
									and tmp.Org_Id = t005.Org_Id
                                    and tmp.Farmer_Id = t005.Farmer_Id
									and tmp.MCC_Id = t005.MCC_Id
									and tmp.MusterCycle_StartDate = t005.MusterCycle_StartDate
									and tmp.MusterCycle_EndDate = t005.MusterCycle_EndDate
									),
			Amount_In = (
						select 
						sum(t005.Amount)
						from t005_milkcollectionfarmer t005
						where t005.MCCCollectionShift_Id in (select t004.MCCCollectionShift_Id from t004_mcccollectionshift t004 where t004.MCC_Id = t005.MCC_Id)
						and tmp.Org_Id = t005.Org_Id
                        and tmp.Farmer_Id = t005.Farmer_Id
						and tmp.MCC_Id = t005.MCC_Id
						and tmp.MusterCycle_StartDate = t005.MusterCycle_StartDate
						and tmp.MusterCycle_EndDate = t005.MusterCycle_EndDate
						);
		select * from temp_Report;
        
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
