-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDieselRate_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDieselRate_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_DieselRate_Id varchar(20)
)
BEGIN

	-- to restrict past Applicable Date from updating
			DECLARE Today_Date DATETIME;
            SET Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');

	if (var_Method_Name = 'Get') then  
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			select Org_Id,DieselRate_Id, DieselRate, 
            date_format(DieselRate_Date, '%d %M %Y') as DieselRate_Date,
            Is_Active,Is_Deleted,
            CASE 
				WHEN DieselRate_Date < Today_Date THEN 1
				ELSE 0
			END AS Is_Locked
            from t001_dieselrate 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and CAST(DieselRate_Date  AS DATE) >= var_StartDate 
            and CAST(DieselRate_Date  AS DATE)  <= var_EndDate
            order by DieselRate_Id DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
        
			
        
			select Org_Id,DieselRate_Id, DieselRate, 
            date_format(DieselRate_Date, '%Y-%m-%d') as DieselRate_Date,
            Is_Active, Is_Deleted,
            CASE 
				WHEN DieselRate_Date < Today_Date THEN 1
				ELSE 0
			END AS Is_Locked            
            from t001_dieselrate 
            where Org_Id = var_Org_Id and DieselRate_Id = var_DieselRate_Id 
            and Is_Deleted =0;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT date_format(DieselRate_Date, '%Y-%m-%d') as DieselRate_Date
			FROM t001_dieselrate
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
			ORDER BY DieselRate_Date DESC
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
