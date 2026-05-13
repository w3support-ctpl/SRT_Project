-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTankerQuantity_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTankerQuantity_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_CellNo varchar(2),
    var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
    var_GrossWeight varchar(45),
    var_TareWeight varchar(45),
    var_Weight varchar(45),
    var_Vehicle_Id varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_SupervisorData longtext,
	var_Reasons longtext,
    var_Date varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Entry_Id varchar(20);
            Declare New_MilkCollectionDairy_Id varchar(20);
            Declare Set_MilkCollectionDairy_Id varchar(20);
            DECLARE New_Driver_Id  varchar(20);
			DECLARE Set_MCC_Id  varchar(20);
			Declare Year_Id varchar(10);
            declare var_Start_Time time;
            DECLARE Today_Date DATETIME;
            declare row_count int;
            set Year_Id = (select right(left(date(var_Date),4),(2)));
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            set var_Start_Time = Time(CONVERT_TZ(date(var_Date), '+00:00', '+00:00'));
            
			Call USP_Number_Range ('t009_milkcollectiondairy_quantity', Year_Id, 'T009A', '', New_Entry_Id );
            
            set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
			SET @Quantity_ltr = var_Weight * @kg_to_ltr;
            
            IF (var_MilkCollectionDairy_Id IS NOT NULL AND var_MilkCollectionDairy_Id <> '') THEN
				if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
            
					if exists(select Entry_Id from t009_milkcollectiondairy_quantity where Org_Id = var_Org_Id 
								and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
								and TripDocument_Id = var_TripDocument_Id 
								and CellNo = var_CellNo) then
						SELECT -1 AS Result_Id, 
						'Cell Number already exists' AS Result_Description, 
						'' AS Result_Extra_Key;
					else
						Insert Into t009_milkcollectiondairy_quantity
						(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,CellNo,
						MilkType_Id,MilkStatus_Id,GrossWeight,TareWeight,Weight,Liters,Start_Time,Batch_Id,
                        Reasons)
						Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id, var_TripDocument_Id,var_CellNo,
						var_MilkType_Id,var_MilkStatus_Id,var_GrossWeight,var_TareWeight,var_Weight,@Quantity_ltr,var_Start_Time,RIGHT(New_Entry_Id, 9),
                        var_Reasons); 
						
						UPDATE t009_milkcollectiondairy_milk AS t009
						SET
							Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
							Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
						WHERE
							t009.Org_Id = var_Org_Id
							AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
							
							select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
							from t009_milkcollectiondairy_header
							where MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                            
						SELECT 
							-- IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
                            IFNULL(MAX(CAST(t0091.Sample_No AS SIGNED)), 0) + 1 INTO row_count
						FROM t009_milkcollectiondairy_header t009
						INNER JOIN t009_milkcollectiondairy_quality t0091 ON
							t009.Org_Id = t0091.Org_Id
							AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
						WHERE t009.Org_Id = var_Org_Id
						AND t009.Is_Active = 1
						AND t009.Is_Deleted = 0
						and t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
						
						call USP_AdminMilkCollectionTankerQuality_Set('Create',  var_Org_Id, '', Set_MilkCollectionDairy_Id, var_TripDocument_Id, var_CellNo, row_count, '',0, 0, var_Vehicle_Id, var_User_Id,var_User_Name,1, 0,var_Date);
									
					end if;
				else
                    if exists(select Entry_Id from t009_milkcollectiondairy_quantity where Org_Id = var_Org_Id 
								and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
								and CellNo = var_CellNo) then
						SELECT -1 AS Result_Id, 
						'Cell Number already exists' AS Result_Description, 
						'' AS Result_Extra_Key;
					else
						SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
						where Org_Id = var_Org_Id 
						and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                        
						Insert Into t009_milkcollectiondairy_quantity
						(Org_Id,Entry_Id,MilkCollectionDairy_Id,MCC_Id,CellNo,
						MilkType_Id,MilkStatus_Id,GrossWeight,TareWeight,Weight,Liters,Start_Time,Batch_Id,
                        Reasons)
						Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id,Set_MCC_Id,var_CellNo,
						var_MilkType_Id,var_MilkStatus_Id,var_GrossWeight,var_TareWeight,var_Weight,@Quantity_ltr,var_Start_Time,
						RIGHT(New_Entry_Id, 9),
                        var_Reasons); 
						
						UPDATE t009_milkcollectiondairy_milk AS t009
						SET
							Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
							Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
						WHERE
							t009.Org_Id = var_Org_Id
							AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                            
                            
                            UPDATE t009_milkcollectiondairy_mcc AS t009
							SET
								Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
										  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
										  and t0091.MCC_Id = t009.MCC_Id),
								Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
										  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
										  and t0091.MCC_Id = t009.MCC_Id)
							WHERE
								t009.Org_Id = var_Org_Id
								AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                AND t009.MCC_Id = Set_MCC_Id;
                                
							select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
							from t009_milkcollectiondairy_header
							where MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                            
                            SELECT 
								-- IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
                                IFNULL(MAX(CAST(t0091.Sample_No AS SIGNED)), 0) + 1 INTO row_count
							FROM t009_milkcollectiondairy_header t009
							INNER JOIN t009_milkcollectiondairy_quality t0091 ON
								t009.Org_Id = t0091.Org_Id
								AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
							WHERE t009.Org_Id = var_Org_Id
							AND t009.Is_Active = 1
							AND t009.Is_Deleted = 0
							and t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
							
							call USP_AdminMilkCollectionTankerQuality_Set('Create',  var_Org_Id, '', Set_MilkCollectionDairy_Id, var_TripDocument_Id, var_CellNo, row_count, '',0, 0, var_Vehicle_Id, var_User_Id,var_User_Name,1, 0,var_Date);
							
					end if;
				end if;
            else
				if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
					select Driver_Id INTO New_Driver_Id
					from t021_tripdocument_header
					where TripDocument_Id = var_TripDocument_Id;
					
					Call USP_Number_Range ('t009_milkcollectiondairy_header', Year_Id, 'T009', '', New_MilkCollectionDairy_Id );
                    
                    
                   
					INSERT INTO t009_milkcollectiondairy_header
					(Org_Id, MilkCollectionDairy_Id, TripDocument_Id, Vehicle_Id,
					Is_Active, Is_Deleted, Created_On, CreatedBy_Id, CreatedBy_Name)
					VALUES (var_Org_Id, New_MilkCollectionDairy_Id, var_TripDocument_Id, var_Vehicle_Id,
					1, 0, Today_Date, var_User_Id, var_User_Name); 
                    
                    
					
					Insert Into t009_milkcollectiondairy_quantity
					(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,CellNo,
					MilkType_Id,MilkStatus_Id,GrossWeight,TareWeight,Weight,Liters,Start_Time,Batch_Id,
                    Reasons)
					Values (var_Org_Id,New_Entry_Id,New_MilkCollectionDairy_Id, var_TripDocument_Id,var_CellNo,
					var_MilkType_Id,var_MilkStatus_Id,var_GrossWeight,var_TareWeight,var_Weight,@Quantity_ltr,var_Start_Time,
					RIGHT(New_Entry_Id, 9),
                    var_Reasons); 
					
					INSERT INTO t009_milkcollectiondairy_milk
					(Org_Id,MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id,Weight,Liters)
					Values( var_Org_Id,New_MilkCollectionDairy_Id,
					'C011001',var_MilkStatus_Id,var_Weight,@Quantity_ltr);
					
					UPDATE t009_milkcollectiondairy_header
					SET Driver_Id = New_Driver_Id
					WHERE Org_Id = var_Org_Id 
					AND MilkCollectionDairy_Id = New_MilkCollectionDairy_Id; 
					
					select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
					from t009_milkcollectiondairy_header
					where MilkCollectionDairy_Id = New_MilkCollectionDairy_Id;
                    
                    
                    SELECT 
						-- IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
                        IFNULL(MAX(CAST(t0091.Sample_No AS SIGNED)), 0) + 1 INTO row_count
					FROM t009_milkcollectiondairy_header t009
					INNER JOIN t009_milkcollectiondairy_quality t0091 ON
						t009.Org_Id = t0091.Org_Id
						AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
					WHERE t009.Org_Id = var_Org_Id
					AND t009.Is_Active = 1
					AND t009.Is_Deleted = 0
					and t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
                     
					
                  
					call USP_AdminMilkCollectionTankerQuality_Set('Create',  var_Org_Id, '', Set_MilkCollectionDairy_Id, var_TripDocument_Id, var_CellNo, row_count, '',0, 0, var_Vehicle_Id, var_User_Id,var_User_Name,1, 0,var_Date);
					call USP_AdminMilkCollectionTankerQuality_Set('Create_MCC',  var_Org_Id, '', Set_MilkCollectionDairy_Id, var_TripDocument_Id, '', '', '',0, 0, var_Vehicle_Id, var_User_Id,var_User_Name,1, 0,var_Date);
                    
				else 
					SELECT t009.MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id 
                    FROM t009_milkcollectiondairy_header t009 
                    where t009.Org_Id = var_Org_Id 
                    and t009.Vehicle_Id =var_Vehicle_Id
					and t009.Is_OutsideVehicle =1
					and t009.Created_On <= CONVERT_TZ(Today_Date, '+00:00', '+00:00') 
					order by t009.Created_On DESC limit 1;
                    
                    
                    SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
					where Org_Id = var_Org_Id 
					and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
                    
                    Insert Into t009_milkcollectiondairy_quantity
					(Org_Id,Entry_Id,MilkCollectionDairy_Id,MCC_Id,CellNo,
					MilkType_Id,MilkStatus_Id,GrossWeight,TareWeight,Weight,Liters,Start_Time,Batch_Id,
                    Reasons)
					Values (var_Org_Id,New_Entry_Id,Set_MilkCollectionDairy_Id,Set_MCC_Id,var_CellNo,
					var_MilkType_Id,var_MilkStatus_Id,var_GrossWeight,var_TareWeight,var_Weight,@Quantity_ltr,var_Start_Time,
					RIGHT(New_Entry_Id, 9),
                    var_Reasons); 
                    
                    UPDATE t009_milkcollectiondairy_milk AS t009
					SET
						Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
						Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
					WHERE
						t009.Org_Id = var_Org_Id
						AND t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
                        
					UPDATE t009_milkcollectiondairy_mcc AS t009
						SET
							Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
									  and t0091.MCC_Id = t009.MCC_Id),
							Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
									  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
									  and t0091.MCC_Id = t009.MCC_Id)
						WHERE
							t009.Org_Id = var_Org_Id
							AND t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id
                            AND t009.MCC_Id = Set_MCC_Id;
						
                        SELECT 
						-- IFNULL(MAX(t0091.Sample_No), 0)  + 1 into row_count
                        IFNULL(MAX(CAST(t0091.Sample_No AS SIGNED)), 0) + 1 INTO row_count
						FROM t009_milkcollectiondairy_header t009
						INNER JOIN t009_milkcollectiondairy_quality t0091 ON
							t009.Org_Id = t0091.Org_Id
							AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
						WHERE t009.Org_Id = var_Org_Id
						AND t009.Is_Active = 1
						AND t009.Is_Deleted = 0
						and t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
						
						call USP_AdminMilkCollectionTankerQuality_Set('Create',  var_Org_Id, '', Set_MilkCollectionDairy_Id, var_TripDocument_Id, var_CellNo, row_count, '',0, 0, var_Vehicle_Id, var_User_Id,var_User_Name,1, 0,var_Date);
                        
						
                    
                end if;
					
			END IF;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			Set_MilkCollectionDairy_Id AS Result_Extra_Key;
            
		end;
	elseif (var_Method_Name = 'Update') then
		begin
		DECLARE Set_MCC_Id  varchar(20);
        
		if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then	
			if exists(select Entry_Id from t009_milkcollectiondairy_quantity where Org_Id = var_Org_Id 
							and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
							and TripDocument_Id = var_TripDocument_Id 
                            and CellNo = var_CellNo and Entry_Id <> var_Entry_Id
					) then
					SELECT -1 AS Result_Id, 
					'Cell Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
			else
				set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
				SET @Quantity_ltr = var_Weight * @kg_to_ltr;
				
				Update t009_milkcollectiondairy_quantity
				set 
				TripDocument_Id = var_TripDocument_Id,
				CellNo = var_CellNo,
				MilkType_Id = var_MilkType_Id,
				MilkStatus_Id = var_MilkStatus_Id,
				GrossWeight = var_GrossWeight,
                TareWeight = var_TareWeight,
                Weight = var_Weight,
				Liters =  @Quantity_ltr,
                Reasons = var_Reasons
				where Org_Id = var_Org_Id 
				and Entry_Id = var_Entry_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
			   
					
				UPDATE t009_milkcollectiondairy_milk AS t009
				SET
					Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
					Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
				WHERE
					t009.Org_Id = var_Org_Id
					AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

				
			end if;
		else
			SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
			if exists(select Entry_Id from t009_milkcollectiondairy_quantity where Org_Id = var_Org_Id 
						and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
						and MCC_Id = Set_MCC_Id 
						and CellNo = var_CellNo and Entry_Id <> var_Entry_Id
				) then
				SELECT -1 AS Result_Id, 
				'Cell Number already exists' AS Result_Description, 
				'' AS Result_Extra_Key;
			else
				set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
				SET @Quantity_ltr = var_Weight * @kg_to_ltr;
				
				Update t009_milkcollectiondairy_quantity
				set 
				CellNo = var_CellNo,
				MilkType_Id = var_MilkType_Id,
				MilkStatus_Id = var_MilkStatus_Id,
                GrossWeight = var_GrossWeight,
                TareWeight = var_TareWeight,
				Weight = var_Weight,
				Liters =  @Quantity_ltr,
                Reasons = var_Reasons
				where Org_Id = var_Org_Id 
				and Entry_Id = var_Entry_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
                
                UPDATE t009_milkcollectiondairy_mcc AS t009
				SET
					Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
							  and t0091.MCC_Id = t009.MCC_Id),
					Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
							  and t0091.MCC_Id = t009.MCC_Id)
					-- Final_Amout =  @Final_Amout
				WHERE
					t009.Org_Id = var_Org_Id
					AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					and t009.MCC_Id =Set_MCC_Id;
			   
					
				UPDATE t009_milkcollectiondairy_milk AS t009
				SET
					Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
					Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
							  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
				WHERE
					t009.Org_Id = var_Org_Id
					AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
			end if;
        end if;
        
        SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
        
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
        DECLARE Set_MCC_Id  varchar(20);
        
        if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then	
			Delete from t009_milkcollectiondairy_quantity
            where Org_Id = var_Org_Id
			and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
		else
			SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
			Delete from t009_milkcollectiondairy_quantity
            where Org_Id = var_Org_Id
			and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
			UPDATE t009_milkcollectiondairy_milk AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
			UPDATE t009_milkcollectiondairy_mcc AS t009
			SET
				Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCC_Id = t009.MCC_Id),
				Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
						  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
                          and t0091.MCC_Id = t009.MCC_Id)
			WHERE
				t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t009.MCC_Id =Set_MCC_Id;
			
        end if;
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Supervisor') then
		begin
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			
            SET row_count := extractValue(var_SupervisorData,'count(//Supervisor/SupervisorItem)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Supervisor/SupervisorItem[', k, ']');
                
                
                IF EXISTS (SELECT 1 FROM t009_milkcollectiondairy_mccloss WHERE 
							Org_Id = var_Org_Id 
							AND MCC_Id = extractValue(var_SupervisorData, concat(xpath,'/MCC_Id'))
                            AND MCCCollectionShift_Id = extractValue(var_SupervisorData, concat(xpath,'/MCCCollectionShift_Id'))
                            AND Entry_Id = var_Entry_Id
                            AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                            AND TripDocument_Id = var_TripDocument_Id
                            AND CellNo = var_CellNo
                            ) THEN
					
                    UPDATE t009_milkcollectiondairy_mccloss AS t009
                    SET t009.Weight = t009.Weight + extractValue(var_SupervisorData, concat(xpath,'/Weight')),
                        t009.Liters = t009.Liters + extractValue(var_SupervisorData, concat(xpath,'/Liters')),
                        t009.Loss = t009.Loss + extractValue(var_SupervisorData, concat(xpath,'/Loss')),
                        t009.Adjusted_Liters = t009.Adjusted_Liters + extractValue(var_SupervisorData, concat(xpath,'/Adjusted_Liters'))
                    WHERE t009.Org_Id = var_Org_Id 
						AND t009.MCC_Id = extractValue(var_SupervisorData, concat(xpath,'/MCC_Id'))
						AND t009.MCCCollectionShift_Id = extractValue(var_SupervisorData, concat(xpath,'/MCCCollectionShift_Id'))
						AND t009.Entry_Id = var_Entry_Id
						AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
						AND t009.TripDocument_Id = var_TripDocument_Id
						AND t009.CellNo = var_CellNo;
                ELSE
                    -- Insert new record
                    INSERT INTO t009_milkcollectiondairy_mccloss (
						Org_Id, 
						Entry_Id, 
						MilkCollectionDairy_Id, 
						TripDocument_Id, 
						MCCCollectionShift_Id, 
						MCC_Id,
						CellNo,
						Weight,
						Liters,
						Loss,
						Adjusted_Liters)
                    VALUES (
						var_Org_Id, 
						var_Entry_Id,
                        var_MilkCollectionDairy_Id,
                        var_TripDocument_Id,
                        extractValue(var_SupervisorData, concat(xpath,'/MCCCollectionShift_Id')),
                        extractValue(var_SupervisorData, concat(xpath,'/MCC_Id')),
                        var_CellNo,
                        extractValue(var_SupervisorData, concat(xpath,'/Weight')),
						extractValue(var_SupervisorData, concat(xpath,'/Liters')),
                        extractValue(var_SupervisorData, concat(xpath,'/Loss')),
						extractValue(var_SupervisorData, concat(xpath,'/Adjusted_Liters'))
                        );
                END IF;
			END WHILE;

			SELECT 1 AS Result_Id, 
			'Supervisor ' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
			
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
