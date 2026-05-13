-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterialIssue_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterialIssue_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_Issue_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Issue_Date varchar(20),
    var_Material longtext,
    var_Quantity varchar(255),
    var_Rate varchar(255),
    var_Amount varchar(255),
    var_Is_Paid int,
    var_Is_Active int,
    var_Is_Deleted int,
    var_User_Id VARCHAR(45),
    var_User_Name longtext,
    var_Deduction_Data LONGTEXT,
    var_No_Of_Installments INT,
    var_Interest VARCHAR(45)
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;

	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Issue_Id varchar(20);
			Declare Year_Id varchar(10);
            declare var_Total_Amount VARCHAR(45);
            
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Entry_Id varchar(20);
            
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t106_mcc_material_issue', Year_Id, 'T106', '', New_Issue_Id );
            
            set var_Total_Amount = ifnull(var_Amount,0) + ifnull(var_Interest,0);
            
            Insert Into t106_mcc_material_issue
			(Org_Id,Issue_Id,MCC_Id,Farmer_Id,Issue_Date,
            Material,Quantity,Rate,Amount,Is_Paid,
			Is_Active,Is_Deleted,
			Created_On,CreatedBy_Id,CreatedBy_Name,
            No_Of_Installments,Amount_Interest,Balance)
			value(
			var_Org_Id,New_Issue_Id,var_MCC_Id,var_Farmer_Id,var_Issue_Date,
            var_Material,var_Quantity,var_Rate,var_Amount,var_Is_Paid,
			var_Is_Active,var_Is_Deleted,
			now(),var_User_Id,var_User_Name,
			var_No_Of_Installments,var_Interest,var_Total_Amount);
            
            if(var_Is_Paid = 0 or var_Is_Paid ='0')then
            
            
				DELETE FROM t106_mcc_material_issue_item
				WHERE Org_Id = var_Org_Id
				AND Issue_Id = New_Issue_Id;
				
				-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_deduction;
				CREATE TEMPORARY TABLE temp_deduction (
					PKeyRowNum int, 
					Org_Id VARCHAR(20),
					Entry_Id VARCHAR(45),
					Issue_Id VARCHAR(45),
					Deduction_Date DATETIME, 
					Deduction_Amount DECIMAL(10,2), 
					Is_Deducted INT,
					MusterCycle_StartDate DATETIME,
					MusterCycle_EndDate DATETIME
				);
				
				
				set @Current_Datetime = (select Issue_Date from t106_mcc_material_issue where Issue_Id = New_Issue_Id 
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
						
						Call USP_Number_Range ('t106_mcc_material_issue_item', Year_Id, 'T106A', '', New_Entry_Id );
						
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
							New_Issue_Id,
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE),
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionAmount')) AS DECIMAL(10,2)),
							0,
							@MusterCycle_StartDate,
							@MusterCycle_EndDate
							-- CAST(extractValue(var_Deduction_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED)
						);
				END WHILE;
				
				
				INSERT INTO t106_mcc_material_issue_item(
					Org_Id, Entry_Id,Issue_Id, Date, 
					Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
				)
				SELECT Org_Id,Entry_Id, Issue_Id, Deduction_Date,
					Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
				FROM temp_deduction;  
				
				DROP TEMPORARY TABLE IF EXISTS temp_deduction;
            
            end if;
			
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Issue_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Update') then
		begin
        Declare Duplicate_Flag int;
			Declare Year_Id varchar(10);
            declare var_Total_Amount VARCHAR(45);
            
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Entry_Id varchar(20);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
        
			set var_Total_Amount = ifnull(var_Amount,0) + ifnull(var_Interest,0);
        
			Update t106_mcc_material_issue
			set 
            Farmer_Id = var_Farmer_Id, 
            Issue_Date = var_Issue_Date, 
			Material = var_Material,
			Quantity = var_Quantity, 
            Rate = var_Rate,
			Amount = var_Amount, 
            Is_Paid = var_Is_Paid, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name,
			No_Of_Installments = var_No_Of_Installments,
            Amount_Interest = var_Interest,
            Balance = var_Total_Amount
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
			and Issue_Id = var_Issue_Id;
            
            
            if(var_Is_Paid = 0 or var_Is_Paid ='0')then
            
            
				DELETE FROM t106_mcc_material_issue_item
				WHERE Org_Id = var_Org_Id
				AND Issue_Id = var_Issue_Id
				AND Is_Deducted = 0;
				
				-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_deduction;
				CREATE TEMPORARY TABLE temp_deduction (
					PKeyRowNum int, 
					Org_Id VARCHAR(20),
					Entry_Id VARCHAR(45),
					Issue_Id VARCHAR(45),
					Deduction_Date DATETIME, 
					Deduction_Amount DECIMAL(10,2), 
					Is_Deducted INT,
					MusterCycle_StartDate DATETIME,
					MusterCycle_EndDate DATETIME
				);
				
				
				set @Current_Datetime = (select Issue_Date from t106_mcc_material_issue where Issue_Id = var_Issue_Id 
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
						
						Call USP_Number_Range ('t106_mcc_material_issue_item', Year_Id, 'T106A', '', New_Entry_Id );
						
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
							var_Issue_Id,
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionDate')) AS DATE),
							CAST(extractValue(var_Deduction_Data, concat(xpath,'/DeductionAmount')) AS DECIMAL(10,2)),
							0,
							@MusterCycle_StartDate,
							@MusterCycle_EndDate
							-- CAST(extractValue(var_Deduction_Data, concat(xpath,'/IsDeducted')) AS UNSIGNED)
						);
				END WHILE;
				
				
				INSERT INTO t106_mcc_material_issue_item(
					Org_Id, Entry_Id,Issue_Id, Date, 
					Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
				)
				SELECT Org_Id,Entry_Id, Issue_Id, Deduction_Date,
					Deduction_Amount, Is_Deducted,MusterCycle_StartDate,MusterCycle_EndDate
				FROM temp_deduction;  
				
				DROP TEMPORARY TABLE IF EXISTS temp_deduction;
            
            end if;
			
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Issue_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			set @Is_Deducted = (select t106.Is_Deducted from t106_mcc_material_issue_item t106
								where t106.Org_Id = var_Org_Id
								and t106.Issue_Id = var_Issue_Id
								order by t106.Is_Deducted desc limit 1);
                                
			if(@Is_Deducted = 1 or @Is_Deducted ='1')then
            
				DELETE FROM t106_mcc_material_issue_item
				WHERE Org_Id = var_Org_Id
				AND Issue_Id = var_Issue_Id
				AND Is_Deducted = 0;
                
                set @Result_Description = 'Some of your entries have been generated into payment.';
                
			elseif(@Is_Deducted = 0 or @Is_Deducted ='0' or @Is_Deducted is null or @Is_Deducted = '')then
				
                DELETE FROM t106_mcc_material_issue_item
				WHERE Org_Id = var_Org_Id
				AND Issue_Id = var_Issue_Id;
                
				DELETE FROM t106_mcc_material_issue
				WHERE Org_Id = var_Org_Id
				AND Issue_Id = var_Issue_Id;
                
                set @Result_Description = 'Deleted';
			
            end if;
            

			/*
            Update t106_mcc_material_issue
			set 
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
			and Issue_Id = var_Issue_Id;
            */
			
			SELECT 1 AS Result_Id, 
			@Result_Description AS Result_Description, 
			var_Issue_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
