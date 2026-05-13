-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserProfile` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserProfile`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(255),
    var_Profile_Id varchar(255),
    Var_LoginType varchar(255),
    var_Profile_Photo longtext
)
BEGIN
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
    if(var_Method_Name = 'SetProfilePhoto') then
		begin
			if(Var_LoginType = 'Salesman' or Var_LoginType = 'ASM')then
            
				update mu12_sales_user
				set Profile_Photo = var_Profile_Photo
				where Org_Id = var_Org_Id
				and SalesUser_Id = var_Profile_Id;
            
            elseif(Var_LoginType = 'Dealer')then
            
				update mu08_dealer
				set Profile_Photo = var_Profile_Photo
				where Org_Id = var_Org_Id
				and Dealer_Id = var_Profile_Id;

            
            end if;
            
            SELECT 1 AS Result_Id,  'Image Uploaededd Successfully' AS Result_Description,  '' AS Result_Extra_Key;
        end;
		elseif(var_Method_Name = 'Get') then
		begin
			select 
            Org_Id,MCC_Id,Farmer_Id,MilkType_Id ,MilkStatus_Id ,Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein
			-- Org_Id,FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id ,Quantity_Ltr
			-- Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id, Farmer_Id, MilkType_Id, MilkStatus_Id, Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate, Amount, EntryTime, Is_Corrected, Correction_Request_Id, MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Id, Is_InvoiceCreated, InvoiceCreated_On, Is_Active, Is_Deleted, Created_On, LastEdited_On, CreatedBy_Id, CreatedBy_Name, LastEditedBy_Id, LastEditedBy_Name, Is_Check, Anamat_Charge, Freight_Charge, Is_FromApp, Is_Missing
            from d003_srtprd.t005_milkcollectionfarmer 
            limit 500
            ;
        end;
        elseif(var_Method_Name = 'GetOne') then
		begin
			select 
            -- Org_Id,MCC_Id,Farmer_Id,MilkType_Id ,MilkStatus_Id ,Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein
			-- Org_Id,FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id ,Quantity_Ltr
			Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id, Farmer_Id, MilkType_Id, MilkStatus_Id, Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate, Amount, EntryTime, Is_Corrected, Correction_Request_Id, MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Id, Is_InvoiceCreated, InvoiceCreated_On, Is_Active, Is_Deleted, Created_On, LastEdited_On, CreatedBy_Id, CreatedBy_Name, LastEditedBy_Id, LastEditedBy_Name, Is_Check, Anamat_Charge, Freight_Charge, Is_FromApp, Is_Missing
            from d003_srtprd.t005_milkcollectionfarmer 
            limit 500
            ;
        end;
        elseif(var_Method_Name = 'GetOne121') then
		begin 
			select 
            '<input type="checkbox" class="row-checkbox k-checkbox" style="width: 20px; height: 20px;" value="">' as new,
            Org_Id,MCC_Id,Farmer_Id,MilkType_Id ,MilkStatus_Id ,Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein
			-- Org_Id,FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id ,Quantity_Ltr
			-- Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id, Farmer_Id, MilkType_Id, MilkStatus_Id, Quantity_Ltr, Quantity_Kg, Fat, SNF, Protein, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate, Amount, EntryTime, Is_Corrected, Correction_Request_Id, MusterCycle_StartDate, MusterCycle_EndDate, Invoice_Id, Is_InvoiceCreated, InvoiceCreated_On, Is_Active, Is_Deleted, Created_On, LastEdited_On, CreatedBy_Id, CreatedBy_Name, LastEditedBy_Id, LastEditedBy_Name, Is_Check, Anamat_Charge, Freight_Charge, Is_FromApp, Is_Missing
            from d003_srtprd.t005_milkcollectionfarmer 
           limit 100
            ;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
