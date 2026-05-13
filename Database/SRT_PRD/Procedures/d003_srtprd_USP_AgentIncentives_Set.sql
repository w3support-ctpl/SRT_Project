-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentIncentives_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentIncentives_Set`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Incentive_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN
		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(Var_Method_Name = 'ApplyIncentive') Then 
		
        
	if exists(select 1 from t017_incentives_request where Org_Id = Var_Org_Id and IncentiveScheme_Id = Var_Incentive_Id and MCC_Id = Var_MCC_Id ) then 

		select -1 as Result_Id, 'Already Applied' as Result_Description, '' as Result_Extra_Key;    
        
	else 
    
		set @Year_Id = (select right(left(curdate(),4),(2)));
        set @Request_Id  = '';
		Call USP_Number_Range ('t017_incentives_request', @Year_Id, 'T017', '', @Request_Id );
        
        INSERT INTO t017_incentives_request (Org_Id , Request_Id, IncentiveScheme_Id ,MCC_Id, Request_For, Request_For_User_Id ,
        Request_By , Request_By_User_Id , Request_Date,Is_Approved
        ) values (
        Var_Org_Id,  @Request_Id , Var_Incentive_Id , Var_MCC_Id , 'Agent' , Var_Profile_Id , 'Agent' , Var_Profile_Id , @Current_Datetime , 0
        ) ;
        
		select 1 as Result_Id, 'successfully Applied' as Result_Description, '' as Result_Extra_Key;   
        

		END IF ;
	END IF ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
