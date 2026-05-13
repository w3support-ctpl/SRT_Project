-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRetailerAuthorization_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRetailerAuthorization_Set`(
	var_Org_Id VARCHAR(20),
	var_Method_Name VARCHAR(20),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
	var_Retailer_Id VARCHAR(20),
	var_Approval_Remarks LONGTEXT,
	var_Retailer_Name VARCHAR(45),
	var_Dealer_Id VARCHAR(20),
	var_SalesArea_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_Mobile_No VARCHAR(20),
    var_Contact_Person VARCHAR(45),
    var_Email_Id VARCHAR(45),
    var_Address_Line_1_Text LONGTEXT,
    var_Address_Line_2_Text LONGTEXT,
    var_State_Id VARCHAR(20),
    var_District_Id VARCHAR(20),
    var_Taluka_Id VARCHAR(20),
    var_Pincode VARCHAR(10),
    var_Pan_No VARCHAR(20),
    var_Bank_Id VARCHAR(20),
    var_Branch_Id VARCHAR(20),
    var_FSSAI_License_No VARCHAR(20),
    var_FSSAI_LicenseValidity_On VARCHAR(45),
    var_GST_No VARCHAR(20),
    var_AgreementValidityPeriod VARCHAR(45),
    var_AgreementDoneFlag INT,
    var_Account_No VARCHAR(45),
    var_IFSC_Code VARCHAR(45),
    var_Account_Name VARCHAR(45),
    var_Shop_License_No VARCHAR(20),
    var_Pan_Card_Photo VARCHAR(255),
    var_Shop_License_Photo VARCHAR(255),
    var_Cheque_Leaf_Photo VARCHAR(255),
    var_Shop_Name_Photo VARCHAR(255),
    var_UdyamAadhar_Card_Photo VARCHAR(255),
    var_FSSAI_License_Photo VARCHAR(255),
    var_GST_Certificate_Photo VARCHAR(255),
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_Is_Approved INT
)
BEGIN
	IF (var_Method_Name = 'Update') THEN
		BEGIN
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
            
				Insert into temp(text) value (concat(var_Retailer_Id));
            
				UPDATE mu09_retailer
                SET 
					Retailer_Name = var_Retailer_Name, 
                    SalesArea_Id = var_SalesArea_Id, 
                    SalesUser_Id = var_SalesUser_Id, 
                    Dealer_Id = var_Dealer_Id, 
                    Mobile_No = var_Mobile_No, 
                    Contact_Person = var_Contact_Person, 
                    Email_Id = var_Email_Id, 
                    Address_Line_1_Text = var_Address_Line_1_Text,
                    Address_Line_2_Text = var_Address_Line_2_Text, 
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
					LastEditedBy_Name = var_User_Name,
                    Approval_Remarks = var_Approval_Remarks,
                    Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                    Approved_Id = var_User_Id,
                    Approved_Name = var_User_Name
                WHERE Org_Id = var_Org_Id 
                AND Retailer_Id = var_Retailer_Id;   
				
                -- sending success/error message
                IF(var_Is_Approved = 1) THEN
                BEGIN
					SELECT 1 AS Result_Id, 
					'Approved' AS Result_Description, 
					var_Retailer_Id AS Result_Extra_Key;
                END;
                ELSEIF(var_Is_Approved = -1) THEN
                BEGIN
					SELECT 1 AS Result_Id, 
					'Rejected' AS Result_Description, 
					var_Retailer_Id AS Result_Extra_Key;
                END;
                ELSE
                BEGIN
					SELECT -1 AS Result_Id, 
					'Failed' AS Result_Description, 
					var_Retailer_Id AS Result_Extra_Key;
                END;
                END IF;
                
				
			END IF;
        END;
		END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
