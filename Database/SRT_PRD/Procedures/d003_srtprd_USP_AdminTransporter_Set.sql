-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTransporter_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTransporter_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Transporter_Id varchar(20),
	var_Transporter_Name varchar(45),
    var_Transporter_Code varchar(45),
    var_ContactPerson_Name varchar(45),
	var_Mobile_No varchar(20),
    var_Address_Text longtext,
    var_State_Id varchar(20),
	var_District_Id varchar(20),
	var_Taluka_Id varchar(20),
    var_Village_Id varchar(20),
    var_Bank_Id varchar(45),
    var_Branch_Id varchar(45),
    var_LicenseValidity_On datetime,
	var_Account_No varchar(45),
	var_Account_Name varchar(45),
	var_Company_Pan_No VARCHAR(10),
	var_FSSAI_License_No VARCHAR(20),
    var_Profile_Photo varchar(255),
	var_Pan_Card_Photo varchar(255),
	var_Aadhar_Card_Photo varchar(255),
    var_Company_Pan_Card_Photo varchar(255),
	var_FSSAI_License_Photo varchar(255),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_WithholdingTaxType_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Transporte_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Transporter_Id from m009_transporter where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Transporter_Id from m009_transporter where Org_Id = var_Org_Id and Company_Pan_No = var_Company_Pan_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m009_transporter', Year_Id, 'M009', '', New_Transporte_Id );
            
				Insert Into m009_transporter
                (Org_Id, Transporter_Id,Transporter_Name, Mobile_No,ContactPerson_Name,
                Address_Text,State_Id,District_Id,Taluka_Id,Village_Id,
                Bank_Id,Branch_Id,LicenseValidity_On,Account_No,Account_Name,
                Company_Pan_No,FSSAI_License_No,Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,
                Company_Pan_Card_Photo,FSSAI_License_Photo,
                Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,WithholdingTaxType_Id)
				Values (var_Org_Id, New_Transporte_Id,var_Transporter_Name,var_Mobile_No,var_ContactPerson_Name,
                var_Address_Text,var_State_Id,var_District_Id,var_Taluka_Id,var_Village_Id,
                var_Bank_Id,var_Branch_Id,var_LicenseValidity_On,var_Account_No,var_Account_Name,
                var_Company_Pan_No,var_FSSAI_License_No,var_Profile_Photo,var_Pan_Card_Photo,var_Aadhar_Card_Photo,
                var_Company_Pan_Card_Photo,var_FSSAI_License_Photo,
				var_Is_Active, var_Is_Deleted,Now(), var_User_Id,var_User_Name,var_WithholdingTaxType_Id); 
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Transporte_Id AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			if exists(select Transporter_Id from m009_transporter where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Transporter_Id <> var_Transporter_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Transporter_Id from m009_transporter where Org_Id = var_Org_Id and Company_Pan_No = var_Company_Pan_No and Is_Deleted = 0 and Transporter_Id <> var_Transporter_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m009_transporter
                set 
                Transporter_Name = var_Transporter_Name,
                Mobile_No = var_Mobile_No,
				ContactPerson_Name = var_ContactPerson_Name,
                Address_Text = var_Address_Text,
                State_Id = var_State_Id,
                District_Id = var_District_Id,
                Taluka_Id = var_Taluka_Id,
                Village_Id = var_Village_Id,
                Bank_Id = var_Bank_Id, 
                Branch_Id = var_Branch_Id,
                LicenseValidity_On = var_LicenseValidity_On,
                Account_No = var_Account_No,
                Account_Name = var_Account_Name,
                Company_Pan_No = var_Company_Pan_No,
                FSSAI_License_No = var_FSSAI_License_No,
                Profile_Photo = var_Profile_Photo,
                Pan_Card_Photo = var_Pan_Card_Photo,
                Aadhar_Card_Photo = var_Aadhar_Card_Photo,
                Company_Pan_Card_Photo = var_Company_Pan_Card_Photo,
                FSSAI_License_Photo = var_FSSAI_License_Photo,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = NOW(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name ,
                WithholdingTaxType_Id = var_WithholdingTaxType_Id
                where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Transporter_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m009_transporter
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Transporter_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'UpdateTransporterCode') then
		begin
			Update m009_transporter
			set 
            Transporter_Code = var_Transporter_Code
			where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;    

			SELECT 1 AS Result_Id, 
			'Update' AS Result_Description, 
			var_Transporter_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
