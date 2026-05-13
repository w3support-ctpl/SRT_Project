-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRoute_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRoute_Set`(
    var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Route_Id varchar(20),
    var_Route_Name varchar(45),
    var_Route_Code varchar(45),
    var_CollectionShift_Id varchar(20),
    var_VehicleType_Id VARCHAR(20),
    var_Freight_Fix_Cost VARCHAR(20),
    var_Frequency text,
    var_Duration VARCHAR(20),
    var_Total_Distance VARCHAR(20),
    var_Fuel_Required VARCHAR(20),
    var_Start_Time time,
    var_End_Time time,
    var_Start_Date Date,
    var_End_Date Date,
    var_User_Id varchar(20),
    var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Is_Lived int
)
BEGIN

	Declare var_Monday_Flag int default 0;
	Declare var_Tuesday_Flag int default 0;
	Declare var_Wednesday_Flag int default 0;
	Declare var_Thursday_Flag int default 0;
	Declare var_Friday_Flag int default 0;
	Declare var_Saturday_Flag int default 0;
	Declare var_Sunday_Flag int default 0;
	-- Declare i int default 1;
	-- Declare freq_length int;
	-- Declare freq_value int;
    
        -- Set the weekday flags based on the comma-separated frequency values
	if(var_Frequency = 'C031000')then
		 SET var_Monday_Flag = 1; 
		 SET var_Tuesday_Flag = 1; 
		 SET var_Wednesday_Flag = 1; 
		 SET var_Thursday_Flag = 1; 
		 SET var_Friday_Flag = 1; 
		 SET var_Saturday_Flag = 1; 
		 SET var_Sunday_Flag = 1; 
    else
		IF FIND_IN_SET('C031001', var_Frequency) THEN SET var_Monday_Flag = 1; END IF;
		IF FIND_IN_SET('C031002', var_Frequency) THEN SET var_Tuesday_Flag = 1; END IF;
		IF FIND_IN_SET('C031003', var_Frequency) THEN SET var_Wednesday_Flag = 1; END IF;
		IF FIND_IN_SET('C031004', var_Frequency) THEN SET var_Thursday_Flag = 1; END IF;
		IF FIND_IN_SET('C031005', var_Frequency) THEN SET var_Friday_Flag = 1; END IF;
		IF FIND_IN_SET('C031006', var_Frequency) THEN SET var_Saturday_Flag = 1; END IF;
		IF FIND_IN_SET('C031007', var_Frequency) THEN SET var_Sunday_Flag = 1; END IF;
    end if;
    if (var_Method_Name = 'Create') then
        begin
            Declare Duplicate_Flag int;
            Declare New_Route_Id varchar(20);
            Declare Year_Id varchar(10);
            if exists(select Route_Id from m006_route where Org_Id = var_Org_Id and Route_Code = var_Route_Code and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Route Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Route_Id from m006_route where Org_Id = var_Org_Id and Route_Name = var_Route_Name and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Route Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
                set Year_Id = (select right(left(curdate(),4),(2)));
                Call USP_Number_Range ('m006_route', Year_Id, 'M006', '', New_Route_Id );

                Insert Into m006_route
                    (Org_Id, Route_Id, Route_Code, Route_Name, CollectionShift_Id, VehicleType_Id,
                    Freight_Fix_Cost, Monday_Flag, Tuesday_Flag, Wednesday_Flag, Thursday_Flag, Friday_Flag, Saturday_Flag, Sunday_Flag,
                    Duration, Fuel_Required,Start_Time,End_Time,Start_Date,End_Date, Is_Active, Is_Deleted,Is_Lived, Created_On, CreatedBy_Id, CreatedBy_Name,
                    Total_Distance)
                Values (var_Org_Id, New_Route_Id, var_Route_Code, var_Route_Name, var_CollectionShift_Id, var_VehicleType_Id,
                    var_Freight_Fix_Cost, var_Monday_Flag, var_Tuesday_Flag, var_Wednesday_Flag, var_Thursday_Flag, var_Friday_Flag, var_Saturday_Flag, var_Sunday_Flag,
                    var_Duration, var_Fuel_Required,var_Start_Time,var_End_Time,var_Start_Date,var_End_Date, var_Is_Active, var_Is_Deleted,var_Is_Lived, Now(), var_User_Id, var_User_Name,
                    var_Total_Distance); 

                SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Route_Id AS Result_Extra_Key;
            end if;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			DECLARE Latest_Applicable_Date datetime;
            
            SELECT To_Date INTO Latest_Applicable_Date
			FROM m008_route_vehicle 
			where Route_Id = var_Route_Id
			and Is_Active = 1
			ORDER BY To_Date DESC LIMIT 1;
            
			if exists(select Route_Id from m006_route where Org_Id = var_Org_Id and  Route_Code = var_Route_Code and Is_Deleted = 0 and Route_Id <> var_Route_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Route Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			/*elseif(Latest_Applicable_Date >= var_End_Date) then
				SELECT -1 AS Result_Id, 
                CONCAT('Route End date greater than this date ', DATE_FORMAT(Latest_Applicable_Date, '%d %M %Y')) AS Result_Description,
                '' AS Result_Extra_Key;*/
			else
				Update m006_route
                set 
                Route_Name = var_Route_Name,
                Route_Code = var_Route_Code,
                CollectionShift_Id = var_CollectionShift_Id,
                VehicleType_Id = var_VehicleType_Id,
                Freight_Fix_Cost = var_Freight_Fix_Cost,
                Duration = var_Duration,
                Fuel_Required = var_Fuel_Required,
                Monday_Flag = var_Monday_Flag,
                Tuesday_Flag = var_Tuesday_Flag,
                Wednesday_Flag = var_Wednesday_Flag,
                Thursday_Flag = var_Thursday_Flag,
                Friday_Flag = var_Friday_Flag,
                Saturday_Flag = var_Saturday_Flag,
                Sunday_Flag = var_Sunday_Flag,
                Start_Date = var_Start_Date,
				End_Date = var_End_Date,
                Start_Time = var_Start_Time,
				End_Time = var_End_Time,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                Is_Lived = var_Is_Lived,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id ,
                LastEditedBy_Name = var_User_Name ,
                Total_Distance = var_Total_Distance
                where Org_Id = var_Org_Id and Route_Id = var_Route_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Route_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m006_route
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id ,
			LastEditedBy_Name = var_User_Name 
			where Org_Id = var_Org_Id and Route_Id = var_Route_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Route_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Copy') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Route_Id varchar(20);
            Declare New_Route_Code varchar(45);
            Declare New_Route_Name varchar(45);
            Declare Year_Id varchar(10);
            DECLARE Existing_Version_No int;
            DECLARE Existing_Route_Id  varchar(20);
            Declare Existing_Route_Code varchar(45);
            Declare Existing_Route_Name varchar(45);
            DECLARE Set_Route_Id  varchar(20);

            set Year_Id = (select right(left(curdate(),4),(2)));
            Call USP_Number_Range ('m006_route', Year_Id, 'M006', '', New_Route_Id );
                

            select Version_No INTO Existing_Version_No
            from m006_route
            where Route_Id = var_Route_Id AND Is_Deleted = 0;
            
            if(Existing_Version_No = 1)then
                
                select Check_Route_Id INTO Existing_Route_Id
				from m006_route
				where Route_Id = var_Route_Id;

                select coalesce(MAX(Version_Check), 0) + 1 INTO Existing_Version_No
				from m006_route
				where Route_Id = Existing_Route_Id;

                select  Route_Code, Route_Name
                INTO  Existing_Route_Code, Existing_Route_Name
                from m006_route
                where Org_Id = var_Org_Id AND Route_Id = Existing_Route_Id AND Is_Deleted = 0;
                
                select CONCAT_WS(' ', Existing_Route_Code, 'V', Existing_Version_No) into New_Route_Code;
				select CONCAT_WS(' ', Existing_Route_Name, 'V', Existing_Version_No) into New_Route_Name;
                
                set Set_Route_Id = Existing_Route_Id;
            else
				select coalesce(MAX(Version_Check), 0) + 1 INTO Existing_Version_No
				from m006_route
				where Route_Id = var_Route_Id;
                
				select CONCAT_WS(' ', var_Route_Code, 'V', Existing_Version_No) into New_Route_Code;
				select CONCAT_WS(' ', var_Route_Name, 'V', Existing_Version_No) into New_Route_Name;
                
                set Set_Route_Id = var_Route_Id;
            end if;   
            
                Insert Into m006_route
                    (Org_Id, Route_Id, Route_Code, Route_Name, CollectionShift_Id, VehicleType_Id,
                    Freight_Fix_Cost, Monday_Flag, Tuesday_Flag, Wednesday_Flag, Thursday_Flag, Friday_Flag, Saturday_Flag, Sunday_Flag,
                    Duration, Fuel_Required,Start_Time,End_Time,Start_Date,End_Date,Version_No, Is_Active, Is_Deleted,Is_Lived, Created_On, CreatedBy_Id, CreatedBy_Name,Total_Distance)
                Values (var_Org_Id, New_Route_Id, New_Route_Code, New_Route_Name, var_CollectionShift_Id, var_VehicleType_Id,
                    var_Freight_Fix_Cost, var_Monday_Flag, var_Tuesday_Flag, var_Wednesday_Flag, var_Thursday_Flag, var_Friday_Flag, var_Saturday_Flag, var_Sunday_Flag,
                    var_Duration, var_Fuel_Required,var_Start_Time,var_End_Time,var_Start_Date,var_End_Date,1, 1, 0,0, Now(), var_User_Id, var_User_Name,var_Total_Distance);
                    
				INSERT INTO m007_route_item (Org_Id, Route_Id, Stage_No, MCC_Id, Distance, Arrival_Time, Departure_Time)
				SELECT var_Org_Id, New_Route_Id, Stage_No, MCC_Id, Distance, Arrival_Time, Departure_Time
				FROM m007_route_item
				WHERE Route_Id = var_Route_Id;
                
                Update m006_route
				set 
				Version_Check = Existing_Version_No
				where Org_Id = var_Org_Id and Route_Id = Set_Route_Id; 
                
                Update m006_route
				set 
				Check_Route_Id = Set_Route_Id
				where Org_Id = var_Org_Id and Route_Id = New_Route_Id;
                
                SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Route_Id AS Result_Extra_Key;
            
				

        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
