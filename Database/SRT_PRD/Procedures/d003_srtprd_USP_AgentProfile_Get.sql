-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentProfile_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentProfile_Get`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
	var_Profile_Id varchar(20),
	var_MCC_Id varchar(20)
)
BEGIN
	if(var_Method_Name = 'GetAgentInfo') then
    
		   select mu05.Agent_Id as Agent_Id, ifnull(mu05.Agent_Name,'') as Agent_Name , 
			ifnull('COLLECTION CENTRE','') as collection_centre_name, 
            ifnull(mu05.Address_Text,'') as Address_Text ,  
            ifnull(mu05.Pincode,'') as Pincode, 
            ifnull(mu05.Bank_Name,'') as Bank_Name, 
            ifnull(mu05.Account_Name,'') as Account_Name, 
            ifnull(mu05.Account_No,'') as Account_No, 
            ifnull(mu05.IFSC_Code,'') as  IFSC_Code , 
            ifnull(mu05.Profile_Photo,'') as Profile_Photo,
            ifnull('','') as Bank_Cheque_Photo,
            MCC_Name, State_Name as Premises_State, District_Name as Premises_District , Taluka_Name as Premises_Taluka, Village_Name as Premises_Village, ifnull(m005.Address_Text,'') as  Premises_Address_Text 
            from mu05_agent mu05 inner join m005_mcc m005 on mu05.Agent_Id = m005.Agent_Id
            inner join ml02_state ml02 on m005.Org_Id = ml02.Org_Id and m005.State_Id = ml02.State_Id
            inner join ml03_district ml03 on m005.Org_Id = ml03.Org_Id and m005.District_Id = ml03.District_Id 
            inner join ml04_taluka ml04 on m005.Org_Id = ml04.Org_Id and m005.Taluka_Id = ml04.Taluka_Id
            inner join ml05_village ml05 on  m005.Org_Id = ml05.Org_Id and m005.Village_Id = ml05.Village_Id
            where mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id and m005.MCC_Id = var_MCC_Id ;
		
			select mu05.State_Id as Item_Id, ml02.State_Name as Item_Value from mu05_agent mu05 inner join ml02_state ml02 on 
            mu05.Org_Id = ml02.Org_Id and mu05.State_Id = ml02.State_Id where  
            mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id;
            
            select mu05.District_Id as Item_Id, District_Name as Item_Value from mu05_agent mu05 inner join ml03_district ml03 on 
            mu05.Org_Id = ml03.Org_Id and mu05.District_Id = ml03.District_Id where  
            mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id;
            
            select mu05.Taluka_Id as Item_Id, Taluka_Name as Item_Value from mu05_agent mu05 inner join ml04_taluka ml04 on 
            mu05.Org_Id = ml04.Org_Id and mu05.Taluka_Id = ml04.Taluka_Id where  
            mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id;
            
			select mu05.Village_Id as Item_Id, Village_Name as Item_Value from mu05_agent mu05 inner join ml05_village ml05 on 
            mu05.Org_Id = ml05.Org_Id and mu05.Village_Id = ml05.Village_Id where  
            mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id;
    
	END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
