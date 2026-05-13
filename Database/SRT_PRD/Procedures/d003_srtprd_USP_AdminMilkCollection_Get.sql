-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollection_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(45),
    var_Vehicle_Id varchar(20),
    var_VehicleType varchar(20),
    var_MCC_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_Date varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then
		begin
        declare Today_Date datetime;
        -- set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
        set Today_Date = date(var_Date);
        /*
			SELECT 
				t009.Org_Id,t009.MilkCollectionDairy_Id,t021.TripDocument_Id,
				c015.CollectionShift_Id, ifnull(c015.CollectionShift_Name,'') as CollectionShift_Name,
                c020.VehicleType_Id, ifnull(c020.VehicleType_Name,'') as VehicleType_Name,
				m006.Route_Id,ifnull( m006.Route_Name,'') as Route_Name, 
                ifnull(Time_FORMAT(m006.End_Time, '%h:%i %p'),'') AS End_Time,
				m003.Vehicle_Id, ifnull(m003.Vehicle_No,'') as Vehicle_No,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release,
				COALESCE(SUM(t0091.Weight), 0) AS Weight,
				COALESCE(SUM(t0091.Cans), 0) AS Total_Cans
			FROM t009_milkcollectiondairy_header t009
			INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id
				and t021.Org_Id = t009.Org_Id
            INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id 
				and t021.Org_Id = m008.Org_Id
			INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			INNER JOIN c015_collectionshift c015 ON c015.CollectionShift_Id = m006.CollectionShift_Id
			INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = m008.Vehicle_Id
				and m003.Org_Id = m008.Org_Id
            INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
            LEFT JOIN t009_milkcollectiondairy_quantity t0091 ON t009.Org_Id = t0091.Org_Id
            and t009.TripDocument_Id = t0091.TripDocument_Id
            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			WHERE t009.Org_Id = var_Org_Id
            and date(t009.Created_On) = date(Today_Date)
			AND t009.Is_Deleted = 0
            -- and m008.VehicleType = var_VehicleType
            GROUP BY
				t009.Org_Id,t009.MilkCollectionDairy_Id,t021.TripDocument_Id,
				c015.CollectionShift_Id, c015.CollectionShift_Name,
                c020.VehicleType_Id, c020.VehicleType_Name,
				m006.Route_Id, m006.Route_Name, m006.End_Time,
				m003.Vehicle_Id, m003.Vehicle_No,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release
			ORDER BY 
				t009.MilkCollectionDairy_Id;
                
			*/
            SELECT *
			FROM (
				SELECT 
					t009.Org_Id, t009.MilkCollectionDairy_Id, t021.TripDocument_Id,
					-- c015.CollectionShift_Id, IFNULL(c015.CollectionShift_Name, '') AS CollectionShift_Name,
					ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
					ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
                    c020.VehicleType_Id, IFNULL(c020.VehicleType_Name, '') AS VehicleType_Name,
					m006.Route_Id, IFNULL(m006.Route_Name, '') AS Route_Name, 
					IFNULL(TIME_FORMAT(m006.End_Time, '%h:%i %p'), '') AS End_Time,
					m003.Vehicle_Id, IFNULL(m003.Vehicle_No, '') AS Vehicle_No,
					t009.Is_Active, t009.Is_Deleted,
					t009.Is_Confirm, t009.Is_Release,t009.Is_Locked,
                    t021.In_Locked_KM as Is_KM,
					COALESCE(SUM(t0091.Weight), 0) AS Weight,
					COALESCE(SUM(t0091.Cans), 0) AS Total_Cans
				FROM t009_milkcollectiondairy_header t009
				INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id
					AND t021.Org_Id = t009.Org_Id
				INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id 
					AND t021.Org_Id = m008.Org_Id
				INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
					AND m006.Org_Id = m008.Org_Id
				left JOIN c015_collectionshift c015 ON c015.CollectionShift_Id = m006.CollectionShift_Id
				INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = m008.Vehicle_Id
					AND m003.Org_Id = m008.Org_Id
				INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
				LEFT JOIN t009_milkcollectiondairy_quantity t0091 ON t009.Org_Id = t0091.Org_Id
					AND t009.TripDocument_Id = t0091.TripDocument_Id
					AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                     and t0091.MilkStatus_Id = 'C016001'
				WHERE t009.Org_Id = var_Org_Id
					AND DATE(t009.Created_On) = DATE(Today_Date)
					AND t009.Is_Deleted = 0
                    AND t009.Is_OutsideVehicle = 0
				GROUP BY
					t009.Org_Id, t009.MilkCollectionDairy_Id, t021.TripDocument_Id,
					c015.CollectionShift_Id, c015.CollectionShift_Name,
					c020.VehicleType_Id, c020.VehicleType_Name,
					m006.Route_Id, m006.Route_Name, m006.End_Time,
					m003.Vehicle_Id, m003.Vehicle_No,
					t009.Is_Active, t009.Is_Deleted,
					t009.Is_Confirm, t009.Is_Release

				UNION ALL

				SELECT 
					t009.Org_Id, t009.MilkCollectionDairy_Id,
					'' AS TripDocument_Id,
					'' AS CollectionShift_Id, '' AS CollectionShift_Name,
					'BulkSupplier' AS VehicleType_Id, 'BulkSupplier' AS VehicleType_Name,
					'' AS Route_Id, '' AS Route_Name, 
					DATE_FORMAT(t009.Created_On, '%h:%i %p') AS End_Time,
					IFNULL(t009.Vehicle_Id, '') AS Vehicle_Id, IFNULL(t009.Vehicle_Id, '') AS Vehicle_No,
					t009.Is_Active, t009.Is_Deleted,
					t009.Is_Confirm, t009.Is_Release,t009.Is_Locked,
                    '1' as Is_KM,
					COALESCE(SUM(t0091.Weight), 0) AS Weight,
					COALESCE(SUM(t0091.Cans), 0) AS Total_Cans
				FROM t009_milkcollectiondairy_header t009
				LEFT JOIN t009_milkcollectiondairy_quantity t0091 ON t009.Org_Id = t0091.Org_Id
					AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                    and t0091.MilkStatus_Id = 'C016001'
				WHERE t009.Org_Id = var_Org_Id
					AND DATE(t009.Created_On) = DATE(Today_Date)
					AND t009.Is_Deleted = 0
					AND t009.Is_OutsideVehicle = 1
				GROUP BY
					t009.Org_Id, t009.MilkCollectionDairy_Id, TripDocument_Id,
					CollectionShift_Id, CollectionShift_Name,
					VehicleType_Id, VehicleType_Name,
					Route_Id, Route_Name, End_Time,
					t009.Vehicle_Id, Vehicle_No,
					t009.Is_Active, t009.Is_Deleted,
					t009.Is_Confirm, t009.Is_Release
			) AS CombinedResult
			ORDER BY 
				CombinedResult.MilkCollectionDairy_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			declare RouteVehicle int;
            set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
			if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
            
			/*
				SELECT 
					m008.Org_Id,
					c015.CollectionShift_Id,c015.CollectionShift_Name,
					c020.VehicleType_Id, c020.VehicleType_Name,
					m006.Route_Id,m006.Route_Name,
					'' as MCC_Id,'' as MCC_Name,'' as MCC_Code,
					Time_FORMAT(m006.End_Time, '%h:%i %p') AS End_Time,
					m003.Vehicle_Id,m003.Vehicle_No,
					m008.Is_Active,m008.Is_Deleted
				FROM m008_route_vehicle m008
				INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
				and  m006.Org_Id = m008.Org_Id
				INNER JOIN c015_collectionshift c015 ON c015.CollectionShift_Id = m006.CollectionShift_Id 
				INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = m008.Vehicle_Id
					and m003.Org_Id = m008.Org_Id
				INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
				WHERE m008.Org_Id = var_Org_Id
				AND m008.Vehicle_Id = var_Vehicle_Id
				AND m008.Is_Deleted = 0
			   ORDER BY 
				m008.Entry_Id;
                
                */
                SELECT m008.Org_Id,
						-- c015.CollectionShift_Id,c015.CollectionShift_Name,
                        ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
						ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
						c020.VehicleType_Id, c020.VehicleType_Name,
						m006.Route_Id,m006.Route_Name,
						'' as MCC_Id,'' as MCC_Name,'' as MCC_Code,
						Time_FORMAT(m006.End_Time, '%h:%i %p') AS End_Time,
						m003.Vehicle_Id,m003.Vehicle_No,
						m008.Is_Active,m008.Is_Deleted
				FROM t021_tripdocument_header t021
				inner join m008_route_vehicle m008 on m008.Org_Id =  t021.Org_Id 
					and t021.Route_Trip_Id =  m008.Entry_Id 
                    and m008.Is_Active = 1
					and m008.Is_Deleted = 0
				INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = t021.Vehicle_Id
					and m003.Org_Id = t021.Org_Id
				 inner join m006_route m006 on m006.Org_Id =  m008.Org_Id 
					and m006.Route_Id =  m008.Route_Id 
				left JOIN c015_collectionshift c015 ON c015.CollectionShift_Id = m006.CollectionShift_Id
                INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
				where t021.Org_Id = var_Org_Id
				and t021.TripDocument_Id = var_TripDocument_Id
                and t021.Vehicle_Id = var_Vehicle_Id
                 ORDER BY 
				m008.Entry_Id;
              
            else
				 SELECT 
					t009.Org_Id,
					'' as CollectionShift_Id,'' as CollectionShift_Name,
					 '' as VehicleType_Id, 'BulkSupplier' as VehicleType_Name,
					'' as Route_Id,'' as Route_Name,
					m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
					DATE_FORMAT(t009.Created_On, '%h:%i %p') AS End_Time,
					t009.Vehicle_Id,t009.Vehicle_Id as Vehicle_No,
					t009.Is_Active,t009.Is_Deleted
					FROM t009_milkcollectiondairy_header t009
					inner join t009_milkcollectiondairy_mcc t0091 on t009.Org_Id = t0091.Org_Id
						and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
					inner join m005_mcc m005 on m005.Org_Id = t0091.Org_Id
						and m005.MCC_Id = t0091.MCC_Id
					 where t009.Org_Id = var_Org_Id 
					 and t009.Vehicle_Id = var_Vehicle_Id
					 and t009.Is_OutsideVehicle =1
					 and date(t009.Created_On) <= date(@Current_Datetime)
					 order by t009.Created_On DESC limit 1;
			end if;
		end;
	elseif (var_Method_Name = 'Get_Vehicle') then
		begin
            Declare Current_Datetime datetime;
			-- set Current_Datetime = CAST(CONVERT_TZ(NOW(), '+00:00', '+00:00') AS DATE);
            set Current_Datetime = date(var_Date);
			SELECT 
				t021.Org_Id,t021.TripDocument_Id,c020.VehicleType_Name,
				-- m003.Vehicle_Id, CONCAT(m003.Vehicle_No, ' - ', m006.Route_Name) AS Vehicle_No
                 m003.Vehicle_Id, 
                 -- CONCAT(c020.VehicleType_Name,' - ', m003.Vehicle_No, ' ( ', m006.Route_Name, ' )') AS Vehicle_No
				CONCAT(c020.VehicleType_Name,' - ', m003.Vehicle_No, ' ( ', m006.Route_Name,' - ', ifnull(c015.CollectionShift_Name,''),' )') AS Vehicle_No
            FROM t021_tripdocument_header t021
			INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id 
				and m008.Org_Id = t021.Org_Id 
			INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = m008.Vehicle_Id
				and m003.Org_Id = m008.Org_Id 
            INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id  
            INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id 
			left JOIN c015_collectionshift c015 ON m006.CollectionShift_Id = c015.CollectionShift_Id
			WHERE t021.Org_Id = var_Org_Id
			AND t021.Trip_Status = 'AtDairy'
			-- and m008.VehicleType = var_VehicleType  
			AND CAST(t021.Created_On AS DATE) =  Current_Datetime
			GROUP BY
			t021.Org_Id,t021.TripDocument_Id,c020.VehicleType_Name,
			-- m003.Vehicle_Id, CONCAT(m003.Vehicle_No, ' - ', m006.Route_Name)
            m003.Vehicle_Id, 
            -- CONCAT(c020.VehicleType_Name,' - ', m003.Vehicle_No, ' ( ', m006.Route_Name, ' )')
            CONCAT(c020.VehicleType_Name,' - ', m003.Vehicle_No, ' ( ', m006.Route_Name,' - ', ifnull(c015.CollectionShift_Name,''),' )')
			ORDER BY 
				t021.TripDocument_Id;
		end;
	elseif (var_Method_Name = 'Get_MCCList') then
		begin
			SELECT
				t022.Org_Id,
				t022.TripDocument_Id,
				t022.MCC_CollectionShift_Id as MCCCollectionShift_Id,
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				date_format(t022.Created_On, '%Y-%m-%d') as Created_On,
				CASE
					WHEN t0091.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Collected,
				CASE
					WHEN t009.TripDocument_Id IS NOT NULL THEN ifnull(MAX(t0091.Weight),'')
					ELSE ''
				END AS Weight,
				CASE
					WHEN t009.TripDocument_Id IS NOT NULL THEN ifnull(MAX(t0091.Liters),'')
					ELSE ''
				END AS Liters,
				CASE
					WHEN t009.TripDocument_Id IS NOT NULL THEN ifnull(MAX(t0091.SNF),'')
					ELSE ''
				END AS SNF,
				CASE
					WHEN t009.TripDocument_Id IS NOT NULL THEN ifnull(MAX(t0091.Fat),'')
					ELSE ''
				END AS Fat
			FROM t022_tripdocument_item t022
			LEFT JOIN t009_milkcollectiondairy_header t009 ON t009.TripDocument_Id = t022.TripDocument_Id
				and t009.Org_Id = t022.Org_Id
			INNER JOIN m005_mcc m005 ON m005.MCC_Id = t022.MCC_Id
				and m005.Org_Id = t022.Org_Id
            LEFT JOIN t009_milkcollectiondairy_mcc t0091 ON t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and m005.MCC_Id = t0091.MCC_Id
				and t009.Org_Id = t0091.Org_Id
			WHERE t022.Org_Id = var_Org_Id
				AND t022.TripDocument_Id = var_TripDocument_Id
			GROUP BY 
				t022.Org_Id,
				t022.TripDocument_Id,
				t022.MCC_CollectionShift_Id,
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				t022.Created_On,
                t0091.MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_AgentEntry') then
		begin
			DECLARE kg_to_ltr DECIMAL(8, 3);
            
            SELECT Kg_To_Ltr_Agent INTO kg_to_ltr FROM c001_organization WHERE Org_Id = var_Org_Id;

			SELECT 
				(ifnull(t006.Aluminum_Can_With_Lid,0) + 
                ifnull(t006.Aluminum_Can_Without_Lid,0) + 
                ifnull(t006.Plastic_Can_With_Lid,0) + 
                ifnull(t006.Plastic_Can_Without_Lid,0) 
                ) AS Cans,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name,
				CAST(t0061.Quantity_Ltr AS DECIMAL(8, 3)) AS Quantity_Ltr,
				CAST(t0061.Quantity_Ltr AS DECIMAL(8, 3)) AS Weight,
				CAST(t0061.FAT AS DECIMAL(8, 2)) AS FAT,
				CAST(t0061.SNF AS DECIMAL(8, 2)) AS SNF
			FROM t006_milkcollectionagent t006 
			INNER JOIN t006_milkcollectionagent_item t0061 ON t0061.AgentCollection_Id = t006.AgentCollection_Id
				and t0061.Org_Id = t006.Org_Id
			INNER JOIN c011_milktype c011 ON t0061.Milktype_Id = c011.Milktype_Id
			INNER JOIN c016_milkstatus c016 ON t0061.MilkStatus_Id = c016.MilkStatus_Id
			WHERE t006.Org_Id = var_Org_Id AND t006.Is_Deleted = 0 AND t006.MCC_Id = var_MCC_Id AND t006.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
			
          
		end;
	elseif (var_Method_Name = 'Get_Entry') then
		begin
			SELECT 
				t009.MilkCollectionDairy_Id ,t009.Is_Confirm,t009.Is_Release,
				c020.VehicleType_Id, c020.VehicleType_Name
			FROM t009_milkcollectiondairy_header t009 
			INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = t009.Vehicle_Id
				and m003.Org_Id = t009.Org_Id
			INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
			WHERE t009.Org_Id = var_Org_Id AND t009.Is_Deleted = 0 
            AND t009.Vehicle_Id = var_Vehicle_Id
            AND t009.TripDocument_Id = var_TripDocument_Id;
		end;
	elseif (var_Method_Name = 'Get_Supervisor') then
		begin
			/*
			SELECT 
				t021.TripDocument_Id ,m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,t008.MCCCollectionShift_Id as MCC_CollectionShift_Id,t008.ChemistCollection_Id,
				-- t0081.Comartment,
                REPLACE(REPLACE(t0081.Comartment, '[', ''), ']', '') as CellNo,
                t0081.FAT,t0081.SNF,t0081.Quantity_Ltr as Liter,t0081.Quantity_Kg as Weight,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name
			FROM t021_tripdocument_header t021 
			INNER JOIN t008_milkcollectionchemist t008 ON t008.Trip_Id = t021.TripDocument_Id
				and t008.Org_Id = t021.Org_Id
                -- and  t008.Is_BMC_Accepted = 1 
			INNER JOIN t008_milkcollectionchemist_item t0081 ON t0081.ChemistCollection_Id = t008.ChemistCollection_Id
				and t0081.Org_Id = t008.Org_Id
			INNER JOIN m005_mcc m005 ON m005.MCC_Id = t008.MCC_Id
				and m005.Org_Id = t008.Org_Id
			inner join c011_milktype c011 on c011.MilkType_Id = t0081.MilkType_Id 
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t0081.MilkStatus_Id 
			WHERE t021.Org_Id = var_Org_Id 
			AND t021.TripDocument_Id = var_TripDocument_Id
            order by m005.MCC_Name;
            */
            
            SELECT 
				t021.TripDocument_Id ,m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,t008.MCCCollectionShift_Id as MCC_CollectionShift_Id,t008.ChemistCollection_Id,
				-- t0081.Comartment,
                REPLACE(REPLACE(t0081.Comartment, '[', ''), ']', '') as CellNo,
                t0081.FAT,t0081.SNF,t0081.Quantity_Ltr as Liter,t0081.Quantity_Kg as Weight,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name
			FROM t021_tripdocument_header t021 
            inner join t022_tripdocument_item t022 on
				t022.TripDocument_Id = t021.TripDocument_Id
				and t022.Org_Id = t021.Org_Id
			INNER JOIN t008_milkcollectionchemist t008 ON t008.Trip_Id = t021.TripDocument_Id
				and t008.Org_Id = t021.Org_Id
                and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
                -- and  t008.Is_BMC_Accepted = 1 
			INNER JOIN t008_milkcollectionchemist_item t0081 ON t0081.ChemistCollection_Id = t008.ChemistCollection_Id
				and t0081.Org_Id = t008.Org_Id
			INNER JOIN m005_mcc m005 ON m005.MCC_Id = t008.MCC_Id
				and m005.Org_Id = t008.Org_Id
			inner join c011_milktype c011 on c011.MilkType_Id = t0081.MilkType_Id 
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t0081.MilkStatus_Id 
			WHERE t021.Org_Id = var_Org_Id
			AND t021.TripDocument_Id = var_TripDocument_Id
            order by m005.MCC_Name;
		end;
	elseif (var_Method_Name = 'Get_AgentMCCList') then
		begin
			set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id) ;
            
			SELECT 
				t021.TripDocument_Id ,m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				t006.MCCCollectionShift_Id as MCC_CollectionShift_Id,t006.AgentCollection_Id,
				t0061.FAT,t0061.SNF,t0061.Quantity_Ltr as Liter,
				CAST(t0061.Quantity_Ltr / @kg_to_ltr AS DECIMAL(10, 3)) AS Weight,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name
			FROM t021_tripdocument_header t021 
			INNER JOIN t022_tripdocument_item t022 ON t022.TripDocument_Id = t021.TripDocument_Id
				and t022.Org_Id = t021.Org_Id
			INNER JOIN t006_milkcollectionagent t006 ON t006.MCC_Id = t022.MCC_Id and  t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
				and t006.Org_Id = t022.Org_Id
			INNER JOIN t006_milkcollectionagent_item t0061 ON t0061.AgentCollection_Id = t006.AgentCollection_Id
				and t0061.Org_Id = t006.Org_Id
			INNER JOIN m005_mcc m005 ON m005.MCC_Id = t006.MCC_Id
				and m005.Org_Id = t006.Org_Id
			inner join c011_milktype c011 on c011.MilkType_Id = t0061.MilkType_Id 
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t0061.MilkStatus_Id 
			WHERE t021.Org_Id = var_Org_Id
			AND t021.TripDocument_Id = var_TripDocument_Id
            order by m005.MCC_Name;
		end;
	elseif (var_Method_Name = 'Get_TankerCell') then
		begin
			SELECT  NoOfCellsInTanker 
			FROM m003_vehicle
			where Org_Id = var_Org_Id and Is_Active = 1
			and Vehicle_Id = var_Vehicle_Id;
		end;
        /*
	elseif (var_Method_Name = 'Get_TankerCellUse') then
		begin
			DECLARE CellSet varchar(255);
            DECLARE k INT UNSIGNED DEFAULT 1;
            DECLARE tempValue VARCHAR(20);
            
            SELECT count(t008A.Comartment) into @CountCheck
			FROM t008_milkcollectionchemist t008
			inner join t008_milkcollectionchemist_item t008A on 
			t008A.ChemistCollection_Id = t008.ChemistCollection_Id
			and t008A.Org_Id = t008.Org_Id
			where t008.Org_Id = var_Org_Id 
			and t008.Trip_Id = var_TripDocument_Id;
            
            if @CountCheck > 1 then
                SELECT 
				CONCAT('[', REPLACE(REPLACE(
				CONCAT('[', GROUP_CONCAT(t008A.Comartment ORDER BY t008A.Comartment SEPARATOR ', '), ']')
				, ']', ''), '[', ''), ']')
				into CellSet FROM t008_milkcollectionchemist t008
				inner join t008_milkcollectionchemist_item t008A on 
				t008A.ChemistCollection_Id = t008.ChemistCollection_Id
				and t008A.Org_Id = t008.Org_Id
				where t008.Org_Id = var_Org_Id 
				and t008.Trip_Id = var_TripDocument_Id;
            else
				SELECT t008A.Comartment into CellSet 
                FROM t008_milkcollectionchemist t008
				inner join t008_milkcollectionchemist_item t008A on 
				t008A.ChemistCollection_Id = t008.ChemistCollection_Id
				and t008A.Org_Id = t008.Org_Id
				where t008.Org_Id = var_Org_Id 
				and t008.Trip_Id = var_TripDocument_Id;
			end if;
			
            
            DROP TEMPORARY TABLE IF EXISTS temp_table;
            CREATE TEMPORARY TABLE temp_table (PKeyRowNum int, item_value int);
            
            SET CellSet = REPLACE(REPLACE(CellSet, '[', ''), ']', '');
			
            WHILE k <= LENGTH(CellSet) - LENGTH(REPLACE(CellSet, ',', '')) + 1 DO
                SET tempValue = SUBSTRING_INDEX(SUBSTRING_INDEX(CellSet, ',', k), ',', -1);
                INSERT INTO temp_table (PKeyRowNum, item_value) VALUES (k, tempValue);
                SET k = k + 1;
            END WHILE;
            
            select 
            item_value as cellno
            from  temp_table;
            
		end;
        */
	elseif (var_Method_Name = 'Get_Quantity') then
		begin
			select t009A.Org_Id,t009A.Batch_Id,
			-- m005.MCC_Name,
			t009A.Weight,t009A.Liters,
			COALESCE(t009A.Cans, t009B.Cans) AS Cans,
			Time_FORMAT(t009A.Start_Time, '%h:%i %p') AS Start_Time,
			c011.MilkType_Name,
			c016.MilkStatus_Name
			from t009_milkcollectiondairy_quantity t009A
			inner join c011_milktype c011 on c011.MilkType_Id = t009A.MilkType_Id 
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009A.MilkStatus_Id
			-- inner join m005_mcc m005 on m005.MCC_Id = t009A.MCC_Id
			left join t009_milkcollectiondairy_quality t009B on t009B.Batch_Id = t009A.Batch_Id
				and t009B.Org_Id = t009A.Org_Id
			where t009A.Org_Id = var_Org_Id  
			and t009A.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			order by t009A.Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_Quality') then
		begin
			select t009.Org_Id,t009.Batch_Id,
			-- m005.MCC_Name,
			t009.Sample_No,ifnull(t009.SNF ,'')as SNF,ifnull(t009.Fat,'') as Fat,
			c016.MilkStatus_Name
			from t009_milkcollectiondairy_quality t009
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id 
			-- inner join m005_mcc m005 on m005.MCC_Id = t009.MCC_Id
			where t009.Org_Id = var_Org_Id  
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			order by t009.Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_BulkSupplier') then
    begin
		 SELECT 
			t009.Org_Id,
			'' as CollectionShift_Id,'' as CollectionShift_Name,
			 '' as VehicleType_Id, 'BulkSupplier' as VehicleType_Name,
			'' as Route_Id,'' as Route_Name,
			m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
			DATE_FORMAT(t009.Created_On, '%h:%i %p') AS End_Time,
			t009.Vehicle_Id,t009.Vehicle_Id as Vehicle_No,
			t009.Is_Active,t009.Is_Deleted
			FROM t009_milkcollectiondairy_header t009
			inner join t009_milkcollectiondairy_mcc t0091 on t009.Org_Id = t0091.Org_Id
				and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			inner join m005_mcc m005 on m005.Org_Id = t0091.Org_Id
				and m005.MCC_Id = t0091.MCC_Id
			 where t009.Org_Id = var_Org_Id 
			 and t009.Vehicle_Id = var_Vehicle_Id
			 and t009.Is_OutsideVehicle =1
			 and t009.Created_On <= CONVERT_TZ(NOW(), '+00:00', '+00:00') 
             order by t009.Created_On DESC limit 1;
    end;
	elseif (var_Method_Name = 'Get_MCCCommission') then
			begin
            /*
            SET @kg_to_ltr = (SELECT Kg_To_Ltr_Dairy FROM c001_organization WHERE Org_Id = var_Org_Id);

				WITH MCCCommission AS (
				SELECT
					m0021.Org_Id,
					m0021.MPPI_Id,
					m0021.MCC_Id,
					MAX(m0021.Version_No) AS MaxVersion
				FROM
					m002_commission_mcc_header m002
					INNER JOIN m002_commission_mcc_item m0021 ON
						m0021.Org_Id = m002.Org_Id
						AND m0021.MPPI_Id = m002.MPPI_Id
				WHERE
					m002.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
					AND m002.Org_Id = var_Org_Id
				GROUP BY
					m0021.Org_Id,
					m0021.MPPI_Id,
					m0021.MCC_Id
			)
	
			SELECT
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
				t0061.Quantity_Ltr as Liters,
                CAST(ifnull((t0061.Quantity_Ltr / @kg_to_ltr),0) AS DECIMAL(8, 3)) as Weight,
				t0061.FAT,
				t0061.SNF,
				m002Item.BaseRate,
				m002Item.ServiceCharge,
				ROUND(
				CASE
				WHEN IFNULL(SUM(t0061.Quantity_Ltr), 0) > MAX(m002Item.MinimumQuantity)
					 AND t0061.FAT > MAX(m002Item.MinimumFat)
					 AND t0061.SNF > MAX(m002Item.MinimumSNF) THEN
					(MAX(m002Item.BaseRate) * IFNULL(SUM(t0061.Quantity_Ltr), 0)) + MAX(m002Item.ServiceCharge)
				ELSE
					0
				END,
				2
			) as Amount
			FROM
				t009_milkcollectiondairy_header t009
				INNER JOIN t022_tripdocument_item t022 ON
					t022.Org_Id = t009.Org_Id
					AND t022.TripDocument_Id = t009.TripDocument_Id
				INNER JOIN t006_milkcollectionagent t006 ON
					t022.Org_Id = t006.Org_Id
					AND t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
					AND t022.MCC_Id = t006.MCC_Id
				INNER JOIN t006_milkcollectionagent_item t0061 ON
					t0061.Org_Id = t006.Org_Id
					AND t0061.AgentCollection_Id = t006.AgentCollection_Id
				INNER JOIN m005_mcc m005 ON
					m005.Org_Id = t006.Org_Id
					AND m005.MCC_Id = t006.MCC_Id
				INNER JOIN c011_milktype c011 ON
					c011.MilkType_Id = t0061.MilkType_Id
				INNER JOIN c016_milkstatus c016 ON
					c016.MilkStatus_Id = t0061.MilkStatus_Id
				INNER JOIN MCCCommission MC ON
					MC.MCC_Id = m005.MCC_Id
					AND MC.Org_Id = m005.Org_Id
				LEFT JOIN (
					SELECT
						Org_Id,
						MPPI_Id,
						BaseRate,
						ServiceCharge,
						MinimumQuantity,
						MinimumFat,
						MinimumSNF,
						BaseFat,
						BaseSNF
					FROM
						m002_commission_item
					WHERE
						Org_Id = var_Org_Id
						AND MPPI_Id IN (SELECT MPPI_Id FROM MCCCommission WHERE Org_Id = var_Org_Id)
						AND Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
                        and Is_Active =1
						and Is_Deleted =0
					ORDER BY
						Applicable_Date DESC
				) m002Item ON MC.MPPI_Id = m002Item.MPPI_Id
			WHERE
				t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				AND t009.Org_Id = var_Org_Id
				GROUP BY
				MC.MCC_Id, 
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
				t0061.Quantity_Ltr,
				t0061.FAT,
				t0061.SNF,
				m002Item.BaseRate,
				m002Item.ServiceCharge;
				*/
                
                SET @kg_to_ltr = (SELECT Kg_To_Ltr_Dairy FROM c001_organization WHERE Org_Id = var_Org_Id);
				SELECT *
							FROM (
				select 
					m005.MCC_Id,
					m005.MCC_Name,
					m005.MCC_Code,
					c011.Milktype_Id,
					c011.MilkType_Name,
					c016.MilkStatus_Id,
					c016.MilkStatus_Name,
					c047.MPPIType_Id,
					c047.MPPIType_Name,
					t0061.Quantity_Ltr as Liters,
					CAST(ifnull((t0061.Quantity_Ltr / @kg_to_ltr),0) AS DECIMAL(8, 3)) as Weight,
					t0061.FAT,
					t0061.SNF,   
					-- m0022.BaseRate as Rate,
                    ROUND(
						CASE
							WHEN IFNULL(SUM(t0061.Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(t0061.Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND t0061.FAT >= m0022.MinimumFat
							AND t0061.FAT <= m0022.MaximumFat
							AND t0061.SNF >= m0022.MinimumSNF 
							AND t0061.SNF <= m0022.MaximumSNF
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
                        2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(t0061.Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(t0061.Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND t0061.FAT >= m0022.MinimumFat
							AND t0061.FAT <= m0022.MaximumFat
							AND t0061.SNF >= m0022.MinimumSNF 
							AND t0061.SNF <= m0022.MaximumSNF
						THEN
							(m0022.BaseRate * IFNULL(SUM(t0061.Quantity_Ltr), 0)) 
						ELSE
							0
						END,
                        2
					) as Amount
				from t009_milkcollectiondairy_header t009
				INNER JOIN t022_tripdocument_item t022 ON
					t022.Org_Id = t009.Org_Id
					AND t022.TripDocument_Id = t009.TripDocument_Id
				INNER JOIN t006_milkcollectionagent t006 ON
					t022.Org_Id = t006.Org_Id
					AND t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
					AND t022.MCC_Id = t006.MCC_Id
				INNER JOIN t006_milkcollectionagent_item t0061 ON
					t0061.Org_Id = t006.Org_Id
					AND t0061.AgentCollection_Id = t006.AgentCollection_Id
				INNER JOIN m005_mcc m005 ON
					m005.Org_Id = t006.Org_Id
					AND m005.MCC_Id = t006.MCC_Id
				INNER JOIN c011_milktype c011 ON
					c011.MilkType_Id = t0061.MilkType_Id
				INNER JOIN c016_milkstatus c016 ON
					c016.MilkStatus_Id = t0061.MilkStatus_Id
				INNER JOIN m002_commission_mcc m002 ON
					m002.Org_Id = t006.Org_Id
					AND m002.MCC_Id = t006.MCC_Id
					and m002.MPPIType_Id = 'C047001'
					AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021 WHERE m0021.Org_Id = var_Org_Id
										and m0021.MPPIType_Id = 'C047001'
										and m0021.MCC_Id = t006.MCC_Id
										AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
										order by m0021.Applicable_Date desc limit 1)
				INNER JOIN m002_commission_item m0022 ON
					m0022.Org_Id = t006.Org_Id
					AND m0022.MPPI_Id = (SELECT m0021.MPPI_Id FROM m002_commission_mcc m0021 WHERE m0021.Org_Id = var_Org_Id
										and m0021.MPPIType_Id = 'C047001'
										and m0021.MCC_Id = t006.MCC_Id
										AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
										order by m0021.Applicable_Date desc limit 1)
				INNER JOIN c047_mppitype c047 ON
					c047.MPPIType_Id = m002.MPPIType_Id
				where
					t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t009.Org_Id = var_Org_Id
				GROUP BY
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
				c047.MPPIType_Id,
				c047.MPPIType_Name,
				t0061.Quantity_Ltr ,
				t0061.FAT,
				t0061.SNF,   
				m0022.MinimumQuantity,
				m0022.MaximumQuantity,
				m0022.MinimumFat,
				m0022.MaximumFat,
				m0022.MinimumSNF,
				m0022.MaximumSNF,
				m0022.BaseRate
				
                /*
				UNION ALL

				select 
					m005.MCC_Id,
					m005.MCC_Name,
					m005.MCC_Code,
					c011.Milktype_Id,
					c011.MilkType_Name,
					c016.MilkStatus_Id,
					c016.MilkStatus_Name,
					c047.MPPIType_Id,
					c047.MPPIType_Name,
					t0061.Quantity_Ltr as Liters,
					CAST(ifnull((t0061.Quantity_Ltr / @kg_to_ltr),0) AS DECIMAL(8, 3)) as Weight,
					t0061.FAT,
					t0061.SNF,   
					-- m0022.BaseRate as Rate,
                    ROUND(
						CASE
							WHEN IFNULL(SUM(t0061.Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(t0061.Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND t0061.FAT >= m0022.MinimumFat
							AND t0061.FAT <= m0022.MaximumFat
							AND t0061.SNF >= m0022.MinimumSNF 
							AND t0061.SNF <= m0022.MaximumSNF
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
                        2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(t0061.Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(t0061.Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND t0061.FAT >= m0022.MinimumFat
							AND t0061.FAT <= m0022.MaximumFat
							AND t0061.SNF >= m0022.MinimumSNF 
							AND t0061.SNF <= m0022.MaximumSNF
						THEN
							(m0022.BaseRate * IFNULL(SUM(t0061.Quantity_Ltr), 0)) 
						ELSE
							0
						END,
                        2
					) as Amount
				from t009_milkcollectiondairy_header t009
				INNER JOIN t022_tripdocument_item t022 ON
					t022.Org_Id = t009.Org_Id
					AND t022.TripDocument_Id = t009.TripDocument_Id
				INNER JOIN t006_milkcollectionagent t006 ON
					t022.Org_Id = t006.Org_Id
					AND t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
					AND t022.MCC_Id = t006.MCC_Id
				INNER JOIN t006_milkcollectionagent_item t0061 ON
					t0061.Org_Id = t006.Org_Id
					AND t0061.AgentCollection_Id = t006.AgentCollection_Id
				INNER JOIN m005_mcc m005 ON
					m005.Org_Id = t006.Org_Id
					AND m005.MCC_Id = t006.MCC_Id
				INNER JOIN c011_milktype c011 ON
					c011.MilkType_Id = t0061.MilkType_Id
				INNER JOIN c016_milkstatus c016 ON
					c016.MilkStatus_Id = t0061.MilkStatus_Id
				INNER JOIN m002_commission_mcc m002 ON
					m002.Org_Id = t006.Org_Id
					AND m002.MCC_Id = t006.MCC_Id
					and m002.MPPIType_Id = 'C047002'
					AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021 WHERE m0021.Org_Id = var_Org_Id
										and m0021.MPPIType_Id = 'C047002'
										and m0021.MCC_Id = t006.MCC_Id
										AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
										order by m0021.Applicable_Date desc limit 1)
				INNER JOIN m002_commission_item m0022 ON
					m0022.Org_Id = t006.Org_Id
					AND m0022.MPPI_Id = (SELECT m0021.MPPI_Id FROM m002_commission_mcc m0021 WHERE m0021.Org_Id = var_Org_Id
										and m0021.MPPIType_Id = 'C047002'
										and m0021.MCC_Id = t006.MCC_Id
										AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
										order by m0021.Applicable_Date desc limit 1)
				INNER JOIN c047_mppitype c047 ON
					c047.MPPIType_Id = m002.MPPIType_Id
				where
					t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t009.Org_Id = var_Org_Id
				GROUP BY
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
				c047.MPPIType_Id,
				c047.MPPIType_Name,
				t0061.Quantity_Ltr ,
				t0061.FAT,
				t0061.SNF,   
				m0022.MinimumQuantity,
				m0022.MaximumQuantity,
				m0022.MinimumFat,
				m0022.MaximumFat,
				m0022.MinimumSNF,
				m0022.MaximumSNF,
				m0022.BaseRate 
				*/
				UNION ALL
				/*
				select 
					m005.MCC_Id,
					m005.MCC_Name,
					m005.MCC_Code,
					c011.Milktype_Id,
					c011.MilkType_Name,
					c016.MilkStatus_Id,
					c016.MilkStatus_Name,
					c047.MPPIType_Id,
					c047.MPPIType_Name,
					t0061.Quantity_Ltr as Liters,
					CAST(ifnull((t0061.Quantity_Ltr / @kg_to_ltr),0) AS DECIMAL(8, 3)) as Weight,
					t0061.FAT,
					t0061.SNF,   
					'0' as Rate,
					'100' as Amount
				from t009_milkcollectiondairy_header t009
				INNER JOIN t022_tripdocument_item t022 ON
					t022.Org_Id = t009.Org_Id
					AND t022.TripDocument_Id = t009.TripDocument_Id
				INNER JOIN t006_milkcollectionagent t006 ON
					t022.Org_Id = t006.Org_Id
					AND t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
					AND t022.MCC_Id = t006.MCC_Id
				INNER JOIN t006_milkcollectionagent_item t0061 ON
					t0061.Org_Id = t006.Org_Id
					AND t0061.AgentCollection_Id = t006.AgentCollection_Id
				INNER JOIN m005_mcc m005 ON
					m005.Org_Id = t006.Org_Id
					AND m005.MCC_Id = t006.MCC_Id
				INNER JOIN c011_milktype c011 ON
					c011.MilkType_Id = t0061.MilkType_Id
				INNER JOIN c016_milkstatus c016 ON
					c016.MilkStatus_Id = t0061.MilkStatus_Id
				INNER JOIN c047_mppitype c047 ON
					c047.MPPIType_Id = 'C047003'
				where
					t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t009.Org_Id = var_Org_Id
				GROUP BY
				m005.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
				c047.MPPIType_Id,
				c047.MPPIType_Name,
				t0061.Quantity_Ltr ,
				t0061.FAT,
				t0061.SNF
                */
                
                select 
				t0081.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				c011.Milktype_Id,
				c011.MilkType_Name,
				'C016001' as MilkStatus_Id,
				'' as MilkStatus_Name,
				c047.MPPIType_Id,
				c047.MPPIType_Name,
				'0' as Liters,
				'0' as Weight,
				'0' as FAT,
				'0' as SNF,   
				'0' as Rate,
				t0081.Total_GainLoss as Amount
				from t009_milkcollectiondairy_header t009
				inner join t022_tripdocument_item t022 on t009.Org_Id = t022.Org_Id 
					and t009.TripDocument_Id = t022.TripDocument_Id
				inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
					and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
				inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
					and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
				INNER JOIN m005_mcc m005 ON
						m005.Org_Id = t0081.Org_Id
						AND m005.MCC_Id = t022.MCC_Id
				INNER JOIN c047_mppitype c047 ON
						c047.MPPIType_Id = 'C047003'
				INNER JOIN c011_milktype c011 ON
						c011.MilkType_Id = t0081.MilkType_Id
				where t009.Org_Id = var_Org_Id
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				group by 
				t0081.MCC_Id,
				m005.MCC_Name,
				m005.MCC_Code,
				t0081.Total_GainLoss,
				c011.Milktype_Id,
				c011.MilkType_Name,
				c047.MPPIType_Id,
				c047.MPPIType_Name


                )AS CombinedResult
                WHERE CombinedResult.Amount <> 0
				ORDER BY 
					CombinedResult.MCC_Name;
			end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
