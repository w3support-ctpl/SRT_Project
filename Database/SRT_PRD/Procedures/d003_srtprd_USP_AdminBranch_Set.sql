-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminBranch_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminBranch_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Bank_Id varchar(20),
    var_Branch_Id varchar(20),
	var_Branch_Name varchar(45),
    var_IFSC_Code varchar(45),
    var_Address_Text longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Branch_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Branch_Id from m016_branch where Org_Id = var_Org_Id 
				and Bank_Id = var_Bank_Id
				and Branch_Name = var_Branch_Name
				and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'Branch Name already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
			elseif exists(select Branch_Id from m016_branch where Org_Id = var_Org_Id 
				and Bank_Id = var_Bank_Id
				and IFSC_Code = var_IFSC_Code
				and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'IFSC Code already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
                    
			
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m016_branch', Year_Id, 'M016', '', New_Branch_Id );
				Insert Into m016_branch
                (Org_Id, Bank_Id,Branch_Id,Branch_Name,IFSC_Code,Address_Text,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, var_Bank_Id,New_Branch_Id,var_Branch_Name,var_IFSC_Code,var_Address_Text,
                    var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Branch_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Branch_Id from m016_branch where Org_Id = var_Org_Id 
            and Bank_Id = var_Bank_Id
            and Branch_Name = var_Branch_Name and Is_Deleted = 0 and Branch_Id <> var_Branch_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Branch Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Branch_Id from m016_branch where Org_Id = var_Org_Id 
            and Bank_Id = var_Bank_Id
            and IFSC_Code = var_IFSC_Code and Is_Deleted = 0 and Branch_Id <> var_Branch_Id
            ) then
				SELECT -1 AS Result_Id, 
                'IFSC Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m016_branch
                set 
                Branch_Name = var_Branch_Name,
                IFSC_Code = var_IFSC_Code,
                Address_Text = var_Address_Text,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Bank_Id = var_Bank_Id
                and Branch_Id = var_Branch_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Branch_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
        
            Update m016_branch
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and Bank_Id = var_Bank_Id
			and Branch_Id = var_Branch_Id;

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Branch_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
