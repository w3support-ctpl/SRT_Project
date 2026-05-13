-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDieselRate_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDieselRate_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_DieselRate_Id varchar(20),
	var_DieselRate varchar(45),
    var_DieselRate_Date DATETIME,
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_DieselRate_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare Today_Date datetime;
            DECLARE Latest_DieselRate_Date datetime;
            
            SELECT DieselRate_Date  INTO Latest_DieselRate_Date
			FROM t001_dieselrate
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
			ORDER BY DieselRate_Date DESC
			LIMIT 1;
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            if (Date(var_DieselRate_Date) < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (Date(var_DieselRate_Date) <= Date(Latest_DieselRate_Date)) then
				SELECT -1 AS Result_Id, 
				'Date must be greater than the latest date' AS Result_Description, 
				'' AS Result_Extra_Key;
			elseif exists(select DieselRate_Id from t001_dieselrate where Org_Id = var_Org_Id 
					and DieselRate_Date = var_DieselRate_Date and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t001_dieselrate', Year_Id, 'T001', '', New_DieselRate_Id );
            
				Insert Into t001_dieselrate
                (Org_Id,DieselRate_Id,DieselRate,DieselRate_Date,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id,New_DieselRate_Id,var_DieselRate,var_DieselRate_Date,
                var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_DieselRate_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			Declare Today_Date datetime;
            DECLARE Latest_DieselRate_Date datetime;
            
            SELECT DieselRate_Date  INTO Latest_DieselRate_Date
			FROM t001_dieselrate
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
            and DieselRate_Id <> var_DieselRate_Id
			ORDER BY DieselRate_Date DESC
			LIMIT 1;
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            if (Date(var_DieselRate_Date) < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (Date(var_DieselRate_Date) <= Date(Latest_DieselRate_Date)) then
				SELECT -1 AS Result_Id, 
				'Date must be greater than the latest date' AS Result_Description, 
				'' AS Result_Extra_Key;
			elseif exists(select DieselRate_Id from t001_dieselrate where Org_Id = var_Org_Id
				and DieselRate_Date = var_DieselRate_Date 
				and Is_Deleted = 0 and DieselRate_Id <> var_DieselRate_Id) then
                SELECT -1 AS Result_Id, 
                'Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				UPDATE t001_dieselrate
				SET
					DieselRate = var_DieselRate,
					DieselRate_Date = var_DieselRate_Date,
					Is_Active = var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name
				WHERE Org_Id = var_Org_Id AND DieselRate_Id = var_DieselRate_Id;
                
				SELECT
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_DieselRate_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update t001_dieselrate
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and DieselRate_Id = var_DieselRate_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_DieselRate_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
