-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDateReOpen_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDateReOpen_Get`(
	var_Org_Id VARCHAR(10),
	var_Method_Name VARCHAR(45),
    var_User_Id VARCHAR(45)
)
BEGIN
	-- table yet to be made
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		select 
		t041.Org_Id,t041.Entry_Id,
		mu12.SalesUser_Id,mu12.SalesUser_Name,
		m019.Route_Id,ifnull(m019.Route_Name,'') as Route_Name,
		c045.RouteDay_Id,c045.RouteDay_Name,
		Time_FORMAT(t041.Start_Time, '%h:%i %p') AS Start_Time,
		ifnull(Time_FORMAT(t041.End_Time, '%h:%i %p'),'') AS End_Time,
		t041.Status,
		DATE_FORMAT(t041.Date, '%d %b %Y %h:%i %p') AS Date,
		t041.Is_Open
		from t041_salesuser_route t041
		inner join mu12_sales_user mu12 on
		mu12.Org_Id = t041.Org_Id
		and mu12.SalesUser_Id = t041.SalesUser_Id
		inner join m019_salesuserroute_header m019 on
		m019.Org_Id = t041.Org_Id
		and m019.Route_Id = t041.RouteId
        and m019.RouteDay_Id = t041.RouteDay_Id
		inner join c045_route_day c045 on
		c045.RouteDay_Id = t041.RouteDay_Id
		where t041.Org_Id = var_Org_Id
        and date(t041.Date) = date(now())
		and t041.Is_Open = 1;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
