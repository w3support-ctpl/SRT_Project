-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRouteItem_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRouteItem_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Route_Id varchar(20),
	var_Stage_No int,
	var_MCC_Id varchar(20),
    var_Distance varchar(20),
	var_Arrival_Time time,
    var_Departure_Time time
)
BEGIN

	DECLARE existing_stage_no int;
	if (var_Method_Name = 'Create') then
		BEGIN
			Declare Duplicate_Flag int;
            Declare New_Route_Id varchar(20);
            Declare Year_Id varchar(10);
            if exists(select MCC_Id from m007_route_item where Org_Id = var_Org_Id and Route_Id = var_Route_Id 
            and MCC_Id = var_MCC_Id) then
                SELECT -1 AS Result_Id, 
                'MCC Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
            select coalesce(MAX(Stage_No), 0) + 1 INTO existing_stage_no
            from m007_route_item
            where Route_Id = var_Route_Id;
            
            insert into m007_route_item (Org_Id, Route_Id, Stage_No, MCC_Id, Distance, Arrival_Time, Departure_Time)
            values (var_Org_Id, var_Route_Id, existing_stage_no, var_MCC_Id, var_Distance, var_Arrival_Time, var_Departure_Time);
            
            SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                existing_stage_no AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        if exists(select MCC_Id from m007_route_item where Org_Id = var_Org_Id and Route_Id = var_Route_Id 
            and MCC_Id = var_MCC_Id and Stage_No = var_Stage_No and Route_Id <> var_Route_Id
            ) then
				SELECT -1 AS Result_Id, 
                'MCC already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
			Update m007_route_item
                set 
                MCC_Id = var_MCC_Id,
                Distance = var_Distance,
                Arrival_Time = var_Arrival_Time,
                Departure_Time = var_Departure_Time
                where Org_Id = var_Org_Id 
                and Route_Id = var_Route_Id
                and Stage_No = var_Stage_No;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Stage_No AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			delete from m007_route_item
				where Org_Id = var_Org_Id 
				and Route_Id = var_Route_Id 
				and Stage_No = var_Stage_No;
            
			update m007_route_item
				set Stage_No = Stage_No - 1
				where Org_Id = var_Org_Id 
				and Route_Id = var_Route_Id 
				and Stage_No > var_Stage_No;
			
				SELECT 1 AS Result_Id, 
				'Deleted' AS Result_Description, 
				var_Stage_No AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
