-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommissionItem_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommissionItem_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Entry_Id varchar(20),
    var_MPPI_Id varchar(20),
    var_MinimumQuantity varchar(20),
	var_MaximumQuantity varchar(20),
    var_BaseRate varchar(20),
    var_MinimumFat varchar(20),
    var_MinimumSNF varchar(20),
    var_MaximumFat varchar(20),
    var_MaximumSNF varchar(20),
    var_MinimumProtein varchar(20),
    var_MaximumProtein varchar(20),
    var_MinimumAsh varchar(20),
    var_MaximumAsh varchar(20),
	var_User_Id varchar(20),
    var_User_Name varchar(45),
    var_Version_No int,
    var_Is_Active int,
    var_Is_Deleted int
    
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Version_No int;
            Declare Today_Date datetime;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            set @MPPIType_Id = (select MPPIType_Id from m002_commission
								where Org_Id = var_Org_Id
								and MPPI_Id = var_MPPI_Id limit 1);
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m002_commission_item', Year_Id, 'M002', '', New_Entry_Id );
                
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m002_commission_item
				where Org_Id = var_Org_Id 
                and MPPI_Id = var_MPPI_Id;
                
                if(@MPPIType_Id = 'C047001' || @MPPIType_Id = 'C047009') then
                
					Insert Into m002_commission_item
					(Org_Id, Entry_Id,MPPI_Id,
						MinimumQuantity,MaximumQuantity,
						BaseRate,
						MinimumFat,MinimumSNF,MaximumFat,MaximumSNF,
						Version_No,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
					Values (var_Org_Id, New_Entry_Id,var_MPPI_Id,
						var_MinimumQuantity,var_MaximumQuantity,
						var_BaseRate,
						var_MinimumFat,var_MinimumSNF,var_MaximumFat,var_MaximumSNF,
						New_Version_No,
						var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                    
				elseif(@MPPIType_Id = 'C047006')then
                
					Insert Into m002_commission_item
					(Org_Id, Entry_Id,MPPI_Id,
						MinimumQuantity,MaximumQuantity,
						BaseRate,
						MinimumProtein,MaximumProtein,
						Version_No,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
					Values (var_Org_Id, New_Entry_Id,var_MPPI_Id,
						var_MinimumQuantity,var_MaximumQuantity,
						var_BaseRate,
						var_MinimumProtein,var_MaximumProtein,
						New_Version_No,
						var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
				
                elseif(@MPPIType_Id = 'C047007')then
                
					Insert Into m002_commission_item
					(Org_Id, Entry_Id,MPPI_Id,
						MinimumQuantity,MaximumQuantity,
						BaseRate,
						MinimumAsh,MaximumAsh,
						Version_No,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
					Values (var_Org_Id, New_Entry_Id,var_MPPI_Id,
						var_MinimumQuantity,var_MaximumQuantity,
						var_BaseRate,
						var_MinimumAsh,var_MaximumAsh,
						New_Version_No,
						var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                
                end if;
                
	
				
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Entry_Id AS Result_Extra_Key;
                
			-- end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        Declare Today_Date datetime;
        
				set @MPPIType_Id = (select MPPIType_Id from m002_commission
								where Org_Id = var_Org_Id
								and MPPI_Id = var_MPPI_Id limit 1);
                                
				if(@MPPIType_Id = 'C047001' || @MPPIType_Id = 'C047009') then
                
					Update m002_commission_item
					set 
					MinimumQuantity = var_MinimumQuantity,
					MaximumQuantity = var_MaximumQuantity,
					BaseRate = var_BaseRate,
					MinimumFat = var_MinimumFat,
					MinimumSNF = var_MinimumSNF,
					MaximumFat = var_MaximumFat,
					MaximumSNF = var_MaximumSNF,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name 
					where Org_Id = var_Org_Id 
					and Entry_Id = var_Entry_Id
					and MPPI_Id = var_MPPI_Id;  
                    
				elseif(@MPPIType_Id = 'C047006')then
                
					Update m002_commission_item
					set 
					MinimumQuantity = var_MinimumQuantity,
					MaximumQuantity = var_MaximumQuantity,
					BaseRate = var_BaseRate,
					MinimumProtein = var_MinimumProtein,
					MaximumProtein = var_MaximumProtein,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name 
					where Org_Id = var_Org_Id 
					and Entry_Id = var_Entry_Id
					and MPPI_Id = var_MPPI_Id;  
                    
				elseif(@MPPIType_Id = 'C047007')then
                
					Update m002_commission_item
					set 
					MinimumQuantity = var_MinimumQuantity,
					MaximumQuantity = var_MaximumQuantity,
					BaseRate = var_BaseRate,
					MinimumAsh = var_MinimumAsh,
					MaximumAsh = var_MaximumAsh,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name 
					where Org_Id = var_Org_Id 
					and Entry_Id = var_Entry_Id
					and MPPI_Id = var_MPPI_Id;
                
                end if;
                

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Entry_Id AS Result_Extra_Key;
                
                
			-- end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m002_commission_item
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and Entry_Id = var_Entry_Id
			and MPPI_Id = var_MPPI_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
