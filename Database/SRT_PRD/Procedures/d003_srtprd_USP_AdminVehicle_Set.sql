-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminVehicle_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminVehicle_Set`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(10),
	var_Vehicle_Id varchar(45),
	var_Vehicle_No varchar(45),
	var_Chassis_No varchar(45),
	var_VehicleType_Id varchar(45),
	var_VehicleOwnershipType_Id varchar(45),
	var_Transporter_Id varchar(20),
	var_Owner_Name varchar(20),
	var_VehicleMake_Id varchar(20),
    var_VehicleAverage varchar(45),
	var_Labour_Charge varchar(20),
	var_Capacity_In_KG varchar(20),
	var_No_Of_Cells_In_Tanker varchar(20),
    var_FSSAILicense_No varchar(45),
	var_FSSAILicenseValidity_On datetime,
	var_User_Id varchar(20),
	var_User_Name varchar(20),
	var_Is_Active int,
	var_Is_Deleted int,
  var_XMLData longtext
    
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Vehicle_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id  
            and Vehicle_No = var_Vehicle_No  and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Vehicle Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m003_vehicle', Year_Id, 'M003', '', New_Vehicle_Id );
            
				Insert Into m003_vehicle
                (Org_Id,Vehicle_Id, Vehicle_No, Chassis_No, VehicleType_Id,
                VehicleOwnershipType_Id,Transporter_Id,OwnerName,VehicleMake_Id,VehicleAverage,LabourCharge,CapacityInKG,FSSAILicense_No,FSSAILicenseValidity_On,
                NoOfCellsInTanker,Is_Active, Is_Deleted,Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Vehicle_Id, var_Vehicle_No,var_Chassis_No,var_VehicleType_Id,
                var_VehicleOwnershipType_Id,var_Transporter_Id,var_Owner_Name,var_VehicleMake_Id,var_VehicleAverage,var_Labour_Charge,var_Capacity_In_KG,var_FSSAILicense_No,var_FSSAILicenseValidity_On,
                var_No_Of_Cells_In_Tanker,var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name);    
                
                
      
			SET @row_count := extractValue(var_XMLData,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
				INSERT INTO m003_vehiclecapacity (Org_Id,Vehicle_id, Cell_No,Capacity_Ltr) VALUES (
					var_Org_Id,
					New_Vehicle_Id,
					extractValue(var_XMLData, concat(@xpath,'/Cell')),
                    extractValue(var_XMLData, concat(@xpath,'/Capacity'))
				);
			END WHILE;
   
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Vehicle_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id 
            and Vehicle_No = var_Vehicle_No  and Is_Deleted = 0  
            and Vehicle_Id <> var_Vehicle_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Vehicle Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m003_vehicle
                set 
                Vehicle_No = var_Vehicle_No,
                Chassis_No = var_Chassis_No,
                VehicleType_Id = var_VehicleType_Id,
                VehicleOwnershipType_Id = var_VehicleOwnershipType_Id,
                Transporter_Id = var_Transporter_Id,
                OwnerName = var_Owner_Name,
                VehicleMake_Id = var_VehicleMake_Id,
                VehicleAverage = var_VehicleAverage,
                LabourCharge = var_Labour_Charge,
                CapacityInKG = var_Capacity_In_KG,
                NoOfCellsInTanker = var_No_Of_Cells_In_Tanker,
                FSSAILicense_No = var_FSSAILicense_No,
                FSSAILicenseValidity_On = var_FSSAILicenseValidity_On,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id;  
                
                
			
                delete from m003_vehiclecapacity where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id;  
                
                
			SET @row_count := extractValue(var_XMLData,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
				INSERT INTO m003_vehiclecapacity (Org_Id,Vehicle_id, Cell_No,Capacity_Ltr) VALUES (
					var_Org_Id,
					var_Vehicle_Id,
					extractValue(var_XMLData, concat(@xpath,'/Cell')),
                    extractValue(var_XMLData, concat(@xpath,'/Capacity'))
				);
			END WHILE;
       
                
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Vehicle_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m003_vehicle
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Vehicle_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
