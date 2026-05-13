-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCC_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCC_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
	var_User_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Search_Text varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m005.Org_Id, m005.MCC_Id, MCC_Name, m005.MCC_Code, 
            c013.MCCCategory_Id, c013.MCCCategory_Name,
            c014.MCCType_Id, c014.MCCType_Name, 
            c023.MCCWorkType_Id, c023.MCCWorkType_Name, 
            mu05.Agent_Id, mu05.Agent_Name, 
            m005.Is_Active, m005.Is_Deleted, ifnull(m005.Plant_Code,'') as Plant_Code, m005.Mobile_No, 
            ifnull(m005.Address_Text,'') as Address_Text, 
            ifnull(m005.Pan_No,'') as Pan_No, 
            ifnull(m005.Aadhar_No,'') as Aadhar_No, m005.Account_No, ifnull(m016.IFSC_Code,'') as IFSC_Code,
            m005.FSSAILicense_No,
            DATE_FORMAT(m005.FSSAILicenseValidity_On, '%d %M %Y')  as FSSAILicenseValidity_On, m005.Account_Name, 
            ifnull(ml05.Village_Name, '') as Village_Name, ifnull(m015.Bank_Name, '') as Bank_Name,
            District_Name, ifnull(Taluka_Name,'') as Taluka_Name,
            ifnull(m005.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
            -- day(now()) as Is_Locked
            '1' as Is_Locked
            from m005_mcc m005
			inner join c013_mcccategory c013 on c013.MCCCategory_Id = m005.MCCCategory_Id
			inner join c014_mcctype c014 on c014.MCCType_Id = m005.MCCType_Id
            inner join c023_mccworktype c023 on c023.MCCWorkType_Id = m005.MCCWorkType_Id
            inner join mu05_agent mu05 on mu05.Agent_Id = m005.Agent_Id and mu05.Org_Id = m005.Org_Id 
            left join m015_bank m015 on m015.Org_Id = m005.Org_Id and m015.Bank_Id = m005.Bank_Id
            left join m016_branch m016 on m016.Org_Id = m005.Org_Id and m016.Branch_Id = m005.Branch_Id
            and m016.Bank_Id = m005.Bank_Id
            left join ml03_district ml03 on ml03.Org_Id = m005.Org_Id and ml03.District_Id = m005.District_Id
            left join ml04_taluka ml04 on ml04.Org_Id = m005.Org_Id and ml04.Taluka_Id = m005.Taluka_Id
            left join ml05_village ml05 on ml05.Village_Id = m005.Village_Id and ml05.Org_Id = m005.Org_Id
            where m005.Org_Id = var_Org_Id 
            and m005.Is_Deleted = 0 
            and (m005.MCC_Name like var_Search_Text 
				or m005.MCC_Code like var_Search_Text
				or ml05.Village_Name like var_Search_Text)
			order by m005.MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select m005.Org_Id, MCC_Id, MCC_Code, MCC_Name, MCCCategory_Id,m005.Pan_No,m005.Aadhar_No,
            MCCType_Id, Agent_Id, Mobile_No,
            State_Id, District_Id, Taluka_Id, Village_Id, m005.Address_Text,
            m005.Bank_Id,m005.Branch_Id, Account_No, m016.IFSC_Code,FSSAILicense_No,
            date_format(FSSAILicenseValidity_On, '%Y-%m-%d') as FSSAILicenseValidity_On, Account_Name,
            MusterType_Id, MCCWorkType_Id,
            PaymentCycle_Id,PaymentType_Id, 
            CONCAT('[', REPLACE(MilkType_Id, ',', ','), ']') AS MilkType_Id, 
			CONCAT('[', REPLACE(CollectionShift_Id, ',', ','), ']') AS CollectionShift_Id,
            ifnull(m005.Latitude,'') as Latitude,
            ifnull(m005.Longitude,'') as Longitude,
            Profile_Photo, Pan_Card_Photo, m005.Is_Active, m005.Is_Deleted,
            m005.Is_ManualWeight,m005.Is_ManualQuality,m005.Is_ManualShiftEnd,
            ifnull(m005.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
            ifnull(m005.Plant_Code,'') as Plant_Code,
            m005.Is_Alternate as Alternate,
            -- day(now()) as Is_Locked
            '1' as Is_Locked
            from m005_mcc m005
            left join m016_branch m016 on m016.Branch_Id = m005.Branch_Id and m016.Org_Id = m005.Org_Id
            and m016.Bank_Id = m005.Bank_Id
            where m005.Org_Id = var_Org_Id 
            and MCC_Id = var_MCC_Id 
            and m005.Is_Deleted =0;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartner') then
		begin
			SELECT 
			''as BusinessPartner,'TO' as AcademicTitle,'0003' as FormOfAddress,
				CASE
				WHEN m005.MCCType_Id = 'C014001' AND m005.MCCWorkType_Id = 'C023001' THEN 'ZRM2'
				WHEN m005.MCCType_Id = 'C014001' AND m005.MCCWorkType_Id = 'C023002' THEN 'ZRM1'
				WHEN m005.MCCType_Id = 'C014002' AND m005.MCCWorkType_Id = 'C023001' THEN 'ZBM2'
				WHEN m005.MCCType_Id = 'C014002' AND m005.MCCWorkType_Id = 'C023002' THEN 'ZBM1'
				WHEN m005.MCCType_Id = 'C014003' THEN 'ZBLK'
				ELSE ''
				END as BusinessPartnerGrouping,
			'2' as BusinessPartnerCategory,
			m005.MCC_Name as OrganizationBPName1,'' as OrganizationBPName2,ml03.District_Name as OrganizationBPName3,
			ml04.Taluka_Name as OrganizationBPName4,'' as SearchTerm1,'' as AuthorizationGroup,'' as LegalForm,
			'' as BusinessPartnerType,false as BusinessPartnerIsBlocked
			FROM m005_mcc m005
			inner join ml03_district ml03 on ml03.Org_Id = m005.Org_Id and ml03.District_Id = m005.District_Id
			inner join ml04_taluka ml04 on ml04.Org_Id = m005.Org_Id and ml04.Taluka_Id = m005.Taluka_Id
			where m005.Org_Id = var_Org_Id 
			and m005.MCC_Id = var_MCC_Id;
					end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddress') then
		begin
			SELECT 
			'IN'as Country,'' as HouseNumber,ml05.Village_Name as StreetName,ml05.Pin_Code as PostalCode,
			ml03.District_Name as CityName,ml03.District_Name as District,'MH' as Region,
			'' as POBox,'EN' as Language,concat('Tal - ', m005.Address_Text) as AdditionalStreetPrefixName
			FROM m005_mcc m005
			inner join ml03_district ml03 on ml03.Org_Id = m005.Org_Id and ml03.District_Id = m005.District_Id
			inner join ml04_taluka ml04 on ml04.Org_Id = m005.Org_Id and ml04.Taluka_Id = m005.Taluka_Id
			inner join ml05_village ml05 on ml05.Org_Id = m005.Org_Id and ml05.Village_Id = m005.Village_Id
			where m005.Org_Id = var_Org_Id 
			and m005.MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerEmailAddress') then
		begin
			SELECT 
			'1'as OrdinalNumber,true as IsDefaultEmailAddress,'' as EmailAddress,
			'' as SearchEmailAddress,'' as AddressCommunicationRemarkText
			FROM m005_mcc 
			where Org_Id = var_Org_Id 
			and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerMobilePhoneNumber') then
		begin
			SELECT 
			'1'as OrdinalNumber,'IN' as DestinationLocationCountry,true as IsDefaultPhoneNumber,Mobile_No as PhoneNumber,
			'' as PhoneNumberExtension,concat('+91',Mobile_No) as InternationalPhoneNumber,'3' as PhoneNumberType,'' as AddressCommunicationRemarkText
			FROM m005_mcc 
			where Org_Id = var_Org_Id 
			and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerAddressUsage') then
		begin
			SELECT 
			'XXDEFAULT'as AddressUsage
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerTax') then
		begin
			SELECT 
			''as BPTaxType,'' as BPTaxNumber,'' as BPTaxLongNumber,'' as AuthorizationGroup
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerIdentification') then
		begin
			SELECT 
			'ZADHAR'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id
			union all
			SELECT 
			'ZFFSAI'as BPIdentificationType,FSSAILicense_No as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id
            union all
			SELECT 
			'ZMSME'as BPIdentificationType,'0' as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id
            union all
			SELECT 
			'ZPAN'as BPIdentificationType, ifnull(Pan_No,'') as BPIdentificationNumber,'' as BPIdnNmbrIssuingInstitute,
			'' as Country,'' as Region,''  as AuthorizationGroup
			FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerRole') then
		begin
			DECLARE BusinessPartnerRole1 varchar(255);
			DECLARE BusinessPartnerRole2 varchar(255);
            
            SELECT Constant_Value into BusinessPartnerRole1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'BusinessPartnerRole1';
			SELECT Constant_Value into BusinessPartnerRole2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'BusinessPartnerRole2';

			SELECT 
			BusinessPartnerRole1 as BusinessPartnerRole FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id
			union all
			SELECT 
			BusinessPartnerRole2 as BusinessPartnerRole FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
		end;
    elseif (var_Method_Name = 'Get_BusinessPartnerBank') then
		begin
			SELECT 
			'' as BankIdentification,'IN' as BankCountryKey,m015.Bank_Name as BankName,
            m016.IFSC_Code as BankNumber,
			'' as SWIFTCode,'' as BankControlKey,'' as BankAccountHolderName,
			'' as BankAccountName,'' as IBAN,
			m005.Account_No as BankAccount,'' as BankAccountReferenceText,false as CollectionAuthInd,
			'' as CityName,'' as AuthorizationGroup
			FROM m005_mcc m005
			inner join m015_bank m015 on m015.Org_Id = m005.Org_Id and m015.Bank_Id = m005.Bank_Id
			inner join m016_branch m016 on m016.Org_Id = m005.Org_Id and m016.Branch_Id = m005.Branch_Id
            and m016.Bank_Id = m005.Bank_Id
			where m005.Org_Id = var_Org_Id and m005.MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplier') then
		begin
			SELECT 
            ifnull(Pan_No,'') as BusinessPartnerPanNumber,
			false as PaymentIsBlockedForSupplier,false as PostingIsBlocked,false as PurchasingIsBlocked,
			false as DeletionIndicator,'' as IsNaturalPerson,'' as TaxNumberResponsible
			 FROM m005_mcc 
			where Org_Id = var_Org_Id 
			and MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_BusinessPartnerSupplierCompany') then
		begin
			DECLARE CompanyCode varchar(255);
			DECLARE ReconciliationAccount11 varchar(255);
            DECLARE ReconciliationAccount12 varchar(255);
            DECLARE ReconciliationAccount21 varchar(255);
            DECLARE ReconciliationAccount22 varchar(255);
            DECLARE ReconciliationAccount3 varchar(255);
            
            SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into ReconciliationAccount11  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'ReconciliationAccount11';
			SELECT Constant_Value into ReconciliationAccount12  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'ReconciliationAccount12';
			SELECT Constant_Value into ReconciliationAccount21  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'ReconciliationAccount21';
			SELECT Constant_Value into ReconciliationAccount22  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'ReconciliationAccount22';
			SELECT Constant_Value into ReconciliationAccount3  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'ReconciliationAccount3';

			SELECT 
			CompanyCode as CompanyCode,
			CASE
			WHEN m005.MCCType_Id = 'C014001' AND m005.MCCWorkType_Id = 'C023001' THEN ReconciliationAccount11
			WHEN m005.MCCType_Id = 'C014001' AND m005.MCCWorkType_Id = 'C023002' THEN ReconciliationAccount12
			WHEN m005.MCCType_Id = 'C014002' AND m005.MCCWorkType_Id = 'C023001' THEN ReconciliationAccount21
			WHEN m005.MCCType_Id = 'C014002' AND m005.MCCWorkType_Id = 'C023002' THEN ReconciliationAccount22
			WHEN m005.MCCType_Id = 'C014003' THEN ReconciliationAccount3
			ELSE ''
			END as ReconciliationAccount,
			'' as SupplierHeadOffice,'' as CashPlanningGroup,
			false as PaymentIsToBeSentByEDI,'' as SupplierAccountNote,false as IsToBeCheckedForDuplicates,false as DeletionIndicator,
			false as SupplierIsBlockedForPosting,false as IsToBeLocallyProcessed,false as ItemIsToBePaidSeparately,false as ClearCustomerSupplier
			FROM m005_mcc  m005 where m005.Org_Id = var_Org_Id and m005.MCC_Id = var_MCC_Id;
		end;
	elseif (var_Method_Name = 'Get_SupplierWithHoldingTax') then
		begin
			DECLARE CompanyCode varchar(255);
			
			SELECT Constant_Value into CompanyCode   FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MCCBP' and Constant_Name = 'CompanyCode';
			
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
			FROM m005_mcc  m005
            inner join c049_withholding_tax_type c049 on c049.WithholdingTaxType_Id = m005.WithholdingTaxType_Id
           where m005.Org_Id = var_Org_Id and m005.MCC_Id = var_MCC_Id;
            
        end;
	elseif (var_Method_Name = 'Get_Locked') then
		begin
			select 
			MusterType_Id,
			PaymentCycle_Id,
			-- day(now()) as Is_Locked
            '1' as Is_Locked
			from m005_mcc_version 
			where Org_Id = var_Org_Id 
			and MCC_Id = var_MCC_Id 
			and date(Applicable_Date) <= date(now())
			order by Applicable_Date desc limit 1;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
