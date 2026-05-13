-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDeductions_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDeductions_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_Deductions_Id VARCHAR(45),
    var_Deduction_Data LONGTEXT,
    var_No_Of_Installments INT,
    var_UserType_Id VARCHAR(45),
    var_UserName_Id VARCHAR(45),
    var_RequestType_Id VARCHAR(45),
    var_Amount VARCHAR(45),
    var_EntryDate VARCHAR(45),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45)
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
			
            DELETE FROM t033_deductions_item
            WHERE Org_Id = var_Org_Id
            AND Deductions_Id = var_Deductions_Id;
			
			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_deduction;
			CREATE TEMPORARY TABLE temp_deduction (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                Deductions_Id VARCHAR(45),
				Deduction_Date DATETIME, 
				Deduction_Amount DECIMAL(10,2), 
                Is_Deducted INT,
                MusterCycle_StartDate DATETIME,
                MusterCycle_EndDate DATETIME
			);
                    
			set @Current_Datetime = (select Entry_Date from t033_deductions_header where Deductions_Id = var_Deductions_Id 
			and Org_Id =var_Org_Id);
            -- set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set @Request_User_Type =( select Request_User_Type from t033_deductions_header where Org_Id = var_Org_Id and Deductions_Id =var_Deductions_Id);
            
            if(@Request_User_Type = 'Farmer')then
            
            set @MCC_Id = (SELECT mu04.MCC_Id FROM t033_deductions_header  t033
					inner join mu04_farmer mu04 on t033.Org_Id =mu04.Org_Id 
					and t033.Request_User_Id =mu04.Farmer_Id
					where t033.Deductions_Id = var_Deductions_Id
					and t033.Request_User_Type = 'Farmer'
					and t033.Org_Id = var_Org_Id);
            
            elseif(@Request_User_Type = 'Agent')then
             
             set @MCC_Id =( select MCC_Id from t033_deductions_header where Org_Id = var_Org_Id and Deductions_Id =var_Deductions_Id);
            
            end if;
            
            
                    
			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
                
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
			
            set Year_Id = (select right(left(curdate(),4),(2)));
			
            SET row_count := extractValue(var_Deduction_Data,'count(//Deduction/DeductionItem)');
			WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Deduction/DeductionItem[', k, ']');
                    
					Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
                    
						if(@MusterType = 1)then 
							
							Set @MusterCycle_StartDate = extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'));
							set @MusterCycle_EndDate =  extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'));
							
						elseif(@MusterType = 7) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-07');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-08');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-14');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
							
							end if;
								
						elseif(@MusterType = 15) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
							
							else 
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
							
							end if;
								
						elseif(@MusterType = 5) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-05');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-06');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-10');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-20');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-25');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
						
							end if;
							
						elseif(@MusterType = 10) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-10');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-20');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
						
							end if;
						
						elseif(@MusterType = 30) then 
								
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
							set @MusterCycle_EndDate =  LAST_DAY(date(@Current_Datetime));
								
						end if;
					INSERT INTO temp_deduction VALUES (
						k,
						var_Org_Id,
                        New_Entry_Id,
                        var_Deductions_Id,
						CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE),
						CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionAmount')) AS DECIMAL(10,2)),
                        0,
                        @MusterCycle_StartDate,
						@MusterCycle_EndDate
						-- CAST(extractValue(var_Deduction_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED)
					);
			END WHILE;
            
				
			-- Save Data in t033_deductions_item table from temp table
			INSERT INTO t033_deductions_item(
				Org_Id, Entry_Id,Deductions_Id, Deduction_Date, 
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			)
			SELECT Org_Id,Entry_Id, Deductions_Id, Deduction_Date,
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			FROM temp_deduction;  
            
                        
            /*
            SET New_Deducted_Amount = (
				SELECT SUM(Deduction_Amount)
                FROM temp_deduction
                WHERE Is_Deducted = 1
            );
            
            
            SET New_Installment_Count = (
				SELECT COUNT(Is_Deducted)
                FROM temp_deduction
            );
            */
            
			-- Drop temp table
			DROP TEMPORARY TABLE temp_deduction;
			
            -- Update Deductions Header
            UPDATE t033_deductions_header
            SET 
            -- Amount_Deducted = New_Deducted_Amount,
            -- Balance = (Total_Amount - New_Deducted_Amount),
            No_Of_Installments = var_No_Of_Installments
            WHERE Deductions_Id = var_Deductions_Id;
            
            -- check if we need to close entry in header table
            /*
            SET Header_Total_Amount = (
				SELECT Total_Amount
                FROM t033_deductions_header
                WHERE Deductions_Id = var_Deductions_Id
            );
            
            SET Header_Balance = (
				SELECT Balance
                FROM t033_deductions_header
                WHERE Deductions_Id = var_Deductions_Id
            );
            
            SET Header_Amount_Deducted = (
				SELECT Amount_Deducted
                FROM t033_deductions_header
                WHERE Deductions_Id = var_Deductions_Id
            );
            
            IF(Header_Total_Amount = Header_Amount_Deducted AND Header_Balance = 0.0) THEN
            BEGIN
				UPDATE t033_deductions_header
                SET Is_Closed = 1
                WHERE Deductions_Id = var_Deductions_Id;
                
                SELECT 1 AS Result_Id,
				'Closed' AS Result_Description,
				var_Deductions_Id AS Result_Extra_Key;
            END;
            ELSE 
            BEGIN
				SELECT 1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Deductions_Id AS Result_Extra_Key;
            END;
            END IF;
            */
            SELECT 1 AS Result_Id,
				'Created' AS Result_Description,
				var_Deductions_Id AS Result_Extra_Key;
            
            
    END;
    -- Updating Entries
    ELSEIF(var_Method_Name = 'Update') THEN 
    BEGIN
		Declare Year_Id varchar(10);
		Declare New_Entry_Id varchar(20);
    
		-- drop rows with Is_Deducted values = 0
        DELETE FROM t033_deductions_item
            WHERE Org_Id = var_Org_Id
            AND Deductions_Id = var_Deductions_Id
            AND Is_Deducted = 0;
        
			set @Current_Datetime = (select Entry_Date from t033_deductions_header where Deductions_Id = var_Deductions_Id 
			and Org_Id =var_Org_Id);
			-- set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
            
            set Year_Id = (select right(left(curdate(),4),(2)));
            
            set @Request_User_Type =( select Request_User_Type from t033_deductions_header where Org_Id = var_Org_Id and Deductions_Id =var_Deductions_Id);
            
            if(@Request_User_Type = 'Farmer')then
            
            set @MCC_Id = (SELECT mu04.MCC_Id FROM t033_deductions_header  t033
					inner join mu04_farmer mu04 on t033.Org_Id =mu04.Org_Id 
					and t033.Request_User_Id =mu04.Farmer_Id
					where t033.Deductions_Id = var_Deductions_Id
					and t033.Request_User_Type = 'Farmer'
					and t033.Org_Id = var_Org_Id);
            
            elseif(@Request_User_Type = 'Agent')then
             
             set @MCC_Id =( select MCC_Id from t033_deductions_header where Org_Id = var_Org_Id and Deductions_Id =var_Deductions_Id);
            
            end if;
                    
			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
                
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
				
        
        -- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_deduction;
			CREATE TEMPORARY TABLE temp_deduction (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                Deductions_Id VARCHAR(45),
				Deduction_Date DATETIME, 
				Deduction_Amount DECIMAL(10,2), 
                Is_Deducted INT,
                MusterCycle_StartDate DATETIME,
                MusterCycle_EndDate DATETIME
			);
			SET row_count := extractValue(var_Deduction_Data,'count(//Deduction/DeductionItem)');
			WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Deduction/DeductionItem[', k, ']');
                    
                    Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
                    
                    if(@MusterType = 1)then 
							
							Set @MusterCycle_StartDate = @Current_Datetime;
							set @MusterCycle_EndDate =  @Current_Datetime;
							
						elseif(@MusterType = 7) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-07');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-08');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-14');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
								
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
							
							end if;
								
						elseif(@MusterType = 15) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
							
							else 
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
							
							end if;
								
						elseif(@MusterType = 5) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-05');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-06');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-10');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-15');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-20');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-25');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-16');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
						
							end if;
							
						elseif(@MusterType = 10) then 
								
							if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-10');
							
							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
						
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-11');
								set @MusterCycle_EndDate =  DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-20');

							elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
							
								Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-21');
								set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
						
							end if;
						
						elseif(@MusterType = 30) then 
								
							Set @MusterCycle_StartDate = DATE_FORMAT(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))), '%Y-%m-01');
							set @MusterCycle_EndDate =  LAST_DAY(date(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate'))));
								
						end if;
                
                    
						INSERT INTO temp_deduction VALUES (
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/Index')) AS UNSIGNED),
							var_Org_Id,
                            New_Entry_Id,
							var_Deductions_Id,
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE),
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionAmount')) AS DECIMAL(10,2)),
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED),
                            @MusterCycle_StartDate,
							@MusterCycle_EndDate
						);					
			END WHILE;
            
				
			-- Save Data in t033_deductions_item table from temp table
            -- insert rows with is_deducted = 0
			INSERT INTO t033_deductions_item(
				Org_Id,Entry_Id, Deductions_Id, Deduction_Date, 
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			)
			SELECT Org_Id,Entry_Id, Deductions_Id, Deduction_Date,
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			FROM temp_deduction
            WHERE Is_Deducted = 0
            AND Org_Id = var_Org_Id; 
        
			-- Drop temp table
			DROP TEMPORARY TABLE temp_deduction;
        
        
			-- update no of installments in header table
            -- Update Deductions Header
            UPDATE t033_deductions_header
            SET No_Of_Installments = var_No_Of_Installments
            WHERE Deductions_Id = var_Deductions_Id;
        
			SELECT 1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Deductions_Id AS Result_Extra_Key;
        
    END;
	ELSEIF(var_Method_Name = 'Insert') THEN 
    begin 
		DECLARE New_Deductions_Header_Id VARCHAR(45);
		DECLARE Year_Id VARCHAR(10);
		
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Header_Id);
        
        
        if(var_UserType_Id = 'Agent') then
        
			INSERT INTO t033_deductions_header(
					Org_Id, Deductions_Id, Entry_Date, 
					Request_User_Type, Request_User_Id,MCC_Id,
					Request_Type, Total_Amount, 
					Amount_Deducted, Balance, 
					Is_Closed, No_Of_Installments, 
					CreatedBy_Id, CreatedBy_Name 
				)
				VALUES(
					var_Org_Id, New_Deductions_Header_Id, var_EntryDate,
					var_UserType_Id, var_UserName_Id,var_UserName_Id,
					var_RequestType_Id, var_Amount,
					0, var_Amount,
					0, 0,
					var_User_Id, var_User_Name
				);
                
		elseif(var_UserType_Id = 'Farmer') then
        
        set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_UserName_Id);
        
			INSERT INTO t033_deductions_header(
					Org_Id, Deductions_Id, Entry_Date, 
					Request_User_Type, Request_User_Id,MCC_Id,
					Request_Type, Total_Amount, 
					Amount_Deducted, Balance, 
					Is_Closed, No_Of_Installments, 
					CreatedBy_Id, CreatedBy_Name 
				)
				VALUES(
					var_Org_Id, New_Deductions_Header_Id, var_EntryDate,
					var_UserType_Id, var_UserName_Id,@MCC_Id,
					var_RequestType_Id, var_Amount,
					0, var_Amount,
					0, 0,
					var_User_Id, var_User_Name
				);
                
		elseif(var_UserType_Id = 'Transporter') then
        
			INSERT INTO t033_deductions_header(
				Org_Id, Deductions_Id, Entry_Date, 
				Request_User_Type, Request_User_Id,
				Request_Type, Total_Amount, 
				Amount_Deducted, Balance, 
				Is_Closed, No_Of_Installments, 
				CreatedBy_Id, CreatedBy_Name 
			)
			VALUES(
				var_Org_Id, New_Deductions_Header_Id, var_EntryDate,
				var_UserType_Id, var_UserName_Id,
				var_RequestType_Id, var_Amount,
				0, var_Amount,
				0, 0,
				var_User_Id, var_User_Name
			);
            
        end if;
			
		SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		New_Deductions_Header_Id AS Result_Extra_Key;
    
    end;
	elseif (var_Method_Name = 'ExcelUpload') then
		begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Deductions_Id varchar(20);
            Declare New_Entry_Id varchar(20);
            SET SQL_SAFE_UPDATES = 0;
            
            DROP TEMPORARY TABLE IF EXISTS temp_deduction_header;
			CREATE TEMPORARY TABLE temp_deduction_header (
				PKeyRowNum int, 
                Farmer_Code VARCHAR(20),
                Entry_Date datetime,
				Amount DECIMAL(20,2),  
                Status longtext
			);
            
            SET row_count := extractValue(var_Deduction_Data,'count(//Deductions/Farmer)');
			
            WHILE k < row_count DO
				set Set_Farmer_Id ='';
                set @MCC_Farmer_Code ='';
                set @EntryDate ='';
                set @Amount ='';
				SET k := k + 1;
				SET xpath := concat('//Deductions/Farmer[', k, ']');
                
                set Year_Id = (select right(left(curdate(),4),(2)));
                
                select Farmer_Id into Set_Farmer_Id from mu04_farmer where Org_Id = var_Org_Id
				and MCC_Farmer_Code = extractValue(var_Deduction_Data, concat(xpath,'/MCC_Farmer_Code'))
				and MCC_Id = var_UserName_Id;
                
              
                set @MCC_Farmer_Code =extractValue(var_Deduction_Data, concat(xpath,'/MCC_Farmer_Code'));
                set @EntryDate = extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'));
                set @Amount = extractValue(var_Deduction_Data, concat(xpath,'/Amount'));
                
                if(Set_Farmer_Id is not null and Set_Farmer_Id <> '') then
 
			
					if exists(select Deductions_Id from t033_deductions_header where 
						Org_Id = var_Org_Id 
						and MCC_Id = var_UserName_Id 
                        and Entry_Date = extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) 
						and Request_User_Id = Set_Farmer_Id 
                        and Request_User_Type = var_UserType_Id
                        and Total_Amount = extractValue(var_Deduction_Data, concat(xpath,'/Amount')) 
						) then
                        
                        
                        INSERT INTO temp_deduction_header(
							Farmer_Code,Entry_Date,Amount,Status) 
						VALUES (
                        @MCC_Farmer_Code,
                        @EntryDate,
                        @Amount,
                        'Duplicate'
                        );
				
				else
                
              
						Call USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Id );
						Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
						INSERT INTO t033_deductions_header(
						Org_Id, Deductions_Id, Entry_Date, 
						Request_User_Type, Request_User_Id,MCC_Id,
						Request_Type, Total_Amount, 
						Amount_Deducted, Balance, 
						Is_Closed, No_Of_Installments, 
						CreatedBy_Id, CreatedBy_Name 
						)
						VALUES(
							var_Org_Id, New_Deductions_Id,
							extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')),
							var_UserType_Id,Set_Farmer_Id, var_UserName_Id,
							var_RequestType_Id,  
							extractValue(var_Deduction_Data, concat(xpath,'/Amount')),
							0,  
							extractValue(var_Deduction_Data, concat(xpath,'/Amount')),
							0, 1,
							var_User_Id, var_User_Name
						);

					  
						set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = var_UserName_Id and is_deleted = 0 and 
						date(Applicable_Date) <= date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')))
						order by Applicable_Date desc limit 1 ) ;
							
						Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
							
						set @Current_Datetime =  extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'));
						if(@MusterType = 1)then 
								
								Set @MusterCycle_StartDate = @Current_Datetime;
								set @MusterCycle_EndDate =  @Current_Datetime;
								
							elseif(@MusterType = 7) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 7 ) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-07');
									
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 8 AND 14) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-08');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-14');

								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 15 AND 21) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 16 AND 31) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))));
								
								end if;
									
							elseif(@MusterType = 15) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 15 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
								
								else 
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))));
								
								end if;
									
							elseif(@MusterType = 5) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 5 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-05');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 6 AND 10) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-06');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-10');

								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 11 AND 15) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-15');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 16 AND 20 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-20');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 21 AND 25 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-25');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 26 AND 31 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))));
							
								end if;
								
							elseif(@MusterType = 10) then 
									
								if (DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 1 AND 10 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-10');
								
								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 11 AND 20) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-20');

								elseif(DATE_FORMAT(CAST(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')) AS DATE), '%d') BETWEEN 21 AND 31) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-21');
									set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))));
							
								end if;
							
							elseif(@MusterType = 30) then 
									
								Set @MusterCycle_StartDate = DATE_FORMAT( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))), '%Y-%m-01');
								set @MusterCycle_EndDate =  LAST_DAY( date(extractValue(var_Deduction_Data, concat(xpath,'/EntryDate'))));
									
							end if;
						
						
						
						INSERT INTO t033_deductions_item(
						Org_Id,Entry_Id,Deductions_Id,Deduction_Date,
						Deduction_Amount,Is_Deducted,
						MusterCycle_StartDate,MusterCycle_EndDate
						)
						VALUES (
								var_Org_Id,
                                New_Entry_Id,
								New_Deductions_Id,
								extractValue(var_Deduction_Data, concat(xpath,'/EntryDate')),
								extractValue(var_Deduction_Data, concat(xpath,'/Amount')),
								0,
								@MusterCycle_StartDate,
								@MusterCycle_EndDate
							);	
							
							INSERT INTO temp_deduction_header(
								Farmer_Code,Entry_Date,Amount,Status) 
							VALUES (
							@MCC_Farmer_Code,
							@EntryDate,
							@Amount,
							'Success'
							);
				   
				end if;
                
                else
                    
                    INSERT INTO temp_deduction_header(
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
            ,Amount,Status from temp_deduction_header;
            
        end;
	elseif (var_Method_Name = 'UpdateAmount') then
		begin
			Update t033_deductions_item
			set 
            Deduction_Amount = var_Amount
			where Org_Id = var_Org_Id 
            and Deductions_Id = var_Deductions_Id
            and Entry_Id = var_Deduction_Data;
            
            SELECT 1 AS Result_Id, 
			'UpdateAmount' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
				delete from t033_deductions_header
				where Org_Id = var_Org_Id 
				and Deductions_Id = var_Deductions_Id;   
				
				delete from t033_deductions_item
				where Org_Id = var_Org_Id 
				and Deductions_Id = var_Deductions_Id;  
				
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't033_deductions_header', var_Deductions_Id, '', '', 
				var_User_Id, var_User_Name);

				SELECT 1 AS Result_Id, 
				'Deleted' AS Result_Description, 
				var_Deductions_Id AS Result_Extra_Key;
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
