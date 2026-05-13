-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDealer_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDealer_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Dealer_Id varchar(20),
	var_Dealer_Name varchar(100),
    var_Dealer_Code varchar(45),
    var_SalesArea_Id varchar(20),
    var_SalesUser_Id varchar(20),
	var_Mobile_No varchar(20),
    var_Phone_No varchar(20),
	var_Contact_Person varchar(45),
    var_Email_Id varchar(45),
    var_Address_Line_1_Text longtext,
    var_Address_Line_2_Text longtext,
	var_State_Id varchar(20),
	var_District_Id varchar(20),
	var_Taluka_Id varchar(20),
	var_Pincode varchar(20),
    var_Pan_No varchar(20),
	var_Bank_Id varchar(45),
    var_Branch_Id varchar(45),
    var_MSME_No varchar(45),
    var_FSSAI_License_No varchar(45),
    var_FSSAI_LicenseValidity_On DATETIME,
    var_GST_No varchar(45),
    var_AgreementValidityPeriod varchar(45),
    var_AgreementDoneFlag INT,
	var_Account_No varchar(45),
	var_IFSC_Code varchar(45),
	var_Account_Name varchar(45),
    var_Profile_Photo varchar(255),
	var_Pan_Card_Photo varchar(255),
	var_Aadhar_Card_Photo varchar(255),
    var_Shop_License_Photo varchar(255),
	var_Cheque_Leaf_Photo varchar(255),
	var_UdyamAadhar_Card_Photo varchar(255),
    var_FSSAI_License_Photo varchar(255),
    var_GST_Certificate_Photo varchar(255),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_Shop_Latitude VARCHAR(20),
    var_Shop_Longitude VARCHAR(20),
    
    
    var_Is_Payment int,
    var_Payment_Url longtext,
    var_Login_Password VARCHAR(20)
    
)
BEGIN
	
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Dealer_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            
            if exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Phone_No = var_Phone_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Phone Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Email_Id = var_Email_Id and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and MSME_No = var_MSME_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'MSME Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and FSSAI_License_No = var_FSSAI_License_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'FSSAI License Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu08_dealer', Year_Id, 'MU08', '', New_Dealer_Id );
				set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
                
                INSERT INTO mu08_dealer(
					Org_Id, Dealer_Id, Login_Name, Login_Password, 
                    Dealer_Code, Dealer_Name, 
                    
                    SalesArea_Id, SalesUser_Id, Pan_No,
                    Phone_No, Mobile_No, Contact_Person, Email_Id, 
                    
                    Address_Line_1_Text, Address_Line_2_Text, State_Id, 
                    District_Id, Taluka_Id, Pincode,
                    
                    Bank_Id, Branch_Id, Account_No, IFSC_Code, Account_Name, 
                    
                    MSME_No, FSSAI_License_No, FSSAI_LicenseValidity_On, GST_No, 
                    
                    Profile_Photo, Pan_Card_Photo, Aadhar_Card_Photo, 
                    Shop_License_Photo, Cheque_Leaf_Photo, UdyamAadhar_Card_Photo, 
                    FSSAI_License_Photo, GST_Certificate_Photo, 
                    
                    Is_Agreement_Done, 
                    AgreementValidiy_StartDate, 
                    AgreementValidity_EndDate, 
                    Is_Active, Is_Deleted, 
                    Created_On, CreatedBy_Id, CreatedBy_Name,
                    Login_Password,Payment_Url,Is_Payment
                    
                ) 
                VALUES(
					var_Org_Id, New_Dealer_Id, var_Mobile_No, New_Password,
                    var_Dealer_Code, var_Dealer_Name, 
                    
					var_SalesArea_Id, var_SalesUser_Id, var_Pan_No,
                    var_Phone_No, var_Mobile_No, var_Contact_Person, var_Email_Id,
                    
                    var_Address_Line_1_Text, var_Address_Line_2_Text, var_State_Id, 
                    var_District_Id, var_Taluka_Id, var_Pincode,
                    
					var_Bank_Id, var_Branch_Id, var_Account_No, var_IFSC_Code, var_Account_Name, 

					var_MSME_No, var_FSSAI_License_No, var_FSSAI_LicenseValidity_On, var_GST_No, 
                    
                    var_Profile_Photo, var_Pan_Card_Photo, var_Aadhar_Card_Photo, 
                    var_Shop_License_Photo, var_Cheque_Leaf_Photo, var_UdyamAadhar_Card_Photo, 
                    var_FSSAI_License_Photo, var_GST_Certificate_Photo, 
                    
                    var_AgreementDoneFlag, 
                    STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', 1), '%m/%d/%Y'), 
                    STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', -1), '%m/%d/%Y'), 
                    var_Is_Active, var_Is_Deleted, 
                    CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name,
                    var_Login_Password,var_Payment_Url,var_Is_Payment
                    
                );
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Dealer_Id AS Result_Extra_Key;
                
			end if;
		end;
        
	elseif (var_Method_Name = 'UpdateAll') then
		begin
			if exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Phone_No = var_Phone_No and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Phone Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Email_Id = var_Email_Id and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Email already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and MSME_No = var_MSME_No and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id) then
				SELECT -1 AS Result_Id, 
                'MSME Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and FSSAI_License_No = var_FSSAI_License_No and Is_Deleted = 0 and Dealer_Id <> var_Dealer_Id) then
				SELECT -1 AS Result_Id, 
                'FSSAI License Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				UPDATE mu08_dealer
                SET 
					Org_Id = var_Org_Id, 
					Login_Name = var_Mobile_No, 
					Dealer_Code = var_Dealer_Code, 
					Dealer_Name = var_Dealer_Name, 
					SalesArea_Id = var_SalesArea_Id, 
					SalesUser_Id = var_SalesUser_Id, 
					Pan_No = var_Pan_No,
					Phone_No = var_Phone_No, 
					Mobile_No = var_Mobile_No, 
					Contact_Person = var_Contact_Person, 
					Email_Id = var_Email_Id, 
					Address_Line_1_Text = var_Address_Line_1_Text, 
					Address_Line_2_Text = var_Address_Line_2_Text, 
					State_Id = var_State_Id, 
					District_Id = var_District_Id, 
					Taluka_Id = var_Taluka_Id, 
					Pincode = var_Pincode,
					Bank_Id = var_Bank_Id, 
					Branch_Id =var_Branch_Id, 
					Account_No = var_Account_No, 
					IFSC_Code = var_IFSC_Code, 
					Account_Name = var_Account_Name, 
					MSME_No = var_MSME_No, 
					FSSAI_License_No = var_FSSAI_License_No, 
					FSSAI_LicenseValidity_On = var_FSSAI_LicenseValidity_On, 
					GST_No = var_GST_No, 
					Profile_Photo = var_Profile_Photo, 
					Pan_Card_Photo = var_Pan_Card_Photo, 
					Aadhar_Card_Photo = var_Aadhar_Card_Photo, 
					Shop_License_Photo = var_Shop_License_Photo, 
					Cheque_Leaf_Photo = var_Cheque_Leaf_Photo, 
					UdyamAadhar_Card_Photo = var_UdyamAadhar_Card_Photo, 
					FSSAI_License_Photo = var_FSSAI_License_Photo, 
					GST_Certificate_Photo = var_GST_Certificate_Photo, 
					Is_Agreement_Done = var_AgreementDoneFlag, 
					AgreementValidiy_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', 1), '%m/%d/%Y'), 
					AgreementValidity_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', -1), '%m/%d/%Y'), 
					Is_Active = var_Is_Active, 
					Is_Deleted = var_Is_Deleted, 
					LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name ,
                    
                    Login_Password = var_Login_Password ,
                    Payment_Url = var_Payment_Url ,
                    Is_Payment = var_Is_Payment 
                    
                where Org_Id = var_Org_Id 
                and Dealer_Id = var_Dealer_Id;   

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Dealer_Id AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Update') then
	begin
			UPDATE mu08_dealer
                SET SalesUser_Id = var_SalesUser_Id, 
                SalesArea_Id = var_SalesArea_Id, 
					Is_Agreement_Done = var_AgreementDoneFlag, 
					AgreementValidiy_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', 1), '%m/%d/%Y'), 
					AgreementValidity_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_AgreementValidityPeriod, ' - ', -1), '%m/%d/%Y'), 
					ShopLatitude = var_Shop_Latitude, 
					ShopLongitude = var_Shop_Longitude, 
					LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
					LastEditedBy_Id = var_User_Id,
					LastEditedBy_Name = var_User_Name ,
                    Login_Password = var_Login_Password ,
                    Payment_Url = var_Payment_Url ,
                    Is_Payment = var_Is_Payment ,
                    Is_Active = var_Is_Active, 
					Is_Deleted = var_Is_Deleted
                where Org_Id = var_Org_Id 
                and Dealer_Id = var_Dealer_Id;   
                
                UPDATE mu09_retailer
                SET SalesUser_Id = var_SalesUser_Id,
                SalesArea_Id = var_SalesArea_Id
                where Org_Id = var_Org_Id 
                and Dealer_Id = var_Dealer_Id;  

				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Dealer_Id AS Result_Extra_Key;
	end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu08_dealer
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id and Dealer_Id = var_Dealer_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Dealer_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
