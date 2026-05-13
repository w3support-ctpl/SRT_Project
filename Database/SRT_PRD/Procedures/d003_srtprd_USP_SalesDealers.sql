-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesDealers` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesDealers`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
	Var_SalesUser_Id varchar(20),
    Var_Profile_Id varchar(20),
    Var_Dealer_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(var_Method_Name = 'GetDealers') then
			
		select Dealer_Id , Dealer_Name , Dealer_Code , 
		TRIM(concat(Address_Line_1_Text, ' ' , Address_Line_2_Text , ' '  , Address_Line_3_Text  , ' ' ,  Village_Name , ' ' , District_Name , ' ' , State_Name , ' ' ,  Pincode  )) as Address
		from mu08_dealer where Org_Id = var_Org_Id and SalesUser_Id in (Var_SalesUser_Id)
        and Is_Active = 1;
	elseif(var_Method_Name = 'GetOneDealers') then
				SELECT mu08.Org_Id, mu08.Dealer_Id, 
				IFNULL(mu08.Dealer_Code,'') as Dealer_Code, 
                IFNULL(mu08.Dealer_Name,'') as Dealer_Name, 
                IFNULL(mu08.SalesArea_Id,'') as SalesArea_Id, 
                IFNULL(m013.SalesArea_Name,'') as SalesArea_Name, 
                IFNULL(mu08.SalesUser_Id,'') as SalesUser_Id, 
                IFNULL(mu12.SalesUser_Name,'') as SalesUser_Name, 
                IFNULL(mu08.Phone_No,'') as Phone_No, 
                IFNULL(mu08.Mobile_No,'') as Mobile_No, ifnull( mu08.Contact_Person,'') as Contact_Person, 
                IFNULL(mu08.Email_Id,'') as Email_Id, ifnull(mu08.Pan_No,'') as Pan_No,
                IFNULL(mu08.Address_Line_1_Text,'') AS Address_Line_1_Text, 
                IFNULL(mu08.Address_Line_2_Text,'') AS Address_Line_2_Text, 
                IFNULL(mu08.Address_Line_3_Text,'') AS Address_Line_3_Text,
                IFNULL(mu08.State_Name,'') AS State_Name, 
                IFNULL(mu08.District_Name,'') AS District_Name, 
                IFNULL(mu08.Taluka_Name,'') AS Taluka_Name,
                IFNULL(mu08.Village_Name,'') AS Village_Name,
                IFNULL(mu08.Pincode,'') AS Pincode,
                ifnull(mu08.Is_Active,'') as Is_Active,
                IFNULL(mu08.Bank_Name,'') AS Bank_Name, 
                IFNULL(mu08.Branch_Name,'') AS Branch_Name, 
                IFNULL(mu08.Account_No,'') AS Account_No,
                IFNULL(mu08.IFSC_Code,'') AS IFSC_Code, 
                IFNULL(mu08.Account_Name,'') AS Account_Name, 
                IFNULL(mu08.MSME_No,'') AS MSME_No, 
                IFNULL(mu08.FSSAI_License_No,'') AS FSSAI_License_No, 
                IFNULL(mu08.GST_No,'') AS GST_No,
                
                DATE_FORMAT(mu08.FSSAI_LicenseValidity_On, '%Y-%m-%d') AS FSSAI_LicenseValidity_On, 
                ifnull(mu08.Profile_Photo,'') as Profile_Photo, 
                ifnull(mu08.Pan_Card_Photo,'') as Pan_Card_Photo, 
                ifnull(mu08.Aadhar_Card_Photo,'') as Aadhar_Card_Photo, ifnull(mu08.Shop_License_Photo,'') as Shop_License_Photo, 
                ifnull(mu08.Cheque_Leaf_Photo,'') as Cheque_Leaf_Photo, ifnull(mu08.UdyamAadhar_Card_Photo,'') as UdyamAadhar_Card_Photo, ifnull(mu08.FSSAI_License_Photo,'') as FSSAI_License_Photo, 
                ifnull(mu08.GST_Certificate_Photo,'') as GST_Certificate_Photo, ifnull(mu08.Is_Agreement_Done,'') as Is_Agreement_Done, 
                CONCAT(
                ifnull(DATE_FORMAT(mu08.AgreementValidiy_StartDate,'%m/%d/%Y'),''),
                ' - ', 
                ifnull(DATE_FORMAT(mu08.AgreementValidity_EndDate,'%m/%d/%Y'),'')
                ) AS Agreement_Validity_Period, 
                IFNULL(mu08.SecurityDepositAmount,'') AS SecurityDepositAmount, 
                IFNULL(mu08.ShopLatitude,'') AS ShopLatitude, 
                IFNULL(mu08.ShopLongitude,'') AS ShopLongitude,
                IFNULL(mu08.Payment_Url,'') AS Payment_Url,
                IFNULL(mu08.Is_Payment,0) AS Is_Payment,
                IFNULL(mu08.Login_Password,'') AS Login_Password
			FROM mu08_dealer mu08
            left join m013_salesarea m013 on
            m013.Org_Id = mu08.Org_Id
            and m013.SalesArea_Id = mu08.SalesArea_Id
            left join mu12_sales_user mu12 on
            mu08.Org_Id = mu12.Org_Id
            and mu08.SalesUser_Id = mu12.SalesUser_Id
			WHERE mu08.Org_Id = var_Org_Id
            and mu08.Is_Active = 1
            AND mu08.Dealer_Id = Var_Dealer_Id;
	elseif(var_Method_Name = 'GetDealerPayment') then
		select 
		ifnull(Payment_Url,'') as Payment_Url ,
		ifnull(Is_Payment,0) as Is_Payment 
		from mu08_dealer
		where Org_Id = var_Org_Id 
        and Is_Active = 1
		and Dealer_Id = Var_Dealer_Id 
		limit 1;
	end if;
        
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
