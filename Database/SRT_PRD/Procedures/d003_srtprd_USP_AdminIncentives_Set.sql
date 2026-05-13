-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentives_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentives_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_Incentives_Id VARCHAR(45),
    var_Incentive_Data LONGTEXT,
    var_No_Of_Installments INT,
    var_UserType_Id VARCHAR(45),
    var_UserName_Id VARCHAR(45),
    var_RequestType_Id VARCHAR(45),
    var_Amount VARCHAR(45),
    var_EntryDate VARCHAR(45),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45),
    var_Remarks text
)
BEGIN
	DECLARE k INT UNSIGNED DEFAULT 0;
	DECLARE row_count INT UNSIGNED;
	DECLARE xpath TEXT;
    Declare Year_Id varchar(10);
	Declare New_Entry_Id varchar(20);
            
    -- DECLARE New_Deducted_Amount DECIMAL(10,2);
    -- DECLARE New_Installment_Count INT;
    -- DECLARE Header_Total_Amount DECIMAL(10,2);
    -- DECLARE Header_Balance DECIMAL(10,2);
	-- DECLARE Header_Amount_Deducted DECIMAL(10,2);
    SET SESSION sql_require_primary_key = 0;
	IF(var_Method_Name = 'Create') THEN
    BEGIN
			
            DELETE FROM t042_incentives_item
            WHERE Org_Id = var_Org_Id
            AND Incentives_Id = var_Incentives_Id;
			
			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_incentive;
			CREATE TEMPORARY TABLE temp_incentive (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                Incentives_Id VARCHAR(45),
				Incentive_Date DATETIME, 
				Incentive_Amount DECIMAL(10,2), 
                Is_Paid INT,
                MusterCycle_StartDate DATETIME,
                MusterCycle_EndDate DATETIME
			);
                    
			
            set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set @Request_User_Type =( select Request_User_Type from t042_incentives_header where Org_Id = var_Org_Id and Incentives_Id =var_Incentives_Id);
            
            if(@Request_User_Type = 'Farmer')then
				set @MCC_Id = (SELECT mu04.MCC_Id FROM t042_incentives_header  t042
				inner join mu04_farmer mu04 on t042.Org_Id =mu04.Org_Id 
				and t042.Request_User_Id =mu04.Farmer_Id
				where t042.Incentives_Id = var_Incentives_Id
				and t042.Request_User_Type = 'Farmer'
				and t042.Org_Id = var_Org_Id);
            
            elseif(@Request_User_Type = 'Agent')then
				set @MCC_Id =( select MCC_Id from t042_incentives_header where Org_Id = var_Org_Id and Incentives_Id =var_Incentives_Id);
            end if;

			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
                
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
			
            set Year_Id = (select right(left(curdate(),4),(2)));
			
            SET row_count := extractValue(var_Incentive_Data,'count(//Incentive/IncentiveItem)');
			WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Incentive/IncentiveItem[', k, ']');
                    
					Call USP_Number_Range ('t042_incentives_item', Year_Id, 'T042A', '', New_Entry_Id );
						if(@MusterType = 1)then 
							
							Set @MusterCycle_StartDate = @Current_Datetime;
							set @MusterCycle_EndDate =  @Current_Datetime;
							
						elseif(@MusterType = 7) then 
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
							
							end if;
						elseif(@MusterType = 15) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
							
							else 
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
							
							end if;
								
						elseif(@MusterType = 5) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
						
							end if;
							
						elseif(@MusterType = 10) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
						
							end if;
						
						elseif(@MusterType = 30) then 
								
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
								
						end if;
                        
						INSERT INTO temp_incentive VALUES (
							k,
							var_Org_Id,
							New_Entry_Id,
							var_Incentives_Id,
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE),
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveAmount')) AS DECIMAL(10,2)),
							0,
							@MusterCycle_StartDate,
							@MusterCycle_EndDate

					);
			END WHILE;

			-- Save Data in t042_incentives_item table from temp table
			INSERT INTO t042_incentives_item(
				Org_Id, Entry_Id,Incentives_Id, Incentive_Date, 
				Incentive_Amount, Is_Paid,MusterCycle_StartDate,MusterCycle_EndDate
			)
			SELECT Org_Id,Entry_Id, Incentives_Id, Incentive_Date,
				Incentive_Amount, Is_Paid,MusterCycle_StartDate,MusterCycle_EndDate
			FROM temp_incentive;  

			-- Drop temp table
			DROP TEMPORARY TABLE temp_incentive;
			
            -- Update Incentives Header
            UPDATE t042_incentives_header
            SET 
            No_Of_Installments = var_No_Of_Installments
            WHERE Incentives_Id = var_Incentives_Id;
            
            
            SELECT 1 AS Result_Id,
			'Created' AS Result_Description,
			var_Incentives_Id AS Result_Extra_Key;
            
            
    END;
    -- Updating Entries
    ELSEIF(var_Method_Name = 'Update') THEN 
    BEGIN
		Declare Year_Id varchar(10);
		Declare New_Entry_Id varchar(20);
    
		-- drop rows with Is_Paid values = 0
        DELETE FROM t042_incentives_item
            WHERE Org_Id = var_Org_Id
            AND Incentives_Id = var_Incentives_Id
            AND Is_Paid = 0;
        
			set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set Year_Id = (select right(left(curdate(),4),(2)));
            
            set @Request_User_Type =( select Request_User_Type from t042_incentives_item where Org_Id = var_Org_Id and Incentives_Id =var_Incentives_Id);
            
            if(@Request_User_Type = 'Farmer')then
            
            set @MCC_Id = (SELECT mu04.MCC_Id FROM t042_incentives_item  t042
					inner join mu04_farmer mu04 on t042.Org_Id =mu04.Org_Id 
					and t042.Request_User_Id =mu04.Farmer_Id
					where t042.Incentives_Id = var_Incentives_Id
					and t042.Request_User_Type = 'Farmer'
					and t042.Org_Id = var_Org_Id);
            
            elseif(@Request_User_Type = 'Agent')then
             
             set @MCC_Id =( select MCC_Id from t042_incentives_item where Org_Id = var_Org_Id and Incentives_Id =var_Incentives_Id);
            
            end if;
                    
			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
                
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
				
        
        -- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_incentive;
			CREATE TEMPORARY TABLE temp_incentive (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                Incentives_Id VARCHAR(45),
				Incentive_Date DATETIME, 
				Incentive_Amount DECIMAL(10,2), 
                Is_Paid INT,
                MusterCycle_StartDate DATETIME,
                MusterCycle_EndDate DATETIME
			);
			SET row_count := extractValue(var_Incentive_Data,'count(//Incentive/IncentiveItem)');
			WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Incentive/IncentiveItem[', k, ']');
                    
                    Call USP_Number_Range ('t042_incentives_item', Year_Id, 'T042A', '', New_Entry_Id );
                    
                    if(@MusterType = 1)then 
							
							Set @MusterCycle_StartDate = @Current_Datetime;
							set @MusterCycle_EndDate =  @Current_Datetime;
							
						elseif(@MusterType = 7) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
							
							end if;
								
						elseif(@MusterType = 15) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
							
							else 
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
							
							end if;
								
						elseif(@MusterType = 5) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
						
							end if;
							
						elseif(@MusterType = 10) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

							elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
								set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
						
							end if;
						
						elseif(@MusterType = 30) then 
								
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
								
						end if;
                
                    
						INSERT INTO temp_incentive VALUES (
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/Index')) AS UNSIGNED),
							var_Org_Id,
                            New_Entry_Id,
							var_Incentives_Id,
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveDate')) AS DATE),
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/IncentiveAmount')) AS DECIMAL(10,2)),
							CAST(extractValue(var_Incentive_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED),
                            @MusterCycle_StartDate,
							@MusterCycle_EndDate
						);					
			END WHILE;
            
				
			-- Save Data in t042_incentives_item table from temp table
            -- insert rows with Is_Paid = 0
			INSERT INTO t042_incentives_item(
				Org_Id,Entry_Id, Incentives_Id, Incentive_Date, 
				Incentive_Amount, Is_Paid,MusterCycle_StartDate,MusterCycle_EndDate
			)
			SELECT Org_Id,Entry_Id, Incentives_Id, Incentive_Date,
				Incentive_Amount, Is_Paid,MusterCycle_StartDate,MusterCycle_EndDate
			FROM temp_incentive
            WHERE Is_Paid = 0
            AND Org_Id = var_Org_Id; 
        
			-- Drop temp table
			DROP TEMPORARY TABLE temp_incentive;
        
        
			-- update no of installments in header table
            -- Update Incentives Header
            UPDATE t042_incentives_item
            SET No_Of_Installments = var_No_Of_Installments
            WHERE Incentives_Id = var_Incentives_Id;
        
			SELECT 1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Incentives_Id AS Result_Extra_Key;
        
    END;
	ELSEIF(var_Method_Name = 'Insert') THEN 
    begin 
		DECLARE New_Incentives_Header_Id VARCHAR(45);
		DECLARE Year_Id VARCHAR(10);
		
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t042_incentives_header', Year_Id, 'T042', '', New_Incentives_Header_Id);
        
        
        if(var_UserType_Id = 'Agent') then
        
			INSERT INTO t042_incentives_header(
					Org_Id, Incentives_Id, Entry_Date, 
					Request_User_Type, Request_User_Id,MCC_Id,
					Request_Type, Total_Amount, 
					Amount_Paid, Balance, 
					Is_Closed, No_Of_Installments, 
					CreatedBy_Id, CreatedBy_Name 
				)
				VALUES(
					var_Org_Id, New_Incentives_Header_Id, var_EntryDate,
					var_UserType_Id, var_UserName_Id,var_UserName_Id,
					var_RequestType_Id, var_Amount,
					0, var_Amount,
					0, 0,
					var_User_Id, var_User_Name
				);
                
		elseif(var_UserType_Id = 'Farmer') then
        
			set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_UserName_Id);
        
			INSERT INTO t042_incentives_header(
					Org_Id, Incentives_Id, Entry_Date, 
					Request_User_Type, Request_User_Id,MCC_Id,
					Request_Type, Total_Amount, 
					Amount_Paid, Balance, 
					Is_Closed, No_Of_Installments, 
					CreatedBy_Id, CreatedBy_Name 
				)
				VALUES(
					var_Org_Id, New_Incentives_Header_Id, var_EntryDate,
					var_UserType_Id, var_UserName_Id,@MCC_Id,
					var_RequestType_Id, var_Amount,
					0, var_Amount,
					0, 0,
					var_User_Id, var_User_Name
				);
                
		elseif(var_UserType_Id = 'Transporter') then
        
			INSERT INTO t042_incentives_header(
				Org_Id, Incentives_Id, Entry_Date, 
				Request_User_Type, Request_User_Id,
				Request_Type, Total_Amount, 
				Amount_Paid, Balance, 
				Is_Closed, No_Of_Installments, 
				CreatedBy_Id, CreatedBy_Name 
			)
			VALUES(
				var_Org_Id, New_Incentives_Header_Id, var_EntryDate,
				var_UserType_Id, var_UserName_Id,
				var_RequestType_Id, var_Amount,
				0, var_Amount,
				0, 0,
				var_User_Id, var_User_Name
			);
            
        end if;
			
		SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		New_Incentives_Header_Id AS Result_Extra_Key;
    
    end;
	elseif (var_Method_Name = 'ExcelUpload') then
		begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Incentives_Id varchar(20);
            Declare New_Entry_Id varchar(20);
            SET SQL_SAFE_UPDATES = 0;
            
            DROP TEMPORARY TABLE IF EXISTS temp_incentive_header;
			CREATE TEMPORARY TABLE temp_incentive_header (
				PKeyRowNum int, 
                Farmer_Code VARCHAR(20),
                Entry_Date datetime,
				Amount DECIMAL(20,2),  
                Status longtext
			);
            
            SET row_count := extractValue(var_Incentive_Data,'count(//Incentives/Farmer)');
			
            WHILE k < row_count DO
				set Set_Farmer_Id ='';
                set @MCC_Farmer_Code ='';
                set @EntryDate ='';
                set @Amount ='';
				SET k := k + 1;
				SET xpath := concat('//Incentives/Farmer[', k, ']');
                
                set Year_Id = (select right(left(curdate(),4),(2)));
                
                select Farmer_Id into Set_Farmer_Id from mu04_farmer where Org_Id = var_Org_Id
				and MCC_Farmer_Code = extractValue(var_Incentive_Data, concat(xpath,'/MCC_Farmer_Code'))
				and MCC_Id = var_UserName_Id;
                
              
                set @MCC_Farmer_Code =extractValue(var_Incentive_Data, concat(xpath,'/MCC_Farmer_Code'));
                set @EntryDate = extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'));
                set @Amount = extractValue(var_Incentive_Data, concat(xpath,'/Amount'));
                
                if(Set_Farmer_Id is not null and Set_Farmer_Id <> '') then
 
			
					if exists(select Incentives_Id from t042_incentives_item where 
						Org_Id = var_Org_Id 
						and MCC_Id = var_UserName_Id 
                        and Entry_Date = extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) 
						and Request_User_Id = Set_Farmer_Id 
                        and Request_User_Type = var_UserType_Id
                        and Total_Amount = extractValue(var_Incentive_Data, concat(xpath,'/Amount')) 
						) then
                        
                        
                        INSERT INTO temp_incentive_header(
							Farmer_Code,Entry_Date,Amount,Status) 
						VALUES (
                        @MCC_Farmer_Code,
                        @EntryDate,
                        @Amount,
                        'Duplicate'
                        );
				
				else
                
              
						Call USP_Number_Range ('t042_incentives_header', Year_Id, 'T042', '', New_Incentives_Id );
						Call USP_Number_Range ('t042_incentives_item', Year_Id, 'T042A', '', New_Entry_Id );
						INSERT INTO t042_incentives_header(
						Org_Id, Incentives_Id, Entry_Date, 
						Request_User_Type, Request_User_Id,MCC_Id,
						Request_Type, Total_Amount, 
						Amount_Deducted, Balance, 
						Is_Closed, No_Of_Installments, 
						CreatedBy_Id, CreatedBy_Name 
						)
						VALUES(
							var_Org_Id, New_Incentives_Id,
							extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')),
							var_UserType_Id,Set_Farmer_Id, var_UserName_Id,
							var_RequestType_Id,  
							extractValue(var_Incentive_Data, concat(xpath,'/Amount')),
							0,  
							extractValue(var_Incentive_Data, concat(xpath,'/Amount')),
							0, 1,
							var_User_Id, var_User_Name
						);

					  
						set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = var_UserName_Id and is_deleted = 0 and 
						date(Applicable_Date) <= date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')))
						order by Applicable_Date desc limit 1 ) ;
							
						Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
							
						set @Current_Datetime =  extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'));
						if(@MusterType = 1)then 
								
								Set @MusterCycle_StartDate = @Current_Datetime;
								set @MusterCycle_EndDate =  @Current_Datetime;
								
							elseif(@MusterType = 7) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-07');
									
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-08');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-14');

								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))));
								
								end if;
									
							elseif(@MusterType = 15) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
								
								else 
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))));
								
								end if;
									
							elseif(@MusterType = 5) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-05');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-06');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-10');

								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-20');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-25');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))));
							
								end if;
								
							elseif(@MusterType = 10) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-10');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-20');

								elseif(DATE_FORMAT(CAST(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))));
							
								end if;
							
							elseif(@MusterType = 30) then 
									
								Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Incentive_Data, concat(xpath,'/EntryDate'))));
									
							end if;
						
						
						
						INSERT INTO t042_incentives_item(
						Org_Id,Entry_Id,Incentives_Id,Incentive_Date,
						Incentive_Amount,Is_Paid,
						MusterCycle_StartDate,MusterCycle_EndDate
						)
						VALUES (
								var_Org_Id,
                                New_Entry_Id,
								New_Incentives_Id,
								extractValue(var_Incentive_Data, concat(xpath,'/EntryDate')),
								extractValue(var_Incentive_Data, concat(xpath,'/Amount')),
								0,
								@MusterCycle_StartDate,
								@MusterCycle_EndDate
							);	
							
							INSERT INTO temp_incentive_header(
								Farmer_Code,Entry_Date,Amount,Status) 
							VALUES (
							@MCC_Farmer_Code,
							@EntryDate,
							@Amount,
							'Success'
							);
				   
				end if;
                
                else
                    
                    INSERT INTO temp_incentive_header(
							Farmer_Code,Entry_Date,Amount,Status) 
						VALUES (
                        @MCC_Farmer_Code,
                        @EntryDate,
                        @Amount,
                        'Error'
                        );
                
                end if;
                
			END WHILE;
            
			/*
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
            */
			select Farmer_Code,
            ifnull(date_format(Entry_Date, '%d %M %Y'),'') as Date
            ,Amount,Status from temp_incentive_header;
            
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
