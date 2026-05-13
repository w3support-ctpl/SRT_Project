-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentCollection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentCollection_Get`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Shift_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    set sql_mode = '';
    

    set @Current_times = (SELECT TIME(CONVERT_TZ(NOW(), '+00:00', '+00:00')));
    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
	order by Applicable_Date desc limit 1 ;
     
    
	if (Var_Method_Name = 'GetShiftStatus') then

        select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
        @MCCType_Id
        from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
        
        Set @Current_CollectionShift_Id  = '';
        Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
        and Shift_Status <> 2 and is_active = 1 order by Collection_Date desc limit 1) ;
      
	
        if (@Current_CollectionShift_Id IS not NULL or @Current_CollectionShift_Id <> '' ) THEN 
        
		/*
		select t021.TripDocument_Id , Driver_Name, t021.Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
        into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
        from t021_tripdocument_header t021
        inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
        inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
        inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
        where  MCC_Id = Var_MCC_Id and Trip_Status <> 'Endtrip' and t022.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;
		
        */
        
        SET SQL_SAFE_UPDATES=0;

		DROP TEMPORARY TABLE IF EXISTS temp_Report;
		CREATE TEMPORARY TABLE temp_Report ( 
		Org_Id varchar(20), TripDocument_Id varchar(20),Driver_Id varchar(20), Vehicle_Id varchar(20),Is_Vehicle_Breakdown int,
		Driver_Name text,Vehicle_No text);

		insert into temp_Report (Org_Id,TripDocument_Id,Driver_Id,Vehicle_Id,Is_Vehicle_Breakdown)
		select t021.Org_Id,t021.TripDocument_Id,t021.Driver_Id,t021.Vehicle_Id,t021.Is_Vehicle_Breakdown 
		from t021_tripdocument_header t021
		inner join t022_tripdocument_item t022 on
		t022.Org_Id = t021.Org_Id and t022.TripDocument_Id = t021.TripDocument_Id
		where  
		t022.MCC_Id = Var_MCC_Id and 
		t021.Trip_Status <> 'Endtrip' and t021.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;

		update temp_Report t
		inner join mu06_driver mu06 on
		mu06.Org_Id = t.Org_Id and mu06.Driver_Id = t.Driver_Id
		set t.Driver_Name = mu06.Driver_Name;

		update temp_Report t
		inner join m003_vehicle m003 on
		m003.Org_Id = t.Org_Id and m003.Vehicle_Id = t.Vehicle_Id
		set t.Vehicle_No = m003.Vehicle_No;

		select 
		TripDocument_Id , Driver_Name, Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
		into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
		from temp_Report;
        
        
        

        select CollectionShift_Id , CollectionShift_Name into @ShiftType_Id , @CollectionShift_Name from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCCCollectionShift_Id = @Current_CollectionShift_Id;
        
		set @CollectionShiftname = (SELECT CollectionShift_Name FROM c015_collectionshift WHERE CollectionShift_Id = @ShiftType_Id  LIMIT 1 );

        
			SELECT Is_Approved into @AutoQuantity FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038001' order by Approved_On desc limit 1;
            
            SELECT Is_Approved into @AutoQuality FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038002' order by Approved_On desc limit 1;
        
			SELECT Is_Approved , Request_Details into @ExtraTime , @ExtraTime_Details  FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038003' order by Approved_On desc limit 1;
            
            
            set @TotalMilkQuantity = '';
             set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001';
		
			set @AvgSNF = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
          and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
           set @AvgFat = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
            
            
		if(@MCCType_Id not in ( 'C014002' , 'C014003' )) then 
            
           set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t005_milkcollectionfarmer T005
            inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id 
            and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , (T005.MCCCollectionShift_Id = @Current_CollectionShift_Id) ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001';
		
           -- set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
           -- set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
		
			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id 
            and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001' ;
		
          --  set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
           -- set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
                        
            
            Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            
            Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
           
           else 
				

                
		Set @Current_CollectionShift_Id  = '';
        Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
        and is_active = 1 order by Collection_Date desc limit 1) ;
      
            
			set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = 0;
			set @TotalMilkQuantityCow =  ( select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
		

			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = 0;
            set @TotalMilkQuantityBuffalo  = (select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
           --  set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
           -- set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
                        
      
            
            Set @AvgFatCow  = (select Fat from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
           
            
            Set @AvgFatBuffalo = (select Fat  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
            Set @AvgSNFCow=  (select snf  from f009_mcc_collection
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            Set @AvgSNFBuffalo =   (select snf  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
                

           end if; 
            -- to get multiple milktype in mcc 
			-- set @Version_No = (select max(Version_No) from m005_mcc_milktype where 
			-- MCC_ID = Var_MCC_Id );
            
            
			set @MCC_MilkType_Id =  (select group_concat(MilkType_Id)  from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;
            
					
			SELECT if (Shift_Status = 1 , 'open' , if(Shift_Status = 2 , 'Closed' , 'Not Started')) as Shift_Status,  ifnull(Is_MilkDispatch,1) as Is_MilkDispatch,  
            @ShiftType_Id as ShiftType_Id,
            c015.ShiftStart_Time , ifnull(Expected_End_Time,'') as Expected_End_Time, 
            ifnull(@Is_ManualWeight,0) as Is_ManualWeight,  ifnull(@Is_ManualQuality,1) as Is_ManualQuality, 
			ifnull(@Is_ExtraTime,0) as Is_ExtraTime ,
			ifnull(@Current_CollectionShift_Id,0) as MCCCollectionShift_Id ,  ifnull(@AutoQuantity,0) as AutoQuantity , 
			ifnull(@AutoQuality,0) as AutoQuality ,
			ifnull(@ExtraTime,0) as ExtraTime ,  ifnull(@ExtraTime_Details,'') as ExtraTime_Details , 
			ifnull(@MCCType_Id,'') as MCCType_Id ,
           -- 'C014002' as MCCType_Id ,
            ifnull(@TotalMilkQuantity,00.0) as Total_Milk_Quantity , ifnull(@AvgSNF,0.0) as AvgSNF , ifnull(@AvgFat,0.0) as AvgFat ,
			ifnull(@Vehicle_trip_id,'') as Vehicle_trip_id , if(ifnull(@Vehicle_trip_id, 0 ) = 0 , 0 , 1 ) as Vehicle_trip_Status ,
            ifnull(@Driver_Name,'') as Driver_Name , @Driver_Id as Driver_Id ,  ifnull(@Vehicle_No,'') as Vehicle_No, 
            ifnull(@Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
            @MCC_MilkType_Id as MCC_MilkType_Id ,
            ifnull(@TotalMilkQuantityCow, 0.0) as TotalMilkQuantityCow ,
            Round(ifnull(@AvgSNFCow , 0.0),2 ) as AvgSNFCow , 
            Round(ifnull(@AvgFatCow , 0.0),2) as AvgFatCow, 
            ifnull(@TotalQuantityBuffalo , 0.0) AS TotalQuantityBuffalo , 
            ifnull(@AvgSNFBuffalo , 0.0) as AvgSNFBuffalo, 
            ifnull(@AvgFatBuffalo , 0.0) as AvgFatBuffalo,
            @CollectionShift_Name as CollectionShift_Name
            from t004_mcccollectionshift t004 left join c015_collectionshift c015 on t004.CollectionShift_Id = c015.CollectionShift_Id
			WHERE  t004.MCCCollectionShift_Id  = @Current_CollectionShift_Id and Org_Id = Var_Org_Id ;
        
    
        
        else 
			
		Set @Current_CollectionShift_Id  = '';
        Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
       and is_active = 1 order by Collection_Date desc limit 1) ;
            
            
			set @CollectionShift_Id = '';
			select CollectionShift_Id INTO @CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id  and Version_No = @Version_No)
			AND @Current_timeS BETWEEN ShiftStart_Time AND ShiftEnd_Time and c015.Is_Active = 1 limit 1;
			
           
          
			IF (@CollectionShift_Id IS NULL or @CollectionShift_Id = '' ) THEN 
			SET @CollectionShift_Id = ( select CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id  and Version_No = @Version_No)
			AND (@Current_times <= ShiftStart_Time or @Current_times <= ShiftEnd_Time or @Current_times >= ShiftStart_Time ) and c015.Is_Active = 1 LIMIT 1 );
			END IF ;
            
                    
            set @CollectionShiftname = (SELECT CollectionShift_Name FROM c015_collectionshift WHERE CollectionShift_Id = @CollectionShift_Id LIMIT 1 );

            
        	SELECT Is_Approved into @AutoQuantity FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038001' order by Approved_On desc limit 1;
            
            SELECT Is_Approved into @AutoQuality FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038002' order by Approved_On desc limit 1;
        
			SELECT Is_Approved , Request_Details into @ExtraTime , @ExtraTime_Details  FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
            AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038003' order by Approved_On desc limit 1;
            
            /*
			select t021.TripDocument_Id , Driver_Name, t021.Driver_Id ,  Vehicle_No  , Is_Vehicle_Breakdown
			into @Vehicle_trip_id , @Driver_Name , @Driver_Id,  @Vehicle_No , @Is_Vehicle_Breakdown
			from t021_tripdocument_header t021
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
			inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
			inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
			where MCC_CollectionShift_Id = @CollectionShift_Id and MCC_Id = Var_MCC_Id ;
            
            
		*/
		SET SQL_SAFE_UPDATES=0;

		DROP TEMPORARY TABLE IF EXISTS temp_Report;
		CREATE TEMPORARY TABLE temp_Report ( 
		Org_Id varchar(20), TripDocument_Id varchar(20),Driver_Id varchar(20), Vehicle_Id varchar(20),Is_Vehicle_Breakdown int,
		Driver_Name text,Vehicle_No text);

		insert into temp_Report (Org_Id,TripDocument_Id,Driver_Id,Vehicle_Id,Is_Vehicle_Breakdown)
		select t021.Org_Id,t021.TripDocument_Id,t021.Driver_Id,t021.Vehicle_Id,t021.Is_Vehicle_Breakdown 
		from t021_tripdocument_header t021
		inner join t022_tripdocument_item t022 on
		t022.Org_Id = t021.Org_Id and t022.TripDocument_Id = t021.TripDocument_Id
		where  
		t022.MCC_Id = Var_MCC_Id and 
		t021.Trip_Status <> 'Endtrip' and t021.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;

		update temp_Report t
		inner join mu06_driver mu06 on
		mu06.Org_Id = t.Org_Id and mu06.Driver_Id = t.Driver_Id
		set t.Driver_Name = mu06.Driver_Name;

		update temp_Report t
		inner join m003_vehicle m003 on
		m003.Org_Id = t.Org_Id and m003.Vehicle_Id = t.Vehicle_Id
		set t.Vehicle_No = m003.Vehicle_No;

		select 
		TripDocument_Id , Driver_Name, Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown 
		into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
		from temp_Report;
        
        

            
             set @TotalMilkQuantity = '';
             set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @CollectionShift_Id and Org_Id = Var_Org_Id ;
		
        
            set @AvgSNF = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @CollectionShift_Id and Org_Id = Var_Org_Id ) / @TotalQuantity;
            
            set @AvgFat = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @CollectionShift_Id and Org_Id = Var_Org_Id ) / @TotalQuantity;
            
            -- to get multiple milktype in mcc 
			set @Version_No = (select max(Version_No) from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id );
            
			set @MCC_MilkType_Id =  (select group_concat(MilkType_Id)  from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;
            
	
             if(@MCCType_Id not in ( 'C014002' , 'C014003' )) then 
            
           set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t005_milkcollectionfarmer T005
            inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id 
            and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , (T005.MCCCollectionShift_Id = @Current_CollectionShift_Id) ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001';
		
           -- set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
           -- set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
		
			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id 
            and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001' ;
		
          --  set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
           -- set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
                        
            
            Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            
            Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
            Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer
            T005 inner join t004_mcccollectionshift T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
            where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
            T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
            
           
           else 
				

                
		Set @Current_CollectionShift_Id  = '';
        Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
        and is_active = 1 order by Collection_Date desc limit 1) ;
      
            
			set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = 0;
			set @TotalMilkQuantityCow =  ( select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
		

			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = 0;
            set @TotalMilkQuantityBuffalo  = (select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
           --  set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
           -- set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
                        
      
            
            Set @AvgFatCow  = (select Fat from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
           
            
            Set @AvgFatBuffalo = (select Fat  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
            Set @AvgSNFCow=  (select snf  from f009_mcc_collection
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            Set @AvgSNFBuffalo =   (select snf  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
                

           end if; 
            -- TO GET LATEST MCCCOLLECTION ID TO VIEW Truck status;
            SET @MCCCollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where 
            Org_Id  = Var_Org_Id and MCC_Id = Var_MCC_Id and Is_Active = 1 order by Collection_Date desc limit 1 ) ;
            
            /*
			select t021.TripDocument_Id , Driver_Name, t021.Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
			into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
			from t021_tripdocument_header t021
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
			inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
			inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
			where  MCC_Id = Var_MCC_Id and t021.Trip_Status <> 'Endtrip' and t022.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;
            
		
		*/
		SET SQL_SAFE_UPDATES=0;

		DROP TEMPORARY TABLE IF EXISTS temp_Report;
		CREATE TEMPORARY TABLE temp_Report ( 
		Org_Id varchar(20), TripDocument_Id varchar(20),Driver_Id varchar(20), Vehicle_Id varchar(20),Is_Vehicle_Breakdown int,
		Driver_Name text,Vehicle_No text);

		insert into temp_Report (Org_Id,TripDocument_Id,Driver_Id,Vehicle_Id,Is_Vehicle_Breakdown)
		select t021.Org_Id,t021.TripDocument_Id,t021.Driver_Id,t021.Vehicle_Id,t021.Is_Vehicle_Breakdown 
		from t021_tripdocument_header t021
		inner join t022_tripdocument_item t022 on
		t022.Org_Id = t021.Org_Id and t022.TripDocument_Id = t021.TripDocument_Id
		where  
		t022.MCC_Id = Var_MCC_Id and 
		t021.Trip_Status <> 'Endtrip' and t021.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;

		update temp_Report t
		inner join mu06_driver mu06 on
		mu06.Org_Id = t.Org_Id and mu06.Driver_Id = t.Driver_Id
		set t.Driver_Name = mu06.Driver_Name;

		update temp_Report t
		inner join m003_vehicle m003 on
		m003.Org_Id = t.Org_Id and m003.Vehicle_Id = t.Vehicle_Id
		set t.Vehicle_No = m003.Vehicle_No;

		select 
		TripDocument_Id , Driver_Name, Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
		into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
		from temp_Report;
        
        

			SELECT  'closed' as Shift_Status, 0 as Is_MilkDispatch, c015.ShiftStart_Time , c015.ShiftEnd_Time as Expected_End_Time,
            ifnull(@CollectionShift_Id,0) as ShiftType_Id ,
            ifnull(@Is_ManualWeight,1) as Is_ManualWeight,  ifnull(@Is_ManualQuality,1) as Is_ManualQuality, 
			ifnull(@Is_ExtraTime ,0) as Is_ExtraTime ,
			@MCCCollectionShift_Id as MCCCollectionShift_Id ,  ifnull(@AutoQuantity,0) as AutoQuantity , 
			ifnull(@AutoQuality ,0) as AutoQuality ,
			ifnull(@ExtraTime ,0) as ExtraTime ,  ifnull(@ExtraTime_Details,'') as ExtraTime_Details ,  ifnull(@MCCType_Id,'') as MCCType_Id ,
			ifnull(@TotalMilkQuantity ,00.0) as Total_Milk_Quantity , ifnull(@AvgSNF,0.0) as AvgSNF , ifnull(@AvgFat,0.0) as AvgFat ,
            ifnull(@Vehicle_trip_id ,'') as Vehicle_trip_id , if(ifnull(@Vehicle_trip_id, 0 ) = 0 , 0 , 1 ) as Vehicle_trip_Status ,
            ifnull(@Driver_Name,'') as Driver_Name , @Driver_Id as Driver_Id , ifnull(@Vehicle_No,'') as Vehicle_No, 
            ifnull(@Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown , 
            @MCC_MilkType_Id as MCC_MilkType_Id,
            ifnull(@TotalMilkQuantityCow, 0.0) as TotalMilkQuantityCow ,
            Round(ifnull(@AvgSNFCow , 0.0),2 ) as AvgSNFCow , 
            Round(ifnull(@AvgFatCow , 0.0),2) as AvgFatCow, 
            ifnull(@TotalQuantityBuffalo , 0.0) AS TotalQuantityBuffalo , 
            ifnull(@AvgSNFBuffalo , 0.0) as AvgSNFBuffalo, 
            ifnull(@AvgFatBuffalo , 0.0) as AvgFatBuffalo,
            @CollectionShiftname AS CollectionShift_Name
            from c015_collectionshift c015  
			WHERE  c015.CollectionShift_Id  = @CollectionShift_Id ;
		-- WHERE  c015.CollectionShift_Id  = 'C015002' ;
        
	end if ;
        
      elseif (Var_Method_Name = 'StartShift') then
	
	
  			set @CollectionShift_Id = '';
			select CollectionShift_Id INTO @CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id =Var_MCC_Id  and Version_No = @Version_No)
			AND @Current_timeS BETWEEN ShiftStart_Time AND ShiftEnd_Time limit 1;
			
			IF ( @CollectionShift_Id IS NULL or @CollectionShift_Id = '' ) THEN 
			SET @CollectionShift_Id = ( select CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
			( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id =Var_MCC_Id  and Version_No = @Version_No)
			AND @Current_times <= ShiftStart_Time LIMIT 1 );
			END IF ;
            
          SET @MyccType = (select MCCType_Id from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1);
          
		
  
        if exists (select 1 from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and Shift_Status = 2
        AND CollectionShift_Id = @CollectionShift_Id and date(Collection_Date) = DATE(now())) then 
			
			select -1 as Result_Id, 'Shift Closed' as Result_Description, '' as Result_Extra_Key;
            
		else 

        SET @CollectionShift_Id = '';
		select CollectionShift_Id , CollectionShift_Name INTO @CollectionShift_Id ,  @CollectionShift_Name  from c015_collectionshift c015 where CollectionShift_Id in 
		(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id  and Version_No = @Version_No)
		AND @Current_times BETWEEN ShiftStart_Time AND ShiftEnd_Time limit 1;

		if (@CollectionShift_Id = '' or @CollectionShift_Id is  null ) then 
        
            select -1 as Result_Id, 'No shift scheduled' as Result_Description, '' as Result_Extra_Key;
            
		else 
			IF EXISTS(select 1 from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and Shift_Status = 1 ) THEN 	
            
            select -1 as Result_Id, 'Shift Already Started' as Result_Description, '' as Result_Extra_Key;
		
		elseif exists (select 1 from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and
        @MyccType = 'C014001' and Is_MilkDispatch <> 2 and  date(Collection_Date) = date(now()) ) then 
        
				select -1 as Result_Id, 'Milk Not Dispatched' as Result_Description, '' as Result_Extra_Key;

            
            else 
            
				set @Year_Id = (select right(left(curdate(),4),(2)));
				set @New_MCCCollectionShift_Id ='';
				
				Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
				
                select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
                
				insert into t004_mcccollectionshift
				(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
				Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
				CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
				( select Var_Org_Id , @New_MCCCollectionShift_Id , 	Var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
				1, @Current_times , 1 , 0 , @Current_Datetime, Var_Profile_Id , Agent_Name , 0 , @ShiftEnd_Time
				from mu05_agent where Org_Id = Var_Org_Id and 
				Agent_Id = Var_Profile_Id limit 1 ) ;
                

        select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
        @MCCType_Id
        from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;

			if (@MCCType_Id in ('C014002' , 'C014003')) then 
			SET @row_number = 0; 
                
            DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Value text);
            
            insert into temp_data(PKeyRowNum , Field_Value)
			select (@row_number := @row_number + 1) , MilkType_Id from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No;
    
    
			set @RowCnt = (select COUNT(*) from temp_data);

			set @var_CursorTestID = 1;

			While @var_CursorTestID <= @RowCnt Do
            
            set @Field_Value = (select Field_Value from temp_data where PKeyRowNum = @var_CursorTestID );
            
            
            if exists (select 1 from f009_mcc_collection F009 where F009.Mlk_Type = @Field_Value and  Date < @Current_Datetime 
            and F009.Entry_Type in ( 'Closing Bal' , 'Collection 1' ) and MCC_Id = Var_MCC_Id) then 
		
	
			insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity,  Fat, Snf, Date, Amount , Rate ) 
			select Var_Org_Id , @New_MCCCollectionShift_Id ,Var_MCC_Id, 'Opening Bal 1' , @Field_Value , F009.Quantity , Fat, Snf , @Current_Datetime ,  Amount , Rate 
            from f009_mcc_collection F009 where F009.Mlk_Type = @Field_Value and  Date < @Current_Datetime 
            and F009.Entry_Type in ( 'Closing Bal' , 'Collection 1' , 'Collection 2' ) and MCC_Id = Var_MCC_Id
            order by Date desc limit 1;
            
			insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity,  Fat, Snf, Date, Amount , Rate ) 
			select Var_Org_Id , @New_MCCCollectionShift_Id ,Var_MCC_Id, 'Collection 1' , @Field_Value , F009.Quantity , Fat, Snf , @Current_Datetime,   Amount , Rate 
            from f009_mcc_collection F009 where F009.Mlk_Type = @Field_Value and  Date < @Current_Datetime 
            and F009.Entry_Type in ( 'Closing Bal' , 'Collection 1' , 'Collection 2' )  and MCC_Id = Var_MCC_Id
            order by Date desc limit 1;
            
		else
            
			insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity,  Fat, Snf, Date ) 
			select Var_Org_Id , @New_MCCCollectionShift_Id ,Var_MCC_Id, 'Opening Bal 1' , @Field_Value , 0, 0 ,0 , @Current_Datetime;
            
			insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity,  Fat, Snf, Date ) 
			select Var_Org_Id , @New_MCCCollectionShift_Id ,Var_MCC_Id, 'Collection 1' , @Field_Value , 0 , 0, 0 , @Current_Datetime;

            END IF;
            
			Set @var_CursorTestID = @var_CursorTestID + 1;

			END WHILE;
            
            end if;
			
				
			select 1 as Result_Id, 'Shift Started' as Result_Description, 'Shift Started' as Result_Extra_Key;  
            
		end if;
	end if;
         
	end if;
   
      elseif (Var_Method_Name = 'EndShift') then
      
		select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
        @MCCType_Id
        from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
      
		if exists (select 1 from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and Shift_Status in ( 1 ) and  MCCCollectionShift_Id = Var_Shift_Id ) then 
			
            update t004_mcccollectionshift set 
            ShiftEnd_Time = @Current_times,
            LastEditedBy_Id = Var_Profile_Id ,
            LastEdited_On =  @Current_Datetime,
            Shift_Status = 2,
            LastEditedBy_Name = (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and 
            Agent_Id = Var_Profile_Id limit 1)
            where Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_Shift_Id ;
            
            
            
            if (@MCCType_Id in ('C014002' , 'C014003')) then 
                
			SET @row_number = 0; 
                
            DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Value text);
            
            insert into temp_data(PKeyRowNum , Field_Value)
			select (@row_number := @row_number + 1) , MilkType_Id from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No;
            
			set @RowCnt = (select COUNT(*) from temp_data);

			set @var_CursorTestID = 1;

			While @var_CursorTestID <= @RowCnt Do
            
            set @Field_Value = (select Field_Value from temp_data where PKeyRowNum = @var_CursorTestID );
            
             insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
             Fat, Snf, Date , Amount , Rate ) 
			select Var_Org_Id , Var_Shift_Id , Var_MCC_Id, 'Closing Bal' , @Field_Value , F009.Quantity , Fat, Snf , @Current_Datetime , Amount , Rate 
            from f009_mcc_collection F009 where F009.Mlk_Type = @Field_Value and  Date < @Current_Datetime 
            and F009.Entry_Type in ('Collection 1' , 'Collection 2' )  and MCC_Id = Var_MCC_Id
            order by Date desc limit 1;
            
            
			Set @var_CursorTestID = @var_CursorTestID + 1;

			END WHILE;
            
            end  if;
            
            
            select 1 as Result_Id, 'Shift ended' as Result_Description, '' as Result_Extra_Key ;   
		else 
           	select -1 as Result_Id, 'Shift already ended' as Result_Description,'' as Result_Extra_Key ;    
		end if;
        
         elseif (Var_Method_Name = 'GetDashBoard') then
		    
            
          
	set @Version_No = (select m005.Version_No from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime
    order by Applicable_Date desc limit 1) ;

     set @CollectionShift = (select count(CollectionShift_Id) from c015_collectionshift where CollectionShift_Id in 
		(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id and Version_No = @Version_No)) ;
		
        if(@CollectionShift > 1) then
			set @CollectionShift_Id = '';
            
			select CollectionShift_Id into @CollectionShift_Id from c015_collectionshift where Is_Deleted = 0 and @Current_times between ShiftStart_Time and ShiftEnd_Time 
            and CollectionShift_Id in 
		(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id and Version_No = @Version_No) ;
            
            if(@CollectionShift_Id = '' or @CollectionShift_Id is null ) then 
				
			select CollectionShift_Id into @CollectionShift_Id from c015_collectionshift where ( @Current_times < ShiftStart_Time or @Current_times < ShiftEnd_Time )  and Is_Deleted = 0 
            and CollectionShift_Id in 
		(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id and Version_No = @Version_No)
            order by ShiftStart_Time desc limit 1;
			
            end if;
            
			
        else 
			set @CollectionShift_Id = ( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id and Version_No = @Version_No
            limit 1);
        end if ;
        
        
		set @MccType = (Select MCCType_Id FROM m005_mcc WHERE MCC_Id = Var_MCC_Id AND Org_Id = Var_Org_Id  AND Is_Deleted = 0);
		set @MCCWorkType_Id = (Select MCCWorkType_Id FROM m005_mcc WHERE MCC_Id = Var_MCC_Id AND Org_Id = Var_Org_Id  AND Is_Deleted = 0);

		if (@MCCType_Id not in  ('C014002' , 'C014003')) then 
        
		
			SET @Current_CollectionShift_Id = (SELECT MCCCollectionShift_Id FROM t004_mcccollectionshift WHERE DATE(Collection_Date) = DATE(@Current_Datetime) AND MCC_Id = Var_MCC_Id
			AND Org_Id = Var_Org_Id order by Collection_Date desc limit 1);

           set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001' limit 1;
		
			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' limit 1;
		

            set @MccType = (Select MCCType_Id FROM m005_mcc WHERE MCC_Id = Var_MCC_Id AND Org_Id = Var_Org_Id  AND Is_Deleted = 0);


            Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @Current_CollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1 limit 1 );
            
            Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @Current_CollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1 limit 1);
            
            
            Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @Current_CollectionShift_Id and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1 limit 1);
            
            Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @Current_CollectionShift_Id and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1 limit 1);


			else 
            
		-- 000 
        
			Set @Current_CollectionShift_Id  = '';
			Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t004_mcccollectionshift where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
			and is_active = 1 order by Collection_Date desc limit 1) ;

        
			set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = 0;
            set @TotalMilkQuantityCow = (select Quantity  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
		
			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = 0;
            set @TotalMilkQuantityBuffalo = (select Quantity  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
           --  set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
           -- set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
           -- and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
                        
            Set @AvgFatCow  = (select Fat from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
           
            
            Set @AvgFatBuffalo = (select Fat  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
            Set @AvgSNFCow=  (select snf  from f009_mcc_collection
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            Set @AvgSNFBuffalo =   (select snf  from f009_mcc_collection 
            where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );

			end if;

		
		drop temporary table if exists temp_TBL;

		create temporary table temp_TBL( 
		Today_Rate varchar(20) ,  
		Base_FAT varchar(20) ,
		Base_SNF varchar(20) ,
		AvgSNF varchar(20)  ,
		AvgFat varchar(20) ,
		Total_Milk varchar(20),
        Millk_Type Varchar(20)
		);
        
        
		Set @ChartIdCW = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = Var_MCC_Id  and CollectionShift_Id = @CollectionShift_Id 
			AND MilkRateEntryType_Id = 'C012001' and MilkType_Id = 'C011001'
			order by Header_Applicable_Date desc limit 1 );


		Set @ChartIdBF= ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = Var_MCC_Id  and CollectionShift_Id = @CollectionShift_Id 
			AND MilkRateEntryType_Id = 'C012001' and MilkType_Id = 'C011002'
			order by Header_Applicable_Date desc limit 1 );

			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;

			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
            
            SET @CollectionShiftNAME = (SELECT CollectionShift_Name FROM c015_collectionshift WHERE CollectionShift_Id = @CollectionShift_Id AND Is_Deleted = 0 LIMIT 1 ) ;

			INSERT INTO temp_TBL(Today_Rate, Base_FAT , Base_SNF, AvgSNF, AvgFat , Total_Milk, Millk_Type ) 
            SELECT IFNULL(Amount, '') AS Today_Rate , Base_FAT , Base_SNF,  IFNULL(round( @AvgSNFCow,2),'') as AvgSNF, 
            IFNULL(round(@AvgFatCow, 2),'') as AvgFat ,
            ifnull(@TotalMilkQuantityCow,'') as Total_Milk , 'C011001'
			FROM f002_milk_rate_current WHERE Org_Id = var_Org_Id AND MCC_Id = Var_MCC_Id  AND CollectionShift_Id = @CollectionShift_Id
			AND MilkRateEntryType_Id = 'C012001' and MilkType_Id = 'C011001' and Chart_id = @ChartIdCW 
            and Item_Applicable_Date <=  @Current_Datetime order by Item_Applicable_Date desc limit 1 ;
            
			INSERT INTO temp_TBL(Today_Rate, Base_FAT , Base_SNF, AvgSNF, AvgFat , Total_Milk , Millk_Type)
			SELECT IFNULL(Amount, '') AS Today_Rate , Base_FAT , Base_SNF,  IFNULL(round(@AvgSNFBuffalo,2),'') as AvgSNF, 
            IFNULL(round(@AvgFatBuffalo,2),'') as AvgFat ,
            ifnull(@TotalMilkQuantityBuffalo,'') as Total_Milk ,'C011002' 
			FROM f002_milk_rate_current f002 WHERE f002.Org_Id = var_Org_Id AND f002.MCC_Id = Var_MCC_Id  AND 
            f002.CollectionShift_Id = @CollectionShift_Id and MilkType_Id = 'C011002' and Chart_id = @ChartIdBF 
			AND f002.MilkRateEntryType_Id = 'C012001' and f002.Item_Applicable_Date <=  @Current_Datetime order by f002.Item_Applicable_Date desc limit 1;
        
			select * , @MusterType as MusterType , @MccType AS MCC_Type , 
            @CollectionShiftNAME AS CollectionShiftName  ,
            @MCCWorkType_Id as MCCWorkType_Id
            from temp_TBL;
            
	     elseif (Var_Method_Name = 'CurrentShiftFarmerCollection') then
			begin
				declare set_Var_Shift_Id varchar(50);
                
                
				if(Var_Shift_Id is null or Var_Shift_Id = '')then
					set set_Var_Shift_Id =(	select MCCCollectionShift_Id from t004_mcccollectionshift
											where Org_Id = Var_Org_Id
											and MCC_Id = Var_MCC_Id
											order by 
											Collection_Date desc,
											MCCCollectionShift_Id desc limit 1);
				else 
                
                set set_Var_Shift_Id = Var_Shift_Id;
				
				end if;
                
				set @CurrentShift_Count = (Select count(*)
				from t005_milkcollectionfarmer t005
				where t005.Org_Id = Var_Org_Id and t005.MCCCollectionShift_Id = set_Var_Shift_Id and t005.Is_Active = 1 and MilkStatus_Id = 'C016001' );
				
				set @AvgSNF = (Select SUM(t005.SNF)
				from t005_milkcollectionfarmer t005
				where t005.Org_Id = Var_Org_Id and t005.MCCCollectionShift_Id = set_Var_Shift_Id and t005.Is_Active = 1 and MilkStatus_Id = 'C016001' ) / @CurrentShift_Count ;
				
                set @AvgSNF =  Roundoff('Quality', @AvgSNF);
                
				set @AvgFAT = (Select SUM(t005.Fat)
				from t005_milkcollectionfarmer t005
				where t005.Org_Id = Var_Org_Id and t005.MCCCollectionShift_Id = set_Var_Shift_Id and t005.Is_Active = 1 and MilkStatus_Id = 'C016001' ) / @CurrentShift_Count ;
				
                set @AvgFAT =  Roundoff('Quality', @AvgFAT);
                
				set @TotalMilk = (Select SUM(t005.Quantity_Ltr)
				from t005_milkcollectionfarmer t005
				where t005.Org_Id = Var_Org_Id and t005.MCCCollectionShift_Id = set_Var_Shift_Id and t005.Is_Active = 1 and MilkStatus_Id = 'C016001' ) ;
				
                set @TotalMilk =  Roundoff('Quantity', @TotalMilk);
                   
				Select t005.FarmerCollection_Id, t005.Quantity_Ltr , t005.Quantity_Kg,
				mu04.Farmer_Name, t005.Fat , t005.SNF , date_format(t005.Created_On, '%e %M %Y') as Created_On
				 , @AvgFAT as AvgFAT , @AvgSNF as AvgSNF, @TotalMilk as TotalMilk,
				ApplicableRate as Rate,Amount as Amount,
                c015.CollectionShift_Id as CollectionShift_Id,
				c015.CollectionShift_Name as CollectionShift_Name
				from t005_milkcollectionfarmer t005 inner join  mu04_farmer mu04 on  mu04.Org_Id = t005.Org_Id and 
				mu04.Farmer_Id = t005.Farmer_Id 
                inner join t004_mcccollectionshift t004 on
                t004.Org_Id = t005.Org_Id 
                and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				inner join c015_collectionshift c015 on
                c015.CollectionShift_Id = t004.CollectionShift_Id 
				where t005.Org_Id = Var_Org_Id and t005.MCCCollectionShift_Id = set_Var_Shift_Id and t005.Is_Active = 1 ;
            end;
	 elseif (Var_Method_Name = 'GetFarmer') then
		begin
			select 
			Farmer_Id, 
            concat(Farmer_Name,' [ ' , MCC_Farmer_Code , ' ] ') as Farmer_Name
			-- concat(' [ ' , MCC_Farmer_Code , ' ] '  ,Farmer_Name) as Farmer_Name
			from mu04_farmer
			where Org_Id = Var_Org_Id
			and MCC_Id = Var_MCC_Id
            and Is_Active = 1
            and Is_Deleted = 0
            and Is_Offline = 0
			and MCC_Farmer_Code = Var_Shift_Id limit 1;
        end;
	elseif (Var_Method_Name = 'GetFarmerOffline') then
		begin
			select 
			Farmer_Id, 
            concat(Farmer_Name,' [ ' , MCC_Farmer_Code , ' ] ') as Farmer_Name
			-- concat(' [ ' , MCC_Farmer_Code , ' ] '  ,Farmer_Name) as Farmer_Name
			from mu04_farmer
			where Org_Id = Var_Org_Id
			and MCC_Id = Var_MCC_Id
            and Is_Active = 1
            and Is_Deleted = 0
            and Is_Offline = 1
			and MCC_Farmer_Code = Var_Shift_Id limit 1;
        end;
	elseif (Var_Method_Name = 'ShiftFarmerCollection') then
		begin
			set @Current_Datetime = (SELECT CONVERT_TZ(Var_Profile_Id, '+00:00', '+00:00'));
            
			if(Var_Shift_Id is null or Var_Shift_Id = '')then
            
				
                set @AvgSNF = (Select Roundoff('Quality', (sum(t005.Quantity_Ltr * t005.SNF)) / sum(t005.Quantity_Ltr))
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));

				set @AvgFAT = (Select Roundoff('Quality', (sum(t005.Quantity_Ltr * t005.Fat)) / sum(t005.Quantity_Ltr))
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));

				set @TotalMilk = (Select SUM(t005.Quantity_Ltr)
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));
				
				select 
				mu04.Farmer_Name,
				ifnull(t005.Fat,0.00) as Fat,
				ifnull(t005.SNF,0.00) as SNF,
				ifnull(t005.Quantity_Kg,0.00) as Quantity_Kg,
				ifnull(t005.Quantity_Ltr,0.00) as Quantity_Ltr,
				ifnull(t005.ApplicableRate,0.00) as Rate,
				ifnull(t005.Amount,0.00) as Amount,
                c015.CollectionShift_Id,
				c015.CollectionShift_Name,
				date_format(t005.Created_On, '%e %M %Y') as Created_On,
                @AvgFAT as AvgFAT , @AvgSNF as AvgSNF, @TotalMilk as TotalMilk
				from t005_milkcollectionfarmer t005
				inner join mu04_farmer mu04 on 
				mu04.Org_Id = t005.Org_Id
				and mu04.MCC_Id = t005.MCC_Id
				and mu04.Farmer_Id = t005.Farmer_Id
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				inner join c015_collectionshift c015 on
				c015.CollectionShift_Id = t004.CollectionShift_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime);
            
			else
            
				set @AvgSNF = (Select Roundoff('Quality', (sum(t005.Quantity_Ltr * t005.SNF)) / sum(t005.Quantity_Ltr))
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				and t004.CollectionShift_Id = Var_Shift_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));

				set @AvgFAT = (Select Roundoff('Quality', (sum(t005.Quantity_Ltr * t005.Fat)) / sum(t005.Quantity_Ltr))
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				and t004.CollectionShift_Id = Var_Shift_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));

				set @TotalMilk = (Select SUM(t005.Quantity_Ltr)
				from t005_milkcollectionfarmer t005
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				and t004.CollectionShift_Id = Var_Shift_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime));
				
				select 
				mu04.Farmer_Name,
				ifnull(t005.Fat,0.00) as Fat,
				ifnull(t005.SNF,0.00) as SNF,
				ifnull(t005.Quantity_Kg,0.00) as Quantity_Kg,
				ifnull(t005.Quantity_Ltr,0.00) as Quantity_Ltr,
				ifnull(t005.ApplicableRate,0.00) as Rate,
				ifnull(t005.Amount,0.00) as Amount,
                c015.CollectionShift_Id,
				c015.CollectionShift_Name,
				date_format(t005.Created_On, '%e %M %Y') as Created_On,
                @AvgFAT as AvgFAT , @AvgSNF as AvgSNF, @TotalMilk as TotalMilk
				from t005_milkcollectionfarmer t005
				inner join mu04_farmer mu04 on 
				mu04.Org_Id = t005.Org_Id
				and mu04.MCC_Id = t005.MCC_Id
				and mu04.Farmer_Id = t005.Farmer_Id
				inner join t004_mcccollectionshift t004 on
				t005.Org_Id = t004.Org_Id
				and t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
				and t005.MCC_Id = t004.MCC_Id
				and t004.CollectionShift_Id = Var_Shift_Id
				inner join c015_collectionshift c015 on
				c015.CollectionShift_Id = t004.CollectionShift_Id
				where t005.Org_Id = Var_Org_Id
				and t005.MCC_Id = Var_MCC_Id
				and date(t005.Created_On) = date(@Current_Datetime);
                
            end if;
        end;
	elseif (Var_Method_Name = 'GRNCollection') then
		begin
			select 
			m005.MCC_Name  as Farmer_Name,
			ifnull(f010.Dairy_Fat,0.00) as Fat,
			ifnull(f010.Dairy_SNF,0.00) as SNF,
			ifnull(f010.Dairy_Quantity_Kg,0.00) as Quantity_Kg,
			ifnull(f010.Dairy_Quantity_Ltr,0.00) as Quantity_Ltr,
			ifnull(f010.MilkRate,0.00) as Rate,
			ifnull(f010.MilkPrice,0.00) as Amount,
			c015.CollectionShift_Name,
			date_format(f010.Collection_Date, '%e %M %Y') as Created_On
			from f010_milkcollectionmcc_final  f010
			inner join m005_mcc m005 on
			m005.Org_Id	=f010.Org_Id
			and m005.MCC_Id	=f010.MCC_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = ifnull(f010.CollectionShift_Id,'C015003')
			where f010.Org_Id = Var_Org_Id
			and f010.MCC_Id = Var_MCC_Id
			order by f010.Collection_Date desc limit 2;
        end;
	elseif (Var_Method_Name = 'GetRemaining') then
		begin
        
        set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc
						where Org_Id = Var_Org_Id
						and MCC_Id = Var_MCC_Id limit 1);
        
        
			if(@MCCWorkType_Id  = 'C023002')then
            
				set @MCCCollectionShift_Id = ( select MCCCollectionShift_Id from t004_mcccollectionshift where 
									Org_Id = Var_Org_Id
									and MCC_Id =Var_MCC_Id 
									and date(Collection_Date) = date(now())
									and Shift_Status <> '2'
									and Is_MilkDispatch <> '2'
									order by Collection_Date desc limit 1 );

				DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Farmer_Id varchar(20));
				insert into temp_Report (Farmer_Id)
				select 
				t005.Farmer_Id
				from t005_milkcollectionfarmer t005
				where t005.Org_Id = Var_Org_Id
				and t005.MCCCollectionShift_Id = @MCCCollectionShift_Id
				and t005.MCC_Id =Var_MCC_Id;

				select 
				concat('[ ',mu04.MCC_Farmer_Code,' ] ' , mu04.Farmer_Name) as Farmer_Name ,
				if(left(mu04.Mobile_No, 3) = '+91', substr(mu04.Mobile_No, 4), mu04.Mobile_No) as Mobile_No
				from mu04_farmer mu04
				where mu04.Org_Id = Var_Org_Id
				and mu04.MCC_Id =Var_MCC_Id
                and mu04.Is_Active = 1
				and mu04.Farmer_Id not in( select Farmer_Id from temp_Report)
				order by cast(mu04.MCC_Farmer_Code as unsigned); 
            
            elseif(@MCCWorkType_Id  = 'C023001')then
            
				set @MCCCollectionShift_Id = ( select MCCCollectionShift_Id from t102_mcccollectionshift_offline where 
								Org_Id = Var_Org_Id
								and MCC_Id =Var_MCC_Id 
								and date(Collection_Date) = date(now())
                                and Shift_Status <> '2'
								and Is_MilkDispatch <> '2'
								order by Collection_Date desc limit 1 );

				DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Farmer_Id varchar(20));
				insert into temp_Report (Farmer_Id)
				select 
				t005.Farmer_Id
				from t103_milkcollectionfarmer_offline t005
				where t005.Org_Id = Var_Org_Id
				and t005.MCCCollectionShift_Id = @MCCCollectionShift_Id
				and t005.MCC_Id =Var_MCC_Id;

				select 
				concat('[ ',mu04.MCC_Farmer_Code,' ] ' , mu04.Farmer_Name) as Farmer_Name ,
				if(left(mu04.Mobile_No, 3) = '+91', substr(mu04.Mobile_No, 4), mu04.Mobile_No) as Mobile_No
				from mu04_farmer mu04
				where mu04.Org_Id = Var_Org_Id
				and mu04.MCC_Id =Var_MCC_Id 
                and mu04.Is_Active = 1
				and mu04.Farmer_Id not in( select Farmer_Id from temp_Report)
				order by cast(mu04.MCC_Farmer_Code as unsigned);
            
            end if;
            
			
			

        end;
	elseif (Var_Method_Name = 'GetMCCStatus') then
		begin
			select 
				MCC_Id,
				CASE
					WHEN MCCWorkType_Id = 'C023001' THEN '1'
					WHEN MCCWorkType_Id = 'C023002' THEN '0'
					ELSE ''
				END as Is_OfflineMCC 
				from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1;
			end;
		elseif (Var_Method_Name = 'GetOfflineShiftStatus_1') then
			begin
            /*
				SELECT 
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'C015001' -- Morning Shift
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'C015002' -- Evening Shift
					ELSE 
						'' -- No shift
				END AS CollectionShift_Id,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'Morning'
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'Evening'
					ELSE 
						''
				END AS CollectionShift_Name,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						Morning_Start_Time
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						Evening_Start_Time
					ELSE 
						'00:00:00'
				END AS ShiftStart_Time,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						Morning_End_Time
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						Evening_End_Time
					ELSE 
						'00:00:00'
				END AS ShiftEnd_Time,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'1'
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'1'
					ELSE 
						'-1'
				END AS Is_Check
			FROM m005_mcc_offline_config
			WHERE Org_Id = Var_Org_Id 
			AND MCC_Id = Var_MCC_Id limit 1;
            
            */
            
			set sql_require_primary_key = 0 ;
			SET SQL_SAFE_UPDATES = 0;
			set sql_mode = '';
			

			set @Current_times = (SELECT TIME(CONVERT_TZ(NOW(), '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
			
			select m005.Version_No into @Version_No 
			from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
			order by Applicable_Date desc limit 1 ;

			select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
			@MCCType_Id
			from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
			
			Set @Current_CollectionShift_Id  = '';
			Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
			and Shift_Status <> 2 and is_active = 1 order by Collection_Date desc limit 1) ;

			if (@Current_CollectionShift_Id IS not NULL or @Current_CollectionShift_Id <> '' ) THEN 

				/*
				select t021.TripDocument_Id , Driver_Name, t021.Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
				into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
				from t021_tripdocument_header t021
				inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
				inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
				inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
				where  MCC_Id = Var_MCC_Id and Trip_Status <> 'Endtrip' and t022.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;
				
				*/
				
				set @Vehicle_trip_id = '';
				set @Driver_Name = '';
				set @Driver_Id = '';
				set @Vehicle_No = '';
				set @Is_Vehicle_Breakdown = '';


				select CollectionShift_Id , CollectionShift_Name into @ShiftType_Id , @CollectionShift_Name from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCCCollectionShift_Id = @Current_CollectionShift_Id;

				set @CollectionShiftname = (SELECT CollectionShift_Name FROM c015_collectionshift WHERE CollectionShift_Id = @ShiftType_Id  LIMIT 1 );

				/*
				SELECT Is_Approved into @AutoQuantity FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038001' order by Approved_On desc limit 1;

				SELECT Is_Approved into @AutoQuality FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038002' order by Approved_On desc limit 1;

				SELECT Is_Approved , Request_Details into @ExtraTime , @ExtraTime_Details  FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038003' order by Approved_On desc limit 1;
				*/
				
				set @AutoQuantity = 0;
				set @AutoQuality = 0;
				set @ExtraTime = "";
				set @ExtraTime_Details = '';

				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001';

				set @AvgSNF = (select sum(SNF)  from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFat = (select sum(Fat)  from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ) / @TotalQuantity;


				if(@MCCType_Id not in ( 'C014002' , 'C014003' )) then 

					set @TotalMilkQuantityCow = '';
					set @TotalQuantityCow = '';
					select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t103_milkcollectionfarmer_offline T005
					inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id 
					and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , (T005.MCCCollectionShift_Id = @Current_CollectionShift_Id) ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001';

					set @TotalMilkQuantityBuffalo  = '';
					set @TotalQuantityBuffalo = '';
					select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo 
					from t103_milkcollectionfarmer_offline T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id 
					and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001' ;

					Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

					Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);


					Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

					Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

				else

					Set @Current_CollectionShift_Id  = '';
					Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
					and is_active = 1 order by Collection_Date desc limit 1) ;


					set @TotalMilkQuantityCow = '';
					set @TotalQuantityCow = 0;
					set @TotalMilkQuantityCow =  ( select Quantity from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );


					set @TotalMilkQuantityBuffalo  = '';
					set @TotalQuantityBuffalo = 0;
					set @TotalMilkQuantityBuffalo  = (select Quantity from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );

					Set @AvgFatCow  = (select Fat from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );


					Set @AvgFatBuffalo = (select Fat  from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );


					Set @AvgSNFCow=  (select snf  from f009_mcc_collection
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );

					Set @AvgSNFBuffalo =   (select snf  from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );

				end if;

			set @MCC_MilkType_Id =  (select group_concat(MilkType_Id)  from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;


			SELECT if (Shift_Status = 1 , 'open' , if(Shift_Status = 2 , 'Closed' , 'Not Started')) as Shift_Status,  ifnull(Is_MilkDispatch,1) as Is_MilkDispatch,  
			@ShiftType_Id as ShiftType_Id,
			c015.ShiftStart_Time , ifnull(Expected_End_Time,'') as Expected_End_Time, 
			ifnull(@Is_ManualWeight,0) as Is_ManualWeight,  ifnull(@Is_ManualQuality,1) as Is_ManualQuality, 
			ifnull(@Is_ExtraTime,0) as Is_ExtraTime ,
            ifnull(@Current_CollectionShift_Id,'')
            as MCCCollectionShift_Id ,  ifnull(@AutoQuantity,0) as AutoQuantity , 
			ifnull(@AutoQuality,0) as AutoQuality ,
			ifnull(@ExtraTime,0) as ExtraTime ,  ifnull(@ExtraTime_Details,'') as ExtraTime_Details , 
			ifnull(@MCCType_Id,'') as MCCType_Id ,
			-- 'C014002' as MCCType_Id ,
			ifnull(@TotalMilkQuantity,00.0) as Total_Milk_Quantity , ifnull(@AvgSNF,0.0) as AvgSNF , ifnull(@AvgFat,0.0) as AvgFat ,
			ifnull(@Vehicle_trip_id,'') as Vehicle_trip_id , if(ifnull(@Vehicle_trip_id, 0 ) = 0 , 0 , 1 ) as Vehicle_trip_Status ,
			ifnull(@Driver_Name,'') as Driver_Name , @Driver_Id as Driver_Id ,  ifnull(@Vehicle_No,'') as Vehicle_No, 
			ifnull(@Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
			@MCC_MilkType_Id as MCC_MilkType_Id ,
			ifnull(@TotalMilkQuantityCow, 0.0) as TotalMilkQuantityCow ,
			Round(ifnull(@AvgSNFCow , 0.0),2 ) as AvgSNFCow , 
			Round(ifnull(@AvgFatCow , 0.0),2) as AvgFatCow, 
			ifnull(@TotalQuantityBuffalo , 0.0) AS TotalQuantityBuffalo , 
			ifnull(@AvgSNFBuffalo , 0.0) as AvgSNFBuffalo, 
			ifnull(@AvgFatBuffalo , 0.0) as AvgFatBuffalo,
			@CollectionShift_Name as CollectionShift_Name
			from t102_mcccollectionshift_offline t004 left join c015_collectionshift c015 on t004.CollectionShift_Id = c015.CollectionShift_Id
			WHERE  t004.MCCCollectionShift_Id  = @Current_CollectionShift_Id and Org_Id = Var_Org_Id ;



			else
            

				Set @Current_CollectionShift_Id  = '';
				Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
				and is_active = 1 order by Collection_Date desc limit 1) ;

				/*
				set @CollectionShift_Id = '';
				select CollectionShift_Id INTO @CollectionShift_Id from c015_collectionshift c015 where CollectionShift_Id in 
				( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = Var_MCC_Id  and Version_No = @Version_No)
				AND @Current_timeS BETWEEN ShiftStart_Time AND ShiftEnd_Time and c015.Is_Active = 1 limit 1;
                */
                
                SELECT 
					CASE
						WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
							'C015001' -- Morning Shift
						WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
							'C015002' -- Evening Shift
						ELSE 
							'' 
						END INTO @CollectionShift_Id  FROM m005_mcc_offline_config
				WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1;

				IF (@CollectionShift_Id IS NULL or @CollectionShift_Id = '' ) THEN 

					SET @CollectionShift_Id = (
						SELECT 
							CASE
								WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
									'C015001' -- Morning Shift
								WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
									'C015002' -- Evening Shift
								ELSE 
									'' 
								END FROM m005_mcc_offline_config
						WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1
                    );

				END IF ;


				set @CollectionShiftname = (SELECT CollectionShift_Name FROM c015_collectionshift WHERE CollectionShift_Id = @CollectionShift_Id LIMIT 1 );
				/*
				SELECT Is_Approved into @AutoQuantity FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038001' order by Approved_On desc limit 1;

				SELECT Is_Approved into @AutoQuality FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038002' order by Approved_On desc limit 1;

				SELECT Is_Approved , Request_Details into @ExtraTime , @ExtraTime_Details  FROM  t010_collectionrequest WHERE Org_Id = Var_Org_Id AND MCC_CollectionShift_Id = @Current_CollectionShift_Id 
				AND MCC_Id = Var_MCC_Id AND RequestType_Id = 'C038003' order by Approved_On desc limit 1;
				*/
				
				set @AutoQuantity = 0;
				set @AutoQuality = 0;
				set @ExtraTime = '';
				set @ExtraTime_Details = '';
				
				/*
				select t021.TripDocument_Id , Driver_Name, t021.Driver_Id ,  Vehicle_No  , Is_Vehicle_Breakdown
				into @Vehicle_trip_id , @Driver_Name , @Driver_Id,  @Vehicle_No , @Is_Vehicle_Breakdown
				from t021_tripdocument_header t021
				inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
				inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
				inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
				where MCC_CollectionShift_Id = @CollectionShift_Id and MCC_Id = Var_MCC_Id ;
				
				*/
				
				set @Vehicle_trip_id = '';
				set @Driver_Name = '';
				set @Driver_Id = '';
				set @Vehicle_No = '';
				set @Is_Vehicle_Breakdown = '';

				set @TotalMilkQuantity = ";
				set @TotalQuantity = ";
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id ;


				set @AvgSNF = (select sum(SNF)  from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id ) / @TotalQuantity;

				set @AvgFat = (select sum(Fat)  from t103_milkcollectionfarmer_offline where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @Current_CollectionShift_Id and Org_Id = Var_Org_Id ) / @TotalQuantity;

				set @Version_No = (select max(Version_No) from m005_mcc_milktype where 
				MCC_ID = Var_MCC_Id );
				
				set @MCC_MilkType_Id =  (select group_concat(MilkType_Id)  from m005_mcc_milktype where 
				MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;

				if(@MCCType_Id not in ( 'C014002' , 'C014003' )) then 

					set @TotalMilkQuantityCow = '';
					set @TotalQuantityCow = '';
					select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t103_milkcollectionfarmer_offline T005
					inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id 
					and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , (T005.MCCCollectionShift_Id = @Current_CollectionShift_Id) ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001';

					set @TotalMilkQuantityBuffalo  = '';
					set @TotalQuantityBuffalo = '';
					select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo 
					from t103_milkcollectionfarmer_offline T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id 
					and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001' ;

					Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
					
					Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
					
					
					Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
					
					Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
					T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
					where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
					T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

				else

					Set @Current_CollectionShift_Id  = '';
					Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
					and is_active = 1 order by Collection_Date desc limit 1) ;
				
						
					set @TotalMilkQuantityCow = '';
					set @TotalQuantityCow = 0;
					set @TotalMilkQuantityCow =  ( select Quantity from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );
				

					set @TotalMilkQuantityBuffalo  = '';
					set @TotalQuantityBuffalo = 0;
					set @TotalMilkQuantityBuffalo  = (select Quantity from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );

					Set @AvgFatCow  = (select Fat from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );
				
					
					Set @AvgFatBuffalo = (select Fat  from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );
					
					
					Set @AvgSNFCow=  (select snf  from f009_mcc_collection
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );
					
					Set @AvgSNFBuffalo =   (select snf  from f009_mcc_collection 
					where  MCCCollectionShift_Id = @Current_CollectionShift_Id and 
					Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
					order by Date desc limit 1 );

				end if;


				SET @MCCCollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where 
				Org_Id  = Var_Org_Id and MCC_Id = Var_MCC_Id and Is_Active = 1 order by Collection_Date desc limit 1 ) ;
				
				/*
				select t021.TripDocument_Id , Driver_Name, t021.Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
				into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
				from t021_tripdocument_header t021
				inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
				inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
				inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
				where  MCC_Id = Var_MCC_Id and t021.Trip_Status <> 'Endtrip' and t022.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;
				*/
				
				set @Vehicle_trip_id = '';
				set @Driver_Name = '';
				set @Driver_Id = '';
				set @Vehicle_No = '';
				set @Is_Vehicle_Breakdown = '';
				
				SELECT  'closed' as Shift_Status, 0 as Is_MilkDispatch, c015.ShiftStart_Time , c015.ShiftEnd_Time as Expected_End_Time,
				ifnull(@CollectionShift_Id,0) as ShiftType_Id ,
				ifnull(@Is_ManualWeight,1) as Is_ManualWeight,  ifnull(@Is_ManualQuality,1) as Is_ManualQuality, 
				ifnull(@Is_ExtraTime ,0) as Is_ExtraTime ,
				ifnull(@MCCCollectionShift_Id,'') as MCCCollectionShift_Id ,  ifnull(@AutoQuantity,0) as AutoQuantity , 
				ifnull(@AutoQuality ,0) as AutoQuality ,
				ifnull(@ExtraTime ,0) as ExtraTime ,  ifnull(@ExtraTime_Details,'') as ExtraTime_Details ,  ifnull(@MCCType_Id,'') as MCCType_Id ,
				ifnull(@TotalMilkQuantity ,00.0) as Total_Milk_Quantity , ifnull(@AvgSNF,0.0) as AvgSNF , ifnull(@AvgFat,0.0) as AvgFat ,
				ifnull(@Vehicle_trip_id ,'') as Vehicle_trip_id , if(ifnull(@Vehicle_trip_id, 0 ) = 0 , 0 , 1 ) as Vehicle_trip_Status ,
				ifnull(@Driver_Name,'') as Driver_Name , @Driver_Id as Driver_Id , ifnull(@Vehicle_No,'') as Vehicle_No, 
				ifnull(@Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown , 
				@MCC_MilkType_Id as MCC_MilkType_Id,
				ifnull(@TotalMilkQuantityCow, 0.0) as TotalMilkQuantityCow ,
				Round(ifnull(@AvgSNFCow , 0.0),2 ) as AvgSNFCow , 
				Round(ifnull(@AvgFatCow , 0.0),2) as AvgFatCow, 
				ifnull(@TotalQuantityBuffalo , 0.0) AS TotalQuantityBuffalo , 
				ifnull(@AvgSNFBuffalo , 0.0) as AvgSNFBuffalo, 
				ifnull(@AvgFatBuffalo , 0.0) as AvgFatBuffalo,
				@CollectionShiftname AS CollectionShift_Name
				from c015_collectionshift c015  
				WHERE  c015.CollectionShift_Id  = @CollectionShift_Id ;

			end if;
        end;
	elseif (Var_Method_Name = 'GetMCCStatus') then
		begin
			select 
				MCC_Id,
				CASE
					WHEN MCCWorkType_Id = 'C023001' THEN '1'
					WHEN MCCWorkType_Id = 'C023002' THEN '0'
					ELSE ''
				END as Is_OfflineMCC 
				from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1;
			end;
		elseif (Var_Method_Name = 'GetOfflineShiftStatus') then
			begin
            
			SET SQL_SAFE_UPDATES = 0;
			set sql_require_primary_key = 0 ;
			set @Current_times = (SELECT TIME(CONVERT_TZ(now(), '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(now(), '+00:00', '+00:00'));
            
            
           set @check_Date = ( select Date from t105_mcc_collection_stock_offline 
								where MCC_Id = Var_MCC_Id
								and Quantity = 0
								and Fat = 0
								and Snf = 0
								order by Date desc limit 1);
						
		
            select m005.Version_No into @Version_No 
			from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
			order by Applicable_Date desc limit 1 ;
            
            set @MCC_MilkType_Id =  (select group_concat(MilkType_Id)  from m005_mcc_milktype where 
			MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;
            
            Set @Current_CollectionShift_Id  = '';
			Set @Current_CollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
			-- and Shift_Status <> 2 
            and is_active = 1 order by Collection_Date desc limit 1) ;
	
			
			set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
			select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityCow , @TotalQuantityCow from t103_milkcollectionfarmer_offline T005
			inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id 
			and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , (T005.MCCCollectionShift_Id = @Current_CollectionShift_Id) ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001';
			
            
            set @S_TotalMilkQuantityCow = '';
			set @S_TotalQuantityCow = '';


			if(@check_Date is null or @check_Date = '')then

				select sum(Quantity),count(*) 
				into @S_TotalMilkQuantityCow , @S_TotalQuantityCow
				from t105_mcc_collection_stock_offline
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Mlk_Type = 'C011001'
				order by Date desc limit 1;

			else
				select sum(Quantity),count(*) 
				into @S_TotalMilkQuantityCow , @S_TotalQuantityCow
				from t105_mcc_collection_stock_offline
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Mlk_Type = 'C011001'
				and date(Date) >= date(@check_Date)
				order by Date desc limit 1;

			end if;

			
			
            
         
			set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
			select sum(T005.Quantity_Ltr) , count(*) into @TotalMilkQuantityBuffalo , @TotalQuantityBuffalo 
			from t103_milkcollectionfarmer_offline T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id 
			and if(@MCCType_Id = 'C014002' , T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and T005.Org_Id = Var_Org_Id AND T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001' ;
			
            
            set @S_TotalMilkQuantityBuffalo = '';
			set @S_TotalQuantityBuffalo = '';


			if(@check_Date is null or @check_Date = '')then

				select sum(Quantity),count(*) 
				into  @S_TotalMilkQuantityBuffalo , @S_TotalQuantityBuffalo 
				from t105_mcc_collection_stock_offline
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Mlk_Type = 'C011002'
				order by Date desc limit 1;

			else
				select sum(Quantity),count(*) 
				into  @S_TotalMilkQuantityBuffalo , @S_TotalQuantityBuffalo 
				from t105_mcc_collection_stock_offline
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Mlk_Type = 'C011002'
				and date(Date) >= date(@check_Date)
				order by Date desc limit 1;

			end if;

			
			
			
            
			Set  @AvgFatCow  =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
			T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
			T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

			Set @AvgFatBuffalo =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
			T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
			T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);



			if(@check_Date is null or @check_Date = '')then

				Set  @S_AvgFatCow  =  (select Fat
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011001'
								order by Date desc limit 1);
            
            	Set  @S_AvgFatBuffalo  =  (select Fat
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011002'
								order by Date desc limit 1);

			else

				Set  @S_AvgFatCow  =  (select Fat
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011001'
								and date(Date) >= date(@check_Date)
								order by Date desc limit 1);
            
            	Set  @S_AvgFatBuffalo  =  (select Fat
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011002'
								and date(Date) >= date(@check_Date)
								order by Date desc limit 1);

			end if;
			
            
            
			
			Set @AvgSNFCow=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
			T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
			T005.MilkType_Id = 'C011001' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

			Set @AvgSNFBuffalo =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
			T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
			where T005.MCC_Id = Var_MCC_Id and if(@MCCType_Id = 'C014002' ,  T004.Is_MilkDispatch <> 2 , T005.MCCCollectionShift_Id = @Current_CollectionShift_Id  ) and 
			T005.MilkType_Id = 'C011002' and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
			
            
			if(@check_Date is null or @check_Date = '')then

				Set  @S_AvgSNFCow  =  (select Snf
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011001'
								order by Date desc limit 1);
            
            	Set  @S_AvgSNFBuffalo  =  (select Snf
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011002'
								order by Date desc limit 1);

			else


				Set  @S_AvgSNFCow  =  (select Snf
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011001'
								and date(Date) >= date(@check_Date)
								order by Date desc limit 1);
            
            	Set  @S_AvgSNFBuffalo  =  (select Snf
								from t105_mcc_collection_stock_offline
								where Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and Mlk_Type = 'C011002'
								and date(Date) >= date(@check_Date)
								order by Date desc limit 1);

			end if;

            
                                
			SET @CollectionShift_Id = ( 
								SELECT 
									CASE
									WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
										'C015001' -- Morning Shift
									WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
										'C015002' -- Evening Shift
									ELSE 
										'' 
									END   FROM m005_mcc_offline_config
								WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1);

			set @MCCCollectionShift_Id = (select ifnull(MCCCollectionShift_Id,'') from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id 
			AND CollectionShift_Id = @CollectionShift_Id and date(Collection_Date) = date(@Current_Datetime));
            
            -- select @MCCCollectionShift_Id , @CollectionShift_Id;
            
            if(@MCCCollectionShift_Id is null and  @CollectionShift_Id is not null) then
            
				if(@CollectionShift_Id = 'C015001')then
					set @MCCCollectionShift_Id = (select ifnull(MCCCollectionShift_Id,'') from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id 
					AND CollectionShift_Id = 'C015002' and date(Collection_Date) = date(@Current_Datetime)  and Shift_Status = 1);
                    
                    set @CollectionShift_Id = 'C015002';
                end if;
                
                if(@CollectionShift_Id = 'C015002')then
					set @MCCCollectionShift_Id = (select ifnull(MCCCollectionShift_Id,'') from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id 
					AND CollectionShift_Id = 'C015001' and date(Collection_Date) = date(@Current_Datetime) and Shift_Status = 1);
                    
                    set @CollectionShift_Id = 'C015001';
                end if;
			else
				set @MCCCollectionShift_Id = @MCCCollectionShift_Id;
                set @CollectionShift_Id = @CollectionShift_Id;
            end if;
            
            -- select @MCCCollectionShift_Id , @CollectionShift_Id;
            
            
            set @Shift_Status = (select ifnull(Shift_Status,0) from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id 
			AND CollectionShift_Id = @CollectionShift_Id and date(Collection_Date) = date(@Current_Datetime));
            
            select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
			@MCCType_Id
			from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
            
            set @Check_Is_MilkDispatch = (select Is_MilkDispatch from t004_mcccollectionshift where 
									Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id
									and CollectionShift_Id = @CollectionShift_Id  and date(Collection_Date) = date(@Current_Datetime) limit 1);
                                    
             if(@Check_Is_MilkDispatch is null or @Check_Is_MilkDispatch = '')then
				set @Check_Is_MilkDispatch = 0;
             else
				set @Check_Is_MilkDispatch = 1;
             end if;
             
             set @Chemist_Is_MilkDispatch = (select Is_MilkDispatch from t004_mcccollectionshift where 
									Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id
									and CollectionShift_Id = @CollectionShift_Id  and date(Collection_Date) = date(@Current_Datetime) limit 1);
			
            if(@MCCType_Id = 'C014002')then
				if(@Chemist_Is_MilkDispatch is null or @Chemist_Is_MilkDispatch = '')then
					set @Chemist_Is_MilkDispatch = 0;
				 else
					set @Chemist_Is_MilkDispatch = @Chemist_Is_MilkDispatch;
				 end if;
			elseif( @MCCType_Id = 'C014003')then
				if(@Chemist_Is_MilkDispatch is null or @Chemist_Is_MilkDispatch = '')then
					set @Chemist_Is_MilkDispatch = 0;
				 else
					set @Chemist_Is_MilkDispatch = @Chemist_Is_MilkDispatch;
				 end if;
			elseif( @MCCType_Id = 'C014001')then
				set @Chemist_Is_MilkDispatch = '';
			end if;
            
            select t021.TripDocument_Id , Driver_Name, t021.Driver_Id , Vehicle_No  , Is_Vehicle_Breakdown
			into @Vehicle_trip_id , @Driver_Name , @Driver_Id ,  @Vehicle_No , @Is_Vehicle_Breakdown
			from t021_tripdocument_header t021
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id
			inner join mu06_driver mu06 on mu06.Org_Id = t022.Org_Id and  mu06.Driver_Id = t021.Driver_Id
			inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = t021.Vehicle_Id
			where  MCC_Id = Var_MCC_Id and Trip_Status <> 'Endtrip' and t022.Org_Id = Var_Org_Id order by t021.Created_On desc limit 1;

			
            
				SELECT 
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'C015001' -- Morning Shift
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'C015002' -- Evening Shift
					ELSE 
						'' -- No shift
				END AS CollectionShift_Id,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'Morning'
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'Evening'
					ELSE 
						''
				END AS CollectionShift_Name,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						Morning_Start_Time
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						Evening_Start_Time
					ELSE 
						'00:00:00'
				END AS ShiftStart_Time,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						Morning_End_Time
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						Evening_End_Time
					ELSE 
						'00:00:00'
				END AS Expected_End_Time,
				CASE
					WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
						'1'
					WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
						'1'
					ELSE 
						'-1'
				END AS Is_Check,
                ifnull(@Is_ManualWeight,0) as Is_ManualWeight,
                ifnull(@Is_ManualQuality,0)  as Is_ManualQuality,
                0 as AutoQuantity,
                0 as AutoQuality,
                ifnull(@Is_ExtraTime,0) as ExtraTime,
                -- 'closed' as Shift_Status
                -- 'open' as Shift_Status,
                CASE
					WHEN @Shift_Status = '1' THEN
                    'open'
                    WHEN @Shift_Status = '2' THEN
                    'closed'
                    WHEN @Shift_Status is null or @Shift_Status = ''then
                    'closed'
				end as Shift_Status,
                @MCCCollectionShift_Id  as MCCCollectionShift_Id,
                @MCC_MilkType_Id as MCC_MilkType_Id,
                ifnull(@TotalMilkQuantityCow, 0.0) as TotalMilkQuantityCow ,
				Round(ifnull(@AvgSNFCow , 0.0),2 ) as AvgSNFCow ,  
				Round(ifnull(@AvgFatCow , 0.0),2) as AvgFatCow, 
				ifnull(@TotalMilkQuantityBuffalo , 0.0) AS TotalQuantityBuffalo , 
				ifnull(@AvgSNFBuffalo , 0.0) as AvgSNFBuffalo, 
				ifnull(@AvgFatBuffalo , 0.0) as AvgFatBuffalo,
                
                ifnull(@S_TotalMilkQuantityCow, 0.0) as S_TotalMilkQuantityCow ,
				Round(ifnull(@S_AvgSNFCow , 0.0),2 ) as S_AvgSNFCow ,  
				Round(ifnull(@S_AvgFatCow , 0.0),2) as S_AvgFatCow, 
				ifnull(@S_TotalMilkQuantityBuffalo , 0.0) AS S_TotalQuantityBuffalo , 
				ifnull(@S_AvgSNFBuffalo , 0.0) as S_AvgSNFBuffalo, 
				ifnull(@S_AvgFatBuffalo , 0.0) as S_AvgFatBuffalo,
                
                ifnull(@MCCType_Id,'') as MCCType_Id ,
                ifnull(@Vehicle_trip_id,'') as Vehicle_trip_id , if(ifnull(@Vehicle_trip_id, 0 ) = 0 , 0 , 1 ) as Vehicle_trip_Status ,
				ifnull(@Driver_Name,'') as Driver_Name , @Driver_Id as Driver_Id ,  ifnull(@Vehicle_No,'') as Vehicle_No, 
				ifnull(@Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
               @Check_Is_MilkDispatch as Check_Is_MilkDispatch,
               @Chemist_Is_MilkDispatch as Chemist_Is_MilkDispatch
			FROM m005_mcc_offline_config
			WHERE Org_Id = Var_Org_Id 
			AND MCC_Id = Var_MCC_Id limit 1;
            
            
            
		end;
	elseif (Var_Method_Name = 'StartOfflineShift') then
		begin
			SET SQL_SAFE_UPDATES = 0;
			set sql_require_primary_key = 0 ;
			set @Current_times = (SELECT TIME(CONVERT_TZ(now(), '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(now(), '+00:00', '+00:00'));
			
			select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
			order by Applicable_Date desc limit 1 ;
            
			
			set @CollectionShift_Id = '';
			
			SELECT 
				CASE
				WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
					'C015001' -- Morning Shift
				WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
					'C015002' -- Evening Shift
				ELSE 
					'' 
				END INTO @CollectionShift_Id  FROM m005_mcc_offline_config
			WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1;
            
            
			
			IF (@CollectionShift_Id IS NULL or @CollectionShift_Id = '' ) THEN 
             
				SET @CollectionShift_Id = ( 
					SELECT 
						CASE
						WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
							'C015001' -- Morning Shift
						WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
							'C015002' -- Evening Shift
						ELSE 
							'' 
						END   FROM m005_mcc_offline_config
					WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1);
			END IF ;
            
             
             
            
             
             
			 
			if exists (select 1 from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Shift_Status = 2
						AND CollectionShift_Id = @CollectionShift_Id and date(Collection_Date) = date(@Current_Datetime)) then 
				select -1 as Result_Id, 'Shift Closed' as Result_Description, '' as Result_Extra_Key;
			else
				SET @CollectionShift_Id = (
					SELECT 
						CASE
						WHEN Is_Morning = 1 AND time(now()) BETWEEN Morning_Start_Time AND Morning_End_Time THEN 
							'C015001' -- Morning Shift
						WHEN Is_Evening = 1 AND time(now()) BETWEEN Evening_Start_Time AND Evening_End_Time THEN 
							'C015002' -- Evening Shift
						ELSE 
							'' 
						END   FROM m005_mcc_offline_config
					WHERE Org_Id = Var_Org_Id AND MCC_Id = Var_MCC_Id limit 1

				);
				select CollectionShift_Id , CollectionShift_Name INTO @CollectionShift_Id ,  @CollectionShift_Name  from c015_collectionshift c015 where CollectionShift_Id = @CollectionShift_Id
				AND @Current_times BETWEEN ShiftStart_Time AND ShiftEnd_Time limit 1;
				
				if (@CollectionShift_Id = '' or @CollectionShift_Id is  null ) then
					select -1 as Result_Id, 'No shift scheduled' as Result_Description, '' as Result_Extra_Key;
				else 
					IF EXISTS(select 1 from t102_mcccollectionshift_offline where Org_Id = var_Org_Id 
                    and MCC_Id = var_MCC_Id 
                    and CollectionShift_Id = @CollectionShift_Id 
                    and date(Collection_Date) = date(@Current_Datetime)
                    and Shift_Status = 1 ) THEN 	
						select -1 as Result_Id, 'Shift Already Started' as Result_Description, '' as Result_Extra_Key;
					else
						set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
						set @New_MCCCollectionShift_Id ='';
						set @Agent_Id = (
						SELECT Agent_Id FROM m005_mcc 
						where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
						
						
						Call USP_Number_Range ('t102_mcccollectionshift_offline', @Year_Id, 'T102', '', @New_MCCCollectionShift_Id);
						
						select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
						
						insert into t102_mcccollectionshift_offline
						(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
						Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
						CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
						( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
						1, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , Agent_Name , 0 , @ShiftEnd_Time
						from mu05_agent where Org_Id = var_Org_Id and 
						Agent_Id = @Agent_Id limit 1 ) ;
						
						select 1 as Result_Id, 'Shift Started' as Result_Description, @New_MCCCollectionShift_Id as Result_Extra_Key;  
				
					end if;
				end if;
			end if;
		end;
        
	elseif (Var_Method_Name = 'EndOfflineShift') then
		begin
			SET SQL_SAFE_UPDATES = 0;
			set sql_require_primary_key = 0 ;
			set @Current_times = (SELECT TIME(CONVERT_TZ(now(), '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(now(), '+00:0	0', '+00:00'));
			
			select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
			order by Applicable_Date desc limit 1 ;
		
			set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
			
			if exists (select 1 from t102_mcccollectionshift_offline where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Shift_Status in ( 1 ) and  MCCCollectionShift_Id = Var_Shift_Id ) then 
				update t102_mcccollectionshift_offline set 
				ShiftEnd_Time = @Current_times,
				LastEditedBy_Id =  @Agent_Id ,
				LastEdited_On =  @Current_Datetime,
				-- Shift_Status = 2,
				LastEditedBy_Name = (select Agent_Name from mu05_agent where Org_Id = var_Org_Id and 
				Agent_Id =  @Agent_Id limit 1)
				where Org_Id = var_Org_Id and MCCCollectionShift_Id = Var_Shift_Id ;
			
				select 1 as Result_Id, 'Shift ended' as Result_Description, '' as Result_Extra_Key ;
			else
				select -1 as Result_Id, 'Shift already ended' as Result_Description,'' as Result_Extra_Key ;
			end if;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
