-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminComplaintType_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminComplaintType_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_ComplaintType_Id varchar(20),
	var_ComplaintType_Name varchar(255),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then  
		begin
			Declare Duplicate_Flag int;
            Declare New_ComplaintType_Id varchar(20);
			Declare Year_Id varchar(10);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('c034_complainttype', Year_Id, 'C034', '', New_ComplaintType_Id );
            Insert Into c034_complainttype(ComplaintType_Id,ComplaintType_Name,Is_Active,Is_Deleted)
            value(New_ComplaintType_Id,var_ComplaintType_Name,1,0);
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_ComplaintType_Id AS Result_Extra_Key;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
