-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverUpcomingTrip_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverUpcomingTrip_Get`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	IF(Var_Method_Name = 'GetUpcomingTrip') then

		select m008.Entry_Id as Route_Trip_Id, m003.Vehicle_No as Vehicle_Number, m006.Route_Name as Trip_Route , 
        m003.Vehicle_Id,
		ifnull(t021.Trip_Status, 'NotStarted' ) as Trip_Status,  TIME_FORMAT(Start_Time, '%h:%i %p')  as Trip_Time ,
		CollectionShift_Name ,if(t021.Route_Trip_Id = m008.Entry_Id and date(t021.Created_On) = date(@Current_Datetime) AND t021.Trip_Status IS NOT NULL , 1 , 0 ) as Is_Already_Started,
        DATE_FORMAT( if(date(@Current_Datetime) between date(m008.From_Date) and date( DATE_ADD(m008.To_Date, INTERVAL 1 DAY)) , @Current_Datetime , m008.From_Date )
        , '%e %M %Y') as Trip_Date ,  if(date(@Current_Datetime) between date(m008.From_Date) and date( DATE_ADD(m008.To_Date, INTERVAL 1 DAY)),  1 , 0 ) as Is_Starttrip_Available
		from m008_route_vehicle m008 left JOIN t021_tripdocument_header t021 on m008.Org_Id = t021.Org_Id 
        and t021.Route_Trip_Id = m008.Entry_Id and date(t021.Created_On) >= date(@Current_Datetime)
		inner join  m006_route m006 on m006.Org_Id = m008.Org_Id and m006.Route_Id = m008.Route_Id
		LEFT join  c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
		-- inner join m007_route_item m007 on m007.Org_Id = m008.Org_Id and m007.Route_Id = m008.Route_Id
		inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id and m003.Org_Id = m008.Org_Id
		where m008.Org_Id = Var_Org_Id and m008.Driver_Id = Var_Profile_Id and 
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date( DATE_ADD(To_Date, INTERVAL 1 DAY))
        and m008.Is_Active = 1 order by Trip_Date asc; 
       -- and date(t021.Created_On) >= date(@Current_Datetime);
		
        elseif(Var_Method_Name = 'GetDashboard') then 
        
        
		select m008.Entry_Id as Route_Trip_Id, m003.Vehicle_No as Vehicle_Number , ifnull(m005.MCC_Name,'--') as next_destination,
		m006.Route_Name as Trip_Route ,   ifnull(t021.Trip_Status, 'NotStarted' ) as Trip_Status, 
		TIME_FORMAT(Start_Time, '%h:%i %p') as Trip_start_time from m008_route_vehicle m008 left JOIN t021_tripdocument_header t021 on m008.Org_Id = t021.Org_Id and t021.Trip_Status <> 'endtrip'   
		and t021.Route_Trip_Id = m008.Entry_Id and date(t021.Created_On) >= date(@Current_Datetime) 
		left join m005_mcc m005 on t021.Org_Id = m005.Org_Id and t021.Next_Destination = m005.MCC_Id
		inner join  m006_route m006 on m006.Org_Id = m008.Org_Id and m006.Route_Id = m008.Route_Id  
		-- inner join m007_route_item m007 on m007.Org_Id = m008.Org_Id and m007.Route_Id = m008.Route_Id  
		inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id and m003.Org_Id = m008.Org_Id 
		where m008.Org_Id = Var_Org_Id and m008.Driver_Id = Var_Profile_Id and 
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date( DATE_ADD(To_Date, INTERVAL 1 DAY))
		and m008.Is_Active = 1
		order by t021.TripDocument_Id desc limit 1 ;

	end if;
 
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
