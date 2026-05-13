-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFatSNFRatio_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFatSNFRatio_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Ratio_Id varchar(20),
	var_Fat varchar(45),
    var_SNF varchar(45),
    var_OverheadAmount varchar(45),
    var_Ratio_Date DATETIME,
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Ratio_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare Today_Date datetime;
            DECLARE Latest_Ratio_Date datetime;
            
            SELECT Ratio_Date  INTO Latest_Ratio_Date
			FROM t024_fatsnf_ratio
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
			ORDER BY Ratio_Date DESC
			LIMIT 1;
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            if (Date(var_Ratio_Date) < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (Date(var_Ratio_Date) <= Date(Latest_Ratio_Date)) then
				SELECT -1 AS Result_Id, 
				'Date must be greater than the latest date' AS Result_Description, 
				'' AS Result_Extra_Key;
			elseif exists(select Ratio_Id from t024_fatsnf_ratio where Org_Id = var_Org_Id 
					and Ratio_Date = var_Ratio_Date and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t024_fatsnf_ratio', Year_Id, 'T001', '', New_Ratio_Id );
            
				Insert Into t024_fatsnf_ratio
                (Org_Id,Ratio_Id,Fat,SNF,Overhead_Amount,
                Ratio_Date,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id,New_Ratio_Id,var_Fat,var_SNF,var_OverheadAmount,
                var_Ratio_Date,
                var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Ratio_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			Declare Today_Date datetime;
            DECLARE Latest_Ratio_Date datetime;
            
            SELECT Ratio_Date  INTO Latest_Ratio_Date
			FROM t024_fatsnf_ratio
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
            and Ratio_Id <> var_Ratio_Id
			ORDER BY Ratio_Date DESC
			LIMIT 1;
            
            set Today_Date = Date(CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            if (Date(var_Ratio_Date) < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Date must be greater than current date' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (Date(var_Ratio_Date) <= Date(Latest_Ratio_Date)) then
				SELECT -1 AS Result_Id, 
				'Date must be greater than the latest date' AS Result_Description, 
				'' AS Result_Extra_Key;
			elseif exists(select Ratio_Id from t024_fatsnf_ratio where Org_Id = var_Org_Id
				and Ratio_Date = var_Ratio_Date 
				and Is_Deleted = 0 and Ratio_Id <> var_Ratio_Id) then
                SELECT -1 AS Result_Id, 
                'Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				UPDATE t024_fatsnf_ratio
				SET
					Fat = var_Fat,
                    SNF = var_SNF,
                    Overhead_Amount = var_OverheadAmount,
					Ratio_Date = var_Ratio_Date,
					Is_Active = var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name
				WHERE Org_Id = var_Org_Id AND Ratio_Id = var_Ratio_Id;
                
				SELECT
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Ratio_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update t024_fatsnf_ratio
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Ratio_Id = var_Ratio_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Ratio_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
