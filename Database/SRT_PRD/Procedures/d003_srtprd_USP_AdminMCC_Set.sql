-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCC_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCC_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_MCC_Id varchar(20),
	var_MCC_Name varchar(255),
    var_MCC_Code varchar(45),
    var_MCCCategory_Id varchar(20),
	var_MCCType_Id varchar(20),
    var_Agent_Id varchar(20),
    var_Mobile_No varchar(20),
    var_Address_Text longtext,
	var_State_Id varchar(20),
	var_District_Id varchar(20),
	var_Taluka_Id varchar(20),
    var_Village_Id varchar(20),
    var_Bank_Id varchar(45),
    var_Branch_Id varchar(45),
	var_Account_No varchar(45),
	var_Account_Name varchar(45),
    var_FSSAILicense_No varchar(45),
	var_FSSAILicenseValidity_On datetime,
    var_MusterType_Id varchar(20),
	var_MCCWorkType_Id varchar(20),
	var_PaymentCycle_Id varchar(20),
    var_PaymentType_Id varchar(20),
    var_MilkType_Id longtext,
    var_CollectionShift_Id longtext,
    var_Latitude varchar(45),
    var_Longitude varchar(45),
    var_Profile_Photo varchar(255),
	var_Pan_Card_Photo varchar(255),
    var_FSSAILicense_Photo varchar(255),
    var_Is_ManualWeight int,
    var_Is_ManualQuality int,
    var_Is_ManualShiftEnd int,
	var_User_Id  varchar(20),
	var_User_Name  varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Pan_No VARCHAR(10),
    var_Anamat  varchar(20),
	var_Freight  varchar(45),
    var_Anamat_TDS  varchar(45),
	var_Freight_TDS  varchar(45),
    var_Rebate  varchar(45),
    var_WithholdingTaxType_Id varchar(20),
    var_Plant_Code varchar(20),
    var_Is_Alternate varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_MCC_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE collectionShiftArray LONGTEXT;
            DECLARE milkTypeArray LONGTEXT;
            DECLARE Today_Date datetime;
            Declare New_CollectionShift_Version_No int;
            Declare New_MilkType_Version_No int;
            DECLARE collectionShiftName LONGTEXT;
            DECLARE milkTypeName LONGTEXT;
            
            if exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Name = var_MCC_Name and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'MCC Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			/*
			elseif exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
			*/
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m005_mcc', Year_Id, 'M005', '', New_MCC_Id );
                set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
                
            
				Insert Into m005_mcc
					(Org_Id, MCC_Id,MCC_Name,MCCCategory_Id,MCCType_Id,Agent_Id,Mobile_No,
					Address_Text, State_Id,District_Id,Taluka_Id,Village_Id,
                    Bank_Id,Branch_Id,Account_No,Account_Name,FSSAILicense_No,FSSAILicenseValidity_On,
                    MusterType_Id,MCCWorkType_Id,PaymentCycle_Id,PaymentType_Id,MilkType_Id,CollectionShift_Id,Latitude,Longitude,Profile_Photo,Pan_Card_Photo,FSSAILicense_Photo,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,
                    Is_ManualWeight,Is_ManualQuality,Is_ManualShiftEnd,Pan_No,
                    Anamat_Applicable_To,Freight_Applicable_To,WithholdingTaxType_Id,
                    Plant_Code,Is_Alternate)
				Values (var_Org_Id, New_MCC_Id,var_MCC_Name,var_MCCCategory_Id,var_MCCType_Id,var_Agent_Id,var_Mobile_No,
					var_Address_Text,var_State_Id,var_District_Id,var_Taluka_Id,var_Village_Id,
                    var_Bank_Id,var_Branch_Id,var_Account_No,var_Account_Name,var_FSSAILicense_No,var_FSSAILicenseValidity_On,
                    var_MusterType_Id,var_MCCWorkType_Id,var_PaymentCycle_Id,var_PaymentType_Id,var_MilkType_Id,var_CollectionShift_Id,var_Latitude,var_Longitude,var_Profile_Photo,var_Pan_Card_Photo,var_FSSAILicense_Photo,
                    var_Is_Active, var_Is_Deleted, Now(), var_User_Id ,var_User_Name,
                    var_Is_ManualWeight,var_Is_ManualQuality,var_Is_ManualShiftEnd,var_Pan_No,
                    var_Anamat_TDS,var_Freight_TDS,var_WithholdingTaxType_Id,
                    var_Plant_Code,var_Is_Alternate); 
                    
                    Insert Into m005_mcc_offline_config
					(Org_Id, MCC_Id, Is_Morning, Morning_Start_Time, Morning_End_Time, Is_Evening, Evening_Start_Time, Evening_End_Time, Created_On, CreatedBy_Id, CreatedBy_Name)
					value
					(var_Org_Id, New_MCC_Id, 1, '04:30:00', '11:59:00', 1, '12:01:00', '23:30:00', now(), var_User_Id, var_User_Name);
										
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_MCC_Id AS Result_Extra_Key;
                
				call USP_AdminMCCVersion_Set('Create', var_Org_Id, New_MCC_Id,0, var_MusterType_Id, var_PaymentCycle_Id,var_CollectionShift_Id,var_MilkType_Id, Today_Date, 1, 0,'0',var_Anamat,var_Freight,var_Anamat_TDS,var_Freight_TDS,var_Rebate);
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
            /*
			if exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Name = var_MCC_Name and Is_Deleted = 0 and MCC_Id <> var_MCC_Id
            ) then
				SELECT -1 AS Result_Id, 
                'MCC Name already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			/*elseif exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and MCC_Id <> var_MCC_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and MCC_Id <> var_MCC_Id
				) then
					SELECT -1 AS Result_Id, 
					'Pan Number already exists' AS Result_Description, 
					'' AS Result_Extra_Key;
			
			else
            */
				Update m005_mcc
                set 
                MCC_Name = var_MCC_Name,
                MCCCategory_Id = var_MCCCategory_Id,
                MCCType_Id = var_MCCType_Id,
                Agent_Id = var_Agent_Id,
                Mobile_No = var_Mobile_No,
                Address_Text = var_Address_Text,
                State_Id = var_State_Id,
                District_Id = var_District_Id,
                Taluka_Id = var_Taluka_Id,
                Village_Id = var_Village_Id,
                Bank_Id = var_Bank_Id, 
                Branch_Id = var_Branch_Id,
                Account_No = var_Account_No,
                Account_Name = var_Account_Name,
                FSSAILicense_No = var_FSSAILicense_No,
                FSSAILicenseValidity_On = var_FSSAILicenseValidity_On,
                -- MusterType_Id = var_MusterType_Id,
                MCCWorkType_Id = var_MCCWorkType_Id,
                -- PaymentCycle_Id = var_PaymentCycle_Id,
                PaymentType_Id= var_PaymentType_Id,
                -- MilkType_Id = var_MilkType_Id,
                -- CollectionShift_Id = var_CollectionShift_Id,
                Latitude = var_Latitude,
                Longitude = var_Longitude,
                Profile_Photo = var_Profile_Photo,
                Pan_Card_Photo = var_Pan_Card_Photo,
                FSSAILicense_Photo = var_FSSAILicense_Photo,
                Is_ManualWeight =  var_Is_ManualWeight,
                Is_ManualQuality =  var_Is_ManualQuality,
                Is_ManualShiftEnd =  var_Is_ManualShiftEnd,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id ,
                LastEditedBy_Name = var_User_Name  ,
                Pan_No = var_Pan_No,
                WithholdingTaxType_Id = var_WithholdingTaxType_Id,
                Plant_Code = var_Plant_Code,
                Is_Alternate = var_Is_Alternate
                where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;   
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_MCC_Id AS Result_Extra_Key;
			-- end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m005_mcc
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id ,
			LastEditedBy_Name = var_User_Name 
			where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_MCC_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'UpdateMCCCode') then
		begin
			Update m005_mcc
			set 
            MCC_Code = var_MCC_Code
			where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;    

			SELECT 1 AS Result_Id, 
			'Update' AS Result_Description, 
			var_MCC_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
