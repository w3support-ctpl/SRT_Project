-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverMilkCollect` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverMilkCollect`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Trip_Id varchar(20),
Var_Milk_Quantity varchar(10),
Var_AluminumCan_Without_Lid int,
Var_AluminumCan_With_Lid int,
Var_PlasticCan_Without_Lid int,
Var_PlasticCan_With_Lid int,
Var_Compartment_Type varchar(20) ,
Var_Profile_Id varchar(20),
Var_Vehicle_No Varchar(20),
Var_FilePath longtext
)
BEGIN

		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
		SET SQL_SAFE_UPDATES = 0;
        
    if(Var_Method_Name = 'CollectMilk') then 
    
    		
			set Var_Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
			set @Route_Trip_Id = (select t021.Route_Trip_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and TripDocument_Id = Var_Trip_Id);
            
            set @CollectionShift_Id = (select m006.CollectionShift_Id from m008_route_vehicle m008 inner join 
			m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id
			where m008.Entry_Id = @Route_Trip_Id limit 1);
            

		if exists (select 1 from t007_milkcollectiondriver where Org_Id =  Var_Org_Id and
        Trip_Id = Var_Trip_Id and MCC_Id = Var_MCC_Id) then 
        
		select -1 as Result_Id, 'Already Collected' as Result_Description, '' as Result_Extra_Key;  
	
	else 
        
		set @kg_to_ltr = (select Kg_To_Ltr_Farmer from c001_organization where Org_Id = Var_Org_Id) ;

		SET @Quantity_ltr = Var_Milk_Quantity;
        
        
        set @MCCCollectionShift_Id = '';
        set @MCCCollectionShift_Id = (SELECT MCCCollectionShift_Id FROM t004_mcccollectionshift 
        WHERE Org_Id = Var_Org_Id AND  MCC_Id = Var_MCC_Id and Is_Active = 1 and date(Collection_Date) = date(now())  and 
        CollectionShift_Id = @CollectionShift_Id
        order by Created_On desc LIMIT 1 );
        
        
        
        
        if (@MCCCollectionShift_Id is null or @MCCCollectionShift_Id = '') then 
        		
		select -1 as Result_Id, 'Shift Not Available' as Result_Description, '' as Result_Extra_Key;  

        else
        
		insert into t007_milkcollectiondriver (Org_Id, Trip_Id ,MCC_Id , Driver_Id, Quantity_Ltr , 
        Aluminum_Lid , Aluminum_Can , Plastic_Can , Plastic_Lid ,  Is_Active , Created_On , CreatedBy_Id , MCCCollectionShift_Id, 
        Vehicle_Id , CompartmentType , FilePath
      ) values 
        (Var_Org_Id , Var_Trip_Id , Var_MCC_Id ,Var_Profile_Id , Var_Milk_Quantity , (Var_AluminumCan_With_Lid),
			(Var_AluminumCan_With_Lid + Var_AluminumCan_Without_Lid) ,
			(Var_PlasticCan_Without_Lid + Var_PlasticCan_With_Lid) ,
            (Var_PlasticCan_With_Lid) , 1 ,  @Current_Datetime , Var_Profile_Id , @MCCCollectionShift_Id , 
            (select Vehicle_Id from m003_vehicle where Org_Id = Var_Org_Id and Vehicle_No = Var_Vehicle_No limit 1),
            Var_Compartment_Type , Var_FilePath
            ) ;

			update t022_tripdocument_item 
			set Is_Reached = 2 ,
            MCC_CollectionShift_Id = @MCCCollectionShift_Id ,
			Arrival_At = @Current_Datetime 
			where Org_Id =  Var_Org_Id and
			TripDocument_Id = Var_Trip_Id and 
			MCC_Id = Var_MCC_Id ;
			
		Set @Total_MCC = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = Var_Trip_Id);
        set @Visited_MCC_Count = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = Var_Trip_Id and Is_Reached = 2);
	
			update t021_tripdocument_header 
			set Trip_Status =  if (@Total_MCC = @Visited_MCC_Count , 'ToDairy' , 'InTrip' ) ,
            Next_Destination = (select MCC_Id from t022_tripdocument_item where  Org_Id =  Var_Org_Id and
			TripDocument_Id = @Trip_Id and Is_Reached <> 2 order by Order_By asc limit 1 )
			where Org_Id = Var_Org_Id and
			TripDocument_Id = Var_Trip_Id ;
            
			update t004_mcccollectionshift set Is_MilkDispatch = 2 where Org_Id = Var_Org_Id and 
            MCCCollectionShift_Id = @MCCCollectionShift_Id ;

			select 1 as Result_Id, 'Milk Collected' as Result_Description, '' as Result_Extra_Key;  
        
		end if;
        end if;
        
        elseif( Var_Method_Name = 'GetAgentMilkData' ) then
			
			set @Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
            
			set @Route_Trip_Id = (select t021.Route_Trip_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
			and TripDocument_Id = @Trip_Id );
            
            set @CollectionShift_Id = (select m006.CollectionShift_Id from m008_route_vehicle m008 inner join 
			m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id
			where m008.Entry_Id = @Route_Trip_Id limit 1);
            
		set @MCCCollectionShift_Id = '';
        set @MCCCollectionShift_Id = (SELECT MCCCollectionShift_Id FROM t004_mcccollectionshift 
        WHERE Org_Id = Var_Org_Id AND  MCC_Id = Var_MCC_Id and Is_Active = 1 and date(Collection_Date) = date(now())  and 
        CollectionShift_Id = @CollectionShift_Id
        order by Created_On desc LIMIT 1 );
            
            
		set @kg_to_ltr = (select Kg_To_Ltr_Farmer from c001_organization where Org_Id = Var_Org_Id) ;

        select 
		Aluminum_Can_Without_Lid as AluminumCan_Without_Lid , 
        Aluminum_Can_With_Lid as AluminumCan_With_Lid , 
		Plastic_Can_Without_Lid as PlasticCan_Without_Lid , 
        Plastic_Can_With_Lid as PlasticCan_With_Lid ,
		-- (Quantity_Ltr / @kg_to_ltr) as Total_Milk
		ifnull(sum(Quantity_Ltr),0.0) as Total_Milk
        from t006_milkcollectionagent t006 
        inner join t022_tripdocument_item t022 
        on t022.Org_Id = t006.Org_Id and 
		t022.MCC_Id = t006.MCC_Id 
        inner join t006_milkcollectionagent_item t006i on t006i.Org_Id = t006.Org_Id and t006.AgentCollection_Id = t006i.AgentCollection_Id
        inner join t004_mcccollectionshift t004 on t004.Org_Id = t006.Org_Id and t004.MCCCollectionShift_Id = t006.MCCCollectionShift_Id
        where t022.MCC_Id = Var_MCC_Id and TripDocument_Id = @Trip_Id and t004.Is_MilkDispatch not in (2) and t006.Org_Id =  Var_Org_Id and 
		t004.MCCCollectionShift_Id = @MCCCollectionShift_Id
        group by AluminumCan_Without_Lid , AluminumCan_With_Lid, PlasticCan_Without_Lid,PlasticCan_With_Lid limit 1;
        
    
    elseif (Var_Method_Name = 'SkipMcc') then
    
    	set Var_Trip_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = Var_Profile_Id 
		and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = Var_Org_Id order by Created_On desc limit 1);
        
    update t022_tripdocument_item 
			set Is_Reached = 2 ,
			Arrival_At = @Current_Datetime 
			where Org_Id =  Var_Org_Id and
			TripDocument_Id = Var_Trip_Id and 
			MCC_Id = Var_MCC_Id ;
			
		Set @Total_MCC = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = Var_Trip_Id);
        set @Visited_MCC_Count = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = Var_Trip_Id and Is_Reached = 2);
	
			update t021_tripdocument_header 
			set Trip_Status =  if (@Total_MCC = @Visited_MCC_Count , 'ToDairy' , 'InTrip' ) ,
            Next_Destination = (select MCC_Id from t022_tripdocument_item where  Org_Id =  Var_Org_Id and
			TripDocument_Id = @Trip_Id and Is_Reached <> 2 order by Order_By asc limit 1 )
			where Org_Id = Var_Org_Id and
			TripDocument_Id = Var_Trip_Id ;
            
            select 1 as Result_Id, 'Skipped' as Result_Description, '' as Result_Extra_Key;  
        
	
		end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
