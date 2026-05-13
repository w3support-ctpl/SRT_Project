-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRateItem_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRateItem_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Entry_Id varchar(20),
    var_Chart_Id varchar(20),
    var_MilkRateEntryType_Id varchar(20),
    var_Slab_Id varchar(20),
    var_BaseFat varchar(20),
    var_BaseSNF varchar(20),
	var_Amount varchar(20),
	var_Applicable_Date DATETIME,
	var_User_Id varchar(20),
    var_User_Name varchar(45),
    var_Version_No int,
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;

	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Version_No int;
            Declare Today_Date datetime;
            DECLARE Latest_Applicable_Date datetime;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m001_milkrate_item
			WHERE Org_Id = var_Org_Id
			AND Chart_Id = var_Chart_Id
            AND MilkRateEntryType_Id = var_MilkRateEntryType_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
            
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
            elseif exists(select Entry_Id from m001_milkrate_item where Org_Id = var_Org_Id 
					and Chart_Id = var_Chart_Id and Applicable_Date = var_Applicable_Date 
                    and MilkRateEntryType_Id = var_MilkRateEntryType_Id  
                    and Slab_Id = var_Slab_Id and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m001_milkrate_item', Year_Id, 'M002', '', New_Entry_Id );
                
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m001_milkrate_item
				where Org_Id = var_Org_Id 
                and Chart_Id = var_Chart_Id
                and MilkRateEntryType_Id = var_MilkRateEntryType_Id;
            
				Insert Into m001_milkrate_item
                (Org_Id, Entry_Id,Chart_Id,MilkRateEntryType_Id,Slab_Id,
					BaseFat,BaseSNF,Version_No,Amount,Applicable_Date,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Entry_Id,var_Chart_Id,var_MilkRateEntryType_Id,var_Slab_Id,
					var_BaseFat,var_BaseSNF,New_Version_No,var_Amount,var_Applicable_Date,
                    var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name); 
                    
                    
                call USP_AdminUpdateMilkRate_Chart('Update_MilkRateChart', var_Org_Id, var_Chart_Id);
    
				
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Entry_Id AS Result_Extra_Key;
                
                call USP_AdminMilkRate_Auto(var_Org_Id);
                
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        Declare Today_Date datetime;
        DECLARE Latest_Applicable_Date datetime;
        
		set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
        
        SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m001_milkrate_item
			WHERE Org_Id = var_Org_Id
			AND Chart_Id = var_Chart_Id
            AND MilkRateEntryType_Id = var_MilkRateEntryType_Id
			AND Is_Deleted = 0
			and Entry_Id <> var_Entry_Id
			ORDER BY Version_No DESC
			LIMIT 1;
            
		
        if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
        elseif exists(select Entry_Id from m001_milkrate_item where 
					Org_Id = var_Org_Id 
					and Chart_Id = var_Chart_Id 
                    and MilkRateEntryType_Id = var_MilkRateEntryType_Id 
                    and Slab_Id = var_Slab_Id
                    and Version_No = var_Version_No
                    and Applicable_Date = var_Applicable_Date 
                    and Is_Deleted = 0 and Entry_Id <> var_Entry_Id) then
                    
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
                
			else
				Update m001_milkrate_item
                set 
                MilkRateEntryType_Id = var_MilkRateEntryType_Id,
                Slab_Id = var_Slab_Id,
                BaseFat = var_BaseFat,
				BaseSNF = var_BaseSNF,
				Amount = var_Amount,
                Applicable_Date = var_Applicable_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Entry_Id = var_Entry_Id
                and Chart_Id = var_Chart_Id;   
                
                call USP_AdminUpdateMilkRate_Chart('Update_MilkRateChart', var_Org_Id, var_Chart_Id);

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Entry_Id AS Result_Extra_Key;
                
                call USP_AdminMilkRate_Auto(var_Org_Id);
                
                
			end if;
        end;
	elseif (var_Method_Name = 'Update_Date') then
		begin
        
				set @SetApplicable_Date  = (select Applicable_Date from m001_milkrate_item
											where Org_Id = var_Org_Id 
											and Entry_Id = var_Entry_Id
											and Chart_Id = var_Chart_Id limit 1);
        
				Update m001_milkrate_item
                set 
                Applicable_Date = var_Applicable_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                Back_On = NOW(),
                BackBy_Id = var_User_Id,
                BackBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Entry_Id = var_Entry_Id
                and Chart_Id = var_Chart_Id;   
                
                set @Set_MilkRateEntryType_Id  = (select MilkRateEntryType_Id from m001_milkrate_item
										where Org_Id = var_Org_Id 
										and Entry_Id = var_Entry_Id
										and Chart_Id = var_Chart_Id limit 1);
				set @Set_Version_No  = (select Version_No from m001_milkrate_item
										where Org_Id = var_Org_Id 
										and Entry_Id = var_Entry_Id
										and Chart_Id = var_Chart_Id limit 1);

				set @Set_Slab_Id  = (select Slab_Id from m001_milkrate_item
										where Org_Id = var_Org_Id 
										and Entry_Id = var_Entry_Id
										and Chart_Id = var_Chart_Id limit 1);
														
				Update f001_milk_rate
				set 
				Item_Applicable_Date = var_Applicable_Date
				where Org_Id = var_Org_Id 
				and Chart_Id = var_Chart_Id
				and MilkRateEntryType_Id = @Set_MilkRateEntryType_Id
				and ifnull(Slab_Id,'') = ifnull(@Set_Slab_Id,'')
				and Item_Version_No = @Set_Version_No; 

				Update f002_milk_rate_current
				set 
				Item_Applicable_Date = var_Applicable_Date
				where Org_Id = var_Org_Id 
				and Chart_Id = var_Chart_Id
				and MilkRateEntryType_Id = @Set_MilkRateEntryType_Id
				and ifnull(Slab_Id,'') = ifnull(@Set_Slab_Id,'')
				and Item_Version_No = @Set_Version_No;  
                
                -- call USP_AdminUpdateMilkRate_Chart('Update_MilkRateChart', var_Org_Id, var_Chart_Id);
                
                
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				'm001_milkrate_item', var_Chart_Id, var_Entry_Id,concat(@SetApplicable_Date , ' - ' ,var_Applicable_Date), 
				var_User_Id, var_User_Name);
            
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Entry_Id AS Result_Extra_Key;
                
                -- call USP_AdminMilkRate_Auto(var_Org_Id);
                
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m001_milkrate_item
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and Entry_Id = var_Entry_Id
			and Chart_Id = var_Chart_Id;    

			call USP_AdminUpdateMilkRate_Chart('Update_MilkRateChart', var_Org_Id, var_Chart_Id);

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
