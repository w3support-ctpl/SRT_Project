-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRateMCC_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRateMCC_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
	var_Chart_Id varchar(20),
    var_Version_No int,
	var_Applicable_Date DATETIME,
    var_MCC_Id longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Version_No int;
            Declare mccArray longtext;
            Declare Today_Date datetime;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date must be greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Version_No from m001_milkrate_mcc_header where Org_Id = var_Org_Id 
					and Chart_Id = var_Chart_Id and Applicable_Date = var_Applicable_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m001_milkrate_mcc_header
				where Org_Id = var_Org_Id 
                and Chart_Id = var_Chart_Id;
            
				Insert Into m001_milkrate_mcc_header
                (Org_Id,Chart_Id,Version_No,Applicable_Date,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id,var_Chart_Id,New_Version_No,var_Applicable_Date,now(),var_User_Id,var_User_Name); 
                
                SET mccArray = var_MCC_Id;
				WHILE LENGTH(mccArray) > 0 DO
					SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
					INSERT INTO m001_milkrate_mcc_item (Org_Id, Chart_Id, Version_No,MCC_Id)
					VALUES (var_Org_Id, var_Chart_Id,New_Version_No, @value);
					SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
				END WHILE;
                
                call USP_AdminMilkRate_Auto(var_Org_Id);
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Version_No AS Result_Extra_Key;
                
                
                
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
        Declare mccArray longtext;
        Declare Today_Date datetime;
        
		set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date must be greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Version_No from m001_milkrate_mcc_header where Org_Id = var_Org_Id 
					and Chart_Id = var_Chart_Id and Applicable_Date = var_Applicable_Date 
                    and Version_No <> var_Version_No) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				Update m001_milkrate_mcc_header
                set 
                Applicable_Date = var_Applicable_Date,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Chart_Id = var_Chart_Id
                and Version_No = var_Version_No;   
                
                DELETE FROM m001_milkrate_mcc_item
					WHERE Org_Id = var_Org_Id 
					AND Chart_Id = var_Chart_Id
					AND Version_No = var_Version_No;
            
                SET mccArray = var_MCC_Id;
				WHILE LENGTH(mccArray) > 0 DO
					SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
					INSERT INTO m001_milkrate_mcc_item (Org_Id, Chart_Id, Version_No,MCC_Id)
					VALUES (var_Org_Id, var_Chart_Id,var_Version_No, @value);
					SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
				END WHILE;
                
                
                call USP_AdminMilkRate_Auto(var_Org_Id);
                

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Version_No AS Result_Extra_Key;
                
                      
                
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
            
            DELETE FROM m001_milkrate_mcc_header
			WHERE Org_Id = var_Org_Id 
            AND Chart_Id = var_Chart_Id
            AND Version_No = var_Version_No;
            
            DELETE FROM m001_milkrate_mcc_item
			WHERE Org_Id = var_Org_Id 
			AND Chart_Id = var_Chart_Id
			AND Version_No = var_Version_No;

		call USP_AdminMilkRate_Auto(var_Org_Id);

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Version_No AS Result_Extra_Key;
            
                 
            
        end;
	elseif (var_Method_Name = 'Update_Date_MCC') then
		begin
        
				set @SetApplicable_Date  = (select Applicable_Date from m001_milkrate_mcc_header
											where Org_Id = var_Org_Id 
											and Version_No = var_Version_No
											and Chart_Id = var_Chart_Id limit 1);
        
				Update m001_milkrate_mcc_header
                set 
                Applicable_Date = var_Applicable_Date,
                Back_On = NOW(),
                BackBy_Id = var_User_Id,
                BackBy_Name = var_User_Name 
                where Org_Id = var_Org_Id 
                and Version_No = var_Version_No
                and Chart_Id = var_Chart_Id;   

				set @Set_Version_No  = (select Version_No from m001_milkrate_mcc_header
										where Org_Id = var_Org_Id 
										and Version_No = var_Version_No
										and Chart_Id = var_Chart_Id limit 1);
														
				Update f001_milk_rate
				set 
				Header_Applicable_Date = var_Applicable_Date
				where Org_Id = var_Org_Id 
				and Chart_Id = var_Chart_Id
				and Header_Version_No = @Set_Version_No; 

				Update f002_milk_rate_current
				set 
				Header_Applicable_Date = var_Applicable_Date
				where Org_Id = var_Org_Id 
				and Chart_Id = var_Chart_Id
				and Header_Version_No = @Set_Version_No;  
                
                
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				'm001_milkrate_mcc_header', var_Chart_Id, var_Version_No,concat(@SetApplicable_Date , ' - ' ,var_Applicable_Date), 
				var_User_Id, var_User_Name);
            
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Chart_Id AS Result_Extra_Key;
                
                
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
