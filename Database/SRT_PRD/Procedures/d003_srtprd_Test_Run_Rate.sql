-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `Test_Run_Rate` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `Test_Run_Rate`()
BEGIN
	SET SQL_SAFE_UPDATES = 0;

    DROP TEMPORARY TABLE IF EXISTS temp_Report;
    
    CREATE TEMPORARY TABLE temp_Report ( 
	Org_Id varchar(20), MCC_Id varchar(20), Fat decimal(18,3),SNF decimal(18,3),rate decimal(18,3));
    
    
	 insert into temp_Report (
     Org_Id,MCC_Id,Fat,SNF 
     )
	select t005.Org_Id,t005.MCC_Id,t005.Fat,t005.SNF 
	from t005_milkcollectionfarmer t005
	inner join t004_mcccollectionshift t004 on
	t004.Org_Id = t005.Org_Id
	and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
	and t004.MCC_Id = t005.MCC_Id
	and  t004.CollectionShift_Id ='C015001'
	where t005.MCC_Id ='M005241000077'
	and date(t005.Created_On) >=  date('2024-07-01')
	and date(t005.Created_On) <=  date('2024-07-01')
	group by t005.Org_Id,t005.MCC_Id,t005.Fat,t005.SNF ;
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015001', Fat, SNF, 'C011001',date('2024-07-02')) ;
    /*
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    
    update temp_Report 
	set rate = GetMilkRateBackDate(Org_Id, MCC_Id,'C015002', Fat, SNF, 'C011001',date('2024-07-01')) 
    where rate is null
    limit 10; 
    
    */
    
    
    
    update t005_milkcollectionfarmer t005
	inner join t004_mcccollectionshift t004 on
	t004.Org_Id = t005.Org_Id
	and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
	and t004.MCC_Id = t005.MCC_Id
	and  t004.CollectionShift_Id ='C015001'
    inner join temp_Report tmp on
	tmp.Org_Id = t005.Org_Id
	and tmp.MCC_Id = t005.MCC_Id
    and tmp.Fat = t005.Fat
    and tmp.SNF = t005.SNF
    set t005.ApplicableRate = tmp.rate 
	where t005.MCC_Id ='M005241000077'
	and date(t005.Created_On) >=  date('2024-07-01')
	and date(t005.Created_On) <=  date('2024-07-01');
    
    update t005_milkcollectionfarmer t005
	inner join t004_mcccollectionshift t004 on
	t004.Org_Id = t005.Org_Id
	and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
	and t004.MCC_Id = t005.MCC_Id
	and  t004.CollectionShift_Id ='C015001'
    set t005.Amount = t005.Quantity_Ltr * t005.ApplicableRate
	where t005.MCC_Id ='M005241000077'
	and date(t005.Created_On) >=  date('2024-07-01')
	and date(t005.Created_On) <=  date('2024-07-01');
    
    
    
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
