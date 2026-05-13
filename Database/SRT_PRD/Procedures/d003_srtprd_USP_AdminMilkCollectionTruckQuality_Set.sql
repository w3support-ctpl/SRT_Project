-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTruckQuality_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTruckQuality_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Sample_No varchar(45),
    var_MilkStatus_Id varchar(20),
    var_SNF varchar(45),
    var_Fat varchar(45),
    var_Cans varchar(45),
    var_Date varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            declare var_MCCCollectionShift_Id varchar(30);
		
            
            if (ifnull(var_MCCCollectionShift_Id, '') = '' or var_MCCCollectionShift_Id = 'null' ) then
					
                  set var_MCCCollectionShift_Id = ( select t022.MCC_CollectionShift_Id from t009_milkcollectiondairy_header t009  
					inner join t022_tripdocument_item t022 on t022.Org_Id = t009.Org_Id
					and t022.TripDocument_Id = t009.TripDocument_Id
					and t022.MCC_Id = var_MCC_Id
					where
					t009.Org_Id = var_Org_Id
					and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
            else
					set var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            end if;
            
            set Year_Id = (select right(left(date(var_Date),4),(2)));
			Call USP_Number_Range ('t009_milkcollectiondairy_quality', Year_Id, 'T009B', '', New_Entry_Id );
            
            
			Insert Into t009_milkcollectiondairy_quality
			(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,MCCCollectionShift_Id,MCC_Id,
			Sample_No,MilkStatus_Id,SNF,Fat,Batch_Id)
			Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id, var_TripDocument_Id,var_MCCCollectionShift_Id,var_MCC_Id,
			var_Sample_No,var_MilkStatus_Id,var_SNF,var_Fat,var_Entry_Id); 
	
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;


			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Entry_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			declare var_MCCCollectionShift_Id varchar(30);
            
            if (ifnull(var_MCCCollectionShift_Id, '') = '' or var_MCCCollectionShift_Id = 'null' ) then
					
                  set var_MCCCollectionShift_Id = ( select t022.MCC_CollectionShift_Id from t009_milkcollectiondairy_header t009  
					inner join t022_tripdocument_item t022 on t022.Org_Id = t009.Org_Id
					and t022.TripDocument_Id = t009.TripDocument_Id
					and t022.MCC_Id = var_MCC_Id
					where
					t009.Org_Id = var_Org_Id
					and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
            else
					set var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            end if;
	
			Update t009_milkcollectiondairy_quality
			set 
            TripDocument_Id = var_TripDocument_Id,
            MCCCollectionShift_Id = var_MCCCollectionShift_Id,
            MCC_Id = var_MCC_Id,
			Sample_No = var_Sample_No,
			MilkStatus_Id = var_MilkStatus_Id,
			SNF = var_SNF,
			Fat =  var_Fat
			where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			declare var_MCCCollectionShift_Id varchar(30);
            
            if (ifnull(var_MCCCollectionShift_Id, '') = '' or var_MCCCollectionShift_Id = 'null' ) then
					
                  set var_MCCCollectionShift_Id = ( select t022.MCC_CollectionShift_Id from t009_milkcollectiondairy_header t009  
					inner join t022_tripdocument_item t022 on t022.Org_Id = t009.Org_Id
					and t022.TripDocument_Id = t009.TripDocument_Id
					and t022.MCC_Id = var_MCC_Id
					where
					t009.Org_Id = var_Org_Id
					and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
            else
					set var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            end if;
        
			Delete from t009_milkcollectiondairy_quality
            where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET 
			t009.SNF = (
				SELECT SUM(t0091.SNF) / COUNT(t0091.SNF)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				),
			t009.Fat = (
				SELECT SUM(t0091.Fat) / COUNT(t0091.Fat)
				FROM t009_milkcollectiondairy_quality AS t0091
				WHERE t0091.Org_Id = t009.Org_Id
				AND t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				)
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
