-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminChemist_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminChemist_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Chemist_Id varchar(20),
	var_Chemist_Name varchar(45),
    var_Chemist_Code varchar(45),
	var_Mobile_No varchar(20),
    var_Joining_Date DATETIME,
    var_Birth_Date DATETIME,
	var_Pan_No VARCHAR(10),
	var_Aadhar_No VARCHAR(12),
	var_CreatedBy_Id varchar(20),
	var_CreatedBy_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Online_App_Flag int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Chemist_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            
            if exists(select Chemist_Id from mu07_routechemist where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu07_routechemist', Year_Id, 'MU07', '', New_Chemist_Id );
                set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
            
				Insert Into mu07_routechemist
                (Org_Id, Chemist_Id,Login_Name,Login_Password,Chemist_Name, Chemist_Code,
                Mobile_No,Is_MobileNo_Verified,Joining_Date,Birth_Date,Pan_No,Aadhar_No,Is_Active,Is_Deleted,Is_PasswordReset,
                Created_On,CreatedBy_Id,CreatedBy_Name,Online_App_Flag)
				Values (var_Org_Id, New_Chemist_Id,var_Mobile_No,New_Password,var_Chemist_Name,New_Chemist_Id,
                var_Mobile_No,1,var_Joining_Date,var_Birth_Date,var_Pan_No,var_Aadhar_No,var_Is_Active, var_Is_Deleted, 1,
                Now(), var_CreatedBy_Id,var_CreatedBy_Name,var_Online_App_Flag); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Chemist_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Chemist_Id from mu07_routechemist where Org_Id = var_Org_Id and Chemist_Code = var_Chemist_Code and Is_Deleted = 0 and Chemist_Id <> var_Chemist_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Chemist Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Chemist_Id from mu07_routechemist where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Chemist_Id <> var_Chemist_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update mu07_routechemist
                set 
                Login_Name = var_Mobile_No,
                Chemist_Name = var_Chemist_Name,
                Mobile_No = var_Mobile_No,
                Pan_No = var_Pan_No,
                Aadhar_No = var_Aadhar_No,
				Joining_Date = var_Joining_Date,
                Birth_Date = var_Birth_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_CreatedBy_Id,
                LastEditedBy_Name = var_CreatedBy_Name,
                Online_App_Flag =  var_Online_App_Flag
                where Org_Id = var_Org_Id and Chemist_Id = var_Chemist_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Chemist_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu07_routechemist
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where Org_Id = var_Org_Id and Chemist_Id = var_Chemist_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Chemist_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
