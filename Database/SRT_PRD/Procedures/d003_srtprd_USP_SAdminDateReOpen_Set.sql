-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDateReOpen_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDateReOpen_Set`(
	var_Org_Id VARCHAR(10),
	var_Method_Name VARCHAR(45),
    var_Entry_Id VARCHAR(45),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(255)
)
BEGIN
	-- table yet to be made
	IF(var_Method_Name = 'Update') THEN
    BEGIN
		UPDATE t041_salesuser_route 
        SET 
            End_Time = null,
            Status = 1,
            LastEdited_On = now(),
            LastEditedBy_Id = var_User_Id,
            LastEditedBy_Name = var_User_Name
        WHERE Entry_Id = var_Entry_Id AND Org_Id = var_Org_Id;

        SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_Entry_Id AS Result_Extra_Key;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
