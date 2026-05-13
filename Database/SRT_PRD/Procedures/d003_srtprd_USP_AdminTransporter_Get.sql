-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTransporter_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTransporter_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Transporter_Id varchar(50),
    var_Transporter_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m9.Org_Id, m9.Transporter_Id, m9.Transporter_Name, ifnull(m9.Transporter_Code,'') as Transporter_Code,
            m9.ContactPerson_Name, ifnull(m9.Mobile_No,'') as Mobile_No, m9.Is_Active, m9.Is_Deleted ,
            ifnull(ml05.Village_Name, '') as Village_Name, ifnull(m015.Bank_Name, '') as Bank_Name, Account_No, IFSC_Code, Account_Name, Company_Pan_No, FSSAI_License_No, 
            District_Name, Taluka_Name,
            DATE_FORMAT(LicenseValidity_On, '%d %M %Y')  as LicenseValidity_On ,
            ifnull(m9.WithholdingTaxType_Id,'') as WithholdingTaxType_Id
            from m009_transporter m9
            left join ml03_district ml03 on ml03.Org_Id = m9.Org_Id and ml03.District_Id = m9.District_Id
            left join ml04_taluka ml04 on ml04.Org_Id = m9.Org_Id and ml04.Taluka_Id = m9.Taluka_Id
            left join ml05_village ml05 on ml05.Village_Id = m9.Village_Id and ml05.Org_Id = m9.Org_Id
            left join m015_bank m015 on m015.Org_Id = m9.Org_Id and m015.Bank_Id = m9.Bank_Id
			where m9.Org_Id = var_Org_Id and m9.Is_Deleted = 0 
            and Transporter_Name like var_Transporter_Name
            order by Transporter_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
            SELECT 
				m009.Org_Id,m009.Transporter_Id,Transporter_Name,ifnull(m009.Transporter_Code,'')as Transporter_Code,ContactPerson_Name,Mobile_No,
				State_Id,District_Id,Taluka_Id,Village_Id,m009.Address_Text,m009.Bank_Id,m009.Branch_Id,
				Account_No,m016.IFSC_Code,Account_Name,date_format(LicenseValidity_On, '%Y-%m-%d') as LicenseValidity_On,Company_Pan_No,
				FSSAI_License_No,Company_Pan_No, FSSAI_License_No, Profile_Photo, Pan_Card_Photo,
                ifnull(m009.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
				Aadhar_Card_Photo, Company_Pan_Card_Photo,FSSAI_License_Photo,
                m009.Is_Active,m009.Is_Deleted,
				CASE
					WHEN m003.Transporter_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m009_transporter m009
			LEFT JOIN m016_branch m016 ON m016.Branch_Id = m009.Branch_Id
				and m016.Org_Id = m009.Org_Id
			LEFT JOIN (
				SELECT DISTINCT Transporter_Id
				FROM m003_vehicle
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m003 ON m003.Transporter_Id = m009.Transporter_Id
			WHERE m009.Org_Id = var_Org_Id 
				AND m009.Transporter_Id = var_Transporter_Id
				AND m009.Is_Deleted = 0;
		end;
		elseif (var_Method_Name = 'Get_BusinessPartner') then
		begin
			SELECT 
			''as BusinessPartner,'TO' as AcademicTitle,'0003' as FormOfAddress,
			'ZTRP' as BusinessPartnerGrouping,
			'2' as BusinessPartnerCategory,
			m009.Transporter_Name as OrganizationBPName1,'' as OrganizationBPName2,ml03.District_Name as OrganizationBPName3,
			ml04.Taluka_Name as OrganizationBPName4,'' as SearchTerm1,'' as AuthorizationGroup,'' as LegalForm,
			'' as BusinessPartnerType,false as BusinessPartnerIsBlocked
			FROM m009_transporter m009
			inner join ml03_district ml03 on ml03.Org_Id = m009.Org_Id and ml03.District_Id = m009.District_Id
			inner join ml04_taluka ml04 on ml04.Org_Id = m009.Org_Id and ml04.Taluka_Id = m009.Taluka_Id
			where m009.Org_Id = var_Org_Id 
			and m009.Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddress') then
		begin
			SELECT 
			'IN'as Country,'' as HouseNumber,ml05.Village_Name as StreetName,ml05.Pin_Code as PostalCode,
			ml03.District_Name as CityName,ml03.District_Name as District,'MH' as Region,
			'' as POBox,'EN' as Language,concat('Tal - ',  m009.Address_Text) as AdditionalStreetPrefixName
			FROM m009_transporter m009
			inner join ml03_district ml03 on ml03.Org_Id = m009.Org_Id and ml03.District_Id = m009.District_Id
			inner join ml04_taluka ml04 on ml04.Org_Id = m009.Org_Id and ml04.Taluka_Id = m009.Taluka_Id
			inner join ml05_village ml05 on ml05.Org_Id = m009.Org_Id and ml05.Village_Id = m009.Village_Id
			where m009.Org_Id = var_Org_Id 
			and m009.Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerEmailAddress') then
		begin
			SELECT 
			'1'as OrdinalNumber,true as IsDefaultEmailAddress,'' as EmailAddress,
			'' as SearchEmailAddress,'' as AddressCommunicationRemarkText
			FROM m009_transporter 
			where Org_Id = var_Org_Id 
			and Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerMobilePhoneNumber') then
		begin
			SELECT 
			'1'as OrdinalNumber,'IN' as DestinationLocationCountry,true as IsDefaultPhoneNumber,Mobile_No as PhoneNumber,
			'' as PhoneNumberExtension,concat('+91',Mobile_No) as InternationalPhoneNumber,'3' as PhoneNumberType,'' as AddressCommunicationRemarkText
			FROM m009_transporter 
			where Org_Id = var_Org_Id 
			and Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddressUsage') then
		begin
			SELECT 
			'XXDEFAULT'as AddressUsage
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;

		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerTax') then
		begin
			SELECT 
			''as BPTaxType,'' as BPTaxNumber,'' as BPTaxLongNumber,'' as AuthorizationGroup
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;

		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerIdentification') then
		begin
			SELECT 
			'ZADHAR'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id
			union all
			SELECT 
			'ZFFSAI'as BPIdentificationType,FSSAI_License_No as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id
            union all
            select
            'ZMSME'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id
            union all
            select
            'ZPAN'as BPIdentificationType,ifnull(Company_Pan_No,0) as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;

		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerRole') then
		begin
			DECLARE BusinessPartnerRole1 varchar(255);
			DECLARE BusinessPartnerRole2 varchar(255);
                
			SELECT Constant_Value into BusinessPartnerRole1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterBP' and Constant_Name = 'BusinessPartnerRole1';
			SELECT Constant_Value into BusinessPartnerRole2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterBP' and Constant_Name = 'BusinessPartnerRole2';

			SELECT 
			BusinessPartnerRole1 as BusinessPartnerRole FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id
			union all
			SELECT 
			BusinessPartnerRole2 as BusinessPartnerRole FROM m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_Transporter_Id;

		end;
    elseif (var_Method_Name = 'Get_BusinessPartnerBank') then
		begin
			SELECT 
			'' as BankIdentification,'IN' as BankCountryKey,m015.Bank_Name as BankName,
            m016.IFSC_Code as BankNumber,
			'' as SWIFTCode,'' as BankControlKey,'' as BankAccountHolderName,
			'' as BankAccountName,'' as IBAN,
			m009.Account_No as BankAccount,'' as BankAccountReferenceText,false as CollectionAuthInd,
			'' as CityName,'' as AuthorizationGroup
			FROM m009_transporter m009
			inner join m015_bank m015 on m015.Org_Id = m009.Org_Id and m015.Bank_Id = m009.Bank_Id
			inner join m016_branch m016 on m016.Org_Id = m009.Org_Id and m016.Branch_Id = m009.Branch_Id
            and m016.Bank_Id = m009.Bank_Id
			where m009.Org_Id = var_Org_Id and m009.Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplier') then
		begin
			SELECT 
            '' as BusinessPartnerPanNumber,
			false as PaymentIsBlockedForSupplier,false as PostingIsBlocked,false as PurchasingIsBlocked,
			false as DeletionIndicator,'' as IsNaturalPerson,'' as TaxNumberResponsible
			 FROM m009_transporter 
			where Org_Id = var_Org_Id 
			and Transporter_Id = var_Transporter_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplierCompany') then
		begin
			DECLARE CompanyCode varchar(255);
			DECLARE ReconciliationAccount varchar(255);
            
            SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterBP' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into ReconciliationAccount  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterBP' and Constant_Name = 'ReconciliationAccount';


			SELECT 
			CompanyCode as CompanyCode,
			ReconciliationAccount as ReconciliationAccount,
			'' as SupplierHeadOffice,'' as CashPlanningGroup,
			false as PaymentIsToBeSentByEDI,'' as SupplierAccountNote,false as IsToBeCheckedForDuplicates,false as DeletionIndicator,
			false as SupplierIsBlockedForPosting,false as IsToBeLocallyProcessed,false as ItemIsToBePaidSeparately,false as ClearCustomerSupplier
			FROM m009_transporter  m009 where m009.Org_Id = var_Org_Id and m009.Transporter_Id = var_Transporter_Id;


		end;
		elseif (var_Method_Name = 'Get_SupplierWithHoldingTax') then
		begin
			DECLARE CompanyCode varchar(255);
			
			SELECT Constant_Value into CompanyCode   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='TransporterBP' and Constant_Name = 'CompanyCode';
			
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
			FROM m009_transporter  m009
            inner join c049_withholding_tax_type c049 on c049.WithholdingTaxType_Id = m009.WithholdingTaxType_Id
			where m009.Org_Id = var_Org_Id and m009.Transporter_Id = var_Transporter_Id;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
