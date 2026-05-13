-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDriver_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDriver_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Driver_Id varchar(20),
	var_Driver_Name varchar(45),
	var_Mobile_No varchar(20),
    var_Joining_Date DATETIME,
    var_Birth_Date DATETIME,
	var_Pan_No VARCHAR(10),
	var_Aadhar_No VARCHAR(12),
    var_DrivingLicense_No VARCHAR(45),
	var_DriverType_Id VARCHAR(45),
	var_CreatedBy_Id varchar(20),
	var_CreatedBy_Name varchar(45),
    var_Online_App_Flag int,
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Driver_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            
            if exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			 elseif exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Aadhar Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu06_driver', Year_Id, 'MU06', '', New_Driver_Id );
                set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
            
				Insert Into mu06_driver
                (Org_Id, Driver_Id,Login_Name,Login_Password,Driver_Name, Driver_Code,DrivingLicense_No,DriverType_Id,
                Mobile_No,Is_MobileNo_Verified,Joining_Date,Birth_Date,Pan_No,Aadhar_No,Is_Active,Is_Deleted,Is_PasswordReset,
                Online_App_Flag,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Driver_Id,var_Mobile_No,New_Password,var_Driver_Name,New_Driver_Id,var_DrivingLicense_No,var_DriverType_Id,
                var_Mobile_No,1,var_Joining_Date,var_Birth_Date,var_Pan_No,var_Aadhar_No,var_Is_Active, var_Is_Deleted, 1,
				var_Online_App_Flag,Now(), var_CreatedBy_Id,var_CreatedBy_Name); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Driver_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Driver_Id <> var_Driver_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and Driver_Id <> var_Driver_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0 and Driver_Id <> var_Driver_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Aadhar Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update mu06_driver
                set 
                Login_Name = var_Mobile_No,
                Driver_Name = var_Driver_Name,
                Mobile_No = var_Mobile_No,
                DrivingLicense_No = var_DrivingLicense_No,
                DriverType_Id = var_DriverType_Id,
                Pan_No = var_Pan_No,
                Aadhar_No = var_Aadhar_No,
                Joining_Date = var_Joining_Date,
                Birth_Date = var_Birth_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                Online_App_Flag  = var_Online_App_Flag,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_CreatedBy_Id,
                LastEditedBy_Name = var_CreatedBy_Name 
                where Org_Id = var_Org_Id and Driver_Id = var_Driver_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Driver_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu06_driver
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where Org_Id = var_Org_Id and Driver_Id = var_Driver_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Driver_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
