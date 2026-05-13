-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTruckQuantity_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTruckQuantity_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_MCC_Id varchar(20),
    var_CellNo varchar(2),
    var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
    var_Weight varchar(45),
    var_Cans varchar(45),
    var_Reasons longtext,
    var_Date varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare Set_CollectionShift_Id varchar(30);
            declare var_Start_Time time;
            declare row_count int;
            declare var_MCCCollectionShift_Id varchar(30);
            set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            
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
            
             
            select m006.CollectionShift_Id  into  Set_CollectionShift_Id
            from t021_tripdocument_header t021
				INNER JOIN m008_route_vehicle  m008 ON
					m008.Org_Id =  t021.Org_Id
					AND m008.Entry_Id =  t021.Route_Trip_Id
				INNER JOIN m006_route  m006 ON
					m008.Org_Id =  m006.Org_Id
					AND m008.Route_Id =  m006.Route_Id
			WHERE t021.Org_Id = var_Org_Id
			and t021.TripDocument_Id = var_TripDocument_Id;
            
            

            /*
            SELECT IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
			FROM t009_milkcollectiondairy_header t009
			INNER JOIN t009_milkcollectiondairy_quality t0091 ON
				t009.Org_Id = t0091.Org_Id
				AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			INNER JOIN m003_vehicle  m003 ON
				t009.Org_Id =  m003.Org_Id
				AND t009.Vehicle_Id =  m003.Vehicle_Id
				and m003.VehicleType_Id ='C020001'
			WHERE t009.Org_Id = var_Org_Id
			AND DATE(t009.Created_On) = DATE(NOW())
			AND t009.Is_Active = 1
			AND t009.Is_Deleted = 0;
            
            */
            
             
            
            SELECT 
			-- IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
            IFNULL(MAX(CAST(t0091.Sample_No AS SIGNED)), 0) + 1 INTO row_count
			FROM t009_milkcollectiondairy_header t009
			INNER JOIN t009_milkcollectiondairy_quality t0091 ON
				t009.Org_Id = t0091.Org_Id
				AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			INNER JOIN t021_tripdocument_header  t021 ON
				t009.Org_Id =  t021.Org_Id
				AND t009.TripDocument_Id =  t021.TripDocument_Id
			INNER JOIN m003_vehicle  m003 ON
				t009.Org_Id =  m003.Org_Id
				AND t021.Vehicle_Id =  m003.Vehicle_Id
				and m003.VehicleType_Id ='C020001'
			INNER JOIN m008_route_vehicle  m008 ON
				m008.Org_Id =  t021.Org_Id
				AND m008.Entry_Id =  t021.Route_Trip_Id
			INNER JOIN m006_route  m006 ON
				m008.Org_Id =  m006.Org_Id
				AND m008.Route_Id =  m006.Route_Id
				AND m006.CollectionShift_Id = Set_CollectionShift_Id
			WHERE t009.Org_Id = var_Org_Id
			AND DATE(t009.Created_On) = DATE(@Current_Datetime)
			AND t009.Is_Active = 1
			AND t009.Is_Deleted = 0;
            
           
             
            set Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
            
            set var_Start_Time = Time(CONVERT_TZ(date(@Current_Datetime), '+00:00', '+00:00'));
			Call USP_Number_Range ('t009_milkcollectiondairy_quantity', Year_Id, 'T009A', '', New_Entry_Id );
            
            set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
			SET @Quantity_ltr = var_Weight * @kg_to_ltr;
             
			Insert Into t009_milkcollectiondairy_quantity
			(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,MCCCollectionShift_Id,MCC_Id,
			MilkType_Id,MilkStatus_Id,Weight,Liters,Cans,Start_Time,CellNo,Batch_Id,
            Reasons)
			Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id, var_TripDocument_Id,var_MCCCollectionShift_Id,var_MCC_Id,
			var_MilkType_Id,var_MilkStatus_Id,var_Weight,@Quantity_ltr,var_Cans,var_Start_Time,var_CellNo,New_Entry_Id
            ,var_Reasons);
            
          
			
            select 
                if (var_MilkType_Id = 'C011001', t006.Final_Amout_Cow , 
                if (var_MilkType_Id = 'C011002', t006.Final_Amout_Buf , 0.00 ))  into @Final_Amout
            from t006_milkcollectionagent t006 
            where t006.Org_Id = var_Org_Id 
            and t006.MCC_Id = var_MCC_Id
            and t006.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
         
            
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id),
				Final_Amout = @Final_Amout
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
                
			
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001'),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001')
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
    
  
			
			SELECT 1 AS Result_Id, 
			var_MCCCollectionShift_Id AS Result_Description, 
			New_Entry_Id AS Result_Extra_Key;
            
            if(var_MilkStatus_Id = 'C016001')then
            
				call USP_AdminMilkCollectionTruckQuality_Set('Create', var_Org_Id,New_Entry_Id, var_MilkCollectionDairy_Id,  var_TripDocument_Id, var_MCCCollectionShift_Id, var_MCC_Id, row_count, var_MilkStatus_Id, 0, 0,'',var_Date);
            
            end if;
            
             
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
			set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
			SET @Quantity_ltr = var_Weight * @kg_to_ltr;
            
			Update t009_milkcollectiondairy_quantity
			set 
            TripDocument_Id = var_TripDocument_Id,
            MCCCollectionShift_Id = var_MCCCollectionShift_Id,
            MCC_Id = var_MCC_Id,
			MilkType_Id = var_MilkType_Id,
			MilkStatus_Id = var_MilkStatus_Id,
			Weight = var_Weight,
			Liters =  @Quantity_ltr,
            Cans = var_Cans,
            CellNo = var_CellNo,
            Reasons = var_Reasons
			where Org_Id = var_Org_Id 
			and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
            select 
                if (var_MilkType_Id = 'C011001', t006.Final_Amout_Cow , 
                if (var_MilkType_Id = 'C011002', t006.Final_Amout_Buf , 0.00 ))  into @Final_Amout
            from t006_milkcollectionagent t006 
            where t006.Org_Id = var_Org_Id 
            and t006.MCC_Id = var_MCC_Id
            and t006.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id),
				Final_Amout =  @Final_Amout
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001'),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001')
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

			SELECT 1 AS Result_Id, 
			var_MCCCollectionShift_Id AS Result_Description, 
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
        
			Delete from t009_milkcollectiondairy_quantity
            where Org_Id = var_Org_Id
			and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            UPDATE t009_milkcollectiondairy_mcc AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCCCollectionShift_Id = t009.MCCCollectionShift_Id
                          and t0091.MilkStatus_Id = 'C016001'
                          and t0091.MCC_Id = t009.MCC_Id)
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCCCollectionShift_Id =var_MCCCollectionShift_Id
                and t009.MCC_Id =var_MCC_Id;
                
                
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001'),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MilkStatus_Id = 'C016001')
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
