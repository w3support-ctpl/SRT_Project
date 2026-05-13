-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTruckQuantity_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTruckQuantity_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_Entry_Id varchar(20),
    var_MCC_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_TripDocument_Id varchar(20)
    )
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then
		begin
			select t009A.Org_Id,t009A.Entry_Id,t009A.MilkCollectionDairy_Id,t009A.Batch_Id,
            t009A.TripDocument_Id,t009A.MCCCollectionShift_Id,
            t009A.MCC_Id,t009A.Weight,t009A.Liters,
            COALESCE(t009A.Cans, t009B.Cans) AS Cans,
            Time_FORMAT(t009A.Start_Time, '%h:%i %p') AS Start_Time,
            c011.MilkType_Id,c011.MilkType_Name,
            c016.MilkStatus_Id,c016.MilkStatus_Name
            from t009_milkcollectiondairy_quantity t009A
            inner join c011_milktype c011 on c011.MilkType_Id = t009A.MilkType_Id 
            inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009A.MilkStatus_Id
            left join t009_milkcollectiondairy_quality t009B on t009B.Batch_Id = t009A.Batch_Id
            where t009A.Org_Id = var_Org_Id  
            and t009A.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t009A.TripDocument_Id = var_TripDocument_Id
            and t009A.MCCCollectionShift_Id = var_MCCCollectionShift_Id
            and t009A.MCC_Id = var_MCC_Id
            order by t009A.Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.MilkCollectionDairy_Id,t009.Batch_Id,
            t009.TripDocument_Id,t009.MCCCollectionShift_Id,
            t009.MCC_Id,t009.Weight,t009.Liters,t009.Cans,
            c011.MilkType_Id,c011.MilkType_Name,
            c016.MilkStatus_Id,c016.MilkStatus_Name,
            t009.Reasons
            from t009_milkcollectiondairy_quantity t009
            inner join c011_milktype c011 on c011.MilkType_Id = t009.MilkType_Id 
            inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id 
            where t009.Org_Id = var_Org_Id  
            and t009.Entry_Id = var_Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_BatchId') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.Batch_Id
            from t009_milkcollectiondairy_quality t009 
            where t009.Org_Id = var_Org_Id  
            and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t009.TripDocument_Id = var_TripDocument_Id
            and t009.MCCCollectionShift_Id = var_MCCCollectionShift_Id
            and t009.MCC_Id = var_MCC_Id
            order by t009.Entry_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
