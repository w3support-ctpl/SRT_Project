-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRoute_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRoute_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Route_Id varchar(20),
    var_Route_Name varchar(50),
    var_Route_Code varchar(50),
    var_Status varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m006.Org_Id, Route_Id, Route_Name, Route_Code, 
            ifnull(c015.CollectionShift_Id ,'' ) as CollectionShift_Id,
            ifnull(c015.CollectionShift_Name ,'' ) as CollectionShift_Name,
            c020.VehicleType_Id,c020.VehicleType_Name,
            m006.Is_Active, m006.Is_Deleted ,m006.Is_Lived
            from m006_route m006
			left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
			inner join c020_vehicletype c020 on c020.VehicleType_Id = m006.VehicleType_Id
            where m006.Org_Id = var_Org_Id 
            and m006.Is_Deleted = 0 
            and m006.CollectionShift_Id like var_Route_Code 
            and m006.Is_Active like var_Status
            and Route_Name like  var_Route_Name
            and Route_Code like  var_Route_Name
            order by Route_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			SELECT 
			m006.Org_Id, m006.Route_Id, m006.Route_Code, m006.Route_Name, ifnull(m006.CollectionShift_Id,'') as CollectionShift_Id,
            m006.VehicleType_Id, m006.Freight_Fix_Cost, m006.Total_Distance,
           CONCAT(
				'[',
				CONCAT_WS(
					',',
					CASE WHEN Monday_Flag = 1 THEN '"C031001"' ELSE NULL END,
					CASE WHEN Tuesday_Flag = 1 THEN '"C031002"' ELSE NULL END,
					CASE WHEN Wednesday_Flag = 1 THEN '"C031003"' ELSE NULL END,
					CASE WHEN Thursday_Flag = 1 THEN '"C031004"' ELSE NULL END,
					CASE WHEN Friday_Flag = 1 THEN '"C031005"' ELSE NULL END,
					CASE WHEN Saturday_Flag = 1 THEN '"C031006"' ELSE NULL END,
					CASE WHEN Sunday_Flag = 1 THEN '"C031007"' ELSE NULL END
				),']'
			) AS Frequency_Id,
            m006.Duration, m006.Fuel_Required, m006.Is_Active, m006.Is_Deleted,m006.Is_Lived,m006.Start_Time,m006.End_Time,
            date_format(m006.Start_Date, '%Y-%m-%d') as Start_Date,
            date_format(m006.End_Date, '%Y-%m-%d') as End_Date,
				CASE
					WHEN m008.Route_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m006_route m006
			LEFT JOIN (
				SELECT DISTINCT Route_Id
				FROM m008_route_vehicle
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m008 ON m008.Route_Id = m006.Route_Id
			WHERE m006.Org_Id = var_Org_Id 
				AND m006.Route_Id = var_Route_Id
				AND m006.Is_Deleted = 0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
