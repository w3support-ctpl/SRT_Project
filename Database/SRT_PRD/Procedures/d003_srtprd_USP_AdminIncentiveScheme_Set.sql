-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveScheme_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveScheme_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_IncentiveScheme_Id varchar(20),
	var_Scheme_Name varchar(45),
	var_IncentiveType_Id varchar(20),
    var_From_Date DATETIME,
	var_To_Date DATETIME,
	var_IncentiveFrequency_Id VARCHAR(20),
	var_Criteria int,
    var_Scheme_Description VARCHAR(255),
    var_Is_For_Farmer int,
    var_Is_For_Agent int,
    var_Photo varchar(255),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_IncentiveScheme_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select IncentiveScheme_Id from m011_incentivescheme where Org_Id = var_Org_Id  
            and Scheme_Name = var_Scheme_Name 
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Scheme Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m011_incentivescheme', Year_Id, 'M011', '', New_IncentiveScheme_Id );
            
				Insert Into m011_incentivescheme
                (Org_Id,IncentiveScheme_Id, Scheme_Name, IncentiveType_Id, IncentiveFrequency_Id,
                Criteria,Scheme_Description,Is_For_Farmer,Is_For_Agent,From_Date,To_Date,
                Is_Active, Is_Deleted,Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_IncentiveScheme_Id, var_Scheme_Name,var_IncentiveType_Id,var_IncentiveFrequency_Id,
                var_Criteria,var_Scheme_Description,var_Is_For_Farmer,var_Is_For_Agent,var_From_Date,var_To_Date,
                var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name);      

				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_IncentiveScheme_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select IncentiveScheme_Id from m011_incentivescheme where Org_Id = var_Org_Id 
			and Scheme_Name = var_Scheme_Name  
            and Is_Deleted = 0 and IncentiveScheme_Id <> var_IncentiveScheme_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Scheme Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m011_incentivescheme
                set 
                Scheme_Name = var_Scheme_Name,
                IncentiveType_Id = var_IncentiveType_Id,
                IncentiveFrequency_Id=var_IncentiveFrequency_Id,
                Criteria = var_Criteria,
                Scheme_Description = var_Scheme_Description,
                Is_For_Farmer=var_Is_For_Farmer,
                Is_For_Agent=var_Is_For_Agent,
                From_Date = var_From_Date,
                To_Date=var_To_Date,
                Photo=var_Photo,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and IncentiveScheme_Id = var_IncentiveScheme_Id;      

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_IncentiveScheme_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m011_incentivescheme
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and IncentiveScheme_Id = var_IncentiveScheme_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_IncentiveScheme_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
