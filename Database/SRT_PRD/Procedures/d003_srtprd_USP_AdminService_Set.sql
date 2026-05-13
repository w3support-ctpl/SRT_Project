-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminService_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminService_Set`(
    var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Service_Id varchar(20),
    var_Service_Name varchar(45),
    var_ServiceType_Id varchar(20),
    var_Service_Description varchar(255),
	var_Material_Id varchar(20),
    var_Condition_1 longtext,
    var_Condition_2 longtext,
    var_Condition_3 longtext,
    var_Condition_4 longtext,
    var_Condition_5 longtext,
    var_Is_For_Farmer int,
    var_Is_For_Agent int,
    var_User_Id varchar(20),
    var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Service_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Service_Id from m012_service where Org_Id = var_Org_Id  
            and Service_Name = var_Service_Name 
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Service Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m012_service', Year_Id, 'M012', '', New_Service_Id );
            
				Insert Into m012_service
                (Org_Id,Service_Id, Service_Name, ServiceType_Id, Service_Description,
                Condition_1,Condition_2,Condition_3,Condition_4,Condition_5,Is_For_Farmer,Is_For_Agent,
                Material_Id,Is_Active, Is_Deleted,Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Service_Id,var_Service_Name, var_ServiceType_Id,var_Service_Description,
                var_Condition_1,var_Condition_2,var_Condition_3,var_Condition_4,var_Condition_5,var_Is_For_Farmer,var_Is_For_Agent,
                var_Material_Id,var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name);      

				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Service_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Service_Id from m012_service where Org_Id = var_Org_Id 
			and Service_Name = var_Service_Name  
            and Is_Deleted = 0 and Service_Id <> var_Service_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Service Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m012_service
                set 
                Service_Name = var_Service_Name,
                ServiceType_Id = var_ServiceType_Id,
                Service_Description=var_Service_Description,
                Material_Id = var_Material_Id,
                Condition_1 = var_Condition_1,
                Condition_2 = var_Condition_2,
                Condition_3 = var_Condition_3,
                Condition_4 = var_Condition_4,
                Condition_5 = var_Condition_5,
                Is_For_Farmer=var_Is_For_Farmer,
                Is_For_Agent=var_Is_For_Agent,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and Service_Id = var_Service_Id;      

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Service_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m012_service
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Service_Id = var_Service_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Service_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
