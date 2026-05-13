-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminVehicle_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminVehicle_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_User_Id varchar(20),
    var_VehicleOwnershipType_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_Vehicle_No varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m003.Org_Id, 
            c020.VehicleType_Id, c020.VehicleType_Name, 
            c021.VehicleOwnershipType_Id,c021.VehicleOwnershipType_Name, 
            c032.VehicleMake_Id,ifnull(c032.VehicleMake_Name,'') as VehicleMake_Name,
            Vehicle_Id, Vehicle_No,VehicleAverage,
            m003.Is_Active, m003.Is_Deleted 
            from m003_vehicle m003
            inner join c020_vehicletype c020 on c020.VehicleType_Id = m003.VehicleType_Id
            inner join c021_vehicleownershiptype c021 on c021.VehicleOwnershipType_Id = m003.VehicleOwnershipType_Id
            left join c032_vehiclemake c032 on c032.VehicleMake_Id = m003.VehicleMake_Id
            where m003.Org_Id = var_Org_Id 
            and m003.Is_Deleted = 0 
            and m003.VehicleOwnershipType_Id like var_VehicleOwnershipType_Id 
            and Vehicle_No like  var_Vehicle_No
            order by Vehicle_No;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
        
            SELECT 
			m003.Org_Id, m003.Vehicle_Id, m003.Vehicle_No, m003.Chassis_No, m003.VehicleType_Id, m003.VehicleOwnershipType_Id,
            m003.Transporter_Id, m003.OwnerName, ifnull(m003.VehicleMake_Id,'') as VehicleMake_Id,m003.VehicleAverage, m003.LabourCharge,
            m003.CapacityInKG, m003.NoOfCellsInTanker, m003.Is_Active, m003.Is_Deleted,
            FSSAILicense_No,
            date_format(FSSAILicenseValidity_On, '%Y-%m-%d') as FSSAILicenseValidity_On,
				CASE
					WHEN m008.Vehicle_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m003_vehicle m003
			LEFT JOIN (
				SELECT DISTINCT Vehicle_Id
				FROM m008_route_vehicle
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m008 ON m008.Vehicle_Id = m003.Vehicle_Id
			WHERE m003.Org_Id = var_Org_Id 
				AND m003.Vehicle_Id = var_Vehicle_Id
				AND m003.Is_Deleted = 0;
		end;
        
        
    elseif (var_Method_Name = 'GetCells') then
    
		SELECT Cell_No AS CellNo,
        Capacity_Ltr AS Capacity
        FROM  m003_vehiclecapacity  WHERE 
        Vehicle_id = var_Vehicle_Id AND Org_Id =  var_Org_Id;
        
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
