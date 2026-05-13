-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFreight_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFreight_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_Freight_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE Today_Date DATETIME;
            
            set Today_Date = CAST(CONVERT_TZ(NOW(), '+00:00', '+00:00') AS DATE);
           
            
            SELECT m004.Org_Id,m004.Freight_Id,m004.Vehicle_Id,
            c029.FreightRateType_Id,c029.FreightRateType_Name,
            m004.Version_No,ifnull(m004.BaseRate,'')as BaseRate,ifnull(m004.Amount,'') as Amount,
            DATE_FORMAT(m004.Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
            m004.Is_Active,m004.Is_Deleted,
                   CASE 
                       -- WHEN Today_Date >= Applicable_Date AND Today_Date <= DATE_ADD(Applicable_Date, INTERVAL 1 DAY) THEN 1
                       -- WHEN Today_Date > DATE_ADD(Applicable_Date, INTERVAL 1 DAY) THEN 1
                       WHEN Today_Date >= CAST(Applicable_Date AS DATE) AND Today_Date <= CAST(Applicable_Date AS DATE) THEN 1
                       WHEN Today_Date > CAST(Applicable_Date AS DATE) THEN 1
                       ELSE 0
                   END AS Is_Locked
			FROM m004_freight m004
            inner join c029_freightratetype c029 on c029.FreightRateType_Id = m004.FreightRateType_Id
            WHERE m004.Org_Id = var_Org_Id  
			and m004.Vehicle_Id = var_Vehicle_Id
            AND m004.Is_Active = 1
            AND m004.Is_Deleted = 0
            ORDER BY DATE(m004.Applicable_Date) DESC, TIME(m004.Applicable_Date) DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Freight_Id, Vehicle_Id, FreightRateType_Id, Version_No, 
            BaseRate, ifnull(Amount,'') as Amount, 
            DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date,
            Is_Active, Is_Deleted
            from m004_freight 
            where Org_Id = var_Org_Id 
            and Freight_Id = var_Freight_Id;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date
			FROM m004_freight
			WHERE Org_Id = var_Org_Id
			AND Vehicle_Id = var_Vehicle_Id
			AND Is_Deleted = 0
            AND Is_Active  = 1
			ORDER BY Applicable_Date DESC
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
