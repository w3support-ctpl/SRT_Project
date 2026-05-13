-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTankerQuality_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTankerQuality_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_CellNo varchar(2),
    var_Sample_No varchar(45),
    var_MilkStatus_Id varchar(20),
    var_SNF varchar(45),
    var_Fat varchar(45),
    var_Vehicle_Id varchar(20),
    var_User_Id varchar(20), 
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Date varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Entry_Id varchar(20);
            Declare New_MilkCollectionDairy_Id varchar(20);
            Declare Set_MilkCollectionDairy_Id varchar(20);
            DECLARE Set_MCC_Id  varchar(20);
            DECLARE New_Driver_Id  varchar(20);
			Declare Year_Id varchar(10);
            DECLARE Today_Date DATETIME;
            
            set Year_Id = (select right(left(date(var_Date),4),(2)));
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            
			Call USP_Number_Range ('t009_milkcollectiondairy_quality', Year_Id, 'T009B', '', New_Entry_Id );
            
            IF (var_MilkCollectionDairy_Id IS NOT NULL AND var_MilkCollectionDairy_Id <> '') THEN
            
				if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
                
					Insert Into t009_milkcollectiondairy_quality
					(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,
					Sample_No,MilkStatus_Id,SNF,Fat,CellNo)
					Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id, var_TripDocument_Id,
					var_Sample_No,var_MilkStatus_Id,var_SNF,var_Fat,var_CellNo);
					
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
						
					
					select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
					from t009_milkcollectiondairy_header
					where MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
					
				else
					/*
					SELECT t009.MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id 
                    FROM t009_milkcollectiondairy_header t009 
                    where t009.Org_Id = var_Org_Id 
                    and t009.Vehicle_Id =var_Vehicle_Id
					and t009.Is_OutsideVehicle =1
					and t009.Created_On <= CONVERT_TZ(NOW(), '+00:00', '+00:00') 
					order by t009.Created_On DESC limit 1;
                    */
                    
                    SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
					where Org_Id = var_Org_Id 
					and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
                    Insert Into t009_milkcollectiondairy_quality
					(Org_Id,Entry_Id,MilkCollectionDairy_Id,MCC_Id,
					Sample_No,MilkStatus_Id,SNF,Fat,CellNo)
					Values (var_Org_Id,New_Entry_Id,var_MilkCollectionDairy_Id,Set_MCC_Id,
					var_Sample_No,var_MilkStatus_Id,var_SNF,var_Fat,var_CellNo);
                    
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
						and t009.MCC_Id =Set_MCC_Id;
					
                    select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
					from t009_milkcollectiondairy_header
					where MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
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
					VALUES (var_Org_Id, New_MilkCollectionDairy_Id, var_TripDocument_Id,var_Vehicle_Id,
					1, 0, Today_Date, var_User_Id, var_User_Name); 
					
					
					Insert Into t009_milkcollectiondairy_quality
					(Org_Id,Entry_Id,MilkCollectionDairy_Id, TripDocument_Id,
					Sample_No,MilkStatus_Id,SNF,Fat,CellNo)
					Values (var_Org_Id,New_Entry_Id,New_MilkCollectionDairy_Id, var_TripDocument_Id,
					var_Sample_No,var_MilkStatus_Id,var_SNF,var_Fat,var_CellNo);
					
					INSERT INTO t009_milkcollectiondairy_milk
					(Org_Id,MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id,SNF,Fat)
					Values( var_Org_Id,New_MilkCollectionDairy_Id,
					'C011001',var_MilkStatus_Id,var_SNF,var_Fat);
					
					UPDATE t009_milkcollectiondairy_header
					SET Driver_Id = New_Driver_Id
					WHERE Org_Id = var_Org_Id 
					AND MilkCollectionDairy_Id = New_MilkCollectionDairy_Id; 
					
					select MilkCollectionDairy_Id INTO Set_MilkCollectionDairy_Id
					from t009_milkcollectiondairy_header
					where MilkCollectionDairy_Id = New_MilkCollectionDairy_Id;
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
                    
                    Insert Into t009_milkcollectiondairy_quality
					(Org_Id,Entry_Id,MilkCollectionDairy_Id,MCC_Id,
					Sample_No,MilkStatus_Id,SNF,Fat,CellNo)
					Values (var_Org_Id,New_Entry_Id,Set_MilkCollectionDairy_Id,Set_MCC_Id,
					var_Sample_No,var_MilkStatus_Id,var_SNF,var_Fat,var_CellNo);
                    
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
						AND t009.MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
						
					
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
						and t009.MCC_Id =Set_MCC_Id;
                    
                end if ;
            END IF;
				
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			Set_MilkCollectionDairy_Id AS Result_Extra_Key;
			
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        DECLARE Set_MCC_Id  varchar(20);
		if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then	
			Update t009_milkcollectiondairy_quality
			set 
            TripDocument_Id = var_TripDocument_Id,
			Sample_No = var_Sample_No,
			MilkStatus_Id = var_MilkStatus_Id,
			SNF = var_SNF,
			Fat =  var_Fat,
            CellNo = var_CellNo
			where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
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
		else
			SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
					where Org_Id = var_Org_Id 
					and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
			Update t009_milkcollectiondairy_quality
			set 
            TripDocument_Id = var_TripDocument_Id,
			Sample_No = var_Sample_No,
			MilkStatus_Id = var_MilkStatus_Id,
			SNF = var_SNF,
			Fat =  var_Fat,
            CellNo = var_CellNo
			where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
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
                and t009.MCC_Id =Set_MCC_Id;
        end if;
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
		DECLARE Set_MCC_Id  varchar(20);
        if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then	
			Delete from t009_milkcollectiondairy_quality
            where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
           
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
		else
			SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
			Delete from t009_milkcollectiondairy_quality
            where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
           
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
                and t009.MCC_Id =Set_MCC_Id;
		end if;
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Create_MCC') then
    begin
		DECLARE New_Entry_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(2);
		DECLARE Today_Date DATETIME;
        DECLARE done INT DEFAULT FALSE;
		DECLARE Org_Id VARCHAR(20);
        DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE TripDocument_Id VARCHAR(20);
		DECLARE MCC_Id VARCHAR(20);
        DECLARE MilkType_Id VARCHAR(20);
		
		DECLARE cur CURSOR FOR
			select 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id,
			t009.TripDocument_Id,
			m005.MCC_Id,
			t0081.MilkType_Id
			from t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
				and t021.TripDocument_Id = t009.TripDocument_Id 
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
				and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id 
				and t021.Route_Trip_Id = m008.Entry_Id 
			inner join m006_route m006 on m006.Org_Id = m008.Org_Id 
				and m006.Route_Id = m008.Route_Id 
			inner join m007_route_item m007 on m006.Org_Id = m007.Org_Id 
				and m006.Route_Id = m007.Route_Id 
			inner join m005_mcc m005 on m005.Org_Id = m007.Org_Id 
				and m005.MCC_Id = m007.MCC_Id 
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
				and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id 
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
				and t008.ChemistCollection_Id = t0081.ChemistCollection_Id 
				and m005.MCC_Id = t0081.MCC_Id 
			WHERE t009.Org_Id = var_Org_Id AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id,
			t009.TripDocument_Id,
			m005.MCC_Id,
			t0081.MilkType_Id;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		OPEN cur;
		read_loop: LOOP
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, TripDocument_Id, MCC_Id,MilkType_Id;
			IF done THEN
				LEAVE read_loop;
			END IF;
            
            
			SET Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            SET Year_Id = RIGHT(LEFT(date(Today_Date), 4), 2);
			-- Generate New_Entry_Id
			CALL USP_Number_Range('t009_milkcollectiondairy_quality', Year_Id, 'T009B', '', New_Entry_Id);

			-- Insert into t009_milkcollectiondairy_quality
			INSERT INTO t009_milkcollectiondairy_quality
			(Org_Id, Entry_Id, MilkCollectionDairy_Id, TripDocument_Id, MCC_Id,MilkType_Id, MilkStatus_Id, SNF, Fat)
			VALUES
			(Org_Id, New_Entry_Id, MilkCollectionDairy_Id, TripDocument_Id, MCC_Id,MilkType_Id, 'C016001', 0, 0);

		END LOOP;

		CLOSE cur;
        SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
    end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
