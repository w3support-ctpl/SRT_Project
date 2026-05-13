-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverProfile_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverProfile_Set`(
	var_Method_Name varchar(40),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    Var_FilePath text
)
BEGIN
    SET SQL_SAFE_UPDATES = 0;
		
        if (var_Method_Name = 'ChangeProfile') then 
		
        update mu06_driver 
		set Profile_Photo = Var_FilePath
        where Driver_Id = var_Profile_Id and Org_Id = var_Org_Id;
        
		select 1 as Result_Id,'Profile Updated' as Result_Description, '' as Result_Extra_Key;
        
        end  if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
