-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminManageTrips` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminManageTrips`(
	Var_Method_Name varchar(20),
	Var_Org_Id varchar(20),
	Var_Route_Trip_Id varchar(20),
	Var_Vehicle_Id varchar(20),
	Var_Profile_Id varchar(20),
	Var_MCC_Id varchar(20),
	Var_Trip_Id varchar(20),
	Var_Reason varchar(50)
)
BEGIN

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    SET SQL_SAFE_UPDATES = 0;
    
    if (Var_Method_Name = 'StartTrip') then
		set @Entry_Id = '';
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t021_trip_document', @Year_Id, 'T021', '', @Entry_Id);
        
        if exists( select 1 from t021_tripdocument_header where Org_Id = Var_Org_Id and Driver_Id = Var_Profile_Id and
        Route_Trip_Id = Var_Route_Trip_Id and date(Created_On) = date(@Current_Datetime) ) then

			select -1 as Result_Id, 'Trip Already Started' as Result_Description, '' as Result_Extra_Key;  
		
		else
			
            Set @Route_Id = (Select Route_Id from m008_route_vehicle where Entry_Id = Var_Route_Trip_Id and Org_Id = Var_Org_Id limit 1);
            
           set @Next_Destination = ( SELECT m007.MCC_Id 
            FROM m007_route_item m007 
			WHERE m007.Route_Id = @Route_Id  and  m007.Org_Id = Var_Org_Id 
            order by Arrival_Time asc limit 1) ;
            
            Set @Transporter_Id = (select Transporter_Id from m003_vehicle where Org_Id = Var_Org_Id and Vehicle_Id = Var_Vehicle_Id limit 1 );
            
            
			insert into t021_tripdocument_header (Org_Id , TripDocument_Id, Route_Trip_Id , Driver_Id , Vehicle_Id, Next_Destination , Created_On , Trip_Status , CreatedBy_Id ,Transporter_Id)
			values (Var_Org_Id, @Entry_Id , Var_Route_Trip_Id ,Var_Profile_Id , Var_Vehicle_Id
            
            -- (select Vehicle_Id from m003_vehicle where Org_Id = Var_Org_Id and Vehicle_No = Var_Vehicle_Id limit 1) 
            , @Next_Destination, @Current_Datetime , 'InTrip' , Var_Profile_Id, @Transporter_Id) ;
		
			SET @row_number = 0;
        
			insert into t022_tripdocument_item (Org_Id ,TripDocument_Id ,Route_Id,  MCC_Id, Expected_Time , Created_On , Order_By , Is_Reached )
            
            SELECT Var_Org_Id , @Entry_Id ,@Route_Id , m007.MCC_Id , Arrival_Time , @Current_Datetime , 
            (@row_number := @row_number + 1) , 0 
            FROM m007_route_item m007 
            inner join m005_mcc m005 on m005.Org_Id = m007.Org_Id and m005.MCC_Id = m007.MCC_Id
			WHERE m007.Route_Id = @Route_Id  and  m007.Org_Id = Var_Org_Id 
            order by Arrival_Time asc;
    
			select 1 as Result_Id, 'Trip Started' as Result_Description, @Entry_Id as Result_Extra_Key;  
		
        end if ;
        
	elseif(Var_Method_Name = 'GetVehicleStatus' )then 
    
		IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
        
        
        set @Is_Release = (select Is_Release from t009_milkcollectiondairy_header where Org_Id = Var_Org_Id 
        and TripDocument_Id = @Trip_Id and is_active = 1 limit 1 );
        
        set @Is_EndTrip_Available = if (@Is_Release is null , 0 , @Is_Release);
        
        
        
        set @VehicleType = (select VehicleType_Id from t021_tripdocument_header t021 inner join m003_vehicle m003 on  t021.Org_Id = m003.Org_Id and t021.Vehicle_Id = m003.Vehicle_Id
		where TripDocument_Id = @Trip_Id limit 1 ) ;
        /* 
        if((select Trip_Status from t021_tripdocument_header where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id and @VehicleType = 'C020001' ) = 'AtMCC' ) then 
        
			select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
            m003.Vehicle_No , DATE_FORMAT(Arrival_At, '%h:%i %p') AS Arrival_At ,
			m003.VehicleType_Id , @Is_EndTrip_Available as Is_EndTrip_Available
            from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
            inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id =  t021.Vehicle_Id
			where t021.TripDocument_Id = @Trip_Id and Is_Reached not in (0 , 2) and t022.Org_Id = Var_Org_Id 
            order by Order_By asc limit 1;
            
        else 
        */
            select
            t021.Route_Trip_Id as Entry_Id,t021.Driver_Id,
            t022.TripDocument_Id ,ifnull(t022.MCC_CollectionShift_Id,'') as MCC_CollectionShift_Id, t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
            m003.Vehicle_No , m003.VehicleType_Id , ifnull(DATE_FORMAT(Arrival_At, '%h:%i %p'),'') AS Arrival_At , @Is_EndTrip_Available as Is_EndTrip_Available,Order_By,
            SUM(IFNULL(t006.Final_Qty_Cow_KG, 0) + IFNULL(t006.Final_Qty_Buf_KG, 0)) AS Weight,
			SUM(IFNULL(t006.Final_Qty_Cow_Ltr, 0) + IFNULL(t006.Final_Qty_Buf_Ltr, 0)) AS Liters,
            CASE
				WHEN t006.MCCCollectionShift_Id IS NULL OR t006.MCC_Id = '' THEN 0
				ELSE 1
			END AS Is_Collected,
            c015.CollectionShift_Id,c015.CollectionShift_Name
            from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
            left join  c015_collectionshift c015 on m006.CollectionShift_Id = c015.CollectionShift_Id 
			inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id =  t021.Vehicle_Id
            left join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
            and t006.MCCCollectionShift_Id =  t022.MCC_CollectionShift_Id
            and t006.MCC_Id =  t022.MCC_Id
			where t021.TripDocument_Id = @Trip_Id and t022.Org_Id = Var_Org_Id
            GROUP BY
            t021.Route_Trip_Id ,t021.Driver_Id,
				t022.TripDocument_Id,t022.MCC_CollectionShift_Id ,
				t022.MCC_Id, m005.MCC_Name, Route_Name, m006.Route_Id, Expected_Time, Is_Reached,
				Trip_Started_On, Trip_Status, Is_Vehicle_Breakdown, m003.Vehicle_No, m003.VehicleType_Id,
				Arrival_At, Is_EndTrip_Available, Order_By,t006.MCCCollectionShift_Id,t006.MCC_Id,
                c015.CollectionShift_Id,c015.CollectionShift_Name
            order by Order_By asc ;
        
        -- end if ;
        
        
    	elseif(Var_Method_Name = 'ReachedDestination' )then 
			
					
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );
					
			update t022_tripdocument_item 
			set Is_Reached = 1 ,
			Arrival_At = @Current_Datetime 
			where Org_Id = Var_Org_Id and
			TripDocument_Id = Var_Trip_Id and 
			MCC_Id = Var_MCC_Id ;
		
			update t021_tripdocument_header 
			set Trip_Status = 'AtMCC' 
			where Org_Id = Var_Org_Id and
			TripDocument_Id = Var_Trip_Id ;
		
			select 1 as Result_Id, 'Reached' as Result_Description, '' as Result_Extra_Key;  

		elseif(Var_Method_Name = 'ChangeDestination' )then 

					IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );

			set @Order_No = (select Order_By from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id =  @Trip_Id and Is_Reached not in (1,2) order by  Order_By asc limit 1);

			update t022_tripdocument_item 
            set Order_By = @Order_No 
            where Org_Id = Var_Org_Id and 
            TripDocument_Id = @Trip_Id and 
			MCC_Id = Var_MCC_Id;
            
            update t022_tripdocument_item 
            set Order_By = Order_By + 1
            where Org_Id = Var_Org_Id and 
            TripDocument_Id = @Trip_Id and 
			MCC_Id <> Var_MCC_Id AND 
            Is_Reached NOT IN (1, 2) ;
            
            update t021_tripdocument_header 
            set Next_Destination = Var_MCC_Id
            where Org_Id = Var_Org_Id and 
            TripDocument_Id = @Trip_Id ;
            
			select 1 as Result_Id, 'Next Destination Changed' as Result_Description, @Entry_Id as Result_Extra_Key;  


		elseif(Var_Method_Name = 'GetMcc' )then 

		IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
		set @Trip_Id = Var_Trip_Id;
	
        END IF;
        
      
        
        -- (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );

		select m005.MCC_Id as Item_Id, MCC_Name as Item_Value 
		from t022_tripdocument_item t022 inner join m005_mcc m005 on t022.Org_Id = m005.Org_Id and t022.MCC_Id = m005.MCC_Id
        where m005.Org_Id = var_Org_Id 
        and t022.Is_Reached <> 2 and t022.TripDocument_Id = @Trip_Id
        order by MCC_Name asc ;

	elseif(Var_Method_Name = 'ReachedDairy' )then 
			
					IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );
				
			update t021_tripdocument_header 
			set Trip_Status = 'AtDairy' 
			where Org_Id = Var_Org_Id and
			TripDocument_Id = @Trip_Id ;
		
			select 1 as Result_Id, 'Reached' as Result_Description, '' as Result_Extra_Key;  
            
		elseif(Var_Method_Name = 'EndTrip' )then 
			
					IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );
				
			update t021_tripdocument_header 
			set Trip_Status = 'EndTrip' 
			where Org_Id = Var_Org_Id and
			TripDocument_Id = @Trip_Id ;
		
			select 1 as Result_Id, 'End' as Result_Description, '' as Result_Extra_Key;  

	elseif(Var_Method_Name = 'VehicleBreakDown' )then 
			
					IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );

			update t021_tripdocument_header 
			set Trip_Status = 'VehicleBeakDown'  ,
            Is_Vehicle_Breakdown = 1
			where Org_Id = Var_Org_Id and
			TripDocument_Id = @Trip_Id ;
		
			select 1 as Result_Id, 'Vehicle BeakDown' as Result_Description, '' as Result_Extra_Key;  
            
	elseif(Var_Method_Name = 'EndBreakDown' )then 
			
		IF (Var_Trip_Id = '' OR  Var_Trip_Id IS NULL ) THEN 
        
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
        else
        
		set @Trip_Id = Var_Trip_Id;
        
        
        END IF;
            
          --  (select Entry_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and  Driver_Id =  Var_Profile_Id and Trip_Status = 'InTrip' limit 1  );
		Set @Total_MCC = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id);
        set @Visited_MCC_Count = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id and Is_Reached = 2);
	
		Set @Visited_MCC = (select MCC_Id from t022_tripdocument_item 
        where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id and Is_Reached = 1);

                
			update t021_tripdocument_header 
			set Trip_Status = if (@Total_MCC = @Visited_MCC_Count , 'ToDairy' , if(@Visited_MCC is not null , 'AtMCC' , 'InTrip'))  , 
             Is_Vehicle_Breakdown = 0
			where Org_Id = Var_Org_Id and
			TripDocument_Id = @Trip_Id ;
            

		
			select 1 as Result_Id, 'End' as Result_Description, '' as Result_Extra_Key;  

		elseif(Var_Method_Name = 'GetBreakDownReasons' ) then 

		select BreakDown_Id as Item_Id, BreakDown_Reason as Item_Value 
		from c041_vehiclebreakdownreasons where Is_Active = 1 
        order by BreakDown_Reason asc ;

    end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
