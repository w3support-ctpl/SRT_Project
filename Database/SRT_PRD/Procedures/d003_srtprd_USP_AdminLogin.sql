-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminLogin` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminLogin`(
	var_Org_Id varchar(20),
    var_Method_Name VARCHAR(20),
    var_Login_Name VARCHAR(45),
    var_Login_Password VARCHAR(45)
)
BEGIN
    -- Check the value of var_Method_Name and perform corresponding actions
    IF var_Method_Name = 'AdminUser' THEN

		-- User login is valid, retrieve user information
		SELECT mu03.Org_Id, c001.Org_Name as Org_Name,c001.TruckCollection_FirstQty,c001.TankerCollection_FirstQty,
        mu03.User_Id, mu01.Role_Id, mu01.Role_Name as Role_Name, User_Name, Mobile_No, Email_Id,
		mu03.Is_Active, mu03.Is_PasswordReset
		FROM mu03_user mu03
        inner join c001_organization c001 on c001.Org_Id = mu03.Org_Id
        inner join mu01_role mu01 on mu01.Org_Id = mu03.Org_Id and mu01.Role_Id = mu03.Role_Id
		WHERE mu03.Login_Name = Var_Login_Name
		AND mu03.Login_Password = Var_Login_Password
		AND mu03.Is_Active = 1 AND mu03.Is_Deleted = 0;

    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
