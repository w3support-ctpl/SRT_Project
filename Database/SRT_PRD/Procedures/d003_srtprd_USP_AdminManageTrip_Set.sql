-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminManageTrip_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminManageTrip_Set`(
	var_Method_Name varchar(255),
	var_Org_Id varchar(20),
	var_User_Id varchar(20),
	var_User_Name varchar(100),
	var_Route_Trip_Id varchar(20),
	var_Vehicle_Id varchar(20),
	var_Profile_Id varchar(20),
	var_MCC_Id varchar(20),
	var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
	var_Reason varchar(50),
    var_CollectionShift_Id varchar(20),
	var_Farmer_Id varchar(20),
	var_Weight varchar(45),
	var_SNF varchar(45),
    var_Fat varchar(45),
	var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
	var_Image text,
    var_CollectionData longtext,
    var_CellNo text,
    var_Date varchar(60)
)
BEGIN
	
    
    
	if (var_Method_Name = 'StartTrip') then
		begin
		SET SQL_SAFE_UPDATES = 0;
		set sql_require_primary_key = 0 ;
		set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
		set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
		
		set @Entry_Id = '';
		set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
		Call USP_Number_Range ('t021_trip_document', @Year_Id, 'T021', '', @Entry_Id);
        
        if exists( select 1 from t021_tripdocument_header where Org_Id = var_Org_Id and Driver_Id = var_Profile_Id and
        Route_Trip_Id = var_Route_Trip_Id and date(Created_On) = date(@Current_Datetime) ) then

			select -1 as Result_Id, 'Trip Already Started' as Result_Description, '' as Result_Extra_Key;  
		
		else
			
            Set @Route_Id = (Select Route_Id from m008_route_vehicle where Entry_Id = var_Route_Trip_Id and Org_Id = var_Org_Id limit 1);
            
            set @var_Vehicle_Id = var_Vehicle_Id;
            
            IF (@var_Vehicle_Id IS NULL or @var_Vehicle_Id = '' ) THEN 
				SET @var_Vehicle_Id = ( Select Vehicle_Id from m008_route_vehicle where Entry_Id = var_Route_Trip_Id and Org_Id = var_Org_Id limit 1 );
			END IF ;
            
           set @Next_Destination = ( SELECT m007.MCC_Id 
            FROM m007_route_item m007 
			WHERE m007.Route_Id = @Route_Id  and  m007.Org_Id = var_Org_Id 
            order by Arrival_Time asc limit 1) ;
            
            Set @Transporter_Id = (select Transporter_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = @var_Vehicle_Id limit 1 );
            
            
			insert into t021_tripdocument_header (Org_Id , TripDocument_Id, Route_Trip_Id , Driver_Id , Vehicle_Id, Next_Destination , Created_On , Trip_Status , CreatedBy_Id ,Transporter_Id)
			values (var_Org_Id, @Entry_Id , var_Route_Trip_Id ,var_Profile_Id , @var_Vehicle_Id
            
            -- (select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_No = var_Vehicle_Id limit 1) 
            , @Next_Destination, @Current_Datetime , 'AtDairy' , var_Profile_Id, @Transporter_Id) ;
		
			SET @row_number = 0;
        
			insert into t022_tripdocument_item (Org_Id ,TripDocument_Id ,Route_Id,  MCC_Id, Expected_Time , Created_On , Order_By , Is_Reached )
            
            SELECT var_Org_Id , @Entry_Id ,@Route_Id , m007.MCC_Id , Arrival_Time , @Current_Datetime , 
            (@row_number := @row_number + 1) , 0 
            FROM m007_route_item m007 
            inner join m005_mcc m005 on m005.Org_Id = m007.Org_Id and m005.MCC_Id = m007.MCC_Id
			WHERE m007.Route_Id = @Route_Id  and  m007.Org_Id = var_Org_Id 
            order by Arrival_Time asc;
    
			select 1 as Result_Id, 'Trip Started' as Result_Description, @Entry_Id as Result_Extra_Key; 
		end if ;
		end;
	elseif (var_Method_Name = 'ReachedDestination') then
		begin
        set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
		set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
		
			IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
				set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
				and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
            else
				set @Trip_Id = var_TripDocument_Id;
			END IF;
			
            
            update t022_tripdocument_item 
			set Is_Reached = 1 ,
			Arrival_At = @Current_Datetime 
			where Org_Id = var_Org_Id and
			TripDocument_Id = @Trip_Id and 
			MCC_Id = var_MCC_Id ;
		
			update t021_tripdocument_header 
			set Trip_Status = 'AtMCC' 
			where Org_Id = var_Org_Id and
			TripDocument_Id = @Trip_Id ;
		
			select 1 as Result_Id, 'Reached' as Result_Description, '' as Result_Extra_Key; 
        end;
	elseif (var_Method_Name = 'StartShift') then
		begin
		SET SQL_SAFE_UPDATES = 0;
		set sql_require_primary_key = 0 ;
		set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
		set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
		
		select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
		order by Applicable_Date desc limit 1 ;
        
		set @CollectionShift_Id = '';
        
		select CollectionShift_Id INTO @CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
		( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id =var_MCC_Id  and Version_No = @Version_No)
		AND @Current_timeS BETWEEN ShiftStart_Time AND ShiftEnd_Time limit 1;
        
        IF (@CollectionShift_Id IS NULL or @CollectionShift_Id = '' ) THEN 
			SET @CollectionShift_Id = ( select CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id =var_MCC_Id  and Version_No = @Version_No)
			AND @Current_times <= ShiftStart_Time LIMIT 1 );
		END IF ;
         
		if exists (select 1 from t004_mcccollectionshift where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Shift_Status = 2
					AND CollectionShift_Id = @CollectionShift_Id and date(Collection_Date) = @Current_Datetime) then 
			select -1 as Result_Id, 'Shift Closed' as Result_Description, '' as Result_Extra_Key;
		else
			SET @CollectionShift_Id = '';
			select CollectionShift_Id , CollectionShift_Name INTO @CollectionShift_Id ,  @CollectionShift_Name  from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = var_MCC_Id  and Version_No = @Version_No)
			AND @Current_times BETWEEN ShiftStart_Time AND ShiftEnd_Time limit 1;
            
            if (@CollectionShift_Id = '' or @CollectionShift_Id is  null ) then
				select -1 as Result_Id, 'No shift scheduled' as Result_Description, '' as Result_Extra_Key;
			else 
				IF EXISTS(select 1 from t004_mcccollectionshift where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Shift_Status = 1 ) THEN 	
					select -1 as Result_Id, 'Shift Already Started' as Result_Description, '' as Result_Extra_Key;
				else
					set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
					set @New_MCCCollectionShift_Id ='';
                    set @Agent_Id = (
                    SELECT Agent_Id FROM m005_mcc 
					where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                    
					
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
					
					select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
					
					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
					2, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , Agent_Name , 0 , @ShiftEnd_Time
					from mu05_agent where Org_Id = var_Org_Id and 
					Agent_Id = @Agent_Id limit 1 ) ;
					
					select 1 as Result_Id, 'Shift Started' as Result_Description, @New_MCCCollectionShift_Id as Result_Extra_Key;  
            
				end if;
            end if;
		end if;
		end;
	elseif (var_Method_Name = 'EndShift') then
		begin
		
        SET SQL_SAFE_UPDATES = 0;
		set sql_require_primary_key = 0 ;
		set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
		set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
		
		select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
		order by Applicable_Date desc limit 1 ;
    
		set @Agent_Id = (
		SELECT Agent_Id FROM m005_mcc 
		where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
        
		if exists (select 1 from t004_mcccollectionshift where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Shift_Status in ( 1 ) and  MCCCollectionShift_Id = var_MCCCollectionShift_Id ) then 
			update t004_mcccollectionshift set 
            ShiftEnd_Time = @Current_times,
            LastEditedBy_Id =  @Agent_Id ,
            LastEdited_On =  @Current_Datetime,
            Shift_Status = 2,
            LastEditedBy_Name = (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and 
            Agent_Id =  @Agent_Id limit 1)
            where Org_Id = var_Org_Id and MCCCollectionShift_Id = var_MCCCollectionShift_Id ;
		
			select 1 as Result_Id, 'Shift ended' as Result_Description, '' as Result_Extra_Key ;
		else
			select -1 as Result_Id, 'Shift already ended' as Result_Description,'' as Result_Extra_Key ;
        end if;
        end;
	elseif (var_Method_Name = 'CollectMilk') then
    
    		proc_Exit: begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			declare	var_Quantity_Auto_Flag int;
			declare var_Quality_Auto_Flag int ;
            SET SQL_SAFE_UPDATES = 0;
            
			set var_Quantity_Auto_Flag = 0;
        	set var_Quality_Auto_Flag = 0;
           
		   	set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            
			set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
            set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
           
            set @Agent_Name = (
			SELECT Agent_Name FROM mu05_agent 
			where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);
            
            IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
				set @TripDocument_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
										and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
			else
				set @TripDocument_Id = var_TripDocument_Id;
			END IF;
            
            IF (var_CollectionShift_Id = '' OR  var_CollectionShift_Id IS NULL ) THEN 
				set @CollectionShift_Id  = (select  m006.CollectionShift_Id from t021_tripdocument_header t021
								inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id and t021.Route_Trip_Id = m008.Entry_Id  
								inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id  
								where t021.Org_Id = var_Org_Id
								and t021.TripDocument_Id = @TripDocument_Id);
			else
				set @CollectionShift_Id = var_CollectionShift_Id;
			END IF;
            
            
            SELECT CollectionShift_Name  into @CollectionShift_Name
            FROM c015_collectionshift 
            where CollectionShift_Id = @CollectionShift_Id ;
            
            set @MCCType_Id = (select MCCType_Id from m005_mcc where MCC_Id = var_MCC_Id
								and Org_Id = var_Org_Id);
                                
			if(@MCCType_Id ='C014002' and @CollectionShift_Id ='C015003')then
            
				set @var_MCCCollectionShift_Id  = (select MCCCollectionShift_Id 
														from t004_mcccollectionshift t004
														where t004.MCC_Id = var_MCC_Id
														and t004.Org_Id = var_Org_Id
														and date(t004.Collection_Date) =  date(@Current_Datetime)
														order by t004.Collection_Date desc limit 1);
				
                set var_MCCCollectionShift_Id = @var_MCCCollectionShift_Id;
                
            end if;
            
            IF (var_MCCCollectionShift_Id = '' OR  var_MCCCollectionShift_Id IS NULL ) THEN 
					set @var_MCCCollectionShift_Id  = (select MCCCollectionShift_Id 
														from t004_mcccollectionshift t004
														where t004.MCC_Id = var_MCC_Id
														and t004.Org_Id = var_Org_Id
														and t004.CollectionShift_Id = @CollectionShift_Id
														and date(t004.Collection_Date) =  date(@Current_Datetime)
														order by t004.Collection_Date desc limit 1);
 
				if(@var_MCCCollectionShift_Id = '' OR  @var_MCCCollectionShift_Id IS NULL )then
					
					set @New_MCCCollectionShift_Id ='';
					
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
			
					select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;

					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
					2, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , Agent_Name , 0 , @ShiftEnd_Time
					from mu05_agent where Org_Id = var_Org_Id and 
					Agent_Id = @Agent_Id limit 1 ) ;

					set @var_MCCCollectionShift_Id =  @New_MCCCollectionShift_Id;
				end if;
			else
				set @var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
			END IF;
            
           
           SET @MusterType_Id = (SELECT m005.MusterType_Id
											FROM m005_mcc_version m005
											WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
												AND Applicable_Date <= @Current_Datetime
											ORDER BY Applicable_Date DESC LIMIT 1);

			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);

			
			IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = @Current_Datetime;
				SET @MusterCycle_EndDate = @Current_Datetime;

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

			END IF;
           
            update t022_tripdocument_item 
			set MCC_CollectionShift_Id = @var_MCCCollectionShift_Id
			where Org_Id = var_Org_Id 
			and TripDocument_Id = @TripDocument_Id
			and MCC_Id = var_MCC_Id;
           
        
					SET @Milk_Base_Rate = '';
					SET @Milk_Base_FAT = '';
					SET @Milk_Base_SNF = '';
					SET @Milk_Fat_Deduction = '';
					SET @Milk_Snf_Deduction = '';
					SET @Milk_High_fat = '';
					SET @Milk_High_Snf = '';
					SET @Total_Milk_Amout = '';
					SET @Milk_Quantity_ltr = '';




					SELECT Amount, Base_FAT, Base_SNF INTO @Milk_Base_Rate, @Milk_Base_FAT, @Milk_Base_SNF
					FROM f002_milk_rate_current
					WHERE MCC_Id = var_MCC_Id AND MilkType_Id = var_MilkType_Id AND CollectionShift_Id = @CollectionShift_Id
						AND MilkRateEntryType_Id = 'C012001' AND Item_Applicable_Date < @Current_Datetime
					ORDER BY Item_Applicable_Date DESC LIMIT 1;
	
					SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);

					
					SET @Milk_Quantity_ltr = var_Weight;

                    
					set @CurrentMilkRate = GetMilkRate(var_Org_Id,var_MCC_Id,@CollectionShift_Id,var_Fat,var_SNF,var_MilkType_Id);
                    
					SET @Total_Milk_Amout = var_Weight * @CurrentMilkRate;
				
					

					IF (var_MilkStatus_Id = 'C016002') THEN
						delete from t005_milkcollectionfarmer
						where MCCCollectionShift_Id = @var_MCCCollectionShift_Id
						and Org_Id  = var_Org_Id
						and Farmer_Id = var_Farmer_Id;
						SET @FarmerCollection_Id = '';
						-- SET @Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
						CALL USP_Number_Range('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);

						INSERT INTO t005_milkcollectionfarmer (Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id,
															Farmer_Id,
															MilkType_Id, MilkStatus_Id, Quantity_Kg, Quantity_Ltr, Fat,
															SNF, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate,
															Amount, EntryTime, Is_Active,
															Is_Deleted, Created_On, CreatedBy_Id,
															CreatedBy_Name
						) VALUE
						(var_Org_Id, @FarmerCollection_Id, var_MCC_Id, @var_MCCCollectionShift_Id, var_Farmer_Id,
						var_MilkType_Id, var_MilkStatus_Id, (var_Weight / @kg_to_ltr), @Milk_Quantity_ltr, var_Fat, var_SNF,
						var_Quantity_Auto_Flag, var_Quality_Auto_Flag,
						@CurrentMilkRate, @Total_Milk_Amout, @Current_Datetime, 1, 0, @Current_Datetime, var_Profile_Id,
						(SELECT Agent_Name FROM mu05_agent WHERE Org_Id = var_Org_Id AND Agent_Id = @Agent_Id LIMIT 1));

						SELECT -1 AS Result_Id, 'Milk Rejected' AS Result_Description, '' AS Result_Extra_Key;

					ELSE
                    
						SET @Total_Milk_Amout = @CurrentMilkRate* var_Weight;

                      
						
						delete from t005_milkcollectionfarmer
						where MCCCollectionShift_Id = @var_MCCCollectionShift_Id
						and Org_Id  = var_Org_Id
						and Farmer_Id = var_Farmer_Id;

						SET @FarmerCollection_Id = '';
						SET @Year_Id = (SELECT RIGHT(LEFT(@Current_Datetime, 4), 2));
						CALL USP_Number_Range('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);

					
						INSERT INTO t005_milkcollectionfarmer (Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id,
															Farmer_Id,
															MilkType_Id, MilkStatus_Id, Quantity_Kg, Quantity_Ltr, Fat,
															SNF, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate,
															Amount, EntryTime, Is_Active,
															Is_Deleted, Created_On, CreatedBy_Id,
															CreatedBy_Name, MusterCycle_StartDate, MusterCycle_EndDate
						) VALUE
						(var_Org_Id, @FarmerCollection_Id, var_MCC_Id, @var_MCCCollectionShift_Id, var_Farmer_Id,
						var_MilkType_Id, var_MilkStatus_Id, (var_Weight / @kg_to_ltr), var_Weight, 
                        CAST(var_Fat AS DECIMAL(8,2)) , CAST(var_SNF AS DECIMAL(8,2)) ,
						var_Quantity_Auto_Flag, var_Quality_Auto_Flag,
						@CurrentMilkRate, @Total_Milk_Amout, @Current_Datetime, 1, 0, @Current_Datetime, var_Profile_Id,
						(SELECT Agent_Name FROM mu05_agent WHERE Org_Id = var_Org_Id AND Agent_Id = @Agent_Id LIMIT 1),
						@MusterCycle_StartDate, @MusterCycle_EndDate);

					END IF;		
			

		update t004_mcccollectionshift set 
            ShiftEnd_Time = @Current_times,
            LastEditedBy_Id =  @Agent_Id ,
            LastEdited_On =  @Current_Datetime,
            Shift_Status = 2,
            LastEditedBy_Name = (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and 
            Agent_Id =  @Agent_Id limit 1)
            where Org_Id = var_Org_Id and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;

			-- Agent 
            /*
            set @TotalMilkQuantity = '';
			set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
			
            set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
            into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
            from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
		
            set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
            set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
             set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
            into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
		
            set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
            set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
 
            Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            */
            
            if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = var_MCC_Id limit 1) then
							
				
											
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id) ;

				DROP TEMPORARY TABLE IF EXISTS temp_Report;

				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20),Collection_Date datetime);

				insert into temp_Report (Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date)
				select Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date 
				from t004_mcccollectionshift 
				where 
				Org_Id = var_Org_Id
				and MCC_Id =var_MCC_Id
                -- and CollectionShift_Id = @CollectionShift_Id
				and date(Collection_Date) <= date(@Current_Datetime)
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id 
												from t006_milkcollectionagent
												where 
												Org_Id = var_Org_Id
												and MCC_Id =var_MCC_Id)
												and date(Created_On) <= date(@Current_Datetime)
				order by Collection_Date  desc
				limit 2;
                

				set @MCCCollectionShift_Id_1  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  desc limit 1);
				set @MCCCollectionShift_Id_2  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  asc limit 1);
                
                
				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;

				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20));

				insert into temp_Report_Main (Org_Id,MCCCollectionShift_Id,MCC_Id)
				select t004.Org_Id,t004.MCCCollectionShift_Id,t004.MCC_Id 
				from t004_mcccollectionshift t004
				where t004.Org_Id = var_Org_Id
				and t004.MCC_Id =var_MCC_Id
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  <= REPLACE(@MCCCollectionShift_Id_1, 'T004', '')
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  > REPLACE(@MCCCollectionShift_Id_2, 'T004', '')
				order by Collection_Date  desc;
				
                
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
              
                
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
				
              
                
				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
                
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
			
                
				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
				
               
                
				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
              
                
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
	
				
				
				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
                
                
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				
                
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
                
				set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ); 
			   
				if(@AgentCollection_Id = '' OR  @AgentCollection_Id IS NULL ) then 
				
					Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
					
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @var_MCCCollectionShift_Id , @Agent_Id  , var_Profile_Id , 
					1,
					1 ,
					1, 
					1,
					@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
					@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
					@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
					0,1,0,@Current_Datetime, @Agent_Id  , (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and Agent_Id = @Agent_Id ) , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = var_Org_Id and 
					MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					
					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
					-- value 
					-- (var_Org_Id,@AgentCollection_Id, var_MilkType_Id, var_Weight , Var_FAT, Var_SNF, Var_MilkStatus_Id );
					select 
					Org_Id,   
					@AgentCollection_Id,
					MilkType_Id,
					sum(Quantity_Ltr) ,
					Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr))) as Fat,
					Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
					MilkStatus_Id
					from t005_milkcollectionfarmer 
					where Org_Id = var_Org_Id
					and MilkStatus_Id = 'C016001'
					and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main)
					group by Org_Id,MilkType_Id,MilkStatus_Id;
					
                    
					-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
			  else
              
					UPDATE t006_milkcollectionagent 
					SET Aluminum_Can_With_Lid =  1, 
					Aluminum_Can_Without_Lid = 1 ,
					Plastic_Can_With_Lid = 1, 
					Plastic_Can_Without_Lid =  1,
					Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
					Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
					Final_FAT_Cow_WtAvg = @CowFatweightAvg,
					Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
					Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
					Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
					Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
					Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
					Final_Amout_Cow = @TotalMilkAmountCow,
					Final_Amout_Buf =  @TotalMilkAmountBuffalo
					WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and AgentCollection_Id =  @AgentCollection_Id ;
					
					
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				   
				   
				   DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
					CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
						PKeyRowNum int, 
						Org_Id VARCHAR(45),
						Milktype_Id VARCHAR(45), 
						Quantity_Ltr DECIMAL(8,2), 
						FAT DECIMAL(8,2), 
						SNF DECIMAL(8,2)
					);
					
					
					 INSERT INTO temp_milkcollectionagent_item (
						Org_Id	,
						Milktype_Id,Quantity_Ltr,FAT,SNF)
					select 
					t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
					from t005_milkcollectionfarmer  t005
					WHERE t005.Org_Id = var_Org_Id 
					and t005.MCC_Id = var_MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main)
					group by  t005.Org_Id, t005.MilkType_Id;
					
					
				
                    
					UPDATE t006_milkcollectionagent_item  t006
					inner join temp_milkcollectionagent_item t005 on
					t005.Org_Id = t006.Org_Id
					and t005.MilkType_Id = var_MilkType_Id
					SET 
					t006.Quantity_Ltr =  t005.Quantity_Ltr, 
					t006.FAT =  t005.FAT,
					t006.SNF = t005.SNF
					WHERE t006.Org_Id = var_Org_Id 
					and t006.AgentCollection_Id =  @AgentCollection_Id
					and t006.Milktype_Id =  var_MilkType_Id ;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				end if;


			else
            
           
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				 set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				

				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
                
                
                set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ); 
			    
				if(@AgentCollection_Id = '' OR  @AgentCollection_Id IS NULL ) then 
				
					Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
					
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @var_MCCCollectionShift_Id , @Agent_Id  , var_Profile_Id , 
					1,
					1 ,
					1, 
					1,
					@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
					@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
					@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
					0,1,0,@Current_Datetime, @Agent_Id  , (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and Agent_Id = @Agent_Id ) , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = var_Org_Id and 
					MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
					-- value 
					-- (var_Org_Id,@AgentCollection_Id, var_MilkType_Id, var_Weight , Var_FAT, Var_SNF, Var_MilkStatus_Id );
					select 
					Org_Id,   
					@AgentCollection_Id,
					MilkType_Id,
					sum(Quantity_Ltr) ,
					Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr))) as Fat,
					Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
					MilkStatus_Id
					from t005_milkcollectionfarmer 
					where Org_Id = var_Org_Id
					and MilkStatus_Id = 'C016001'
					and MCCCollectionShift_Id = @var_MCCCollectionShift_Id 
					group by Org_Id,MilkType_Id,MilkStatus_Id;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
			  else
					UPDATE t006_milkcollectionagent 
					SET Aluminum_Can_With_Lid =  1, 
					Aluminum_Can_Without_Lid = 1 ,
					Plastic_Can_With_Lid = 1, 
					Plastic_Can_Without_Lid =  1,
					Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
					Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
					Final_FAT_Cow_WtAvg = @CowFatweightAvg,
					Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
					Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
					Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
					Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
					Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
					Final_Amout_Cow = @TotalMilkAmountCow,
					Final_Amout_Buf =  @TotalMilkAmountBuffalo
					WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and AgentCollection_Id =  @AgentCollection_Id ;
					
					
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				   
				   
				   DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
					CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
						PKeyRowNum int, 
						Org_Id VARCHAR(45),
						Milktype_Id VARCHAR(45), 
						Quantity_Ltr DECIMAL(8,2), 
						FAT DECIMAL(8,2), 
						SNF DECIMAL(8,2)
					);
					
					
					 INSERT INTO temp_milkcollectionagent_item (
						Org_Id	,
						Milktype_Id,Quantity_Ltr,FAT,SNF)
					select 
					t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
					from t005_milkcollectionfarmer  t005
					WHERE t005.Org_Id = var_Org_Id 
					and t005.MCC_Id = var_MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					group by  t005.Org_Id, t005.MilkType_Id;
					
					
					
					UPDATE t006_milkcollectionagent_item  t006
					inner join temp_milkcollectionagent_item t005 on
					t005.Org_Id = t006.Org_Id
					and t005.MilkType_Id = var_MilkType_Id
					SET 
					t006.Quantity_Ltr =  t005.Quantity_Ltr, 
					t006.FAT =  t005.FAT,
					t006.SNF = t005.SNF
					WHERE t006.Org_Id = var_Org_Id 
					and t006.AgentCollection_Id =  @AgentCollection_Id
					and t006.Milktype_Id =  var_MilkType_Id ;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				end if;
				

			end if;

            
            
			update t022_tripdocument_item 
			set Is_Reached = 2 ,
			Arrival_At = @Current_Datetime 
			where Org_Id = var_Org_Id 
			and TripDocument_Id = @TripDocument_Id
			and MCC_CollectionShift_Id = @var_MCCCollectionShift_Id
			and MCC_Id = var_MCC_Id;

			update t021_tripdocument_header 
			set Trip_Status = 'AtDairy' 
			where Org_Id = var_Org_Id and
			TripDocument_Id = @TripDocument_Id ;
            
            set @setCurrent_Datetime =  (select Collection_Date from t004_mcccollectionshift where 
			Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id limit 1);

			if(@setCurrent_Datetime is null or @setCurrent_Datetime = '')then
				set @setCurrent_Datetime = @Current_Datetime;
			else 
				set @setCurrent_Datetime = @setCurrent_Datetime;
			end if;

			update t005_milkcollectionfarmer 
			set Created_On = @setCurrent_Datetime
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
			SELECT 1 AS Result_Id, 
			'CollectMilk' AS Result_Description, 
			@var_MCCCollectionShift_Id AS Result_Extra_Key;
END;
    elseif (var_Method_Name = 'Collection') then
		begin
		DECLARE total_rows INT;
        DECLARE Set_MCC_CollectionShift_Id varchar(20);
        DECLARE loop_counter INT UNSIGNED DEFAULT 1;
        DECLARE current_org_id varchar(20);
        DECLARE current_driver_id varchar(20);
        DECLARE current_mcc_id varchar(20);
        DECLARE current_agent_id varchar(20);
        DECLARE current_agent_name varchar(255);
        DECLARE current_collectionshift_id varchar(20);
        DECLARE current_collectionshift_name varchar(255);
        DECLARE current_shiftstart_time time;
        DECLARE current_shiftend_time time;

        SET SQL_SAFE_UPDATES = 0;
		set sql_require_primary_key = 0 ;
		set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
		set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
		set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));

        IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
            set @TripDocument_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
                            and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
        else
            set @TripDocument_Id = var_TripDocument_Id;
        END IF;
        IF (var_CollectionShift_Id = '' OR  var_CollectionShift_Id IS NULL ) THEN 
            set @CollectionShift_Id  = (select  m006.CollectionShift_Id from t021_tripdocument_header t021
                            inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id and t021.Route_Trip_Id = m008.Entry_Id  
                            inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id  
                            where t021.Org_Id = var_Org_Id
                            and t021.TripDocument_Id = @TripDocument_Id);
        else
            set @CollectionShift_Id = var_CollectionShift_Id;
        END IF;

        DROP TEMPORARY TABLE IF EXISTS temp;
        DROP TEMPORARY TABLE IF EXISTS temp_agent;

        CREATE TEMPORARY TABLE temp (PKeyRowNum int, 
                Org_Id varchar(20),Driver_Id varchar(20),
				MCC_Id varchar(20),Agent_Id varchar(20), Agent_Name varchar(255), 
                CollectionShift_Id varchar(20), CollectionShift_Name varchar(255), 
                ShiftStart_Time time,ShiftEnd_Time time);

        CREATE TEMPORARY TABLE temp_agent ( 
                Org_Id varchar(20),AgentCollection_Id varchar(20),
				Milktype_Id varchar(20),MilkStatus_Id varchar(20));

        SET @PKeyRowNum := 0;

        INSERT INTO temp (PKeyRowNum,Org_Id,Driver_Id, MCC_Id, Agent_Id, 
					Agent_Name, CollectionShift_Id, CollectionShift_Name,
                    ShiftStart_Time,ShiftEnd_Time)
        SELECT @PKeyRowNum := @PKeyRowNum + 1, t021.Org_Id,t021.Driver_Id,
        m005.MCC_Id,
        mu05.Agent_Id,mu05.Agent_Name,
        c015.CollectionShift_Id ,c015.CollectionShift_Name,c015.ShiftStart_Time,c015.ShiftEnd_Time
        from t021_tripdocument_header t021
        inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id and t021.Route_Trip_Id = m008.Entry_Id  
        inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id 
        inner join c015_collectionshift c015 on m006.CollectionShift_Id = c015.CollectionShift_Id
        inner join t022_tripdocument_item t022 on t022.Org_Id = t021.Org_Id and t022.TripDocument_Id = t021.TripDocument_Id 
        inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id  
        inner join mu05_agent mu05 on m005.Org_Id = mu05.Org_Id and m005.Agent_Id = mu05.Agent_Id
        where t021.Org_Id = var_Org_Id
        and t021.TripDocument_Id = @TripDocument_Id;
		
        SELECT COUNT(*) INTO total_rows FROM temp; 
        
        select MCC_CollectionShift_Id  into Set_MCC_CollectionShift_Id
		from t022_tripdocument_item 
		where Org_Id = var_Org_Id
		and TripDocument_Id = @TripDocument_Id order by MCC_CollectionShift_Id desc limit 1;
        
        IF (Set_MCC_CollectionShift_Id IS NOT NULL AND Set_MCC_CollectionShift_Id <> '') THEN
		
        SELECT -1 AS Result_Id, 
		'Collection entries already exists for this Trip.  You cant create new collection entries' AS Result_Description, 
		@TripDocument_Id AS Result_Extra_Key;
        
        else

        WHILE loop_counter <= total_rows DO

            SELECT Org_Id,Driver_Id, MCC_Id, Agent_Id, Agent_Name, CollectionShift_Id,CollectionShift_Name,ShiftStart_Time,ShiftEnd_Time
					INTO current_org_id,current_driver_id, current_mcc_id, current_agent_id, current_agent_name, current_collectionshift_id,current_collectionshift_name,current_shiftstart_time,current_shiftend_time
					FROM temp
					WHERE PKeyRowNum = loop_counter;

            Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);

            Insert Into t004_mcccollectionshift
                (Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
                Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , 
                Created_On , CreatedBy_Id ,CreatedBy_Name,LastEdited_On,LastEditedBy_Id,
                Is_MilkDispatch, Expected_End_Time)
				Values (current_org_id,@New_MCCCollectionShift_Id,current_mcc_id,@Current_Datetime ,current_collectionshift_id,current_collectionshift_name,
                2,@Current_times,1,0,
                @Current_Datetime,current_agent_id,current_agent_name,@Current_Datetime,current_agent_id,
                0,current_shiftend_time); 


                
                set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = current_mcc_id and is_deleted = 0 and 
                                        Applicable_Date <= @Current_Datetime
                                        order by Applicable_Date desc limit 1 ) ;
                    
                Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

				if(@MusterType = 1)then 
					
                    Set @MusterCycle_StartDate = @Current_Datetime;
                    set @MusterCycle_EndDate =  @Current_Datetime;
                    
                elseif(@MusterType = 7) then 
						
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7 ) then
                        
                        Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-07');
                        
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-14');

					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
                        
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15 ) then
                    
                        Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
                    
                    else 
                        Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
                        set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
                    
                    end if;
                        
				elseif(@MusterType = 5) then 
                        
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5 ) then
                        
                        Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-05');
                        
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
                        
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
                    
                    end if;
                    
                elseif(@MusterType = 10) then 
                        
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10 ) then
                        
                        Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');
                        
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
                    
                    end if;
                
				elseif(@MusterType = 30) then 
                        
                    Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
                    set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
                        
				end if;
				
                
                
                

                Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);


            insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
                Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
                Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
                Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
                Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
                ) values 
                ( current_org_id, @AgentCollection_Id , current_mcc_id , @New_MCCCollectionShift_Id , current_agent_id , current_driver_id , 
                0,0,0,0,0, 0, 0,0,0,0,0, 0, 0, 0,0,1,0,
                @Current_Datetime, current_agent_id ,current_agent_name , @MusterCycle_StartDate , @MusterCycle_EndDate
                ) ;

			INSERT INTO temp_agent (Org_Id, AgentCollection_Id, Milktype_Id, MilkStatus_Id)
			SELECT current_org_id ,@AgentCollection_Id,m0052.MilkType_Id,'C016001'
			FROM m005_mcc m005
			INNER JOIN m005_mcc_milktype m0052 ON m0052.Org_Id = m005.Org_Id 
				AND m0052.MCC_Id = m005.MCC_Id
				AND m0052.Version_No = (
					SELECT m0051.Version_No
					FROM m005_mcc m005
					INNER JOIN m005_mcc_version m0051 ON m0051.Org_Id = m005.Org_Id 
						AND m0051.MCC_Id = m005.MCC_Id
						AND m0051.Is_Active = 1
						AND m0051.Is_Deleted = 0
						AND m0051.Applicable_Date <= @Current_Datetime
					WHERE m0051.Org_Id = current_org_id 
						AND m0051.MCC_Id = current_mcc_id
					ORDER BY m0051.Applicable_Date DESC
					LIMIT 1
				)
			WHERE m005.Org_Id = current_org_id 
				AND m005.MCC_Id = current_mcc_id;

			update t022_tripdocument_item 
			set MCC_CollectionShift_Id = @New_MCCCollectionShift_Id
			where Org_Id = var_Org_Id and
			TripDocument_Id = @TripDocument_Id and
            MCC_Id = current_mcc_id;
            
            SET loop_counter = loop_counter + 1;
		END WHILE;

        INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
		SELECT Org_Id,AgentCollection_Id,Milktype_Id,0,0,0,MilkStatus_Id
		FROM temp_agent;
		
        update t022_tripdocument_item 
        set Is_Reached = 2 ,
        Arrival_At = @Current_Datetime 
        where Org_Id = var_Org_Id and
        TripDocument_Id = @TripDocument_Id;
        
        update t021_tripdocument_header 
        set Trip_Status = 'AtDairy' 
        where Org_Id = var_Org_Id and
        TripDocument_Id = @TripDocument_Id ;
        
        end if;
        
		SELECT 1 AS Result_Id, 
		'Collection entries added for this Trip.' AS Result_Description, 
		@TripDocument_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'BulkCollectMilk') then
		proc_Exit: begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			declare	var_Quantity_Auto_Flag int;
			declare var_Quality_Auto_Flag int ;
            SET SQL_SAFE_UPDATES = 0;
            
			set var_Quantity_Auto_Flag = 0;
        	set var_Quality_Auto_Flag = 0;
           
		   	set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            set @Year_Id = (select right(left(@Current_Datetime,4),(2)));
            set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
           
            set @Agent_Name = (
			SELECT Agent_Name FROM mu05_agent 
			where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);
            
            IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
				set @TripDocument_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
										and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
			else
				set @TripDocument_Id = var_TripDocument_Id;
			END IF;
            
           
            
            IF (var_CollectionShift_Id = '' OR  var_CollectionShift_Id IS NULL ) THEN 
				set @CollectionShift_Id  = (select  m006.CollectionShift_Id from t021_tripdocument_header t021
								inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id and t021.Route_Trip_Id = m008.Entry_Id  
								inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id  
								where t021.Org_Id = var_Org_Id
								and t021.TripDocument_Id = @TripDocument_Id);
			else
				set @CollectionShift_Id = var_CollectionShift_Id;
			END IF;
            
            
            
            SELECT CollectionShift_Name  into @CollectionShift_Name
            FROM c015_collectionshift 
            where CollectionShift_Id = @CollectionShift_Id ;
            
            set @MCCType_Id = (select MCCType_Id from m005_mcc where MCC_Id = var_MCC_Id
								and Org_Id = var_Org_Id);
                                
			if(@MCCType_Id ='C014002' and @CollectionShift_Id ='C015003')then
            
				set @var_MCCCollectionShift_Id  = (select MCCCollectionShift_Id 
														from t004_mcccollectionshift t004
														where t004.MCC_Id = var_MCC_Id
														and t004.Org_Id = var_Org_Id
														and date(t004.Collection_Date) =  date(@Current_Datetime)
														order by t004.Collection_Date desc limit 1);
				
                set var_MCCCollectionShift_Id = @var_MCCCollectionShift_Id;
                
            end if;
            
            IF (var_MCCCollectionShift_Id = '' OR  var_MCCCollectionShift_Id IS NULL ) THEN 
					set @var_MCCCollectionShift_Id  = (select MCCCollectionShift_Id 
														from t004_mcccollectionshift t004
														where t004.MCC_Id = var_MCC_Id
														and t004.Org_Id = var_Org_Id
														and t004.CollectionShift_Id = @CollectionShift_Id
														and date(t004.Collection_Date) =  date(@Current_Datetime)
														order by t004.Collection_Date desc limit 1);
 
				if(@var_MCCCollectionShift_Id = '' OR  @var_MCCCollectionShift_Id IS NULL )then
					
					set @New_MCCCollectionShift_Id ='';
					
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
			
					select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;

					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
					2, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , Agent_Name , 0 , @ShiftEnd_Time
					from mu05_agent where Org_Id = var_Org_Id and 
					Agent_Id = @Agent_Id limit 1 ) ;

					set @var_MCCCollectionShift_Id =  @New_MCCCollectionShift_Id;
				end if;
			else
				set @var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
			END IF;
            
            
            
            
            
           
           SET @MusterType_Id = (SELECT m005.MusterType_Id
											FROM m005_mcc_version m005
											WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
												AND Applicable_Date <= @Current_Datetime
											ORDER BY Applicable_Date DESC LIMIT 1);

			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);

			
			IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = @Current_Datetime;
				SET @MusterCycle_EndDate = @Current_Datetime;

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

			END IF;
           
            update t022_tripdocument_item 
			set MCC_CollectionShift_Id = @var_MCCCollectionShift_Id
			where Org_Id = var_Org_Id 
			and TripDocument_Id = @TripDocument_Id
			and MCC_Id = var_MCC_Id;
           
			delete from t005_milkcollectionfarmer
			where MCCCollectionShift_Id = @var_MCCCollectionShift_Id
			and Org_Id  = var_Org_Id;

           
			
            SET row_count := extractValue(var_CollectionData,'count(//CollectionData/Farmer)');
			
            WHILE k < row_count DO
				set Set_Farmer_Id ='';
				SET k := k + 1;
				SET xpath := concat('//CollectionData/Farmer[', k, ']');
               
               
                   
                  
				   	select Farmer_Id into Set_Farmer_Id from mu04_farmer where Org_Id = var_Org_Id
					and MCC_Farmer_Code = extractValue(var_CollectionData, concat(xpath,'/MCC_Farmer_Code'))
					and MCC_Id = var_MCC_Id;
                    
                    if(Set_Farmer_Id is not null and Set_Farmer_Id <> '') then

					SET @Milk_Base_Rate = '';
					SET @Milk_Base_FAT = '';
					SET @Milk_Base_SNF = '';
					SET @Milk_Fat_Deduction = '';
					SET @Milk_Snf_Deduction = '';
					SET @Milk_High_fat = '';
					SET @Milk_High_Snf = '';
					SET @Total_Milk_Amout = '';
					SET @Milk_Quantity_ltr = '';



					SELECT Amount, Base_FAT, Base_SNF INTO @Milk_Base_Rate, @Milk_Base_FAT, @Milk_Base_SNF
					FROM f002_milk_rate_current
					WHERE MCC_Id = var_MCC_Id AND MilkType_Id = extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')) AND CollectionShift_Id = @CollectionShift_Id
						AND MilkRateEntryType_Id = 'C012001' AND Item_Applicable_Date < @Current_Datetime
					ORDER BY Item_Applicable_Date DESC LIMIT 1;


					SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);

					SET @Milk_Quantity_ltr = extractValue(var_CollectionData, concat(xpath,'/Liters'));

					-- SET @Milk_Base_Rate = CAST(@Milk_Base_Rate AS DECIMAL(8, 2));
                    
                    set @CurrentMilkRate = GetMilkRate(var_Org_Id,var_MCC_Id,@CollectionShift_Id,
                    extractValue(var_CollectionData, concat(xpath,'/Fat')),
                    extractValue(var_CollectionData, concat(xpath,'/SNF')),
                    extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')));
                    

					SET @Total_Milk_Amout = extractValue(var_CollectionData, concat(xpath,'/Liters')) * @CurrentMilkRate;

					IF (extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')) = 'C016002') THEN

						SET @FarmerCollection_Id = '';
						-- SET @Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
						CALL USP_Number_Range('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);

						INSERT INTO t005_milkcollectionfarmer (Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id,
															Farmer_Id,
															MilkType_Id, MilkStatus_Id, Quantity_Kg, Quantity_Ltr, Fat,
															SNF, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate,
															Amount, EntryTime, Is_Active,
															Is_Deleted, Created_On, CreatedBy_Id,
															CreatedBy_Name
						) VALUE
						(var_Org_Id, @FarmerCollection_Id, var_MCC_Id, @var_MCCCollectionShift_Id, Set_Farmer_Id,
						extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')), extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')), (extractValue(var_CollectionData, concat(xpath,'/Liters')) / @kg_to_ltr), extractValue(var_CollectionData, concat(xpath,'/Liters')), extractValue(var_CollectionData, concat(xpath,'/Fat')), extractValue(var_CollectionData, concat(xpath,'/SNF')),
						var_Quantity_Auto_Flag, var_Quality_Auto_Flag,
						@CurrentMilkRate, @Total_Milk_Amout, @Current_Datetime, 1, 0, var_Date, var_Profile_Id,
						(SELECT Agent_Name FROM mu05_agent WHERE Org_Id = var_Org_Id AND Agent_Id = @Agent_Id LIMIT 1));

						SELECT -1 AS Result_Id, 'Milk Rejected' AS Result_Description, '' AS Result_Extra_Key;

					ELSE
						

						SET @FarmerCollection_Id = '';
						SET @Year_Id = (SELECT RIGHT(LEFT(@Current_Datetime, 4), 2));
						CALL USP_Number_Range('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);

						INSERT INTO t005_milkcollectionfarmer (Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id,
															Farmer_Id,
															MilkType_Id, MilkStatus_Id, Quantity_Kg, Quantity_Ltr, Fat,
															SNF, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate,
															Amount, EntryTime, Is_Active,
															Is_Deleted, Created_On, CreatedBy_Id,
															CreatedBy_Name, MusterCycle_StartDate, MusterCycle_EndDate
						) VALUE
						(var_Org_Id, @FarmerCollection_Id, var_MCC_Id, @var_MCCCollectionShift_Id, Set_Farmer_Id,
						extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')), extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')), (extractValue(var_CollectionData, concat(xpath,'/Liters')) / @kg_to_ltr), extractValue(var_CollectionData, concat(xpath,'/Liters')), extractValue(var_CollectionData, concat(xpath,'/Fat')), extractValue(var_CollectionData, concat(xpath,'/SNF')),
						var_Quantity_Auto_Flag, var_Quality_Auto_Flag,
						@CurrentMilkRate, @Total_Milk_Amout, @Current_Datetime, 1, 0, @Current_Datetime, var_Profile_Id,
						(SELECT Agent_Name FROM mu05_agent WHERE Org_Id = var_Org_Id AND Agent_Id = @Agent_Id LIMIT 1),
						@MusterCycle_StartDate, @MusterCycle_EndDate);

					-- 	SELECT 1 AS Result_Id, 'Milk Collected' AS Result_Description, '' AS Result_Extra_Key;

					END IF;
                    
				 end if;

               --  END IF;
			END WHILE;


			update t004_mcccollectionshift set 
            ShiftEnd_Time = @Current_times,
            LastEditedBy_Id =  @Agent_Id ,
            LastEdited_On =  @Current_Datetime,
            Shift_Status = 2,
            LastEditedBy_Name = (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and 
            Agent_Id =  @Agent_Id limit 1)
            where Org_Id = var_Org_Id and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;

			-- Agent 
            
            set @TotalMilkQuantity = '';
			set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
			
            set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
            into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
            from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
		
            set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
            set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
             set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
            into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
		
            set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
            set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
            and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
 
            Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ); 
			
				
                
            if(@AgentCollection_Id = '' OR  @AgentCollection_Id IS NULL ) then 
            
                Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                

                insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
				Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
				Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
				Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
				 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
				) values 
				( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @var_MCCCollectionShift_Id , @Agent_Id  , var_Profile_Id , 
				1,
				1 ,
				1, 
				1,
				@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
				@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
				@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
				0,1,0,var_Date, @Agent_Id  , (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and Agent_Id = @Agent_Id ) , @MusterCycle_StartDate , @MusterCycle_EndDate
				) ;
                
                update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = var_Org_Id and 
				MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;
                
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				
                    
				DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
				CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
					PKeyRowNum int, 
					Org_Id VARCHAR(20),
					AgentCollection_Id VARCHAR(45),
					Milktype_Id VARCHAR(45), 
					Quantity_Ltr DECIMAL(8,2), 
                    FAT DECIMAL(8,2), 
                    SNF DECIMAL(8,2), 
                    MilkStatus_Id VARCHAR(45)
				);
                SET @PKeyRowNum := 0;
                
				SET row_count := extractValue(var_CollectionData,'count(//CollectionData/Farmer)');
				Set k := 0;
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//CollectionData/Farmer[', k, ']');
                    
                    INSERT INTO temp_milkcollectionagent_item VALUES (
						k,
						var_Org_Id,
                        @AgentCollection_Id,
						extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')),
						extractValue(var_CollectionData, concat(xpath,'/Liters')),
						extractValue(var_CollectionData, concat(xpath,'/Fat')),
						extractValue(var_CollectionData, concat(xpath,'/SNF')),
					   extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id'))
					);
				END WHILE;
                
                INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
                Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
				SELECT Org_Id,AgentCollection_Id,Milktype_Id,
                sum(Quantity_Ltr),
                Roundoff('Quality',sum(Quantity_Ltr * FAT) / (sum(Quantity_Ltr))),
                Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))),
                -- avg(FAT),
                -- avg(SNF),
                MilkStatus_Id
				FROM temp_milkcollectionagent_item
				GROUP BY Org_Id,AgentCollection_Id,Milktype_Id,MilkStatus_Id;
                    
				-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
            
			else
            
				
                    
				UPDATE t006_milkcollectionagent 
				SET Aluminum_Can_With_Lid =  1, 
				Aluminum_Can_Without_Lid = 1 ,
				Plastic_Can_With_Lid = 1, 
				Plastic_Can_Without_Lid =  1,
				Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
				Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
				Final_FAT_Cow_WtAvg = @CowFatweightAvg,
				Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
				Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
				Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
				Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
				Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
				Final_Amout_Cow = @TotalMilkAmountCow,
				Final_Amout_Buf =  @TotalMilkAmountBuffalo
				WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id
				and AgentCollection_Id =  @AgentCollection_Id ;
                
               
                set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
			   
               
               DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
				CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
					PKeyRowNum int, 
                    Org_Id VARCHAR(45),
					Milktype_Id VARCHAR(45), 
					Quantity_Ltr DECIMAL(8,2), 
                    FAT DECIMAL(8,2), 
                    SNF DECIMAL(8,2)
				);
                
                
				 INSERT INTO temp_milkcollectionagent_item (
					Org_Id	,
					Milktype_Id,Quantity_Ltr,FAT,SNF)
				select 
                t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
                Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
                Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
                from t005_milkcollectionfarmer  t005
                WHERE t005.Org_Id = var_Org_Id 
                and t005.MCC_Id = var_MCC_Id  
                and t005.MilkStatus_Id = 'C016001'
                and t005.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
                group by  t005.Org_Id, t005.MilkType_Id;
                
                
                
                UPDATE t006_milkcollectionagent_item  t006
                inner join temp_milkcollectionagent_item t005 on
                t005.Org_Id = t006.Org_Id
                and t005.MilkType_Id = t006.MilkType_Id
				SET 
                t006.Quantity_Ltr =  t005.Quantity_Ltr, 
				t006.FAT =  t005.FAT,
				t006.SNF = t005.SNF
				WHERE t006.Org_Id = var_Org_Id 
                and t006.AgentCollection_Id =  @AgentCollection_Id;
                
				-- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
            end if;
            
           
            
			update t022_tripdocument_item 
			set Is_Reached = 2 ,
			Arrival_At = @Current_Datetime 
			where Org_Id = var_Org_Id 
			and TripDocument_Id = @TripDocument_Id
			and MCC_CollectionShift_Id = @var_MCCCollectionShift_Id
			and MCC_Id = var_MCC_Id;

			update t021_tripdocument_header 
			set Trip_Status = 'AtDairy' 
			where Org_Id = var_Org_Id and
			TripDocument_Id = @TripDocument_Id ;
            
            set @setCurrent_Datetime =  (select Collection_Date from t004_mcccollectionshift where 
			Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id limit 1);

			if(@setCurrent_Datetime is null or @setCurrent_Datetime = '')then
				set @setCurrent_Datetime = @Current_Datetime;
			else 
				set @setCurrent_Datetime = @setCurrent_Datetime;
			end if;

			update t005_milkcollectionfarmer 
			set Created_On = @setCurrent_Datetime
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
			SELECT 1 AS Result_Id, 
			'Collection' AS Result_Description, 
			@var_MCCCollectionShift_Id AS Result_Extra_Key;
            
          
        end;
		elseif (var_Method_Name = 'ChemistCollectMilk') then
        begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			declare	var_Quantity_Auto_Flag int;
			declare var_Quality_Auto_Flag int ;
            SET SQL_SAFE_UPDATES = 0;
            
			set var_Quantity_Auto_Flag = 0;
        	set var_Quality_Auto_Flag = 0;
           
		   	set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            set @Year_Id = (select right(left(@Current_Datetime,4),(2)));
            set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
           
            set @Agent_Name = (
			SELECT Agent_Name FROM mu05_agent 
			where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);
            
            IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
				set @TripDocument_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
										and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
			else
				set @TripDocument_Id = var_TripDocument_Id;
			END IF;
            
            IF (var_CollectionShift_Id = '' OR  var_CollectionShift_Id IS NULL ) THEN 
				set @CollectionShift_Id  = (select  m006.CollectionShift_Id from t021_tripdocument_header t021
								inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id and t021.Route_Trip_Id = m008.Entry_Id  
								inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id  
								where t021.Org_Id = var_Org_Id
								and t021.TripDocument_Id = @TripDocument_Id);
			else
				set @CollectionShift_Id = var_CollectionShift_Id;
			END IF;
            
            
            SELECT CollectionShift_Name  into @CollectionShift_Name
            FROM c015_collectionshift 
            where CollectionShift_Id = @CollectionShift_Id ;
            
            
             IF (var_MCCCollectionShift_Id = '' OR  var_MCCCollectionShift_Id IS NULL ) THEN 
					set @var_MCCCollectionShift_Id  = (select MCCCollectionShift_Id 
														from t004_mcccollectionshift t004
														where t004.MCC_Id = var_MCC_Id
														and t004.Org_Id = var_Org_Id
														and t004.CollectionShift_Id = @CollectionShift_Id
														and date(t004.Collection_Date) =  date(@Current_Datetime)
														order by t004.Collection_Date desc limit 1);
 
				
			else
				set @var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;
			END IF;
            
			set @VehicleType_Id = (SELECT VehicleType_Id FROM m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id =  var_Vehicle_Id );
            
            if (@VehicleType_Id = 'C020002') then
            
				set @Count  = (select count(t022.MCC_CollectionShift_Id)
								from t022_tripdocument_item t022
								inner join t021_tripdocument_header t021 on
								t021.Org_Id = t022.Org_Id
								and t021.TripDocument_Id = t022.TripDocument_Id
								and date(t021.Created_On) = date(@Current_Datetime)
								where t022.Org_Id = var_Org_Id
								and t022.MCC_Id = var_MCC_Id
								and t022.MCC_CollectionShift_Id = @var_MCCCollectionShift_Id
								group by t022.MCC_CollectionShift_Id);
                                
                                
				set @MCC_Count = (select count(t022.MCC_Id)
								from t022_tripdocument_item t022
								inner join t021_tripdocument_header t021 on
								t021.Org_Id = t022.Org_Id
								and t021.TripDocument_Id = t022.TripDocument_Id
								and date(t021.Created_On) = date(@Current_Datetime)
								where t022.Org_Id = var_Org_Id
								and t022.MCC_Id = var_MCC_Id
								group by t022.MCC_Id);
                
                if(@Count = '1')then
                
					set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
					set @ChemistCollection_Id  = '';
					Call USP_Number_Range ('t008_milkcollectionchemist', @Year_Id, 'T008', '', @ChemistCollection_Id );
					
					delete t0081 from t008_milkcollectionchemist_item t0081
					inner join  t008_milkcollectionchemist t008 on t0081.Org_Id = t008.Org_Id
					and t008.Trip_Id = var_TripDocument_Id
                    and t008.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
					and t0081.Comartment =  concat('[',var_CellNo,']') 
					where t0081.Org_Id  = var_Org_Id;
					
					delete t0081 from t008_milkcollectionchemist_compartment t0081
					inner join  t008_milkcollectionchemist t008 on t0081.Org_Id = t008.Org_Id
					and t008.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
                    and t008.Trip_Id = var_TripDocument_Id
					and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
					and t0081.Compartment_No = var_CellNo
					where t0081.Org_Id  = var_Org_Id;
					
				   
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					insert into t008_milkcollectionchemist (Org_Id ,ChemistCollection_Id, Trip_Id, MCC_Id ,Driver_Id , MCCCollectionShift_Id,
					 Is_Active ,Is_BMC_Accepted, Created_On , CreatedBy_Id ) values 
					(var_Org_Id,@ChemistCollection_Id, @TripDocument_Id , var_MCC_Id ,var_Profile_Id,  @var_MCCCollectionShift_Id, 
					1 ,1, @Current_Datetime, var_Profile_Id);
					
					
					INSERT INTO t008_milkcollectionchemist_item (Org_Id ,ChemistCollection_Id, MilkType_Id  ,  Quantity_Kg,Quantity_Ltr,
					FAT , SNF , MilkStatus_Id,Comartment)
					values (var_Org_Id,@ChemistCollection_Id,var_MilkType_Id,var_Weight,var_Weight * @kg_to_ltr,
					var_Fat,var_SNF,var_MilkStatus_Id,
					concat('[',var_CellNo,']')
					);
					
					delete from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id  and MCC_Id = Var_MCC_Id
					and ChemistCollection_Id = @ChemistCollection_Id;
					
					INSERT INTO t008_milkcollectionchemist_compartment (Org_Id,ChemistCollection_Id, MilkType_Id,
					Compartment_No,MCC_Id,Quantity_Kg,Quantity_Ltr)
					values (var_Org_Id,@ChemistCollection_Id,var_MilkType_Id,
					var_CellNo,var_MCC_Id,var_Weight,var_Weight * @kg_to_ltr
				   );
				   
					 delete from t008_milkcollectionchemist_item where  Org_Id = var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id and
					( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
					
					delete from t008_milkcollectionchemist_compartment where  Org_Id = var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id and
					( Quantity_Ltr = 0  or Quantity_Ltr is null  or Quantity_Ltr = 0.0 ) ;
					
					SELECT 1 AS Result_Id, 
					'Collection' AS Result_Description, 
					@var_MCCCollectionShift_Id AS Result_Extra_Key;
					
					call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
					't006_milkcollectionagent', @var_MCCCollectionShift_Id, var_MCC_Id, @ChemistCollection_Id, 
					var_User_Id, var_User_Name);
                    
                else
					set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
                   
					/*
					set @New_MCCCollectionShift_Id = '';
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
                    
					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					select 
					Org_Id, @New_MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time
					from t004_mcccollectionshift
					where Org_Id = var_Org_Id
					and MCC_Id = var_MCC_Id
					and MCCCollectionShift_Id = @var_MCCCollectionShift_Id limit 1;
                    
                    set @var_MCCCollectionShift_Id = @New_MCCCollectionShift_Id;
					*/
                    
					update t022_tripdocument_item 
					set DispatchNo = @MCC_Count
					where Org_Id = var_Org_Id 
					and TripDocument_Id = @TripDocument_Id
					and MCC_Id = var_MCC_Id;
					
					set @ChemistCollection_Id  = '';
					Call USP_Number_Range ('t008_milkcollectionchemist', @Year_Id, 'T008', '', @ChemistCollection_Id );
					
					delete t0081 from t008_milkcollectionchemist_item t0081
					inner join  t008_milkcollectionchemist t008 on t0081.Org_Id = t008.Org_Id
					and t008.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
                    and t008.Trip_Id = var_TripDocument_Id
					and t0081.Comartment =  concat('[',var_CellNo,']') 
					where t0081.Org_Id  = var_Org_Id;
					
					delete t0081 from t008_milkcollectionchemist_compartment t0081
					inner join  t008_milkcollectionchemist t008 on t0081.Org_Id = t008.Org_Id
					and t008.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
                    and t008.Trip_Id = var_TripDocument_Id
					and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
					and t0081.Compartment_No = var_CellNo
					where t0081.Org_Id  = var_Org_Id;
					
				   
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					insert into t008_milkcollectionchemist (Org_Id ,ChemistCollection_Id, Trip_Id, MCC_Id ,Driver_Id , MCCCollectionShift_Id,
					 Is_Active ,Is_BMC_Accepted, Created_On , CreatedBy_Id ,DispatchNo) values 
					(var_Org_Id,@ChemistCollection_Id, @TripDocument_Id , var_MCC_Id ,var_Profile_Id,  @var_MCCCollectionShift_Id, 
					1 ,1, @Current_Datetime, var_Profile_Id,@MCC_Count);
					
					
					INSERT INTO t008_milkcollectionchemist_item (Org_Id ,ChemistCollection_Id, MilkType_Id  ,  Quantity_Kg,Quantity_Ltr,
					FAT , SNF , MilkStatus_Id,Comartment)
					values (var_Org_Id,@ChemistCollection_Id,var_MilkType_Id,var_Weight,var_Weight * @kg_to_ltr,
					var_Fat,var_SNF,var_MilkStatus_Id,
					concat('[',var_CellNo,']')
					);
					
					delete from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id  and MCC_Id = Var_MCC_Id
					and ChemistCollection_Id = @ChemistCollection_Id;
					
					INSERT INTO t008_milkcollectionchemist_compartment (Org_Id,ChemistCollection_Id, MilkType_Id,
					Compartment_No,MCC_Id,Quantity_Kg,Quantity_Ltr)
					values (var_Org_Id,@ChemistCollection_Id,var_MilkType_Id,
					var_CellNo,var_MCC_Id,var_Weight,var_Weight * @kg_to_ltr
				   );
				   
					 delete from t008_milkcollectionchemist_item where  Org_Id = var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id and
					( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
					
					delete from t008_milkcollectionchemist_compartment where  Org_Id = var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id and
					( Quantity_Ltr = 0  or Quantity_Ltr is null  or Quantity_Ltr = 0.0 ) ;
					
					SELECT 1 AS Result_Id, 
					'Collection' AS Result_Description, 
					@var_MCCCollectionShift_Id AS Result_Extra_Key;
					
					call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
					't006_milkcollectionagent', @var_MCCCollectionShift_Id, var_MCC_Id, @ChemistCollection_Id, 
					var_User_Id, var_User_Name);
                
                end if;
            end if;
        end;
	elseif (var_Method_Name = 'DeleteAgent') then
        begin
	
			DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			AgentCollection_Id varchar(20));
             
			insert into temp_Voucher(AgentCollection_Id)
            select AgentCollection_Id from t006_milkcollectionagent
			where Org_Id = Var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
                            
			SET SQL_SAFE_UPDATES = 0;
            
            delete from t006_milkcollectionagent
			where Org_Id = var_Org_Id
			and AgentCollection_Id  in (select AgentCollection_Id from temp_Voucher);

			delete from t006_milkcollectionagent_item
			where Org_Id = var_Org_Id
			and AgentCollection_Id in (select AgentCollection_Id from temp_Voucher);
            
            SELECT 1 AS Result_Id, 
			'Delete' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			't006_milkcollectionagent', var_MCCCollectionShift_Id, var_MCC_Id, '', 
			var_User_Id, var_User_Name);

			
            
        end;
	elseif (var_Method_Name = 'DeleteChemist') then
        begin
			
            set @DispatchNo = (select DispatchNo from t022_tripdocument_item
			where Org_Id = Var_Org_Id
			and TripDocument_Id = var_TripDocument_Id
            and MCC_CollectionShift_Id = var_MCCCollectionShift_Id limit 1);
	
			DROP TEMPORARY TABLE IF EXISTS temp_Voucher;
			CREATE TEMPORARY TABLE temp_Voucher ( 
			ChemistCollection_Id varchar(20));
             
			insert into temp_Voucher(ChemistCollection_Id)
            select ChemistCollection_Id from t008_milkcollectionchemist
			where Org_Id = Var_Org_Id
			and MCC_Id = var_MCC_Id
            and DispatchNo =  @DispatchNo
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
                            
			SET SQL_SAFE_UPDATES = 0;
            
            delete from t008_milkcollectionchemist
			where Org_Id = var_Org_Id
			and ChemistCollection_Id  in (select ChemistCollection_Id from temp_Voucher);

			delete from t008_milkcollectionchemist_compartment
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (select ChemistCollection_Id from temp_Voucher);
            
            delete from t008_milkcollectionchemist_item
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (select ChemistCollection_Id from temp_Voucher);
            
            SELECT 1 AS Result_Id, 
			'Delete' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			't008_milkcollectionchemist', var_MCCCollectionShift_Id, var_MCC_Id, '', 
			var_User_Id, var_User_Name);

			
            
        end;
	elseif (var_Method_Name = 'GetMCCCollectionShiftId') then
        begin
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            
            set @MCC_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift
											where Org_Id = var_Org_Id
											and MCC_Id = var_MCC_Id 
											and CollectionShift_Id = var_CollectionShift_Id
											and date(Collection_Date)= date(@Current_Datetime)
											limit 1);
			if(@MCC_CollectionShift_Id is null or @MCC_CollectionShift_Id = '')then
				set @MCC_CollectionShift_Id = '';
            else
				
				update t022_tripdocument_item 
				set MCC_CollectionShift_Id = @MCC_CollectionShift_Id
				where Org_Id = var_Org_Id 
				and TripDocument_Id = var_TripDocument_Id
				and MCC_Id = var_MCC_Id;
                
            end if;
			
            SELECT 1 AS Result_Id, 
			'Found' AS Result_Description, 
			@MCC_CollectionShift_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'DeleteFarmerCollection') then
			proc_Exit: begin
			Declare Is_Locked varchar(20);
			Declare var_MilkType_Id varchar(20);

			set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            
			set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
            set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
           
            set @Agent_Name = (
			SELECT Agent_Name FROM mu05_agent 
			where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);
            

			SELECT t005.Is_InvoiceCreated,MilkType_Id
			into Is_Locked ,var_MilkType_Id
			FROM t005_milkcollectionfarmer t005
			where t005.Org_Id = var_Org_Id
			and t005.MCC_Id = var_MCC_Id
			and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id
			and t005.Farmer_Id = var_Farmer_Id;

			set @var_MCCCollectionShift_Id = var_MCCCollectionShift_Id;


			if(Is_Locked = 1 or Is_Locked = '1')then

				SELECT -1 AS Result_Id, 
				'The farmer invoice is already posted, so this entry cannot be removed.' AS Result_Description, 
				@var_MCCCollectionShift_Id AS Result_Extra_Key;

			else
				
				insert into bk_t005_milkcollectionfarmer
				select * FROM t005_milkcollectionfarmer t005
				where t005.Org_Id = var_Org_Id
				and t005.MCC_Id = var_MCC_Id
				and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id
				and t005.Farmer_Id = var_Farmer_Id;

				delete FROM t005_milkcollectionfarmer t005
				where t005.Org_Id = var_Org_Id
				and t005.MCC_Id = var_MCC_Id
				and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id
				and t005.Farmer_Id = var_Farmer_Id;


				set @setCurrent_Datetime =  (select Collection_Date from t004_mcccollectionshift where 
				Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id limit 1);

				if(@setCurrent_Datetime is null or @setCurrent_Datetime = '')then
					set @setCurrent_Datetime = @Current_Datetime;
				else 
					set @setCurrent_Datetime = @setCurrent_Datetime;
				end if;
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Voucher_1;
				CREATE TEMPORARY TABLE temp_Voucher_1 ( 
				AgentCollection_Id varchar(20));
				 
				insert into temp_Voucher_1(AgentCollection_Id)
				select AgentCollection_Id from t006_milkcollectionagent
				where Org_Id = Var_Org_Id
				and MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
				
								
				SET SQL_SAFE_UPDATES = 0;
                
                delete from t006_milkcollectionagent_item
				where Org_Id = var_Org_Id
				and AgentCollection_Id in (select AgentCollection_Id from temp_Voucher_1);
				
				delete from t006_milkcollectionagent
				where Org_Id = var_Org_Id
				and AgentCollection_Id  in (select AgentCollection_Id from temp_Voucher_1);



				if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = var_MCC_Id limit 1) then
							
				
											
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id) ;

				DROP TEMPORARY TABLE IF EXISTS temp_Report;

				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20),Collection_Date datetime);

				insert into temp_Report (Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date)
				select Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date 
				from t004_mcccollectionshift 
				where 
				Org_Id = var_Org_Id
				and MCC_Id =var_MCC_Id
                -- and CollectionShift_Id = @CollectionShift_Id
				and date(Collection_Date) <= date(@Current_Datetime)
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id 
												from t006_milkcollectionagent
												where 
												Org_Id = var_Org_Id
												and MCC_Id =var_MCC_Id)
												and date(Created_On) <= date(@Current_Datetime)
				order by Collection_Date  desc
				limit 2;
                

				set @MCCCollectionShift_Id_1  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  desc limit 1);
				set @MCCCollectionShift_Id_2  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  asc limit 1);
                
                
				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;

				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20));

				insert into temp_Report_Main (Org_Id,MCCCollectionShift_Id,MCC_Id)
				select t004.Org_Id,t004.MCCCollectionShift_Id,t004.MCC_Id 
				from t004_mcccollectionshift t004
				where t004.Org_Id = var_Org_Id
				and t004.MCC_Id =var_MCC_Id
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  <= REPLACE(@MCCCollectionShift_Id_1, 'T004', '')
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  > REPLACE(@MCCCollectionShift_Id_2, 'T004', '')
				order by Collection_Date  desc;
				
                
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
              
                
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
				
              
                
				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
                
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
			
                
				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
				
               
                
				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
              
                
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
	
				
				
				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
                
                
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				
                
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
                
                
				
				set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ); 
			   
				if(@AgentCollection_Id = '' OR  @AgentCollection_Id IS NULL ) then 
				
					Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
					
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @var_MCCCollectionShift_Id , @Agent_Id  , var_Profile_Id , 
					1,
					1 ,
					1, 
					1,
					@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
					@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
					@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
					0,1,0,@Current_Datetime, @Agent_Id  , (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and Agent_Id = @Agent_Id ) , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = var_Org_Id and 
					MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					
					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
					-- value 
					-- (var_Org_Id,@AgentCollection_Id, var_MilkType_Id, var_Weight , Var_FAT, Var_SNF, Var_MilkStatus_Id );
					select 
					Org_Id,   
					@AgentCollection_Id,
					MilkType_Id,
					sum(Quantity_Ltr) ,
					Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr))) as Fat,
					Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
					MilkStatus_Id
					from t005_milkcollectionfarmer 
					where Org_Id = var_Org_Id
					and MilkStatus_Id = 'C016001'
					and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main)
					group by Org_Id,MilkType_Id,MilkStatus_Id;
					
                    
					-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
			  else
              
					UPDATE t006_milkcollectionagent 
					SET Aluminum_Can_With_Lid =  1, 
					Aluminum_Can_Without_Lid = 1 ,
					Plastic_Can_With_Lid = 1, 
					Plastic_Can_Without_Lid =  1,
					Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
					Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
					Final_FAT_Cow_WtAvg = @CowFatweightAvg,
					Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
					Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
					Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
					Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
					Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
					Final_Amout_Cow = @TotalMilkAmountCow,
					Final_Amout_Buf =  @TotalMilkAmountBuffalo
					WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and AgentCollection_Id =  @AgentCollection_Id ;
					
					
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				   
				   
				   DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
					CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
						PKeyRowNum int, 
						Org_Id VARCHAR(45),
						Milktype_Id VARCHAR(45), 
						Quantity_Ltr DECIMAL(8,2), 
						FAT DECIMAL(8,2), 
						SNF DECIMAL(8,2)
					);
					
					
					 INSERT INTO temp_milkcollectionagent_item (
						Org_Id	,
						Milktype_Id,Quantity_Ltr,FAT,SNF)
					select 
					t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
					from t005_milkcollectionfarmer  t005
					WHERE t005.Org_Id = var_Org_Id 
					and t005.MCC_Id = var_MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main)
					group by  t005.Org_Id, t005.MilkType_Id;
					
					
				
                    
					UPDATE t006_milkcollectionagent_item  t006
					inner join temp_milkcollectionagent_item t005 on
					t005.Org_Id = t006.Org_Id
					and t005.MilkType_Id = var_MilkType_Id
					SET 
					t006.Quantity_Ltr =  t005.Quantity_Ltr, 
					t006.FAT =  t005.FAT,
					t006.SNF = t005.SNF
					WHERE t006.Org_Id = var_Org_Id 
					and t006.AgentCollection_Id =  @AgentCollection_Id
					and t006.Milktype_Id =  var_MilkType_Id ;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				end if;


			else
            
           
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				 set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = @var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				

				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
                
                
                set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id ); 
			    
				if(@AgentCollection_Id = '' OR  @AgentCollection_Id IS NULL ) then 
				
					Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
					
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @var_MCCCollectionShift_Id , @Agent_Id  , var_Profile_Id , 
					1,
					1 ,
					1, 
					1,
					@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
					@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
					@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
					0,1,0,@Current_Datetime, @Agent_Id  , (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and Agent_Id = @Agent_Id ) , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = var_Org_Id and 
					MCCCollectionShift_Id = @var_MCCCollectionShift_Id ;
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);

					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
					-- value 
					-- (var_Org_Id,@AgentCollection_Id, var_MilkType_Id, var_Weight , Var_FAT, Var_SNF, Var_MilkStatus_Id );
					select 
					Org_Id,   
					@AgentCollection_Id,
					MilkType_Id,
					sum(Quantity_Ltr) ,
					Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr))) as Fat,
					Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
					MilkStatus_Id
					from t005_milkcollectionfarmer 
					where Org_Id = var_Org_Id
					and MilkStatus_Id = 'C016001'
					and MCCCollectionShift_Id = @var_MCCCollectionShift_Id 
					group by Org_Id,MilkType_Id,MilkStatus_Id;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
			  else
					UPDATE t006_milkcollectionagent 
					SET Aluminum_Can_With_Lid =  1, 
					Aluminum_Can_Without_Lid = 1 ,
					Plastic_Can_With_Lid = 1, 
					Plastic_Can_Without_Lid =  1,
					Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
					Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
					Final_FAT_Cow_WtAvg = @CowFatweightAvg,
					Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
					Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
					Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
					Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
					Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
					Final_Amout_Cow = @TotalMilkAmountCow,
					Final_Amout_Buf =  @TotalMilkAmountBuffalo
					WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					and AgentCollection_Id =  @AgentCollection_Id ;
					
					
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				   
				   
				   DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
					CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
						PKeyRowNum int, 
						Org_Id VARCHAR(45),
						Milktype_Id VARCHAR(45), 
						Quantity_Ltr DECIMAL(8,2), 
						FAT DECIMAL(8,2), 
						SNF DECIMAL(8,2)
					);
					
					
					 INSERT INTO temp_milkcollectionagent_item (
						Org_Id	,
						Milktype_Id,Quantity_Ltr,FAT,SNF)
					select 
					t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
					from t005_milkcollectionfarmer  t005
					WHERE t005.Org_Id = var_Org_Id 
					and t005.MCC_Id = var_MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id = @var_MCCCollectionShift_Id
					group by  t005.Org_Id, t005.MilkType_Id;
					
					
					
					UPDATE t006_milkcollectionagent_item  t006
					inner join temp_milkcollectionagent_item t005 on
					t005.Org_Id = t006.Org_Id
					and t005.MilkType_Id = var_MilkType_Id
					SET 
					t006.Quantity_Ltr =  t005.Quantity_Ltr, 
					t006.FAT =  t005.FAT,
					t006.SNF = t005.SNF
					WHERE t006.Org_Id = var_Org_Id 
					and t006.AgentCollection_Id =  @AgentCollection_Id
					and t006.Milktype_Id =  var_MilkType_Id ;
					
					-- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
					-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				end if;
				

			end if;


				SELECT 1 AS Result_Id, 
				'Delete' AS Result_Description, 
				@var_MCCCollectionShift_Id AS Result_Extra_Key;

		end if;           
			
	END;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
