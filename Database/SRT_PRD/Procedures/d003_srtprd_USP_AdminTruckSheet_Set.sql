-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTruckSheet_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTruckSheet_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Route_Id varchar(20),
	var_Entry_Id varchar(20),
	var_Vehicle_Id varchar(20),
    var_VehicleType varchar(20),
	var_Driver_Id varchar(20),
	var_Chemist_Id varchar(20),
    var_From_Date DATETIME,
	var_To_Date DATETIME,
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	SET sql_mode='PIPES_AS_CONCAT';
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Entry_Id varchar(20);
            Declare Set_Route_Name varchar(20);
            Declare Set_Start_Date date;
            Declare Set_End_Date date;
			Declare Year_Id varchar(10);
            DECLARE Check_Start_Date date;
            DECLARE Check_End_Date date;
            declare var_Role_Id varchar(20);
            
            Declare Today_Date datetime;
            SET sql_mode='PIPES_AS_CONCAT';
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set var_Role_Id = ( select Role_Id from mu03_user where User_Id = var_User_Id
									and Org_Id = var_Org_Id limit 1);
            
            
            
            SELECT DATE_SUB(Start_Date, INTERVAL 1 DAY),DATE_ADD(End_Date, INTERVAL 1 DAY)
            INTO Check_Start_Date,Check_End_Date
			FROM m006_route
			WHERE Org_Id = var_Org_Id
			AND Route_Id = var_Route_Id
			AND Is_Deleted = 0;
            
           
            
            SELECT date(To_Date) into @Check_Sheet_End_Date FROM m008_route_vehicle 
			WHERE Org_Id = var_Org_Id
			AND Route_Id = var_Route_Id
			and Is_Active = 1 
			and Is_Deleted = 0
			order by To_Date  DESC limit 1;
            
            set @CollectionShift_Id = (SELECT CollectionShift_Id FROM m006_route 
            where Org_Id = var_Org_Id and Route_Id = var_Route_Id);

            
             if(@Check_Sheet_End_Date = '' or  @Check_Sheet_End_Date IS NULL )then
				set @Check_Sheet_End_Date = ( select CURDATE() - INTERVAL 1 DAY);
             end if;
             
            if (Date(var_From_Date) < date(Today_Date) and var_Role_Id <> 'MU001') then
                SELECT -1 AS Result_Id, 
                'Start Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
			
            /*
            elseif (Check_Start_Date <= var_From_Date  and Check_End_Date <= var_To_Date) then
				SELECT -1 AS Result_Id, 
                -- 'Make sure the Start Date and End Date are within the Route Start Date and End Date.' 
                'Make sure the Start Date (' || DATE_FORMAT(Check_Start_Date, '%d %M %Y') || ') and End Date (' || DATE_FORMAT(Check_End_Date, '%d %M %Y') || ') are within the Route' AS Result_Description, 
                '' AS Result_Extra_Key;
			*/
            
          
            elseif exists(SELECT Entry_Id FROM m008_route_vehicle m008 
							inner join m006_route m006 on m006.Org_Id = m008.Org_Id 
                            and m006.Route_Id = m008.Route_Id
                            and m006.CollectionShift_Id = @CollectionShift_Id
							WHERE m008.Org_Id = var_Org_Id
							AND m008.Route_Id = var_Route_Id
							AND m008.Vehicle_Id = var_Vehicle_Id AND m008.Is_Active = 1 AND m008.Is_Deleted = 0
							AND date(var_From_Date) BETWEEN DATE(m008.From_Date) AND DATE(m008.To_Date) ORDER BY m008.From_Date DESC, m008.To_Date DESC limit 1) then
				
                
							SELECT m006.Route_Name,date(m008.From_Date),date(m008.To_Date) 
							into Set_Route_Name,  Set_Start_Date, Set_End_Date
							FROM m008_route_vehicle  m008
							inner join m006_route m006 on m006.Org_Id = m008.Org_Id 
                            and m006.Route_Id = m008.Route_Id 
                            and m006.CollectionShift_Id = @CollectionShift_Id
							WHERE m008.Org_Id = var_Org_Id
                            AND m008.Route_Id = var_Route_Id
							AND m008.Vehicle_Id = var_Vehicle_Id AND m008.Is_Active = 1 AND m008.Is_Deleted = 0
							AND date(var_From_Date) BETWEEN DATE(m008.From_Date) AND DATE(m008.To_Date) ORDER BY m008.From_Date DESC, m008.To_Date DESC limit 1;
							
							SELECT -1 AS Result_Id, 
							concat('This Vehicle is assigned to this ' , Set_Route_Name , ' route  from (' , DATE_FORMAT(Set_Start_Date, '%d %M %Y') , ') to (' , DATE_FORMAT(Set_End_Date, '%d %M %Y') , ')') AS Result_Description, 
							'' AS Result_Extra_Key;
          
			elseif (Check_Start_Date > var_From_Date  or Check_End_Date < var_To_Date and var_Role_Id <> 'MU001') then
				SELECT -1 AS Result_Id, 
                -- 'Make sure the Start Date and End Date are within the Route Start Date and End Date.' 
                concat( 'Make sure the Start Date (', DATE_FORMAT(DATE_ADD(Check_Start_Date, INTERVAL 1 DAY), '%d %M %Y') , ') and End Date (' , DATE_FORMAT(DATE_SUB(Check_End_Date, INTERVAL 1 DAY), '%d %M %Y') ,') are within the Route') AS Result_Description, 
                '' AS Result_Extra_Key;
               
			elseif (DATE(var_To_Date) <= DATE(@Check_Sheet_End_Date)  and var_Role_Id <> 'MU001') then
				SELECT -1 AS Result_Id, 
                concat('The end date is greater than this (' , DATE_FORMAT(@Check_Sheet_End_Date, '%d %M %Y') , ') date.') AS Result_Description, 
                '' AS Result_Extra_Key;
				
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m008_route_vehicle', Year_Id, 'M008', '', New_Entry_Id );
            
				Insert Into m008_route_vehicle
                (Org_Id, Route_Id,Entry_Id,Vehicle_Id,VehicleType,Driver_Id,Chemist_Id,From_Date,To_Date,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, var_Route_Id,New_Entry_Id,var_Vehicle_Id,var_VehicleType,var_Driver_Id,var_Chemist_Id,var_From_Date,var_To_Date,
                var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Entry_Id AS Result_Extra_Key;
                
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			DECLARE Check_Start_Date date;
            DECLARE Check_End_Date date;
            Declare Today_Date datetime;
            DECLARE Check_Sheet_End_Date_One date;
            DECLARE Check_Sheet_End_Date_Two date;
            declare var_Role_Id varchar(20);
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set var_Role_Id = ( select Role_Id from mu03_user where User_Id = var_User_Id
									and Org_Id = var_Org_Id limit 1);
            
            SELECT Start_Date,End_Date INTO Check_Start_Date,Check_End_Date
			FROM m006_route
			WHERE Org_Id = var_Org_Id
			AND Route_Id = var_Route_Id
			AND Is_Deleted = 0;
            
            SELECT To_Date into Check_Sheet_End_Date_One FROM m008_route_vehicle 
			WHERE Org_Id = var_Org_Id
			AND Route_Id = var_Route_Id
			and Is_Active = 1 
			and Is_Deleted = 0
			order by To_Date  DESC limit 1;
            
            SELECT To_Date into Check_Sheet_End_Date_Two FROM m008_route_vehicle 
			WHERE Org_Id = var_Org_Id
			AND Route_Id = var_Route_Id
            AND Entry_Id = var_Entry_Id
			and Is_Active = 1 
			and Is_Deleted = 0;
            
            if (Date(var_From_Date) < date(Today_Date) and var_Role_Id <> 'MU001') then
                SELECT -1 AS Result_Id, 
                'Start Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif (Check_Start_Date <= var_From_Date  and Check_End_Date <= var_To_Date and var_Role_Id <> 'MU001') then
				SELECT -1 AS Result_Id, 
                'Make sure the Start Date (' || DATE_FORMAT(Check_Start_Date, '%d %M %Y') || ') and End Date (' || DATE_FORMAT(Check_End_Date, '%d %M %Y') || ') are within the Route' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (DATE(var_To_Date) <= DATE(Check_Sheet_End_Date_One) and DATE(var_To_Date) != DATE(Check_Sheet_End_Date_Two) and var_Role_Id <> 'MU001') then
				SELECT -1 AS Result_Id, 
                'The end date is greater than this (' || DATE_FORMAT(Check_Sheet_End_Date_One, '%d %M %Y') || ') date.' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				Update m008_route_vehicle
				set 
				Route_Id = var_Route_Id,
				Vehicle_Id = var_Vehicle_Id,
				VehicleType = var_VehicleType,
				Driver_Id = var_Driver_Id,
				Chemist_Id = var_Chemist_Id,
				From_Date = var_From_Date,
				To_Date = var_To_Date,
				Is_Active = var_Is_Active,
				Is_Deleted = var_Is_Deleted,
				LastEdited_On = NOW(),
				LastEditedBy_Id = var_User_Id,
				LastEditedBy_Name = var_User_Name 
				where Org_Id = var_Org_Id 
				and Entry_Id = var_Entry_Id;   

				SELECT 1 AS Result_Id, 
				'Updated' AS Result_Description, 
				var_Entry_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
         if exists(select TripDocument_Id from t021_tripdocument_header where Org_Id =var_Org_Id and Route_Trip_Id = var_Entry_Id) then
				SELECT -1 AS Result_Id, 
                'This entry cannot be deleted as it is already in use' AS Result_Description, 
                '' AS Result_Extra_Key;
		else
			Update m008_route_vehicle
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and Entry_Id = var_Entry_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
		end if;
        end;
	elseif (var_Method_Name = 'UpdateAll') then
		begin
			
				Update m008_route_vehicle
				set 
				Route_Id = var_Route_Id,
				Vehicle_Id = var_Vehicle_Id,
				VehicleType = var_VehicleType,
				Driver_Id = var_Driver_Id,
				Chemist_Id = var_Chemist_Id,
				From_Date = var_From_Date,
				To_Date = var_To_Date,
				Is_Active = var_Is_Active,
				Is_Deleted = var_Is_Deleted,
				LastEdited_On = NOW(),
				LastEditedBy_Id = var_User_Id,
				LastEditedBy_Name = var_User_Name 
				where Org_Id = var_Org_Id 
				and Entry_Id = var_Entry_Id;  
                
                call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				'm008_route_vehicle', var_Entry_Id, '', '', 
				var_User_Id, var_User_Name);
                
				set @var_TripDocument_Id = (select TripDocument_Id from t021_tripdocument_header 
											where Org_Id = var_Org_Id
											and Route_Trip_Id = var_Entry_Id);
				
                if(@var_TripDocument_Id is not null or @var_TripDocument_Id <> '')then
                
                
					set @var_Transporter_Id = (select Transporter_Id from m003_vehicle
												where Org_Id = var_Org_Id 
												and Vehicle_Id = var_Vehicle_Id);
                
					Update t021_tripdocument_header
					set 
					Vehicle_Id = var_Vehicle_Id,
					Driver_Id = var_Driver_Id,
                    Transporter_Id = @var_Transporter_Id
					where Org_Id = var_Org_Id 
					and Route_Trip_Id = var_Entry_Id
					and TripDocument_Id = @var_TripDocument_Id;
                    
                   set @var_Trip_Id_1 = (select Trip_Id from t007_milkcollectiondriver
										where Org_Id = var_Org_Id 
										and Trip_Id = @var_TripDocument_Id
										limit 1);
					
					if(@var_Trip_Id_1 is not null or @var_Trip_Id_1 <> '')then
                    
						Update t007_milkcollectiondriver 
						set 
						Vehicle_Id = var_Vehicle_Id,
						Driver_Id = var_Driver_Id
						where Org_Id = var_Org_Id 
						and Trip_Id = @var_Trip_Id_1;
							
                    end if;
                    
                    set @var_Trip_Id_2 = (select Trip_Id from t008_milkcollectionchemist
										where Org_Id = var_Org_Id 
										and Trip_Id = @var_TripDocument_Id
										limit 1);
					
					if(@var_Trip_Id_2 is not null or @var_Trip_Id_2 <> '')then
                    
						Update t008_milkcollectionchemist 
						set 
						Chemist_Id = var_Chemist_Id,
						Driver_Id = var_Driver_Id
						where Org_Id = var_Org_Id 
						and Trip_Id = @var_Trip_Id_2;
							
                    end if;
                    
                    
                    set @var_Trip_Id_3 = (select TripDocument_Id from t009_milkcollectiondairy_header
										where Org_Id = var_Org_Id 
										and TripDocument_Id = @var_TripDocument_Id
										limit 1);
					
					if(@var_Trip_Id_3 is not null or @var_Trip_Id_3 <> '')then
                    
						Update t009_milkcollectiondairy_header 
						set 
						Vehicle_Id = var_Vehicle_Id,
						Driver_Id = var_Driver_Id
						where Org_Id = var_Org_Id 
						and TripDocument_Id = @var_Trip_Id_3;
							
                    end if;
                    
                end if;

				SELECT 1 AS Result_Id, 
				'Updated' AS Result_Description, 
				var_Entry_Id AS Result_Extra_Key;
			
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
