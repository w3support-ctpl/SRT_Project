-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommission_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommission_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_MPPI_Id varchar(20),
	var_MPPI_Name varchar(45),
    var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
	var_UOM_Id varchar(20),
    var_MCCType_Id varchar(20),
    var_MCCWorkType_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Is_Lived int,
    var_MPPI_Type varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_MPPI_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select MPPI_Id from m002_commission where Org_Id = var_Org_Id and MPPI_Name = var_MPPI_Name
            and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'MPPI Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m002_commission', Year_Id, 'M002', '', New_MPPI_Id );
            
				Insert Into m002_commission
                (Org_Id, MPPI_Id,MPPI_Name,MilkType_Id,MilkStatus_Id,UOM_Id,MCCType_Id,MCCWorkType_Id,CollectionShift_Id,
                    Is_Active,Is_Deleted,Is_Lived,Created_On,CreatedBy_Id,CreatedBy_Name,
                    MPPIType_Id)
				Values (var_Org_Id, New_MPPI_Id,var_MPPI_Name,var_MilkType_Id,var_MilkStatus_Id,var_UOM_Id,var_MCCType_Id,var_MCCWorkType_Id,var_CollectionShift_Id,
                    var_Is_Active, var_Is_Deleted,var_Is_Lived,Now(), var_User_Id,var_User_Name,
                    var_MPPI_Type); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_MPPI_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select MPPI_Id from m002_commission where Org_Id = var_Org_Id and MPPI_Name = var_MPPI_Name 
			and Is_Deleted = 0 and MPPI_Id <> var_MPPI_Id
            ) then
				SELECT -1 AS Result_Id, 
                'MPPI Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m002_commission
                set 
                MPPI_Name = var_MPPI_Name,
                MPPIType_Id = var_MPPI_Type,
                MilkType_Id = var_MilkType_Id,
                MilkStatus_Id = var_MilkStatus_Id,
                UOM_Id = var_UOM_Id,
                MCCType_Id = var_MCCType_Id,
                MCCWorkType_Id = var_MCCWorkType_Id,
				CollectionShift_Id = var_CollectionShift_Id,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
				Is_Lived = var_Is_Lived,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id and MPPI_Id = var_MPPI_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_MPPI_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m002_commission
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and MPPI_Id = var_MPPI_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_MPPI_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
