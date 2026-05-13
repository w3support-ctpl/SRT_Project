-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRebate_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRebate_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(10),
	var_InvoiceData longtext,
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Date varchar(45),
	var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year varchar(20),
    var_Invoice_Id longtext
)
BEGIN
SET SESSION sql_require_primary_key = 0;
SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Create') then
		begin
			Declare Year_Id varchar(10);
            DECLARE New_Entry_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            set Year_Id = (select right(left(curdate(),4),(2)));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
			SET row_count := extractValue(var_InvoiceData,'count(//Rebate/RebateItem)');
			WHILE k < row_count DO
				SET k := k + 1;
				SET xpath := concat('//Rebate/RebateItem[', k, ']');
                
				CALL USP_Number_Range ('t044_rebate', Year_Id, 'T044', '', New_Entry_Id );
				-- Insert new record
				INSERT INTO t044_rebate (Org_Id, Entry_Id, MCC_Id, Entry_Date, Quantity_Ltr, RebateRate,RebateMilkPrice,Is_Posted,Created_On,CreatedBy_Id)
				VALUES (var_Org_Id, New_Entry_Id, 
                extractValue(var_InvoiceData, concat(xpath,'/MCC_Id')),
                -- extractValue(var_InvoiceData, concat(xpath,'/Date')),
                @Current_Datetime,
                extractValue(var_InvoiceData, concat(xpath,'/Quantity')),
                extractValue(var_InvoiceData, concat(xpath,'/Rate')),
                extractValue(var_InvoiceData, concat(xpath,'/Amount')),
                1,
                now(),
                var_User_Id
                );
			
			END WHILE;
            
			SELECT 1 AS Result_Id, 
			'Create' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Update') then  
			begin
				UPDATE t044_rebate
				SET SAP_Document_Id = var_SAP_Document_Id,
				SAP_Document_Year = var_SAP_Document_Year,
				Is_Posted = var_InvoiceData
				WHERE Org_Id = var_Org_Id
                and Is_Posted <> 4
				AND Entry_Id = var_Invoice_Id;
                    
				SELECT 
				1 AS Result_Id,
				'Updated' AS Result_Description,
				var_Org_Id AS Result_Extra_Key;
			end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
