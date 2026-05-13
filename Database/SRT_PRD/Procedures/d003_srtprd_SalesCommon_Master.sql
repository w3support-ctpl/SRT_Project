-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `SalesCommon_Master` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `SalesCommon_Master`(
    var_Method_Name varchar(100),
    var_Org_Id varchar(10),
    var_ParentField_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if (var_Method_Name = 'GetState') then
    
		select State_Id as Item_Id, State_Name as Item_Value
		from ml02_state where Org_Id = var_Org_Id order by State_Name asc ;
	
    elseif(var_Method_Name = 'GetDistrict') then
    
    	select District_Id as Item_Id, District_Name as Item_Value
		from ml03_district where Org_Id = var_Org_Id  and State_Id = var_ParentField_Id order by District_Name asc ;

    elseif(var_Method_Name = 'GetTaluka') then
    
    	select Taluka_Id as Item_Id, Taluka_Name as Item_Value
		from ml04_taluka where Org_Id = var_Org_Id  and District_Id = var_ParentField_Id and is_active = 1 order by Taluka_Name asc ;

    elseif(var_Method_Name = 'GetVillage') then
    
    	select Village_Id as Item_Id, Village_Name as Item_Value
		from ml05_village where Org_Id = var_Org_Id  and Taluka_Id = var_ParentField_Id and is_active = 1 order by Village_Name asc ;   
	
    elseif(var_Method_Name = 'Getsalesmans') then
        
		select SalesUser_Id as Item_Id, SalesUser_Name as Item_Value
		from mu12_sales_user where Org_Id = var_Org_Id  and SalesUser_Id = var_ParentField_Id and is_active = 1    
        union all 
    	select SalesUser_Id as Item_Id, SalesUser_Name as Item_Value
		from mu12_sales_user where Org_Id = var_Org_Id  and ReportingTo_Id = var_ParentField_Id and is_active = 1 ;   
        
        
elseif(var_Method_Name = 'GetDealer') then
    
    	select Dealer_Id as Item_Id, Dealer_Name as Item_Value
		from mu08_dealer where Org_Id = var_Org_Id  ; 
        
elseif(var_Method_Name = 'Getsalesarea') then
    
    	select SalesArea_Id as Item_Id, SalesArea_Name as Item_Value
		from m013_salesarea where Org_Id = var_Org_Id  ; 
        
		elseif (var_Method_Name = 'GetComplaintType') then
    
		select ComplaintType_Id as Item_Id, ComplaintType_Name as Item_Value
		from c034_complainttype where Is_Deleted = 0 order by ComplaintType_Name asc ;
	
        
        end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
