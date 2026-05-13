-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCStock` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCStock`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Material_Id varchar(20),
Var_Profile_Id varchar(20),
Var_StartDate varchar(20),
Var_EndDate varchar(20)
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(Var_Method_Name = 'GetCanSummary')then 
		
        select MCC_Id , Opening_Quantity , Credit , Debit , Balance 
        from f006_mccstocks f006
        where MCC_Id = Var_MCC_Id and Material_Id = Var_Material_Id and
        date(f006.Date) between date(var_StartDate) and DATE_ADD(date(var_EndDate), INTERVAL 1 DAY) ;

		end if;
		
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
