-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFreight_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFreight_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Freight_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_FreightRateType_Id varchar(20),
    var_BaseRate varchar(20),
	var_Amount varchar(20),
	var_Applicable_Date DATETIME,
	var_User_Id varchar(20),
    var_User_Name varchar(45),
    var_Version_No int,
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Freight_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Version_No int;
            Declare Today_Date datetime;
            DECLARE Latest_Applicable_Date datetime;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m004_freight
			WHERE Org_Id = var_Org_Id
			AND Vehicle_Id = var_Vehicle_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
            elseif exists(select Freight_Id from m004_freight where Org_Id = var_Org_Id 
					and Vehicle_Id = var_Vehicle_Id and Applicable_Date = var_Applicable_Date 
                    and FreightRateType_Id = var_FreightRateType_Id  
                    and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m004_freight', Year_Id, 'M004', '', New_Freight_Id );
                
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m004_freight
				where Org_Id = var_Org_Id 
                and Vehicle_Id = var_Vehicle_Id
                and FreightRateType_Id = var_FreightRateType_Id;
            
				Insert Into m004_freight
                (Org_Id, Freight_Id,Vehicle_Id,FreightRateType_Id,BaseRate,
					Version_No,Amount,Applicable_Date,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Freight_Id,var_Vehicle_Id,var_FreightRateType_Id,var_BaseRate,
					New_Version_No,var_Amount,var_Applicable_Date,
                    var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                    
				
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Freight_Id AS Result_Extra_Key;
                
                
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        Declare Today_Date datetime;
        DECLARE Latest_Applicable_Date datetime;
        
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m004_freight
			WHERE Org_Id = var_Org_Id
			AND Vehicle_Id = var_Vehicle_Id
			AND Is_Deleted = 0
            and Freight_Id <> var_Freight_Id
			ORDER BY Version_No DESC
			LIMIT 1;
            
        if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
		elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
        elseif exists(select Freight_Id from m004_freight where Org_Id = var_Org_Id 
					and Vehicle_Id = var_Vehicle_Id and Applicable_Date = var_Applicable_Date 
                    and FreightRateType_Id = var_FreightRateType_Id  
                    and Version_No = var_Version_No 
                    and Is_Deleted = 0 and Freight_Id <> var_Freight_Id) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				Update m004_freight
                set 
                FreightRateType_Id = var_FreightRateType_Id,
                BaseRate = var_BaseRate,
				Amount = var_Amount,
                Applicable_Date = var_Applicable_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Freight_Id = var_Freight_Id
                and Vehicle_Id = var_Vehicle_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Freight_Id AS Result_Extra_Key;
                
                
                
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m004_freight
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and Freight_Id = var_Freight_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Freight_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
