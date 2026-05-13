-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverPerformance` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverPerformance`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Date varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(Var_Method_Name ='GetDriverPerformance') then 
	 
	select avg(Route_Time) as Route_Time , avg(Route_Fuel)  AS AVGRoute_Fuel , sum(BreakDown) AS AVGBreakDown ,  week(Trip_Date) as Trip_Date ,     
    CONCAT( DATE_FORMAT(MIN(Trip_Date), '%e %b'), ' - ', DATE_FORMAT(MAX(Trip_Date), '%e %b %Y')) AS Trip_Date , 
    2.4 AS Time_Rating , 2.8 as Fuel_Rating , 2.9 as Breakdown_Rating , 2.7 as Monthly_Rating 
    from f007_driverperformance where Org_Id = Var_Org_Id and  
    Driver_Id = Var_Profile_Id and month(Trip_Date) = month(Var_Date) and  year(Trip_Date) = year(Var_Date)
	GROUP BY Trip_Date;
    
    end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
