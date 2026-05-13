-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveScheme_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveScheme_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_IncentiveType_Id varchar(20),
    var_Date varchar(60),
    var_IncentiveScheme_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');

			select m011.Org_Id, IncentiveScheme_Id, Scheme_Name,
            c025.IncentiveType_Id, c025.IncentiveType_Name, 
			c026.IncentiveFrequency_Id, c026.IncentiveFrequency_Name,
            date_format(m011.From_Date, '%d %M %Y') as from_date,
            date_format(m011.To_Date, '%d %M %Y') as to_date,
            m011.Is_Active, m011.Is_Deleted
            from m011_incentivescheme m011
			inner join c025_incentivetype c025 on c025.IncentiveType_Id = m011.IncentiveType_Id 
            inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id 
            where m011.Org_Id = var_Org_Id and m011.Is_Deleted = 0 
            and m011.IncentiveType_Id like var_IncentiveType_Id
			and CAST(m011.From_Date  AS DATE) >=  var_StartDate and CAST(m011.To_Date  AS DATE) <= var_EndDate
            order by Scheme_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, IncentiveScheme_Id, Scheme_Name, 
            IncentiveType_Id, IncentiveFrequency_Id, 
            Criteria, Scheme_Description, Is_For_Farmer, Is_For_Agent,
            date_format(From_Date, '%Y-%m-%d') as from_date,
            date_format(To_Date, '%Y-%m-%d') as to_date,
            Photo, Is_Active, Is_Deleted 
            from m011_incentivescheme 
            where Org_Id = var_Org_Id and IncentiveScheme_Id = var_IncentiveScheme_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
