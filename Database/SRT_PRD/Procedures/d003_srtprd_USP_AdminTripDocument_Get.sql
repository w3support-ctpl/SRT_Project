-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTripDocument_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTripDocument_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_Date varchar(60),
    var_TripDocumentStatus_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            select t021.Org_Id,t021.TripDocument_Id,
			m003.Vehicle_Id,m003.Vehicle_No, 
			mu06.Driver_Id,mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id,m006.Route_Name, m006.Route_Code, 
			CONCAT(Time_FORMAT(m006.Start_Time, '%h:%i %p'), ' - ', Time_FORMAT(m006.End_Time, '%h:%i %p')) as Duration,
			-- c015.CollectionShift_Id,c015.CollectionShift_Name, 
            ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
			ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
			date_format(t021.Created_On, '%d %M %Y') as Created_On,
			t021.FreightRateType_Id,ifnull(t021.DistanceAsPerApp ,'')as disatance_driver,t021.DistanceAsPerFleetX,ifnull(t021.FinalDistance,'') as FinalDistance,
			t021.Rate,t021.TripAmount,t021.SAP_Document_No,t021.Is_PostedInSAP,t021.Is_TripDocument_Locked
			from t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id
				and m003.Org_Id = t021.Org_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = t021.Driver_Id
				and mu06.Org_Id = t021.Org_Id
			inner join m008_route_vehicle m008 on m008.Entry_Id = t021.Route_Trip_Id
				and m008.Org_Id = t021.Org_Id
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
			where t021.Org_Id = var_Org_Id
			-- and (var_TripDocumentStatus_Id = '%%' or t021.Is_TripDocument_Locked = var_TripDocumentStatus_Id)
			and t021.Is_TripDocument_Locked like var_TripDocumentStatus_Id
            and 
			CAST(t021.Created_On AS DATE) >= var_StartDate and 
			CAST(t021.Created_On AS DATE) <= var_EndDate
			order by TripDocument_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
        Declare Current_Datetime datetime;
		set Current_Datetime = CONVERT_TZ(NOW(), '+00:00', '+00:00');
        /*
			select t021.Org_Id,t021.TripDocument_Id,
			m003.Vehicle_Id,m003.Vehicle_No, 
			mu06.Driver_Id,mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id,m006.Route_Name, m006.Route_Code, 
			CONCAT(Time_FORMAT(m006.Start_Time, '%h:%i %p'), ' - ', Time_FORMAT(m006.End_Time, '%h:%i %p')) as Duration,
			c015.CollectionShift_Id,c015.CollectionShift_Name, 
			date_format(t021.Created_On, '%d %M %Y') as Created_On,
			t021.DistanceAsPerApp,t021.DistanceAsPerFleetX,ifnull(t021.FinalDistance,'') as FinalDistance,
			t021.TripAmount,t021.SAP_Document_No,t021.Is_PostedInSAP,t021.Is_TripDocument_Locked,
            CASE 
				WHEN m004.FreightRateType_Id = 'C029001' THEN m006.Freight_Fix_Cost
				ELSE m004.Amount
			END
            -- '3' 
            as Rate,
            ifnull(m004.BaseRate,'') as DieselBaseRate,
			c029.FreightRateType_Id,c029.FreightRateType_Name,
			t001.DieselRate_Id,t001.DieselRate as CurrentDieselRate,
            t0091.Weight,t0091.Liters
			from t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id
				and m003.Org_Id = t021.Org_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = t021.Driver_Id
				and mu06.Org_Id = t021.Org_Id
			inner join m008_route_vehicle m008 on m008.Entry_Id = t021.Route_Trip_Id
				and m008.Org_Id = t021.Org_Id
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
            left join m004_freight m004 on m004.Vehicle_Id = m003.Vehicle_Id 
				and  date(m004.Applicable_Date) <= date(Current_Datetime)
				and m004.Is_Active =1
				and m004.Org_Id = m003.Org_Id
            inner join c029_freightratetype c029 on c029.FreightRateType_Id = m004.FreightRateType_Id
			left join t001_dieselrate t001 on t001.Org_Id = t021.Org_Id 
				and  date(t001.DieselRate_Date) >= date(Current_Datetime)
            left join t009_milkcollectiondairy_header t009 on t009.TripDocument_Id = t021.TripDocument_Id
				and t009.Org_Id = t021.Org_Id
			left join t009_milkcollectiondairy_milk t0091 on t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0091.Org_Id = t009.Org_Id
			where t021.Org_Id = var_Org_Id 
			and t021.TripDocument_Id = var_TripDocument_Id 
			order by m004.Applicable_Date DESC Limit 1;
            
            */
            
            /*
            select t021.Org_Id,t021.TripDocument_Id,
			m003.Vehicle_Id,m003.Vehicle_No, 
			mu06.Driver_Id,mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id,m006.Route_Name, m006.Route_Code, 
			CONCAT(Time_FORMAT(m006.Start_Time, '%h:%i %p'), ' - ', Time_FORMAT(m006.End_Time, '%h:%i %p')) as Duration,
			c015.CollectionShift_Id,c015.CollectionShift_Name, 
			date_format(t021.Created_On, '%d %M %Y') as Created_On,
			t021.DistanceAsPerApp,t021.DistanceAsPerFleetX,ifnull(t021.FinalDistance,'') as FinalDistance,
			t021.TripAmount,t021.SAP_Document_No,t021.Is_PostedInSAP,t021.Is_TripDocument_Locked,
            CASE 
				WHEN m004.FreightRateType_Id = 'C029001' THEN m006.Freight_Fix_Cost
				ELSE m004.Amount
			END
            -- '3' 
            as Rate,
            ifnull(m004.BaseRate,'') as DieselBaseRate,
			c029.FreightRateType_Id,c029.FreightRateType_Name,
			t001.DieselRate_Id,t001.DieselRate as CurrentDieselRate,
            t0091.Weight,t0091.Liters,ifnull(t021.FleetX_Id, '') as FleetX_Id
			from t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id
				and m003.Org_Id = t021.Org_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = t021.Driver_Id
				and mu06.Org_Id = t021.Org_Id
			inner join m008_route_vehicle m008 on m008.Entry_Id = t021.Route_Trip_Id
				and m008.Org_Id = t021.Org_Id
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
            left join m004_freight m004 on m004.Vehicle_Id = m003.Vehicle_Id 
				and  date(m004.Applicable_Date) <= date(Current_Datetime)
				and m004.Is_Active =1
				and m004.Is_Deleted =0
				and m004.Org_Id = m003.Org_Id
            inner join c029_freightratetype c029 on c029.FreightRateType_Id = m004.FreightRateType_Id
			left join t001_dieselrate t001 on t001.Org_Id = t021.Org_Id 
				and  date(t001.DieselRate_Date) <= date(Current_Datetime)
                and t001.Is_Active =1
				and t001.Is_Deleted =0
            left join t009_milkcollectiondairy_header t009 on t009.TripDocument_Id = t021.TripDocument_Id
				and t009.Org_Id = t021.Org_Id
			left join t009_milkcollectiondairy_milk t0091 on t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0091.Org_Id = t009.Org_Id
			where t021.Org_Id = var_Org_Id
			and t021.TripDocument_Id = var_TripDocument_Id 
			order by m004.Applicable_Date DESC, m004.Applicable_Date DESC ,  t001.DieselRate_Date DESC  Limit 1;
            
            */
            
            		select t021.Org_Id,t021.TripDocument_Id,
			m003.Vehicle_Id,m003.Vehicle_No, 
			mu06.Driver_Id,mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id,m006.Route_Name, m006.Route_Code, 
			CONCAT(Time_FORMAT(m006.Start_Time, '%h:%i %p'), ' - ', Time_FORMAT(m006.End_Time, '%h:%i %p')) as Duration,
			-- c015.CollectionShift_Id,c015.CollectionShift_Name, 
            ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
			ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
			date_format(t021.Created_On, '%d %M %Y') as Created_On,
			ifnull(m006.Total_Distance,'') as disatance_driver,t021.DistanceAsPerFleetX,ifnull(t021.FinalDistance,'') as FinalDistance,
			t021.TripAmount,t021.SAP_Document_No,t021.Is_PostedInSAP,t021.Is_TripDocument_Locked,
            CASE 
				WHEN m004.FreightRateType_Id = 'C029001' THEN m006.Freight_Fix_Cost
				ELSE m004.Amount
			END
            -- '3' 
            as Rate,
            ifnull(m004.BaseRate,'') as DieselBaseRate,
			c029.FreightRateType_Id,c029.FreightRateType_Name,
			t001.DieselRate_Id,t001.DieselRate as CurrentDieselRate,
            t0091.Weight,t0091.Liters,ifnull(t021.FleetX_Id, '') as FleetX_Id
			from t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id
				and m003.Org_Id = t021.Org_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = t021.Driver_Id
				and mu06.Org_Id = t021.Org_Id
			inner join m008_route_vehicle m008 on m008.Entry_Id = t021.Route_Trip_Id
				and m008.Org_Id = t021.Org_Id
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			inner join m007_route_item m007 on m006.Route_Id = m007.Route_Id
				and m006.Org_Id = m007.Org_Id
			left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
            left join m004_freight m004 on m004.Vehicle_Id = m003.Vehicle_Id 
				and  date(m004.Applicable_Date) <= date(Current_Datetime)
				and m004.Is_Active =1
				and m004.Is_Deleted =0
				and m004.Org_Id = m003.Org_Id
            inner join c029_freightratetype c029 on c029.FreightRateType_Id = m004.FreightRateType_Id
			left join t001_dieselrate t001 on t001.Org_Id = t021.Org_Id 
				and  date(t001.DieselRate_Date) <= date(Current_Datetime)
                and t001.Is_Active =1
				and t001.Is_Deleted =0
            left join t009_milkcollectiondairy_header t009 on t009.TripDocument_Id = t021.TripDocument_Id
				and t009.Org_Id = t021.Org_Id
			left join t009_milkcollectiondairy_milk t0091 on t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0091.Org_Id = t009.Org_Id
			where t021.Org_Id = var_Org_Id
			and t021.TripDocument_Id = var_TripDocument_Id
            GROUP BY 
			t021.Org_Id, t021.TripDocument_Id, m003.Vehicle_Id, m003.Vehicle_No, mu06.Driver_Id, mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id, m006.Route_Name, m006.Route_Code, c015.CollectionShift_Id, c015.CollectionShift_Name,
			date_format(t021.Created_On, '%d %M %Y'), t021.DistanceAsPerFleetX, t021.FinalDistance, t021.TripAmount, t021.SAP_Document_No,
			t021.Is_PostedInSAP, t021.Is_TripDocument_Locked, m006.Freight_Fix_Cost, m004.Amount, m004.BaseRate,
			c029.FreightRateType_Id, c029.FreightRateType_Name, t001.DieselRate_Id, t001.DieselRate, t0091.Weight, t0091.Liters, t021.FleetX_Id,
			m004.Applicable_Date,m006.Total_Distance
			order by m004.Applicable_Date DESC, m004.Applicable_Date DESC ,  t001.DieselRate_Date DESC  Limit 1;
		end;
        elseif (var_Method_Name = 'Get_View') then
		begin
        
			select t021.Org_Id,t021.TripDocument_Id,
			m003.Vehicle_Id,m003.Vehicle_No, 
			mu06.Driver_Id,mu06.Driver_Name, mu06.Driver_Code,
			m006.Route_Id,m006.Route_Name, m006.Route_Code, 
			CONCAT(Time_FORMAT(m006.Start_Time, '%h:%i %p'), ' - ', Time_FORMAT(m006.End_Time, '%h:%i %p')) as Duration,
			-- c015.CollectionShift_Id,c015.CollectionShift_Name, 
            ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
			ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
			date_format(t021.Created_On, '%d %M %Y') as Created_On,
			ifnull(t021.DistanceAsPerApp ,'')as disatance_driver,ifnull(t021.DistanceAsPerFleetX,'')as disatance_fleetx,ifnull(t021.FinalDistance,'') as FinalDistance,
			t021.TripAmount,t021.SAP_Document_No,t021.Is_PostedInSAP,t021.Is_TripDocument_Locked,
            t021.Rate,t021.FreightRateType_Id,
            t021.DieselBaseRate,t021.CurrentDieselRate,t021.Weight,t021.Liters,ifnull(t021.FleetX_Id, '') as FleetX_Id
			from t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id
				and m003.Org_Id = t021.Org_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = t021.Driver_Id
				and mu06.Org_Id = t021.Org_Id
			inner join m008_route_vehicle m008 on m008.Entry_Id = t021.Route_Trip_Id
				and m008.Org_Id = t021.Org_Id
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
			where t021.Org_Id = var_Org_Id 
			and t021.TripDocument_Id = var_TripDocument_Id 
			order by t021.TripDocument_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
