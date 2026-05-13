-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDealer_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDealer_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_SalesArea_Id varchar(20), 
    var_Dealer_Id varchar(20),
    var_Dealer_Name varchar(50),
	var_Dealer_Code varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select dealer.Org_Id, dealer.Dealer_Id, 
				salesarea.SalesArea_Id, ifnull(salesarea.SalesArea_Name , '-') as SalesArea_Name, 
                dealer.Dealer_Name, dealer.Dealer_Code, ifnull(SalesUser_Name , '-') as SalesUser_Name, 
				dealer.Phone_No as Mobile_No, ifnull(mu12.SalesUser_Name,'') as Contact_Person,
                dealer.Is_Active, dealer.Is_Deleted
            from mu08_dealer dealer
			left join m013_salesarea salesarea on salesarea.SalesArea_Id = dealer.SalesArea_Id 
				and salesarea.Org_Id = dealer.Org_Id 
            left join mu12_sales_user mu12 on dealer.Org_Id = mu12.Org_Id and dealer.SalesUser_Id = mu12.SalesUser_Id    
            where dealer.Org_Id = var_Org_Id 
            and dealer.Is_Deleted = 0 
            and ifnull(dealer.SalesArea_Id ,'' ) like var_SalesArea_Id
            and dealer.Dealer_Name like var_Dealer_Name
            and dealer.Dealer_Code like var_Dealer_Code
            order by dealer.Dealer_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			SELECT Org_Id, Dealer_Id, 
				Dealer_Code, Dealer_Name, SalesArea_Id, SalesUser_Id, Phone_No, 
                Mobile_No, Contact_Person, Email_Id, Pan_No,
                IFNULL(Address_Line_1_Text,'') AS Address_Line_1_Text, 
                IFNULL(Address_Line_2_Text,'') AS Address_Line_2_Text, 
                IFNULL(Address_Line_3_Text,'') AS Address_Line_3_Text,
                IFNULL(State_Name,'') AS State_Name, 
                IFNULL(District_Name,'') AS District_Name, 
                IFNULL(Taluka_Name,'') AS Taluka_Name,
                IFNULL(Village_Name,'') AS Village_Name, 
                IFNULL(Pincode,'') AS Pincode, 
                Is_Active,
                IFNULL(Bank_Name,'') AS Bank_Name, 
                IFNULL(Branch_Name,'') AS Branch_Name, 
                IFNULL(Account_No,'') AS Account_No,
                IFNULL(IFSC_Code,'') AS IFSC_Code, 
                IFNULL(Account_Name,'') AS Account_Name, 
                IFNULL(MSME_No,'') AS MSME_No, 
                IFNULL(FSSAI_License_No,'') AS FSSAI_License_No, 
                IFNULL(GST_No,'') AS GST_No,
                DATE_FORMAT(FSSAI_LicenseValidity_On, '%Y-%m-%d') AS FSSAI_LicenseValidity_On, 
                Profile_Photo, Pan_Card_Photo, Aadhar_Card_Photo, Shop_License_Photo, 
                Cheque_Leaf_Photo, UdyamAadhar_Card_Photo, FSSAI_License_Photo, 
                GST_Certificate_Photo, Is_Agreement_Done, 
                CONCAT(
                DATE_FORMAT(AgreementValidiy_StartDate,'%m/%d/%Y'),
                ' - ', 
                DATE_FORMAT(AgreementValidity_EndDate,'%m/%d/%Y')
                ) AS Agreement_Validity_Period, 
                IFNULL(SecurityDepositAmount,'') AS SecurityDepositAmount, 
                IFNULL(ShopLatitude,'') AS ShopLatitude, 
                IFNULL(ShopLongitude,'') AS ShopLongitude,
                IFNULL(Payment_Url,'') AS Payment_Url,
                IFNULL(Is_Payment,0) AS Is_Payment,
                IFNULL(Login_Password,'') AS Login_Password,
                IFNULL(CrateLimit,'') AS CrateLimit
			FROM mu08_dealer
			WHERE Org_Id = var_Org_Id
            AND Is_Deleted = 0
            AND Dealer_Id = var_Dealer_Id;
        
        
        
        
        
        
        
        
			/*
			select mu08.Org_Id, Dealer_Id,Dealer_Code, Dealer_Name, SalesArea_Id, Phone_No, Mobile_No,
            Contact_Person,Email_Id,Pan_No,
            State_Id,District_Id,Taluka_Id,Village_Id,Address_Line_1_Text, Address_Line_2_Text, Pincode,
            mu08.Bank_Id,mu08.Branch_Id,m016.IFSC_Code,Account_No,Account_Name,
            MSME_No,FSSAI_License_No,date_format(FSSAI_LicenseValidity_On, '%Y-%m-%d') as FSSAI_LicenseValidity_On,FSSAI_LicenseValidity_On,GST_No,
            Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,Shop_License_Photo,Cheque_Leaf_Photo,
            UdyamAadhar_Card_Photo,FSSAI_License_Photo,GST_Certificate_Photo,
            mu08.Is_Active, mu08.Is_Deleted 
            from mu08_dealer mu08
            left join m016_branch m016 on m016.Branch_Id = mu08.Branch_Id
            and m016.Org_Id = mu08.Org_Id
            where mu08.Org_Id = var_Org_Id and mu08.Dealer_Id = var_Dealer_Id 
            and mu08.Is_Deleted =0;
            */
		end;
	elseif (var_Method_Name = 'Get_V2') then
		begin
        
			select 
			ifnull(mu08.Dealer_Id,'') as Dealer_Id,
			ifnull(mu08.Dealer_Code,'') as Dealer_Code,
			ifnull(mu08.Dealer_Name,'') as Dealer_Name,
			ifnull(m013.SalesArea_Name,'') as SalesArea_Name,
			ifnull(mu12.SalesUser_Name,'') as SalesUser_Name,
			ifnull(mu08.Phone_No,'') as Phone_No,
			ifnull(mu08.Mobile_No,'') as Mobile_No,
			ifnull(mu08.Contact_Person,'') as Contact_Person,
			ifnull(mu08.Email_Id,'') as Email_Id,
			ifnull(mu08.Address_Line_1_Text,'') as Address_Line_1_Text,
			ifnull(mu08.Address_Line_2_Text,'') as Address_Line_2_Text,
			ifnull(mu08.Address_Line_3_Text,'') as Address_Line_3_Text,
			ifnull(mu08.State_Name,'') as State_Name,
			ifnull(mu08.District_Name,'') as District_Name,
			ifnull(mu08.Taluka_Name,'') as Taluka_Name,
			ifnull(mu08.Village_Name,'') as Village_Name,
			ifnull(mu08.Pincode,'') as Pincode,
			ifnull(mu08.Pan_No,'') as Pan_No,
			ifnull(mu08.Bank_Name,'') as Bank_Name,
			ifnull(mu08.Branch_Name,'') as Branch_Name,
			ifnull(mu08.Account_No,'') as Account_No,
			ifnull(mu08.IFSC_Code,'') as IFSC_Code,
			ifnull(mu08.Account_Name,'') as Account_Name,
			ifnull(mu08.MSME_No,'') as MSME_No,
			ifnull(mu08.FSSAI_License_No,'') as FSSAI_License_No,
			ifnull(date_format(mu08.FSSAI_LicenseValidity_On, '%d %M %Y'),'') as FSSAI_LicenseValidity_On,
			ifnull(mu08.GST_No,'') as GST_No,
			ifnull(date_format(mu08.AgreementValidiy_StartDate, '%d %M %Y'),'') as AgreementValidiy_StartDate,
			ifnull(date_format(mu08.AgreementValidity_EndDate, '%d %M %Y'),'') as AgreementValidity_EndDate,
			ifnull(mu08.SecurityDepositAmount,'') as SecurityDepositAmount,
			ifnull(mu08.ShopLatitude,'') as ShopLatitude,
			ifnull(mu08.ShopLongitude,'') as ShopLongitude,
			ifnull(mu08.Payment_Url,'') as Payment_Url,
			ifnull(mu08.Is_Payment,'') as Is_Payment,
			ifnull(mu08.CrateLimit,'') as CrateLimit,
			mu08.Is_Active, 
			mu08.Is_Deleted
			from mu08_dealer mu08
			left join m013_salesarea m013 on
			m013.Org_Id = mu08.Org_Id
			and m013.SalesArea_Id = mu08.SalesArea_Id
			left join mu12_sales_user mu12  on
			mu12.Org_Id = mu08.Org_Id 
			and mu12.SalesUser_Id = mu08.SalesUser_Id
			where mu08.Org_Id = var_Org_Id 
			and mu08.Is_Deleted = 0 
			and ifnull(mu08.SalesArea_Id,'') like var_SalesArea_Id
			and mu08.Dealer_Name like var_Dealer_Name
			and mu08.Dealer_Code like var_Dealer_Code
			order by mu08.Dealer_Name;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
