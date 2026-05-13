-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentGetVehicle_Status` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentGetVehicle_Status`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_MCC_Collection_Shift varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN


	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	
    if (Var_Method_Name = 'GetVehicleStatus') then
		
        
		select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
        @MCCType_Id
        from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
		

        set @ColllectionShift_Id = (select CollectionShift_Id from t004_mcccollectionshift where
        Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift );
        
		set @Route_Id = '';
        set @Trip_Id  ='';
        
        select m008.Route_Id ,t021.TripDocument_Id into @Route_Id, @Trip_Id  from m006_route m006 inner join m007_route_item m007  on m006.Org_Id = m007.Org_Id and m006.Route_Id = m007.Route_Id
		inner join m008_route_vehicle m008 on m008.Org_Id = m007.Org_Id and m007.Route_Id = m008.Route_Id
        inner join t021_tripdocument_header t021 on t021.Org_Id = m008.Org_Id and t021.Route_Trip_Id = m008.Entry_Id
		where IF(  @MCCType_Id <> 'C014001' , 1=1 , CollectionShift_Id = @ColllectionShift_Id)
         and 
		MCC_Id = Var_MCC_Id and m008.Is_Active = 1 and t021.Trip_Status <> 'EndTrip' and t021.Org_Id = Var_Org_Id AND
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date( DATE_ADD(To_Date, INTERVAL 1 DAY)) 
        order by t021.Created_On desc
        limit 1 ;
       
        

        if((select Trip_Status from t021_tripdocument_header where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id ) = 'AtMCC' 
        and  ( Select Is_Reached from t022_tripdocument_item where
        Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and TripDocument_Id = @Trip_Id ) = 1
        ) then 
        
			select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
			where t021.TripDocument_Id = @Trip_Id and t021.Org_Id = Var_Org_Id
            order by Order_By asc limit 1;
		
        else 
        
            select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id ,DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
			where t021.TripDocument_Id = @Trip_Id and t021.Org_Id = Var_Org_Id and date(t021.Created_On) = date(@Current_Datetime) order by Order_By asc ;
        
        end if ;
	elseif (Var_Method_Name = 'GetVehicleStatusOffline') then
    
        select MCCCollectionShift_Id
		into @MCCCollectionShift_Id
		from  t102_mcccollectionshift_offline 
		where Org_Id = Var_Org_Id
		and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
        
        if(@MCCCollectionShift_Id is not null or @MCCCollectionShift_Id <> '')then
            
            set @ColllectionShift_Id = (select CollectionShift_Id from t102_mcccollectionshift_offline where
			Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift );
            
        else

			set @ColllectionShift_Id = (select CollectionShift_Id from t004_mcccollectionshift where
			Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift );
            
				
        end if;
        
        
		select Is_ManualWeight , Is_ManualQuality , Is_ExtraTime , MCCType_Id into @Is_ManualWeight , @Is_ManualQuality , @Is_ExtraTime  , 
        @MCCType_Id
        from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1 ;
		
        
		set @Route_Id = '';
        set @Trip_Id  ='';
        
        select m008.Route_Id ,t021.TripDocument_Id into @Route_Id, @Trip_Id  from m006_route m006 inner join m007_route_item m007  on m006.Org_Id = m007.Org_Id and m006.Route_Id = m007.Route_Id
		inner join m008_route_vehicle m008 on m008.Org_Id = m007.Org_Id and m007.Route_Id = m008.Route_Id
        inner join t021_tripdocument_header t021 on t021.Org_Id = m008.Org_Id and t021.Route_Trip_Id = m008.Entry_Id
		where IF(  @MCCType_Id <> 'C014001' , 1=1 , CollectionShift_Id = @ColllectionShift_Id)
		and 
		MCC_Id = Var_MCC_Id 
        and m008.Is_Active = 1 and t021.Trip_Status <> 'EndTrip' and t021.Org_Id = Var_Org_Id AND
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date( DATE_ADD(To_Date, INTERVAL 1 DAY)) 
        order by t021.Created_On desc
        limit 1 ;

        if((select Trip_Status from t021_tripdocument_header where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id ) = 'AtMCC' 
        and  ( Select Is_Reached from t022_tripdocument_item where
        Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and TripDocument_Id = @Trip_Id ) = 1
        ) then 
			
			select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
			where t021.TripDocument_Id = @Trip_Id and t021.Org_Id = Var_Org_Id
            -- and t022.MCC_Id = Var_MCC_Id
            order by Order_By asc ;
            
		
        else 
			
            select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id ,DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
			where t021.TripDocument_Id = @Trip_Id and t021.Org_Id = Var_Org_Id 
            and date(t021.Created_On) = date(@Current_Datetime)
           --  and t022.MCC_Id = Var_MCC_Id
            order by Order_By asc ;
        
        end if ;
    end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
