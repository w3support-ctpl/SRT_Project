-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminAgent_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminAgent_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Agent_Id varchar(20),
	var_Agent_Name varchar(45),
	var_Mobile_No varchar(20),
    var_Email_Id varchar(45),
    var_Joining_Date DATETIME,
    var_Birth_Date DATETIME,
	var_Pan_No VARCHAR(10),
	var_Aadhar_No VARCHAR(12),
    var_Address_Text longtext,
	var_State_Id varchar(20),
	var_District_Id varchar(20),
	var_Taluka_Id varchar(20),
    var_Village_Id varchar(20),
    var_Profile_Photo varchar(255),
	var_Pan_Card_Photo varchar(255),
	var_Aadhar_Card_Photo varchar(255),
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
            Declare New_Agent_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            
            if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			/*
            elseif var_Pan_No IS NOT NULL and var_Pan_No != '' THEN
				if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
				end if;
			elseif var_Aadhar_No IS NOT NULL and var_Aadhar_No != '' THEN
				if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'Aadhar Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
				end if;
			*/
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu05_agent', Year_Id, 'MU05', '', New_Agent_Id );
				set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
				Insert Into mu05_agent
                (Org_Id, Agent_Id,Login_Name,Login_Password,Agent_Name, Agent_Code, Mobile_No,Is_MobileNo_Verified,Joining_Date,Birth_Date,Address_Text, 
                    State_Id,District_Id,Taluka_Id,Village_Id,Pan_No,Aadhar_No,Email_Id,
                    Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,Is_Active,Is_Deleted,Is_PasswordReset,Online_App_Flag,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Agent_Id,var_Mobile_No,New_Password,var_Agent_Name,New_Agent_Id,var_Mobile_No,1,var_Joining_Date,var_Birth_Date,var_Address_Text,
                    var_State_Id,var_District_Id,var_Taluka_Id,var_Village_Id,var_Pan_No,var_Aadhar_No,var_Email_Id,
                    var_Profile_Photo,var_Pan_Card_Photo,var_Aadhar_Card_Photo,var_Is_Active, var_Is_Deleted, 1,var_Online_App_Flag,Now(), var_CreatedBy_Id,var_CreatedBy_Name); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Agent_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Agent_Id <> var_Agent_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			/*
			elseif var_Pan_No IS NOT NULL and var_Pan_No != '' THEN
            
				if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and Agent_Id <> var_Agent_Id
				) then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
				end if;
            
			if  var_Aadhar_No IS NOT NULL and var_Aadhar_No != '' THEN
				if exists(select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0 and Agent_Id <> var_Agent_Id
				) then
					SELECT -1 AS Result_Id, 
					'Aadhar Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
                    */
			else
				Update mu05_agent
                set 
                Login_Name = var_Mobile_No,
                Agent_Name = var_Agent_Name,
                Mobile_No = var_Mobile_No,
                Email_Id = var_Email_Id,
				Joining_Date = var_Joining_Date,
                Birth_Date = var_Birth_Date,
                Address_Text = var_Address_Text,
                State_Id = var_State_Id,
                District_Id = var_District_Id,
                Taluka_Id = var_Taluka_Id,
                Village_Id = var_Village_Id,
                Pan_No = var_Pan_No,
                Aadhar_No = var_Aadhar_No,
                Profile_Photo = var_Profile_Photo,
                Pan_Card_Photo = var_Pan_Card_Photo,
                Aadhar_Card_Photo = var_Aadhar_Card_Photo,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                Online_App_Flag  = var_Online_App_Flag,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_CreatedBy_Id,
                LastEditedBy_Name = var_CreatedBy_Name 
                where Org_Id = var_Org_Id and Agent_Id = var_Agent_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Agent_Id AS Result_Extra_Key;
			end if;
           /* end if;
            end if;*/
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu05_agent
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where Org_Id = var_Org_Id and Agent_Id = var_Agent_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Agent_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
