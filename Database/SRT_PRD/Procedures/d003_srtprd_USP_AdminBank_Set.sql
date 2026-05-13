-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminBank_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminBank_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Bank_Id varchar(20),
	var_Bank_Name varchar(45),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Bank_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Bank_Id from m015_bank where Org_Id = var_Org_Id 
            and Bank_Name = var_Bank_Name
			and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Bank Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m015_bank', Year_Id, 'M015', '', New_Bank_Id );
            
				Insert Into m015_bank
                (Org_Id, Bank_Id,Bank_Name,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Bank_Id,var_Bank_Name,
                    var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Bank_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Bank_Id from m015_bank where Org_Id = var_Org_Id 
            and Bank_Name = var_Bank_Name and Is_Deleted = 0 and Bank_Id <> var_Bank_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Bank Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m015_bank
                set 
                Bank_Name = var_Bank_Name,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id and Bank_Id = var_Bank_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Bank_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m015_bank
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Bank_Id = var_Bank_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Bank_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
