-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Chart_Id varchar(20),
	var_Chart_Name varchar(45),
    var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
	var_UOM_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Is_Lived int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Chart_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Chart_Id from m001_milkrate where Org_Id = var_Org_Id and Chart_Name = var_Chart_Name
            and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Chart Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m001_milkrate', Year_Id, 'M001', '', New_Chart_Id );
            
				Insert Into m001_milkrate
                (Org_Id, Chart_Id,Chart_Name,MilkType_Id,MilkStatus_Id,UOM_Id,CollectionShift_Id,
                    Is_Active,Is_Deleted,Is_Lived,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Chart_Id,var_Chart_Name,var_MilkType_Id,var_MilkStatus_Id,var_UOM_Id,var_CollectionShift_Id,
                    var_Is_Active, var_Is_Deleted,var_Is_Lived,Now(), var_User_Id,var_User_Name); 
                    
				if(var_Is_Lived = 1) then
						call USP_AdminMilkRate_Auto(var_Org_Id);
                end if;
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Chart_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Chart_Id from m001_milkrate where Org_Id = var_Org_Id and Chart_Name = var_Chart_Name 
			and Is_Deleted = 0 and Chart_Id <> var_Chart_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Chart Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m001_milkrate
                set 
                Chart_Name = var_Chart_Name,
                MilkType_Id = var_MilkType_Id,
                MilkStatus_Id = var_MilkStatus_Id,
                UOM_Id = var_UOM_Id,
                CollectionShift_Id = var_CollectionShift_Id,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
				Is_Lived = var_Is_Lived,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id and Chart_Id = var_Chart_Id;  
                
                if(var_Is_Lived = 1) then
						call USP_AdminMilkRate_Auto(var_Org_Id);
                end if;

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Chart_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m001_milkrate
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Chart_Id = var_Chart_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Chart_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
