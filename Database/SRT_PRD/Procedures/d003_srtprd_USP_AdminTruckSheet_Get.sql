-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTruckSheet_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTruckSheet_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Route_Id varchar(20),
    var_VehicleType varchar(20),
    var_Entry_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m008.Org_Id,
             mu06.Driver_Id ,mu06.Driver_Name,
			m006.Route_Id ,m006.Route_Name,m006.Route_Code,
             m003.Vehicle_Id ,m003.Vehicle_No,
             c020.VehicleType_Id, c020.VehicleType_Name,
             -- c015.CollectionShift_Id, c015.CollectionShift_Name,
             ifnull(c015.CollectionShift_Id ,'' ) as CollectionShift_Id,
            ifnull(c015.CollectionShift_Name ,'' ) as CollectionShift_Name,
            date_format(m008.To_Date, '%d %b %Y') To_Date,
            date_format(m008.From_Date, '%d %b %Y') From_Date,
            Chemist_Id,Entry_Id,m008.Is_Active,m008.Is_Deleted
            from m008_route_vehicle m008
             inner join mu06_driver mu06 on mu06.Driver_Id = m008.Driver_Id 
				and mu06.Org_Id = m008.Org_Id 
			 inner join m006_route m006 on m006.Route_Id = m008.Route_Id 
				and  m006.Org_Id = m008.Org_Id 
			 inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id 
				and  m003.Org_Id = m008.Org_Id 
			 inner join c020_vehicletype c020 on c020.VehicleType_Id = m003.VehicleType_Id 
             left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id 
            where m008.Org_Id = var_Org_Id and m008.Is_Deleted = 0 
            and m008.Route_Id = var_Route_Id
            and m008.VehicleType = var_VehicleType
            order by m008.From_Date DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			Declare Today_Date datetime;
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
			select Org_Id, Route_Id,Entry_Id, Vehicle_Id, VehicleType, 
            Driver_Id, Chemist_Id,
			date_format(From_Date, '%Y-%m-%d') as From_Date,
            date_format(To_Date, '%Y-%m-%d') as To_Date ,Is_Active, Is_Deleted ,
             CASE WHEN To_Date <= Today_Date THEN 1 ELSE 0 END AS Is_Locked
            from m008_route_vehicle 
            where Org_Id = var_Org_Id and Entry_Id = var_Entry_Id
            and Is_Deleted =0
            and VehicleType ='truck'
            
			union all 
             
			select m008.Org_Id, m008.Route_Id,m008.Entry_Id, m008.Vehicle_Id, m008.VehicleType, 
            m008.Driver_Id, m008.Chemist_Id,
			date_format(m008.From_Date, '%Y-%m-%d') as From_Date,
            date_format(m008.To_Date, '%Y-%m-%d') as To_Date ,
            m008.Is_Active, 
            m008.Is_Deleted ,
			CASE WHEN COALESCE(t021.Route_Trip_Id, '') != '' THEN 1 ELSE 0 END AS Is_Locked
            from m008_route_vehicle m008
            LEFT JOIN 
			t021_tripdocument_header t021 ON m008.Entry_Id = t021.Route_Trip_Id
            where m008.Org_Id = var_Org_Id and m008.Entry_Id = var_Entry_Id
            and m008.VehicleType ='tanker'
            and m008.Is_Deleted =0;
             
		end;
	elseif (var_Method_Name = 'Get_Route') then
		begin
			select Route_Id , Route_Name,
            date_format(Start_Date, '%Y-%m-%d') as Start_Date,
            date_format(End_Date, '%Y-%m-%d') as End_Date
			from m006_route where Org_Id = var_Org_Id and Is_Active = 1 and Route_Id = var_Route_Id
			order by Route_Name;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
