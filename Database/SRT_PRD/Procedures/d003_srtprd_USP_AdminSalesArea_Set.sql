-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSalesArea_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSalesArea_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_SalesArea_Id varchar(20),
    var_SalesArea_Name varchar(50),
	var_SalesArea_Code varchar(45),
    var_User_Id varchar(20),
    var_User_Name varchar(20),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_SalesArea_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select SalesArea_Id from m013_salesarea where Org_Id = var_Org_Id and SalesArea_Code = var_SalesArea_Code
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Sales Area Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select SalesArea_Id from m013_salesarea where Org_Id = var_Org_Id  and SalesArea_Name = var_SalesArea_Name 
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Sales Area Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m013_salesarea', Year_Id, 'M013', '', New_SalesArea_Id );
            
				Insert Into m013_salesarea
                (Org_Id, SalesArea_Id, SalesArea_Name, SalesArea_Code,
                Is_Active, Is_Deleted,Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_SalesArea_Id,var_SalesArea_Name,var_SalesArea_Code,
                var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name);      

				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_SalesArea_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select SalesArea_Id from m013_salesarea where Org_Id = var_Org_Id 
			and SalesArea_Code = var_SalesArea_Code  
            and Is_Deleted = 0 and SalesArea_Id <> var_SalesArea_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Sales Area Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select SalesArea_Id from m013_salesarea where Org_Id = var_Org_Id 
            and SalesArea_Name = var_SalesArea_Name  
            and Is_Deleted = 0 and SalesArea_Id <> var_SalesArea_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Sales Area Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;

			else
            
				Update m013_salesarea
                set 
                SalesArea_Name = var_SalesArea_Name,
                SalesArea_Code = var_SalesArea_Code,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and SalesArea_Id = var_SalesArea_Id;      

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_SalesArea_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m013_salesarea
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and SalesArea_Id = var_SalesArea_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_SalesArea_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
