-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminReverseLog_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminReverseLog_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Entry_Id varchar(20),
    var_Table_Name longtext,
    var_Table_Id varchar(20),
    var_SAP_Document_Id varchar(20),
    var_SAP_Document_Year longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('l007_reverselog', Year_Id, 'L007', '', New_Entry_Id );
            
            Insert Into l007_reverselog
			(Org_Id,Entry_Id,Entry_Date,Table_Name,Table_Id,SAP_Document_Id,SAP_Document_Year,CreatedBy_Id,CreatedBy_Name)
			Values 
            (var_Org_Id,New_Entry_Id,now(),var_Table_Name,var_Table_Id,
            var_SAP_Document_Id,var_SAP_Document_Year,var_User_Id,var_User_Name); 
			
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Entry_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
