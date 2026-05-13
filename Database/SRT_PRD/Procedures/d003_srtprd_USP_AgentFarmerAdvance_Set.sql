-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerAdvance_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerAdvance_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_AdvanceType_Id varchar(20),
    var_Advance_Amount varchar(20),
	var_Advance_Remark longtext,
    var_Farmer_Id varchar(20),
	var_Date varchar(255)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Advance_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare Current_Datetime datetime;
            Declare var_MCC_Id varchar(45);
            
            select MCC_Id INTO var_MCC_Id
            from mu04_farmer
            where Farmer_Id = var_Farmer_Id AND Org_Id = var_Org_Id AND Is_Deleted = 0;
            
			set Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
			set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t015_advance', Year_Id, 'T015', '', New_Advance_Id );
		
			Insert Into t015_advance
			(Org_Id, Advance_Id, AdvanceType_Id, Advance_Amount, Advance_Remark,
			MCC_Id,Request_For, Request_For_User_Id, Request_By, Request_By_User_Id, Created_On, Is_Approved)
			Values (var_Org_Id, New_Advance_Id, var_AdvanceType_Id, var_Advance_Amount, var_Advance_Remark,
			var_MCC_Id,'farmer',var_Farmer_Id,'Agent',var_Profile_Id,Current_Datetime , 0); 
            
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Advance_Id AS Result_Extra_Key; 
			
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
