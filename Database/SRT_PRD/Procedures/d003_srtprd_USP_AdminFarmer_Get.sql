-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmer_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmer_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Search_Text varchar(50),
    var_MCC_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select mu04.Org_Id, Farmer_Id, 
            m005.MCC_Id, ifnull(m005.MCC_Name,'') as MCC_Name, 
            ifnull(Farmer_Name,'') as Farmer_Name, ifnull(Farmer_Code,'')as Farmer_Code, ifnull(mu04.Mobile_No,'') as Mobile_No, mu04.Is_Active, mu04.Is_Deleted,
            ifnull(MCC_Farmer_Code,'')as MCC_Farmer_Code, 
            ifnull(District_Name,'') as District_Name, ifnull(Taluka_Name,'') as Taluka_Name, ifnull(Village_Name, '') as Village_Name, 
            ifnull(mu04.Address_Text, '') as Address_Text, ifnull(PinCode, '') as PinCode ,
            ifnull(mu04.Pan_No, '') as Pan_No, ifnull(mu04.Aadhar_No, '') as Aadhar_No, ifnull(m015.Bank_Name, '') as Bank_Name, ifnull(mu04.Account_Name,'') as Account_Name , 
            concat('''',ifnull(mu04.Account_No,'')) as Account_No,
            ifnull(m016.IFSC_Code, '') as IFSC_Code, 
            ifnull(Nominee_Name, '') as Nominee_Name, ifnull(NomineeRelation_Name,'' ) as NomineeRelation_Name, 
            ifnull(Nominee_Mobile_No, '') as Nominee_Mobile_No, ifnull(Nominee_Aadhar_No, '') as Nominee_Aadhar_No,
            ifnull(mu04.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
            ifnull(mu04.Gov_Farmer_Id,'') as Gov_Farmer_Id,
            ifnull(mu04.Gov_Farmer_Name,'') as Gov_Farmer_Name
            from mu04_farmer mu04 
            left join m005_mcc m005 on m005.MCC_Id = mu04.MCC_Id and m005.Org_Id = mu04.Org_Id 
            left join ml03_district ml03 on ml03.Org_Id = mu04.Org_Id and ml03.District_Id = mu04.District_Id
            left join ml04_taluka ml04 on ml04.Org_Id = mu04.Org_Id and ml04.Taluka_Id = mu04.Taluka_Id
            left join ml05_village ml05 on ml05.Village_Id = mu04.Village_Id and ml05.Org_Id = mu04.Org_Id
            left join m015_bank m015 on m015.Org_Id = mu04.Org_Id and m015.Bank_Id = mu04.Bank_Id
            left join m016_branch m016 on m016.Org_Id = mu04.Org_Id and m016.Branch_Id = mu04.Branch_Id
            and m016.Bank_Id = mu04.Bank_Id
            left join c030_nomineerelation c030 on c030.NomineeRelation_Id = mu04.Nominee_Relation
            where mu04.Org_Id = var_Org_Id and mu04.Is_Deleted = 0 
            and mu04.MCC_Id like var_MCC_Id
            -- and mu04.Is_Offline = 0
            and (mu04.Farmer_Name like var_Search_Text 
				or mu04.Farmer_Code like var_Search_Text
                or mu04.Mobile_No like var_Search_Text
                or mu04.Pan_No like var_Search_Text
                -- or mu04.MCC_Id like var_MCC_Id
                )
            order by Farmer_Code;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select mu04.Org_Id, Farmer_Id,ifnull(Farmer_Code,'') as Farmer_Code,ifnull(mu04.MCC_Farmer_Code,'') as MCC_Farmer_Code,
			ifnull(Farmer_Name,'') as Farmer_Name, ifnull(Mobile_No,'') as Mobile_No,
            ifnull(AlternateMobile_No,'') as AlternateMobile_No,ifnull(Email_Id,'') as Email_Id,
            date_format(Birth_Date, '%Y-%m-%d') as Birth_Date, Agent_Id,
            ifnull(Pan_No,'') as Pan_No,ifnull(Aadhar_No,'') as Aadhar_No,Cow_Count,Buffalo_Count,Calf_Count,Milk_Capacity,
            State_Id,District_Id,Taluka_Id,Village_Id,mu04.Address_Text,mu04.Bank_Id,mu04.Branch_Id,ifnull(Account_No,'') as Account_No,
            m016.IFSC_Code,ifnull(Account_Name,'')as Account_Name,ifnull(Nominee_Name,'') as Nominee_Name,Nominee_Relation,ifnull(Nominee_Mobile_No,'') as Nominee_Mobile_No,
            ifnull(Nominee_Aadhar_No,'') as Nominee_Aadhar_No,Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,Ration_Card_Photo,
            Bank_Cheque_PBook_Photo,mu04.MCC_Id,mu04.Is_Active, mu04.Is_Deleted ,
            ifnull(mu04.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
            ifnull(mu04.Gov_Farmer_Id,'') as Gov_Farmer_Id,
            ifnull(mu04.Gov_Farmer_Name,'') as Gov_Farmer_Name
            from mu04_farmer mu04
            left join m016_branch m016 on m016.Branch_Id = mu04.Branch_Id 
            and m016.Bank_Id = mu04.Bank_Id 
            and m016.Org_Id = mu04.Org_Id
            where mu04.Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id 
            and mu04.Is_Deleted =0;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartner') then
		begin
			SELECT 
			'' as BusinessPartner,'TO' as AcademicTitle,'0003' as FormOfAddress,'ZFRM' as BusinessPartnerGrouping,'2' as BusinessPartnerCategory,
			mu04.Farmer_Name as OrganizationBPName1,m005.MCC_Name as OrganizationBPName2,ml03.District_Name as OrganizationBPName3,
			ml04.Taluka_Name as OrganizationBPName4,'' as SearchTerm1,'' as AuthorizationGroup,'' as LegalForm,
			'' as BusinessPartnerType,false as BusinessPartnerIsBlocked
			FROM mu04_farmer mu04
			inner join ml03_district ml03 on ml03.Org_Id = mu04.Org_Id and ml03.District_Id = mu04.District_Id
			inner join ml04_taluka ml04 on ml04.Org_Id = mu04.Org_Id and ml04.Taluka_Id = mu04.Taluka_Id
			inner join m005_mcc m005 on m005.Org_Id = mu04.Org_Id and m005.MCC_Id = mu04.MCC_Id
			where mu04.Org_Id = var_Org_Id 
			and mu04.Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddress') then
		begin
			SELECT 
				'IN'as Country,'' as HouseNumber,ml05.Village_Name as StreetName,ml05.Pin_Code as PostalCode,
				ml03.District_Name as CityName,ml03.District_Name as District,'MH' as Region,
				'' as POBox,'EN' as Language,concat('Tal - ', mu04.Address_Text) as AdditionalStreetPrefixName
				FROM mu04_farmer mu04
				inner join ml03_district ml03 on ml03.Org_Id = mu04.Org_Id and ml03.District_Id = mu04.District_Id
				inner join ml04_taluka ml04 on ml04.Org_Id = mu04.Org_Id and ml04.Taluka_Id = mu04.Taluka_Id
				inner join ml05_village ml05 on ml05.Org_Id = mu04.Org_Id and ml05.Village_Id = mu04.Village_Id
				where mu04.Org_Id = var_Org_Id 
				and mu04.Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerEmailAddress') then
		begin
			SELECT 
			'1'as OrdinalNumber,true as IsDefaultEmailAddress,Email_Id as EmailAddress,
			Email_Id as SearchEmailAddress,'' as AddressCommunicationRemarkText
			FROM mu04_farmer 
			where Org_Id = var_Org_Id 
			and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerMobilePhoneNumber') then
		begin
			SELECT 
			'1'as OrdinalNumber,'IN' as DestinationLocationCountry,true as IsDefaultPhoneNumber,Mobile_No as PhoneNumber,
			'' as PhoneNumberExtension,concat('+91',Mobile_No) as InternationalPhoneNumber,'3' as PhoneNumberType,'' as AddressCommunicationRemarkText
			FROM mu04_farmer 
			where Org_Id = var_Org_Id 
			and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddressUsage') then
		begin
			SELECT 
			'XXDEFAULT'as AddressUsage
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerTax') then
		begin
			SELECT 
			''as BPTaxType,'' as BPTaxNumber,'' as BPTaxLongNumber,'' as AuthorizationGroup
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerIdentification') then
		begin
			SELECT 
			'ZADHAR'as BPIdentificationType, Aadhar_No as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id
			union all
			SELECT 
			'ZFFSAI'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id
            union all
			SELECT 
			'ZMSME'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id
            union all
			SELECT 
			'ZPAN'as BPIdentificationType, ifnull(Pan_No,'') as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerRole') then
		begin
				DECLARE BusinessPartnerRole1 varchar(255);
                DECLARE BusinessPartnerRole2 varchar(255);
                
                SELECT Constant_Value into BusinessPartnerRole1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerBP' and Constant_Name = 'BusinessPartnerRole1';
				SELECT Constant_Value into BusinessPartnerRole2   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerBP' and Constant_Name = 'BusinessPartnerRole2';
				
			SELECT 
			BusinessPartnerRole1 as BusinessPartnerRole FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id
			union all
			SELECT 
			BusinessPartnerRole2 as BusinessPartnerRole FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;
		end;
    elseif (var_Method_Name = 'Get_BusinessPartnerBank') then
		begin
			SELECT 
			'' as BankIdentification,'IN' as BankCountryKey,m015.Bank_Name as BankName,
			m016.IFSC_Code  as BankNumber,
			'' as SWIFTCode,'' as BankControlKey,'' as BankAccountHolderName,
			'' as BankAccountName,'' as IBAN,
			mu04.Account_No as BankAccount,'' as BankAccountReferenceText,false as CollectionAuthInd,
			'' as CityName,'' as AuthorizationGroup
			FROM mu04_farmer mu04
			inner join m015_bank m015 on m015.Org_Id = mu04.Org_Id and m015.Bank_Id = mu04.Bank_Id
			inner join m016_branch m016 on m016.Org_Id = mu04.Org_Id and m016.Branch_Id = mu04.Branch_Id
            and m016.Bank_Id = mu04.Bank_Id
			where mu04.Org_Id = var_Org_Id and mu04.Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplier') then
		begin
			SELECT 
            ifnull(Pan_No,'') as BusinessPartnerPanNumber,
			false as PaymentIsBlockedForSupplier,false as PostingIsBlocked,false as PurchasingIsBlocked,
			false as DeletionIndicator,'' as IsNaturalPerson,'' as TaxNumberResponsible
			 FROM mu04_farmer 
			where Org_Id = var_Org_Id 
			and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplierCompany') then
		begin
			DECLARE CompanyCode varchar(255);
			DECLARE ReconciliationAccount varchar(255);
			
			SELECT Constant_Value into CompanyCode   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerBP' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into ReconciliationAccount   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerBP' and Constant_Name = 'ReconciliationAccount';

			SELECT 
			CompanyCode as CompanyCode,ReconciliationAccount as ReconciliationAccount,'' as SupplierHeadOffice,'' as CashPlanningGroup,
			false as PaymentIsToBeSentByEDI,'' as SupplierAccountNote,false as IsToBeCheckedForDuplicates,false as DeletionIndicator,
			false as SupplierIsBlockedForPosting,false as IsToBeLocallyProcessed,false as ItemIsToBePaidSeparately,false as ClearCustomerSupplier
			FROM mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;
		end;
	elseif (var_Method_Name = 'Get_SupplierWithHoldingTax') then
		begin
			DECLARE CompanyCode varchar(255);
			
			SELECT Constant_Value into CompanyCode   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='FarmerBP' and Constant_Name = 'CompanyCode';
			
            SELECT 
			'' as Supplier ,
			CompanyCode as CompanyCode ,
			c049.WithholdingTaxType as WithholdingTaxType ,
			'' as ExemptionReason ,
			true as IsWithholdingTaxSubject ,
			c049.Recipient as RecipientType ,
			'' as WithholdingTaxCertificate ,
			c049.WithholdingTaxType_Code as WithholdingTaxCode ,
			'0.00' as WithholdingTaxExmptPercent ,
			'' as WithholdingTaxNumber ,
			'' as AuthorizationGroup 
			FROM mu04_farmer  mu04
            inner join c049_withholding_tax_type c049 on c049.WithholdingTaxType_Id = mu04.WithholdingTaxType_Id
            where mu04.Org_Id = var_Org_Id and mu04.Farmer_Id = var_Farmer_Id;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
