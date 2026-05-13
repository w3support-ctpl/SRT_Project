-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminComplaintType_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminComplaintType_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_ComplaintType_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			SELECT ComplaintType_Id,ComplaintType_Name,Is_Active FROM c034_complainttype;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
