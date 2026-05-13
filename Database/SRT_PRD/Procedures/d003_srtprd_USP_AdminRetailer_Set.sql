-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRetailer_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRetailer_Set`(
	var_Method_Name VARCHAR(50),
    var_Org_Id VARCHAR(10),
	var_Retailer_Id VARCHAR(20),
	var_Retailer_Name VARCHAR(45),
    var_Dealer_Id VARCHAR(45),
    var_SalesArea_Id VARCHAR(20),
   
	var_Mobile_No VARCHAR(20),
	var_Contact_Person VARCHAR(45),
    var_Email_Id VARCHAR(45),
    var_Address_Line_1_Text longtext,
    var_Address_Line_2_Text longtext,
	var_Address_Line_3_Text longtext,
    var_State_Id VARCHAR(20),
	var_District_Id VARCHAR(20),
	var_Taluka_Id VARCHAR(20),
	var_Pincode VARCHAR(20),
    var_Pan_No varchar(20),
    var_MSME varchar(20),
    var_Aadhar_No varchar(20),
    var_ASME varchar(20),
    var_Bank_Id VARCHAR(45),
    var_Branch_Id VARCHAR(45),
    var_FSSAI_License_No VARCHAR(45),
    var_FSSAI_LicenseValidity_On DATETIME,
    var_GST_No VARCHAR(45),
    var_AgreementValidityPeriod VARCHAR(45),
    var_AgreementDoneFlag INT,
	var_Account_No VARCHAR(45),
	var_IFSC_Code VARCHAR(45),
	var_Account_Name VARCHAR(45),
    var_Shop_License_No VARCHAR(45),
    var_Pan_Card_Photo VARCHAR(255),
	var_Shop_License_Photo VARCHAR(255),
	var_Cheque_Leaf_Photo VARCHAR(255),
    var_Shop_Name_Photo VARCHAR(255),
    var_UdyamAadhar_Card_Photo VARCHAR(255),
    var_FSSAI_License_Photo VARCHAR(255),
    var_GST_Certificate_Photo VARCHAR(255),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_Is_Approved INT,
    var_Landline_Number varchar(255)
)
BEGIN
	IF (var_Method_Name = 'Create') THEN
		BEGIN
			DECLARE Duplicate_Flag INT;
            DECLARE New_Retailer_Id VARCHAR(20);
			DECLARE Year_Id VARCHAR(10);
            
            if exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Email_Id = var_Email_Id and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
				CALL USP_Number_Range ('mu09_retailer', Year_Id, 'MU09', '', New_Retailer_Id );
				
                INSERT INTO mu09_retailer(
					Org_Id, Retailer_Id, Retailer_Name, 
                    SalesArea_Id, Dealer_Id, 
                    Mobile_No, Contact_Person, Email_Id, 
                    Address_Line_1_Text, Address_Line_2_Text, Address_Line_3_Text,
                    State_Id, District_Id, Taluka_Id, 
                    Pincode, Pan_No, Shop_License_No, 
                    Bank_Id, Branch_Id, Account_No, IFSC_Code, Account_Name, 
                    FSSAI_License_No, FSSAI_LicenseValidity_On, GST_No, 
                    Pan_Card_Photo, Shop_License_Photo, Cheque_Leaf_Photo, 
                    Shop_Name_Photo, UdyamAadhar_Card_Photo, 
                    FSSAI_License_Photo, GST_Certificate_Photo, 
                    Is_Agreement_Done, 
                    AgreementValidiy_StartDate, 
                    AgreementValidity_EndDate, 
                    Is_Active, Is_Deleted, Is_Approved,
                    Created_On, CreatedBy_Id, CreatedBy_Name,
                    Approved_On, Approved_Id, Approved_Name,
                    Approval_Remarks,
                    MSME,
                    Aadhar_No,
                    ASME,
					Landline_Number
                ) 
                VALUES(
					var_Org_Id, New_Retailer_Id, var_Retailer_Name, 
                    var_SalesArea_Id, var_Dealer_Id, 
                    var_Mobile_No, var_Contact_Person, var_Email_Id, 
                    var_Address_Line_1_Text, var_Address_Line_2_Text, var_Address_Line_3_Text,
                    var_State_Id, var_District_Id, var_Taluka_Id, 
                    var_Pincode, var_Pan_No, var_Shop_License_No, 
                    var_Bank_Id, var_Branch_Id, var_Account_No, var_IFSC_Code, var_Account_Name, 
                    var_FSSAI_License_No, var_FSSAI_LicenseValidity_On, var_GST_No, 
                    var_Pan_Card_Photo, var_Shop_License_Photo, var_Cheque_Leaf_Photo, 
                    var_Shop_Name_Photo, var_UdyamAadhar_Card_Photo, 
                    var_FSSAI_License_Photo, var_GST_Certificate_Photo, 
                    var_AgreementDoneFlag, 
					STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', 1), '%m/%d/%Y'), 
                    STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', -1), '%m/%d/%Y'), 
                    var_Is_Active, var_Is_Deleted, var_Is_Approved,
                    CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name,
                    CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name,
                    'Retailer Created Through Admin Portal.',
                    var_MSME,
                    var_Aadhar_No,
                    var_ASME,
                    var_Landline_Number
                );
                
                
                
                
                /*
				Insert Into mu09_retailer
					(Org_Id, Retailer_Id,Retailer_Name,SalesArea_Id,Dealer_Id,
                    Mobile_No,Contact_Person,Email_Id,
					Address_Line_1_Text,Address_Line_2_Text,State_Id,District_Id,Taluka_Id,Pincode,
                    Pan_No,Shop_Latitude,Shop_Longitude,Shop_License_No,
                    Pan_Card_Photo,Shop_License_Photo,Cheque_Leaf_Photo,Shop_Name_Photo,
                    Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				Values (var_Org_Id, New_Retailer_Id,var_Retailer_Name,var_SalesArea_Id,var_Dealer_Id,
					var_Mobile_No,var_Contact_Person,var_Email_Id,
                    var_Address_Line_1_Text,var_Address_Line_2_Text, var_State_Id,var_District_Id,var_Taluka_Id,var_Pincode,
                    var_Pan_No,var_Shop_Latitude,var_Shop_Longitude,var_Shop_License_No,
					var_Pan_Card_Photo,var_Shop_License_Photo,var_Cheque_Leaf_Photo,var_Shop_Name_Photo,
                    var_Is_Active, var_Is_Deleted, Now(), var_User_Id,var_User_Name); */
				
                SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Retailer_Id AS Result_Extra_Key;
			END IF;
		END;
	ELSEIF (var_Method_Name = 'Update') THEN
		begin
			if exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Retailer_Id <> var_Retailer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Email_Id = var_Email_Id and Is_Deleted = 0 and Retailer_Id <> var_Retailer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Retailer_Id from mu09_retailer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and Retailer_Id <> var_Retailer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;

			else
				UPDATE mu09_retailer
                SET 
					Retailer_Name = var_Retailer_Name, 
                    SalesArea_Id = var_SalesArea_Id, 
                  
                    Dealer_Id = var_Dealer_Id, 
                    Mobile_No = var_Mobile_No, 
                    Contact_Person = var_Contact_Person, 
                    Email_Id = var_Email_Id, 
                    Address_Line_1_Text = var_Address_Line_1_Text,
                    Address_Line_2_Text = var_Address_Line_2_Text, 
                    Address_Line_3_Text = var_Address_Line_3_Text, 
                    State_Id = var_State_Id, 
                    District_Id = var_District_Id, 
                    Taluka_Id = var_Taluka_Id, 
                    Pincode = var_Pincode, 
                    Pan_No = var_Pan_No, 
                    Shop_License_No = var_Shop_License_No, 
                    Bank_Id = var_Bank_Id, 
                    Branch_Id = var_Branch_Id, 
                    Account_No = var_Account_No, 
                    IFSC_Code = var_IFSC_Code, 
                    Account_Name = var_Account_Name, 
                    FSSAI_License_No = var_FSSAI_License_No, 
                    FSSAI_LicenseValidity_On = var_FSSAI_LicenseValidity_On,
                    GST_No = var_GST_No, 
                    Pan_Card_Photo = var_Pan_Card_Photo, 
                    Shop_License_Photo = var_Shop_License_Photo, 
                    Cheque_Leaf_Photo = var_Cheque_Leaf_Photo, 
                    Shop_Name_Photo = var_Shop_Name_Photo, 
                    UdyamAadhar_Card_Photo = var_UdyamAadhar_Card_Photo, 
                    FSSAI_License_Photo = var_FSSAI_License_Photo, 
                    GST_Certificate_Photo = var_GST_Certificate_Photo, 
                    Is_Agreement_Done = var_AgreementDoneFlag, 
                    AgreementValidiy_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', 1), '%m/%d/%Y'), 
                    AgreementValidity_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', -1), '%m/%d/%Y'), 
                    Is_Active = var_Is_Active, 
                    Is_Deleted = var_Is_Deleted, 
                    Is_Approved = var_Is_Approved,
                    LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name  ,
                    MSME = var_MSME,
                    Aadhar_No = var_Aadhar_No,
                    ASME = var_ASME,
                    Landline_Number = var_Landline_Number
                WHERE Org_Id = var_Org_Id 
                AND Retailer_Id = var_Retailer_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Retailer_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		BEGIN
			UPDATE mu09_retailer
			SET 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			WHERE Org_Id = var_Org_Id
            AND Retailer_Id = var_Retailer_Id;    
            
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Retailer_Id AS Result_Extra_Key;
        END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
