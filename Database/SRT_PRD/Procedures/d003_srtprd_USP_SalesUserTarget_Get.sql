-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserTarget_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserTarget_Get`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    Var_Profile_Id varchar(20),
    Var_SalesUser_Id varchar(20),
	Var_Type varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(var_Method_Name = 'GetTargetProduct') then 

		select 1;

	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
