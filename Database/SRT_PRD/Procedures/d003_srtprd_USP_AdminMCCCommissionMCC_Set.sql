-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommissionMCC_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommissionMCC_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_MPPI_Id varchar(20),
    var_Version_No int,
	var_Applicable_Date DATETIME,
    var_MCC_Id longtext
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
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Version_No from m002_commission_mcc_header where Org_Id = var_Org_Id 
					and MPPI_Id = var_MPPI_Id and Applicable_Date = var_Applicable_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m002_commission_mcc_header
				where Org_Id = var_Org_Id 
                and MPPI_Id = var_MPPI_Id;
            
				Insert Into m002_commission_mcc_header
                (Org_Id,MPPI_Id,Version_No,Applicable_Date)
				Values (var_Org_Id,var_MPPI_Id,New_Version_No,var_Applicable_Date); 
                
                SET mccArray = var_MCC_Id;
				WHILE LENGTH(mccArray) > 0 DO
					SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
					INSERT INTO m002_commission_mcc_item (Org_Id, MPPI_Id, Version_No,MCC_Id)
					VALUES (var_Org_Id, var_MPPI_Id,New_Version_No, @value);
					SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
				END WHILE;
                
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
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Version_No from m002_commission_mcc_header where Org_Id = var_Org_Id 
					and MPPI_Id = var_MPPI_Id and Applicable_Date = var_Applicable_Date 
                    and Version_No <> var_Version_No) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				Update m002_commission_mcc_header
                set 
                Applicable_Date = var_Applicable_Date
                where Org_Id = var_Org_Id 
                and MPPI_Id = var_MPPI_Id
                and Version_No = var_Version_No;   
                
                DELETE FROM m002_commission_mcc_item
					WHERE Org_Id = var_Org_Id 
					AND MPPI_Id = var_MPPI_Id
					AND Version_No = var_Version_No;
            
                SET mccArray = var_MCC_Id;
				WHILE LENGTH(mccArray) > 0 DO
					SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
					INSERT INTO m002_commission_mcc_item (Org_Id, MPPI_Id, Version_No,MCC_Id)
					VALUES (var_Org_Id, var_MPPI_Id,var_Version_No, @value);
					SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
				END WHILE;
                

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Version_No AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
            
            DELETE FROM m002_commission_mcc_header
			WHERE Org_Id = var_Org_Id 
            AND MPPI_Id = var_MPPI_Id
            AND Version_No = var_Version_No;
            
            DELETE FROM m002_commission_mcc_item
			WHERE Org_Id = var_Org_Id 
			AND MPPI_Id = var_MPPI_Id
			AND Version_No = var_Version_No;

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Version_No AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Create_MCC') then
		begin
			Declare Duplicate_Flag int;
            Declare Today_Date datetime;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select MPPI_Id from m002_commission_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and Applicable_Date = var_Applicable_Date) then
				
                
                set @MPPI_Name =( select MPPI_Name from m002_commission_mcc m0021
                inner join m002_commission m002 on m002.Org_Id = m0021.Org_Id
                and m002.MPPI_Id = m0021.MPPI_Id
                where m0021.Org_Id = var_Org_Id 
                and m0021.MCC_Id = var_MCC_Id 
                and m0021.Applicable_Date = var_Applicable_Date);
                
              
                SELECT -1 AS Result_Id, 
                 concat('This MCC Assign on this',@MPPI_Name, ' on ',DATE_FORMAT(var_Applicable_Date, '%d %M %Y')) AS Result_Description, 
                '' AS Result_Extra_Key;
            else
                set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m002_commission_mcc', Year_Id, 'M002', '', New_Entry_Id );
				
                set @MPPI_TYpe = (select MPPIType_Id from m002_commission 
									where Org_Id = var_Org_Id
									and  MPPI_Id  = var_MPPI_Id);
                                    
				Insert Into m002_commission_mcc
                (Org_Id,Entry_Id,MCC_Id,MPPI_Id,Applicable_Date,MPPIType_Id)
				Values (var_Org_Id,New_Entry_Id,var_MCC_Id,
                var_MPPI_Id,var_Applicable_Date,@MPPI_TYpe); 
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Entry_Id AS Result_Extra_Key;
			end if;
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
