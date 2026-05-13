-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminAccountStatement_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminAccountStatement_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_MCC_Id varchar(20),
	var_Agent_Id varchar(20),
    var_Farmer_Id  varchar(20),
    var_Transporter_Id  varchar(20),
	var_Type varchar(20),
    var_Date varchar(255)
)
BEGIN
	DECLARE StartDate DATE;
	DECLARE EndDate DATE;
	SET StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
	SET EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
    
	if (var_Method_Name = 'Get') then
		begin
			if (var_Type = 'Farmer') then
				begin
					select Farmer_Code as Supplier,
                    DATE_FORMAT(StartDate, '%Y%m%d') as StartDate,
					DATE_FORMAT(EndDate, '%Y%m%d') as EndDate
					from mu04_farmer 
					where Org_Id = var_Org_Id
					and Farmer_Id = var_Farmer_Id limit 1;
				end;
			elseif(var_Type = 'Agent') then
				begin
					select MCC_Code as Supplier ,
                    DATE_FORMAT(StartDate, '%Y%m%d') as StartDate,
					DATE_FORMAT(EndDate, '%Y%m%d') as EndDate
					from m005_mcc 
					where Org_Id = var_Org_Id
					and MCC_Id = var_MCC_Id limit 1;
				end;
			elseif(var_Type = 'Transporter') then
				begin
					select Transporter_Code as Supplier ,
                    DATE_FORMAT(StartDate, '%Y%m%d') as StartDate,
					DATE_FORMAT(EndDate, '%Y%m%d') as EndDate
					from m009_transporter 
					where Org_Id = var_Org_Id
					and Transporter_Id = var_Transporter_Id limit 1;
				end;
			end if;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
