-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverProfile_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverProfile_Get`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN

	if(Var_Method_Name ='GetDriverInfo') then 
    
		select Driver_Name , DrivingLicense_No , Birth_Date ,Driver_Id ,Aadhar_No , Pan_No , ifnull(Account_No, '-') as Account_No,ifnull( Bank_Name , '-') as Bank_Name
        from mu06_driver where Org_Id = Var_Org_Id and Driver_Id = Var_Profile_Id;
        
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
