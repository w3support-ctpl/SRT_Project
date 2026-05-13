-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFatSNFRatio_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFatSNFRatio_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_Ratio_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			select Org_Id,Ratio_Id,Fat, SNF, ifnull(Overhead_Amount,'')  as overhead,
            date_format(Ratio_Date, '%d %M %Y') as Ratio_Date,
            Is_Active,Is_Deleted,
            CASE WHEN date(Ratio_Date) <= date(now()) THEN 1 ELSE 0 END AS Is_Locked
            from t024_fatsnf_ratio 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and CAST(Ratio_Date  AS DATE) >= var_StartDate 
            and CAST(Ratio_Date  AS DATE)  <= var_EndDate
            order by Ratio_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Ratio_Id, Fat, SNF,ifnull(Overhead_Amount,'')  as overhead,
            date_format(Ratio_Date, '%Y-%m-%d') as Ratio_Date,
            Is_Active, Is_Deleted,
            CASE WHEN date(Ratio_Date) <= date(now()) THEN 1 ELSE 0 END AS Is_Locked
            from t024_fatsnf_ratio 
            where Org_Id = var_Org_Id and Ratio_Id = var_Ratio_Id 
            and Is_Deleted =0;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT date_format(Ratio_Date, '%Y-%m-%d') as Ratio_Date  
			FROM t024_fatsnf_ratio
			WHERE Org_Id = var_Org_Id
			AND Is_Deleted = 0
			ORDER BY Ratio_Date DESC
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
