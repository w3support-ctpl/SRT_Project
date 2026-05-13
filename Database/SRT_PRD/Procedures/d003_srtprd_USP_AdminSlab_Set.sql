-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSlab_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSlab_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Slab_Id varchar(20),
	var_Slab_Name varchar(45),
    var_Slab_Type varchar(45),
    var_Slab_Min varchar(20),
	var_Slab_Max varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Slab_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Slab_Id from m014_slab where Org_Id = var_Org_Id and Slab_Name = var_Slab_Name
            and Slab_Type = var_Slab_Type and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Slab Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m014_slab', Year_Id, 'M014', '', New_Slab_Id );
            
				Insert Into m014_slab
                (Org_Id, Slab_Id,Slab_Name,Slab_Type,Slab_Min,Slab_Max,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Slab_Id,var_Slab_Name,var_Slab_Type,var_Slab_Min,var_Slab_Max,
                    var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                    
				Update m014_slab m014
                set 
                m014.Slab_Name = concat(m014.Slab_Max , ' - ', m014.Slab_Min)
                where m014.Org_Id = var_Org_Id and Slab_Id = New_Slab_Id; 
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Slab_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Slab_Id from m014_slab where Org_Id = var_Org_Id and Slab_Name = var_Slab_Name 
			and Slab_Type = var_Slab_Type and Is_Deleted = 0 and Slab_Id <> var_Slab_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Slab Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m014_slab
                set 
                Slab_Name = var_Slab_Name,
                Slab_Type = var_Slab_Type,
                Slab_Min = var_Slab_Min,
                Slab_Max = var_Slab_Max,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id and Slab_Id = var_Slab_Id; 
                
                Update m014_slab m014
                set 
                m014.Slab_Name = concat(m014.Slab_Max , ' - ', m014.Slab_Min)
                where m014.Org_Id = var_Org_Id and Slab_Id = var_Slab_Id; 

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Slab_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m014_slab
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Slab_Id = var_Slab_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Slab_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
