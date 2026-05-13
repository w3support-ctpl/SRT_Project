-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_CommonMaster` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_CommonMaster`(
    var_Method_Name varchar(20),
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
	
    elseif(var_Method_Name = 'GetFarmerStatus') then
    
    	select Is_Offline as Item_Id, Is_Offline as Item_Value from mu04_farmer
		where Org_Id = var_Org_Id  and Farmer_Id = var_ParentField_Id;

    elseif(var_Method_Name = 'GetTaluka') then
    
    	select Taluka_Id as Item_Id, Taluka_Name as Item_Value
		from ml04_taluka where Org_Id = var_Org_Id  and District_Id = var_ParentField_Id and is_active = 1 order by Taluka_Name asc ;

    elseif(var_Method_Name = 'GetVillage') then
    
    	select Village_Id as Item_Id, Village_Name as Item_Value
		from ml05_village where Org_Id = var_Org_Id  and Taluka_Id = var_ParentField_Id and is_active = 1 order by Village_Name asc ;       
	
	elseif(var_Method_Name = 'GetMappedMCC') then
    
    	select MCC_Id as Item_Id, MCC_Name as Item_Value
		from m005_mcc where Org_Id = var_Org_Id  and Agent_Id = var_ParentField_Id and is_active = 1 order by MCC_Name asc ; 
        
	elseif(var_Method_Name = 'GetMCCFarmers') then
    
    	select Farmer_Id as Item_Id, ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name)as Item_Value
		from mu04_farmer where Org_Id = var_Org_Id  and MCC_Id = var_ParentField_Id  order by Farmer_Name asc ;  
        
	elseif(var_Method_Name = 'GetFarmersOffline') then
    
    	select Farmer_Id as Item_Id, ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name)as Item_Value
		from mu04_farmer where Org_Id = var_Org_Id  and MCC_Id = var_ParentField_Id and is_active = 1
        and Is_Offline =1 
        order by Farmer_Name asc ;  
        
    
    elseif (var_Method_Name = 'GetAdvanceType') then
    
		select AdvanceType_Id as Item_Id, AdvanceType_Name as Item_Value
		from c040_advancetype where Is_Deleted = 0 order by AdvanceType_Name asc ;
      
	elseif (var_Method_Name = 'GetMilktType') then
    
		select MilkType_Id as Item_Id, MilkType_Name as Item_Value
		from c011_milktype where Is_Deleted = 0 
        and MilkType_Id in ('C011001','C011002') order by MilkType_Name asc ;
	
    elseif (var_Method_Name = 'GetMusterType') then
    
		select MusterType_Id as Item_Id, MusterType_Name as Item_Value
		from c022_mustertype where Is_Deleted = 0  order by MusterType_Name asc ;
      
      
	elseif (var_Method_Name = 'GetExpenseType') then
    
		select ExpenseType_Id as Item_Id, ExpenseType_Name as Item_Value
		from c036_expensetype where Is_Deleted = 0 order by ExpenseType_Name asc ;
        
	elseif (var_Method_Name = 'GetComplaintType') then
    
		select ComplaintType_Id as Item_Id, ComplaintType_Name as Item_Value
		from c034_complainttype where Is_Deleted = 0 order by ComplaintType_Name asc ;
        
	elseif (var_Method_Name = 'GetServiceType') then
    
		select ServiceType_Id as Item_Id, ServiceType_Name as Item_Value
		from c027_servicetype where Is_Deleted = 0 order by ServiceType_Name asc ;
        
	elseif (var_Method_Name = 'GetUnit') then
    
		SELECT UOM_Type as Item_Id, UOM_Name as Item_Value FROM c019_uom where Is_Deleted = 0;
        
	elseif(var_Method_Name = 'GetCollectionShifts')then
        	
	set @Version_No = (select m005.Version_No from m005_mcc_version m005 where MCC_Id = var_ParentField_Id and Applicable_Date <= @Current_Datetime
    order by Applicable_Date desc limit 1) ;
    
     select CollectionShift_Id as Item_Id ,  CollectionShift_Name as Item_Value  from c015_collectionshift where CollectionShift_Id in 
	(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = var_ParentField_Id and Version_No = @Version_No) ;
        
     elseif (var_Method_Name = 'GetBank') then
		begin
			select Bank_Id as item_id, Bank_Name as item_value
			from m015_bank where Org_Id = var_Org_Id and Is_Active = 1
			order by Bank_Name;
		end;
	elseif (var_Method_Name = 'GetBranch') then
		begin
			select Branch_Id as item_id, Branch_Name as item_value
			from m016_branch where Org_Id = var_Org_Id and Bank_Id = var_ParentField_Id and Is_Active = 1
			order by Branch_Name;
		end;   
        
		elseif (var_Method_Name = 'GetNominee') then
	
			select NomineeRelation_Id as item_id, NomineeRelation_Name as item_value
			from c030_nomineerelation where Is_Active = 1;


	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
