-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveSchemeMCC_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveSchemeMCC_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_IncentiveScheme_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select 
            m011.Entry_Id,
            m005.MCC_Id,
            m005.MCC_Name,
            m005.MCC_Code
			from m011_incentivescheme_item m011
            inner join m005_mcc m005 on
            m005.Org_Id =  m011.Org_Id
            and m005.MCC_Id = m011.MCC_Id
            where m011.Org_Id = var_Org_Id 
            and m011.IncentiveScheme_Id = var_IncentiveScheme_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
