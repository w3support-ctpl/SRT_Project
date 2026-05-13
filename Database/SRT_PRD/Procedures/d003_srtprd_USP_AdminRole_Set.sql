-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRole_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRole_Set`(
	IN `var_Method_Name` varchar(20),
	IN `var_Org_Id` varchar(10),
	IN `var_Role_Id` varchar(20),
	IN `var_Role_Name` varchar(50),
	IN `var_Application_Id` varchar(20),
	IN `var_Role_Menu` text,
	IN `var_User_Id` varchar(20),
	IN `var_User_Name` varchar(45),
	IN `var_Is_Active` int,
	IN `var_Is_Deleted` int
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Role_Id varchar(20);
			Declare Year_Id varchar(10);
			Declare new_Id varchar(20);
            
            if exists(select Role_Id from mu01_role where Org_Id = var_Org_Id and Role_Name = var_Role_Name
            and Is_Deleted = 0 ) then
				SELECT -1 AS Result_Id, 
                'Role Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu01_role', Year_Id, 'MU01', '', New_Role_Id );
            
				Insert Into mu01_role
                (Org_Id, Role_Id, Role_Name,Is_SystemRole,
                Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Role_Id, var_Role_Name, 0,
                var_Is_Active, var_Is_Deleted, 
				Now(), var_User_Id,var_User_Name);

				SELECT 
				1 AS Result_Id,
				'Saved' AS Result_Description,
				New_Role_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			-- Declare var_Is_Sys_Locked int;
            -- Check if this is a system rold
            if exists(select Role_Id from mu01_role where Org_Id = var_Org_Id 
				and Role_Name = var_Role_Name and Is_Deleted = 0 and Role_Id <> var_Role_Id ) then
				SELECT -1 AS Result_Id, 
                'Role Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				Update mu01_role
                set 
                Role_Name = var_Role_Name,
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
				LastEdited_On = Now(), 
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id and Role_Id = var_Role_Id;
				
                -- Update Role_Menu
				-- Delete from mu02_role_menu
				DELETE m2.* FROM mu02_role_menu m2
				INNER JOIN c002_menu c2 ON m2.Menu_Id = c2.Menu_Id
				WHERE m2.Org_Id = var_Org_Id AND m2.Role_Id = var_Role_Id AND c2.Application_Id = var_Application_Id;
					
				-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_menu;
				CREATE TEMPORARY TABLE temp_menu (PKeyRowNum int, 
				Menu_Id varchar(20), Display_Flag int, Add_Flag int, Edit_Flag int, Delete_Flag int);
                    
				SET row_count := extractValue(var_Role_Menu,'count(//Menu/MenuItem)');
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Menu/MenuItem[', k, ']');
					INSERT INTO temp_menu VALUES (
						k,
						extractValue(var_Role_Menu, concat(xpath,'/Menu_Id')),
						extractValue(var_Role_Menu, concat(xpath,'/Display_Flag')),
						extractValue(var_Role_Menu, concat(xpath,'/Add_Flag')),
						extractValue(var_Role_Menu, concat(xpath,'/Edit_Flag')),
						extractValue(var_Role_Menu, concat(xpath,'/Delete_Flag'))
					);
				END WHILE;
				
				-- Save Data in mu02_role_menu table from temp table
				Insert into mu02_role_menu
				(Org_Id, Role_Id, Menu_Id, Display_Flag, Add_Flag, Edit_Flag,Delete_Flag)
				SELECT var_Org_Id, var_Role_Id, Menu_Id, Display_Flag,Add_Flag, Edit_Flag, Delete_Flag
				from temp_menu;  
				
				-- Drop temp table
				drop temporary table temp_menu;
                
				SELECT 
					1 AS Result_Id,
					'Updated' AS Result_Description,
					var_Role_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
				Update mu01_role
				set 
				Is_Deleted = 1, 
				LastEdited_On = Now(), 
				LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
				where Org_Id = var_Org_Id and Role_Id = var_Role_Id;      

				SELECT 1 AS Result_Id, 
				'Deleted' AS Result_Description, 
				var_Role_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Create_Report') then

		begin

			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            delete from mu02_role_report 
			where Org_Id = var_Org_Id and Role_Id = var_Role_Id;
            
			SET row_count := extractValue(var_Role_Menu,'count(//Menu/MenuItem)');

			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//Menu/MenuItem[', k, ']');

				INSERT INTO mu02_role_report(
				Org_Id,Role_Id,ReportType_Id,Flag
				) VALUES (
				var_Org_Id,
				var_Role_Id,
				extractValue(var_Role_Menu, concat(xpath,'/ReportType_Id')),
				extractValue(var_Role_Menu, concat(xpath,'/Flag'))
				);
				
			END WHILE;

			SELECT 1 AS Result_Id, 
			'Create' AS Result_Description, 
			var_Role_Id AS Result_Extra_Key;

        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
