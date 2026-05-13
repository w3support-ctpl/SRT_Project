-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerIncentiveScheme_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerIncentiveScheme_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_IncentiveScheme_Id varchar(20),
    Var_Farmer_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Request_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare Current_Datetime datetime;
            Declare var_MCC_Id varchar(45);
            
            select MCC_Id INTO var_MCC_Id
            from mu04_farmer
            where Farmer_Id = Var_Farmer_Id AND Org_Id = var_Org_Id AND Is_Deleted = 0 limit 1;
            
				set Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+05:30'));
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t017_incentives_request', Year_Id, 'T017', '', New_Request_Id );
            
				Insert Into t017_incentives_request
                (Org_Id, Request_Id,IncentiveScheme_Id,MCC_Id,
                Request_For,Request_For_User_Id,Request_By,Request_By_User_Id,Request_Date, Is_Approved)
				Values (var_Org_Id, New_Request_Id,var_IncentiveScheme_Id,var_MCC_Id,
                'Farmer',Var_Farmer_Id ,'Agent',var_Profile_Id,Current_Datetime , 0); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Request_Id AS Result_Extra_Key;
			
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
