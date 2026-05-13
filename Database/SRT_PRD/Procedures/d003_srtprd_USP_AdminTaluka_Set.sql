-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTaluka_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTaluka_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_State_Id varchar(20),
    var_District_Id varchar(20),
    var_Taluka_Id varchar(20),
    var_Taluka_Name varchar(50),
    var_User_Id varchar(20),
    var_User_Name varchar(20),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Taluka_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Taluka_Id from ml04_taluka where Org_Id = var_Org_Id  
            and State_Id = var_State_Id  and District_Id = var_District_Id and Taluka_Name = var_Taluka_Name 
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Taluka Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('ml04_taluka', Year_Id, 'ML04', '', New_Taluka_Id );
            
				Insert Into ml04_taluka
                (Org_Id,State_Id,District_Id, Taluka_Id, Taluka_Name, Taluka_Code,
                Is_Active, Is_Deleted,Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, var_State_Id,var_District_Id, New_Taluka_Id,var_Taluka_Name,New_Taluka_Id,
                var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name);      

				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Taluka_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Taluka_Id from ml04_taluka where Org_Id = var_Org_Id 
            and State_Id = var_State_Id and District_Id = var_District_Id and Taluka_Name = var_Taluka_Name  
            and Is_Deleted = 0 and Taluka_Id <> var_Taluka_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Taluka Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
                
			else
            
				Update ml04_taluka
                set 
                Taluka_Name = var_Taluka_Name,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and Taluka_Id = var_Taluka_Id;      

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Taluka_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update ml04_taluka
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Taluka_Id = var_Taluka_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Taluka_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
