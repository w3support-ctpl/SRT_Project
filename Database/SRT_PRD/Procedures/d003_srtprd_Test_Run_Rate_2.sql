-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `Test_Run_Rate_2` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `Test_Run_Rate_2`()
BEGIN
	SET SQL_SAFE_UPDATES = 0;

    DROP TEMPORARY TABLE IF EXISTS temp_Report;
    
    CREATE TEMPORARY TABLE temp_Report ( 
	Org_Id varchar(20), MCC_Id varchar(20), Fat decimal(18,3),SNF decimal(18,3),rate decimal(18,3));
    
    
	 insert into temp_Report (
     Org_Id,MCC_Id,Fat,SNF 
     )
     select 
	Org_Id,MCC_Id,Dairy_Fat,Dairy_SNF
	from f010_milkcollectionmcc_final
	where MCC_Id = 'M005242000127'
	and date(Collection_Date) >= date('2024-07-11')
	and date(Collection_Date) <= date(now())
    group by Org_Id,MCC_Id,Dairy_Fat,Dairy_SNF;
    
    
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015003', Fat, SNF, 'C011001',date(now())) ;
    
    
    
	update f010_milkcollectionmcc_final t005
	inner join temp_Report tmp on
	tmp.Org_Id = t005.Org_Id
	and tmp.MCC_Id = t005.MCC_Id
	and tmp.Fat = t005.Dairy_Fat
	and tmp.SNF = t005.Dairy_SNF
	set t005.MilkRate = tmp.rate 
	where t005.MCC_Id ='M005242000127'
	and date(t005.Collection_Date) >=  date('2024-07-11')
	and date(t005.Collection_Date) <=  date(now());


	update f010_milkcollectionmcc_final t005
	inner join temp_Report tmp on
	tmp.Org_Id = t005.Org_Id
	and tmp.MCC_Id = t005.MCC_Id
	and tmp.Fat = t005.Dairy_Fat
	and tmp.SNF = t005.Dairy_SNF
	set t005.MilkPrice = t005.Dairy_Quantity_Ltr * t005.MilkRate
	where t005.MCC_Id ='M005242000127'
	and date(t005.Collection_Date) >=  date('2024-07-11')
	and date(t005.Collection_Date) <=  date(now());
     
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
