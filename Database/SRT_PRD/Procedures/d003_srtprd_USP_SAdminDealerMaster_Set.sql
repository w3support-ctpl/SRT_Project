-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerMaster_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerMaster_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_XML_Data longtext)
BEGIN
SET SQL_SAFE_UPDATES = 0;


	set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Dealer/DealerData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Dealer/DealerData[', @k, ']');
                
		if exists(select 1 from mu08_dealer where Org_Id = var_Org_Id and Dealer_Code =
				extractValue(var_XML_Data, concat(@xpath,'/DealerCode')) ) then 
                
                
               /*
               update mu08_dealer 
               set Mobile_No = extractValue(var_XML_Data, concat(@xpath,'/MobileNo'))
                    where Org_Id = var_Org_Id and Dealer_Code =
					extractValue(var_XML_Data, concat(@xpath,'/DealerCode'));
			*/
            
				UPDATE mu08_dealer
					SET 
						Login_Name = extractValue(var_XML_Data, concat(@xpath,'/DealerName')),
						Dealer_Code = extractValue(var_XML_Data, concat(@xpath,'/DealerCode')),
						Dealer_Name = extractValue(var_XML_Data, concat(@xpath,'/DealerName')),
						-- SalesArea_Id = extractValue(var_XML_Data, concat(@xpath,'/SalesGroup')),
						-- SalesUser_Id = extractValue(var_XML_Data, concat(@xpath,'/SalesUser')),
						Phone_No = extractValue(var_XML_Data, concat(@xpath,'/PhoneNo')),
						Mobile_No = extractValue(var_XML_Data, concat(@xpath,'/MobileNo')),
						Contact_Person = extractValue(var_XML_Data, concat(@xpath,'/ContactPerson')),
						Email_Id = extractValue(var_XML_Data, concat(@xpath,'/EmailId')),
						Address_Line_1_Text = extractValue(var_XML_Data, concat(@xpath,'/AddressLine1')),
						Address_Line_2_Text = extractValue(var_XML_Data, concat(@xpath,'/AddressLine2')),
						Address_Line_3_Text = extractValue(var_XML_Data, concat(@xpath,'/AddressLine3')),
						State_Name = extractValue(var_XML_Data, concat(@xpath,'/State')),
						District_Name = extractValue(var_XML_Data, concat(@xpath,'/District')),
						Taluka_Name = extractValue(var_XML_Data, concat(@xpath,'/CityTaluka')),
						Village_Name = '',
						Pincode = extractValue(var_XML_Data, concat(@xpath,'/PinCode')),
						Pan_No = '',
						Bank_Name = extractValue(var_XML_Data, concat(@xpath,'/BankName')),
						Branch_Name = extractValue(var_XML_Data, concat(@xpath,'/BranchName')),
						Account_No = extractValue(var_XML_Data, concat(@xpath,'/AccountNo')),
						IFSC_Code = extractValue(var_XML_Data, concat(@xpath,'/IFSCCode')),
						Account_Name = extractValue(var_XML_Data, concat(@xpath,'/AccountName')),
						MSME_No = extractValue(var_XML_Data, concat(@xpath,'/MSMENo')),
						FSSAI_License_No = extractValue(var_XML_Data, concat(@xpath,'/FSSAILicenseNo')),
						GST_No = extractValue(var_XML_Data, concat(@xpath,'/GSTNo'))
					where Org_Id = var_Org_Id and Dealer_Code =
					extractValue(var_XML_Data, concat(@xpath,'/DealerCode'));
                    
			else
            
			
				CALL USP_Number_Range ('mu08_dealer', @Year_Id, 'MU08', '', @New_dealer_Id );


                insert into mu08_dealer (
                Org_Id, Dealer_Id, Login_Name , Login_Password, Dealer_Code, Dealer_Name, 
                SalesArea_Id, SalesUser_Id, Phone_No , Mobile_No, Contact_Person, Is_MobileNo_Verified, 
                Email_Id, Address_Line_1_Text, Address_Line_2_Text , Address_Line_3_Text, State_Name,
                District_Name, Taluka_Name, Village_Name, Pincode , Pan_No, Bank_Name, Branch_Name,
                Account_No, IFSC_Code, Account_Name, MSME_No, FSSAI_License_No, FSSAI_LicenseValidity_On,
                GST_No, Is_Active, Is_Deleted, Is_PasswordReset, Created_On 
                )  value (
                var_Org_Id ,@New_dealer_Id , extractValue(var_XML_Data, concat(@xpath,'/DealerName')),
                'srt@123',
                extractValue(var_XML_Data, concat(@xpath,'/DealerCode')),
                extractValue(var_XML_Data, concat(@xpath,'/DealerName')),
				extractValue(var_XML_Data, concat(@xpath,'/SalesGroup')),
				extractValue(var_XML_Data, concat(@xpath,'/SalesUser')),
                extractValue(var_XML_Data, concat(@xpath,'/PhoneNo')),
				extractValue(var_XML_Data, concat(@xpath,'/MobileNo')),
                extractValue(var_XML_Data, concat(@xpath,'/ContactPerson')),
                0,
				extractValue(var_XML_Data, concat(@xpath,'/EmailId')),
				extractValue(var_XML_Data, concat(@xpath,'/AddressLine1')),
				extractValue(var_XML_Data, concat(@xpath,'/AddressLine2')),
				extractValue(var_XML_Data, concat(@xpath,'/AddressLine3')), 
				extractValue(var_XML_Data, concat(@xpath,'/State')), 
				extractValue(var_XML_Data, concat(@xpath,'/District')), 
				extractValue(var_XML_Data, concat(@xpath,'/CityTaluka')), 
                '',
                extractValue(var_XML_Data, concat(@xpath,'/PinCode')), 
                '',
			    extractValue(var_XML_Data, concat(@xpath,'/BankName')), 
			   extractValue(var_XML_Data, concat(@xpath,'/BranchName')), 
			   extractValue(var_XML_Data, concat(@xpath,'/AccountNo')), 
				extractValue(var_XML_Data, concat(@xpath,'/IFSCCode')), 
               extractValue(var_XML_Data, concat(@xpath,'/AccountName')), 
               extractValue(var_XML_Data, concat(@xpath,'/MSMENo')),
                extractValue(var_XML_Data, concat(@xpath,'/FSSAILicenseNo')),
				now(),
                -- CAST(extractValue(var_XML_Data, concat(@xpath,'/FSSAILicenseValidityDate')) AS DATE)
                extractValue(var_XML_Data, concat(@xpath,'/GSTNo')),
                -- extractValue(var_XML_Data, concat(@xpath,'/SecurityDepositAmount')),
               1, 0 ,1, NOW() ) ;
               
			end if;
   
			END WHILE;
            
 
		SELECT 1 AS Result_Id, 
		'Downloaded' AS Result_Description, 
		'' AS Result_Extra_Key;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
