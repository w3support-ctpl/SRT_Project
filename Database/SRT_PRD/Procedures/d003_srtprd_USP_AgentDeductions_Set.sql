-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentDeductions_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentDeductions_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_Deductions_Id VARCHAR(45),
    var_Deduction_Data LONGTEXT,
    var_No_Of_Installments INT,
    var_MCC_Id VARCHAR(45),
    var_Farmer_Id VARCHAR(45),
    var_Amount VARCHAR(45),
    var_Interest VARCHAR(45),
    Var_Profile_Id VARCHAR(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;

	if(var_Method_Name = 'Create') then
		begin
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			Declare Year_Id varchar(10);
            DECLARE New_Deductions_Header_Id VARCHAR(45);
            declare var_Total_Amount VARCHAR(45);
            Declare New_Entry_Id varchar(20);
			
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t033_deductions_header_offline', Year_Id, 'T033', '', New_Deductions_Header_Id);
        
			
            
            set var_Total_Amount = ifnull(var_Amount,0) + ifnull(var_Interest,0);
            
			INSERT INTO t033_deductions_header_offline(
			Org_Id  ,  
			Deductions_Id  ,  
			Entry_Date  , 
			Farmer_Id  , 
			MCC_Id  , 
			Total_Amount  ,
			Amount_Interest  ,
			Amount_Deducted  ,
			Balance  ,
			Is_Closed  , 
			No_Of_Installments  , 
			CreatedBy_Id  , 
			CreatedBy_Name  
			)
			VALUES(
			var_Org_Id  ,  
			New_Deductions_Header_Id  ,  
			now()  , 
			var_Farmer_Id  , 
			var_MCC_Id  , 
			var_Amount  ,
			var_Interest  ,
			0  ,
			var_Total_Amount  ,
			0  , 
			var_No_Of_Installments  ,
			Var_Profile_Id  , 
			""   
			);
            
            DELETE FROM t033_deductions_item_offline
            WHERE Org_Id = var_Org_Id
            AND Deductions_Id = New_Deductions_Header_Id;
            
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
            
            set @Current_Datetime = (select Entry_Date from t033_deductions_header_offline where Deductions_Id = New_Deductions_Header_Id 
			and Org_Id =var_Org_Id);
            
            set @MusterType_Id = (select MusterType_Id from m005_mcc_muster
						where Org_Id = Var_Org_Id
						and MCC_Id = Var_MCC_Id limit 1);
                        
			if(ifnull(@MusterType_Id,'') =''  or @MusterType_Id is null or @MusterType_Id ='')then
			
				set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
				Applicable_Date <= @Current_Datetime
				order by Applicable_Date desc limit 1 ) ;
			
			else
			
				set @MusterType_Id  = @MusterType_Id;
			
			end if;
            
            Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
            
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
                        New_Deductions_Header_Id,
						CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE),
						CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionAmount')) AS DECIMAL(10,2)),
                        0,
                        @MusterCycle_StartDate,
						@MusterCycle_EndDate
						-- CAST(extractValue(var_Deduction_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED)
					);
			END WHILE;
            
            
            INSERT INTO t033_deductions_item_offline(
				Org_Id, Entry_Id,Deductions_Id, Deduction_Date, 
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			)
			SELECT Org_Id,Entry_Id, Deductions_Id, Deduction_Date,
				Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
			FROM temp_deduction;  
            
            DROP TEMPORARY TABLE IF EXISTS temp_deduction;
            
            SELECT 1 AS Result_Id,
			'Created' AS Result_Description,
			New_Deductions_Header_Id AS Result_Extra_Key;

            
            
        end;
	ELSEIF(var_Method_Name = 'Update') THEN 
		BEGIN
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			Declare Year_Id varchar(10);
			Declare New_Entry_Id varchar(20);
            
            DELETE FROM t033_deductions_item_offline
            WHERE Org_Id = var_Org_Id
            AND Deductions_Id = var_Deductions_Id
            AND Is_Deducted = 0;
            
            set @Current_Datetime = (select Entry_Date from t033_deductions_header_offline where Deductions_Id = var_Deductions_Id 
			and Org_Id =var_Org_Id);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
            
            set @MusterType_Id = (select MusterType_Id from m005_mcc_muster
						where Org_Id = Var_Org_Id
						and MCC_Id = Var_MCC_Id limit 1);
                        
			if(ifnull(@MusterType_Id,'') =''  or @MusterType_Id is null or @MusterType_Id ='')then
			
				set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
				Applicable_Date <= @Current_Datetime
				order by Applicable_Date desc limit 1 ) ;
			
			else
			
				set @MusterType_Id  = @MusterType_Id;
			
			end if;
            
            
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
            
            INSERT INTO t033_deductions_item_offline(
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
            
            UPDATE t033_deductions_header_offline
            SET No_Of_Installments = var_No_Of_Installments
            WHERE Deductions_Id = var_Deductions_Id;
        
			SELECT 1 AS Result_Id,
			'Updated' AS Result_Description,
			var_Deductions_Id AS Result_Extra_Key;
            
            
            
		end;
	elseif (var_Method_Name = 'Delete') then
		begin
			set @Is_Deducted = (select t033.Is_Deducted from t033_deductions_item_offline t033
								where t033.Org_Id = var_Org_Id
								and t033.Deductions_Id = var_Deductions_Id
								order by t033.Is_Deducted desc limit 1);
                                
			if(@Is_Deducted = 1 or @Is_Deducted ='1')then
            
				DELETE FROM t033_deductions_item_offline
				WHERE Org_Id = var_Org_Id
				AND Deductions_Id = var_Deductions_Id
				AND Is_Deducted = 0;
                
                set @Result_Description = 'Some of your entries have been generated into payment.';
                
			elseif(@Is_Deducted = 0 or @Is_Deducted ='0' or @Is_Deducted is null or @Is_Deducted = '')then
				
                DELETE FROM t033_deductions_item_offline
				WHERE Org_Id = var_Org_Id
				AND Deductions_Id = var_Deductions_Id;
                
				DELETE FROM t033_deductions_header_offline
				WHERE Org_Id = var_Org_Id
				AND Deductions_Id = var_Deductions_Id;
                
                set @Result_Description = 'Deleted';
			
            end if;
            
			
			SELECT 1 AS Result_Id, 
			@Result_Description AS Result_Description, 
			var_Deductions_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
