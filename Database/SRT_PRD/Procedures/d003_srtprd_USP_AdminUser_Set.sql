-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminUser_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminUser_Set`(
	var_Method_Name VARCHAR(50),
    var_Org_Id varchar(10),
	var_User_Id VARCHAR(20),
	var_Role_Id VARCHAR(20),
    var_Employee_Id varchar(45),
	var_User_Name VARCHAR(45),
	var_Mobile_No VARCHAR(20),
	var_Email_Id VARCHAR(45),
	var_Joining_Date DATETIME,
	var_Pan_No VARCHAR(10),
	var_Aadhar_No VARCHAR(12),
	var_CreatedBy_Id varchar(20), 
	var_CreatedBy_Name longtext,
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_User_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            
            set @var_Mobile_No = (select User_Id from mu03_user where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) ;
            set @var_Email_Id = (select User_Id from mu03_user where Org_Id = var_Org_Id and Email_Id = var_Email_Id  and Is_Deleted = 0) ;
            set @var_Pan_No = (select User_Id from mu03_user where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) ;
            set @var_Aadhar_No = (select User_Id from mu03_user where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No  and Is_Deleted = 0) ;
            
			if (@var_Mobile_No is not null or @var_Mobile_No  <> '') then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (@var_Email_Id is not null or @var_Email_Id  <> '') then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
                 
			
				elseif (@var_Pan_No is not null or @var_Pan_No  <> '') then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
                      
			
				elseif (@var_Aadhar_No is not null or @var_Aadhar_No  <> '') then
					SELECT -1 AS Result_Id, 
					'Aadhar Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
                      
				
			else
               
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu03_user', Year_Id, 'MU03', '', New_User_Id );
                set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
            
				Insert Into mu03_user
                (Org_Id, User_Id,Login_Name,Login_Password,Role_Id,Employee_Id, User_Name, Mobile_No,Email_Id,Joining_Date, 
                    Pan_No,Aadhar_No,Is_Active,Is_Deleted,Is_PasswordReset,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_User_Id,var_Email_Id,New_Password,var_Role_Id,var_Employee_Id, var_User_Name,var_Mobile_No,var_Email_Id,var_Joining_Date,
                    var_Pan_No,var_Aadhar_No,var_Is_Active, var_Is_Deleted,1, Now(), var_CreatedBy_Id,var_CreatedBy_Name);      

				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_User_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select User_Id from mu03_user where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and User_Id <> var_User_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select User_Id from mu03_user where Org_Id = var_Org_Id and Email_Id = var_Email_Id and Is_Deleted = 0 and User_Id <> var_User_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			-- elseif var_Pan_No IS NOT NULL AND var_Pan_No != '' THEN
				elseif exists(select User_Id from mu03_user where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and User_Id <> var_User_Id
				) then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
			-- 	end if;
			-- elseif var_Aadhar_No IS NOT NULL AND var_Aadhar_No != '' THEN
				elseif exists(select User_Id from mu03_user where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0 and User_Id <> var_User_Id
				) then
					SELECT -1 AS Result_Id, 
					'Aadhar Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
				-- end if;
			else
            
				Update mu03_user
                set 
                Login_Name = var_Email_Id,
                Employee_Id = var_Employee_Id,
                Role_Id = var_Role_Id,
                User_Name = var_User_Name,
                Mobile_No = var_Mobile_No,
                Email_Id = var_Email_Id,
                Joining_Date = var_Joining_Date,
                Pan_No = var_Pan_No,
                Aadhar_No = var_Aadhar_No,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_CreatedBy_Id,
                LastEditedBy_Name = var_CreatedBy_Name,
                Is_Active = var_Is_Active,
				Is_Deleted = var_Is_Deleted
                where Org_Id = var_Org_Id and User_Id = var_User_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_User_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu03_user
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where Org_Id = var_Org_Id and User_Id = var_User_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_User_Id AS Result_Extra_Key;
        end;
	ELSEIF(var_Method_Name = 'ResetPassword') THEN
    BEGIN
		DECLARE Generated_OTP VARCHAR(10);
		SET Generated_OTP = (SELECT CONVERT(FLOOR(RAND()*(9000)+1000), CHAR));
        
        UPDATE mu03_user
        SET Login_Password = Generated_OTP,
        Is_PasswordReset = 1,
        LastEdited_On = NOW(),
		LastEditedBy_Id = var_CreatedBy_Id,
		LastEditedBy_Name = var_CreatedBy_Name
        WHERE Org_Id = var_Org_Id
        AND User_Id = var_User_Id; 
        
        SELECT 1 AS Result_Id, 
		'Reset' AS Result_Description, 
		Generated_OTP AS Result_Extra_Key;

    END;
    ELSEIF(var_Method_Name = 'UpdatePassword') THEN
    BEGIN
		Declare varCurrentPassword varchar(50);
        
		-- Validate if Current Password is correct or no
        set varCurrentPassword = (Select Login_Password from mu03_user where Org_Id = var_Org_Id
        AND User_Id = var_User_Id); 
        
        -- Since Current Password is correct update it.
        if (varCurrentPassword = var_User_Name) then
			UPDATE mu03_user
			SET Login_Password = var_Email_Id,
			LastEdited_On = NOW(),
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			WHERE Org_Id = var_Org_Id
			AND User_Id = var_User_Id; 
			
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			'' AS Result_Extra_Key;
		else
			SELECT -1 AS Result_Id, 
			'Invalid Current Password' AS Result_Description, 
			'Invalid Current Password' AS Result_Extra_Key;
        end if;
    END;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
