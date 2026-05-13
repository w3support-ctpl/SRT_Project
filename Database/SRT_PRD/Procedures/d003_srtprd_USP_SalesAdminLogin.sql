-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesAdminLogin` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesAdminLogin`(
	var_Org_Id varchar(20),
    var_Method_Name VARCHAR(20),
    var_Login_Name VARCHAR(45),
    var_Login_Password VARCHAR(45)
)
BEGIN
	-- Check the value of var_Method_Name and perform corresponding actions
    IF (var_Method_Name = 'AdminUser') THEN
	BEGIN
		-- User login is valid, retrieve user information
		SELECT mu03.Org_Id, c001.Org_Name as Org_Name,
        mu03.User_Id, mu01.Role_Id, mu01.Role_Name as Role_Name, User_Name, Mobile_No, Email_Id,
		mu03.Is_Active, mu03.Is_PasswordReset
		FROM mu03_user mu03
        inner join c001_organization c001 on c001.Org_Id = mu03.Org_Id
        inner join mu01_role mu01 on mu01.Org_Id = mu03.Org_Id and mu01.Role_Id = mu03.Role_Id
		WHERE mu03.Login_Name = Var_Login_Name
		AND mu03.Login_Password = Var_Login_Password
		AND mu03.Is_Active = 1 AND mu03.Is_Deleted = 0;
	END;
    -- Change Password
    ELSEIF(var_Method_Name = 'ChangePassword') THEN
    BEGIN
		UPDATE mu03_user
        SET Login_Password = var_Login_Password,
        Is_PasswordReset = 0
        WHERE Org_Id = var_Org_Id
        AND User_Id = var_Login_Name
        AND Is_Active = 1
        AND Is_PasswordReset = 1;
        
        /*
        		SELECT '' as Org_Id, 'S R Thorat Dairy' as Org_Name, var_Login_Name AS User_Id, 
                '' AS Role_Id, '' as Role_Name, '' AS User_Name, 
                '' AS Mobile_No, '' AS Email_Id,
				1 AS Is_Active, 0 AS Is_PasswordReset ;
        */
        
        SELECT 0 AS Is_PasswordReset,
        var_Login_Name AS User_Id;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
