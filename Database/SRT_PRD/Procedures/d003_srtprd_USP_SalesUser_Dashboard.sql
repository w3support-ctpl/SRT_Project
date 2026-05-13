-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUser_Dashboard` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUser_Dashboard`(
	var_Method_Name varchar(40),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
	Var_LoginType varchar(40),
    var_RouteDay_Id varchar(40),
    var_Route_Id varchar(20)
    )
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
    if(var_Method_Name = 'GetDashboard') then 
    
		select m019.Route_Name , m019.RouteDay_Id , 
        
        -- if(t041.Entry_Id is null , 0 , 1 ) AS Route_Started , 
        CASE 
			WHEN t041.Entry_Id IS NULL THEN 0 
			ELSE t041.Status 
		END AS Route_Started,

        m019.Route_Id ,
        -- ifnull((TIME_FORMAT(t041.Start_Time, '%h:%i %p')) , '') as Route_Started_At
        CASE 
			WHEN t041.Entry_Id IS NULL THEN '' 
			WHEN t041.Status = 1 THEN TIME_FORMAT(t041.Start_Time, '%h:%i %p') 
			WHEN t041.Status = 2 THEN TIME_FORMAT(t041.End_Time, '%h:%i %p') 
			ELSE '' 
		END AS Route_Started_At
		from m019_salesuserroute_header m019 
		inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id and 
        c045.RouteDay_Name = DAYNAME(CURDATE())
        LEFT JOIN t041_salesuser_route t041 on t041.Org_Id = m019.Org_Id and t041.RouteId = m019.Route_Id and date( t041.date) = date(now())
        where m019.SalesUser_Id = var_Profile_Id 
        limit 1;
    elseif(var_Method_Name = 'GetDashboards') then 
    
		select m019.Route_Name , m019.RouteDay_Id , 
        
        -- if(t041.Entry_Id is null , 0 , 1 ) AS Route_Started , 
        CASE 
			WHEN t041.Entry_Id IS NULL THEN 0 
			ELSE t041.Status 
		END AS Route_Started,

        m019.Route_Id ,
        -- ifnull((TIME_FORMAT(t041.Start_Time, '%h:%i %p')) , '') as Route_Started_At
        CASE 
			WHEN t041.Entry_Id IS NULL THEN '' 
			WHEN t041.Status = 1 THEN TIME_FORMAT(t041.Start_Time, '%h:%i %p') 
			WHEN t041.Status = 2 THEN TIME_FORMAT(t041.End_Time, '%h:%i %p') 
			ELSE '' 
		END AS Route_Started_At
		from m019_salesuserroute_header m019 
		inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id 
        and c045.RouteDay_Name = DAYNAME(CURDATE())
        LEFT JOIN t041_salesuser_route t041 on t041.Org_Id = m019.Org_Id and t041.RouteId = m019.Route_Id and date( t041.date) = date(now())
        where m019.SalesUser_Id = var_Profile_Id ; 
    
	ELSEif(var_Method_Name = 'StartDay') then  
    
    
			set @Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t041_salesuser_route', @Year_Id, 'T041', '', @Entry_Id );
            
			
            SET @Route_Date = (select RouteDay_Name FROM  c045_route_day WHERE  
            RouteDay_Id = var_RouteDay_Id LIMIT 1);
    
			insert into t041_salesuser_route( Org_Id, Entry_Id, SalesUser_Id, RouteId, RouteDay_Id, Route_Day, Start_Time, Status , Date) 
            values (var_Org_Id , @Entry_Id , var_Profile_Id , var_Route_Id , var_RouteDay_Id , @Route_Date , TIME(NOW()) ,  1 , now()
            );
    
    
			SELECT 1 AS Result_Id,  'Day Started' AS Result_Description,  '' AS Result_Extra_Key;


    elseif(var_Method_Name = 'GetInfo') then 
    
		
      select mu12.SalesUser_Id, mu12.SalesUser_Name, mu12.SAP_BP_Partner_Code, mu12.SalesUser_Code, mu12.SalesUserRole_Id as SalesUserRole, 
      mu12.ReportingTo_Id as ReportingTo 
      , mu12.Mobile_No, mu12.Address_Text, mu12.Pincode, mu12.Pan_No, mu12.Aadhar_No, mu12.Profile_Photo 
      from mu12_sales_user mu12
      left join c044_sales_user_role c044 on mu12.SalesUserRole_Id = c044.SalesUserRole_Id 
      left join mu12_sales_user mu12a on mu12a.ReportingTo_Id = mu12.SalesUser_Id and mu12.Org_Id = mu12a.Org_Id
      where mu12.SalesUser_Id = var_Profile_Id and mu12.Org_Id = var_Org_Id limit 1;
      
    
    elseif(var_Method_Name = 'EndDay') then 
		
        update t041_salesuser_route 
		set End_Time = now(),
		Status = 2
		where Org_Id = var_Org_Id
		and SalesUser_Id = var_Profile_Id
		and RouteDay_Id = var_RouteDay_Id
		and RouteId = var_Route_Id
		and date(Date) = date(now());
        
        SELECT 1 AS Result_Id,  'Day Closed' AS Result_Description,  '' AS Result_Extra_Key;

	elseif(var_Method_Name = 'ReOpen') then 
		
        update t041_salesuser_route 
		set Is_Open = 1
		where Org_Id = var_Org_Id
		and SalesUser_Id = var_Profile_Id
		and RouteDay_Id = var_RouteDay_Id
		and RouteId = var_Route_Id
		and date(Date) = date(now());
        
        SELECT 1 AS Result_Id,  'Day ReOpen' AS Result_Description,  '' AS Result_Extra_Key;
    
	end if ;
    
    

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
