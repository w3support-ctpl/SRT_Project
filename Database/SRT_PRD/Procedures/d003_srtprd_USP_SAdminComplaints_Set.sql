-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminComplaints_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminComplaints_Set`(
var_Method_Name varchar(255),
var_Org_Id varchar(255),
Var_Complaint_Id varchar(255),
var_User_Id varchar(255),
var_Complaint_Remark longtext
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(var_Method_Name = 'Updatecomplaint') then 

		set @Year_Id = (select right(left(curdate(),4),(2)));
		set @Entry_Id = '';
		Call USP_Number_Range ('t037_sales_complaint_item', @Year_Id, 'T037', '', @Entry_Id );
		
	
		insert into t037_sales_complaint_item (Org_Id , Complaint_Id , Entry_Id , Action_Date , Action_By_Id , Action_By_Name , 
		Remarks , Is_Display , New_Status_Id, Current_Status_Id ) 
		select Org_Id , Complaint_Id  , @Entry_Id  , @Current_Datetime, var_User_Id ,var_User_Id, var_Complaint_Remark  , 1 , New_Status_Id ,  Current_Status_Id 
		from t037_sales_complaint_item where Org_Id = var_Org_Id and Complaint_Id  = Var_Complaint_Id order by 
		Action_Date desc limit 1 ;

		SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;
		
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
