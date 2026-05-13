-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveSchemeMCC_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveSchemeMCC_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
	var_IncentiveScheme_Id varchar(20),
    var_MCC_Id varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN	
	SET SQL_SAFE_UPDATES = 0;

	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
			if exists(select Entry_Id from m011_incentivescheme_item where Org_Id = var_Org_Id  
            and IncentiveScheme_Id = var_IncentiveScheme_Id 
            and MCC_Id = var_MCC_Id ) then
            
				SELECT -1 AS Result_Id, 
                'MCC Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
                
            else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m011_incentivescheme_item', Year_Id, 'M011', '', New_Entry_Id );
				
				Insert Into m011_incentivescheme_item
				(Org_Id,Entry_Id,IncentiveScheme_Id,MCC_Id)
				value(var_Org_Id,New_Entry_Id,var_IncentiveScheme_Id,var_MCC_Id);
				
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				New_Entry_Id AS Result_Extra_Key;
                
            end if;
            
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
        
			delete from m011_incentivescheme_item
            where Org_Id = var_Org_Id and Entry_Id = var_Entry_Id;
            
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
