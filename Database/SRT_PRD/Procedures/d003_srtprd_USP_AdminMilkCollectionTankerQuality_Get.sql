-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTankerQuality_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTankerQuality_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_Entry_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_TripDocument_Id varchar(20),
	var_Vehicle_Id varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then
		begin
			if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
            
				select t009.Org_Id,t009.Entry_Id,t009.MilkCollectionDairy_Id,
				t009.TripDocument_Id,t009.MCCCollectionShift_Id,
				t009.MCC_Id,t009.Batch_Id as Batch_Id,
				t009.Sample_No,
				-- t009.SNF,t009.Fat,
				ifnull(t009.SNF,'')as SNF,ifnull(t009.Fat,'') as Fat,
				t009.CellNo,
				ifnull(c016.MilkStatus_Id,'')as MilkStatus_Id,
                ifnull(c016.MilkStatus_Name,'')as MilkStatus_Name
				from t009_milkcollectiondairy_quality t009
				left join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id 
				where t009.Org_Id = var_Org_Id  
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t009.TripDocument_Id = var_TripDocument_Id
                and t009.Sample_No IS NOT NULL
                AND t009.Sample_No <> ''
				order by t009.Entry_Id;
			else
				select t0091.Org_Id,t0091.Entry_Id,t0091.MilkCollectionDairy_Id,
				'' as TripDocument_Id, '' as MCCCollectionShift_Id,
				t0091.MCC_Id,t0091.Batch_Id as Batch_Id,
				t0091.Sample_No,
				-- t0091.SNF,t0091.Fat,
				ifnull(t0091.SNF,'')as SNF,ifnull(t0091.Fat,'') as Fat,
				t0091.CellNo,
				-- c016.MilkStatus_Id,c016.MilkStatus_Name
                ifnull(c016.MilkStatus_Id,'')as MilkStatus_Id,
                ifnull(c016.MilkStatus_Name,'')as MilkStatus_Name
				from t009_milkcollectiondairy_quality t0091
				left join c016_milkstatus c016 on c016.MilkStatus_Id = t0091.MilkStatus_Id 
				inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
				and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				and t009.Vehicle_Id = var_Vehicle_Id
				where t0091.Org_Id = var_Org_Id
				and t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				order by t0091.Entry_Id;
            end if;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.MilkCollectionDairy_Id,
            t009.TripDocument_Id,t009.MCCCollectionShift_Id,
            t009.MCC_Id,t009.Sample_No,
            -- t009.SNF,t009.Fat,
            ifnull(t009.SNF,'')as SNF,ifnull(t009.Fat,'') as Fat,
            t009.CellNo,
            t009.MilkStatus_Id,t009.Batch_Id as Batch_Id
            from t009_milkcollectiondairy_quality t009
            where t009.Org_Id = var_Org_Id
            and t009.Entry_Id = var_Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_BatchId') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.Batch_Id
            from t009_milkcollectiondairy_quantity t009 
            where t009.Org_Id = var_Org_Id  
            and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t009.TripDocument_Id = var_TripDocument_Id
            order by t009.Entry_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
