-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminBusinessPartnerInSAP_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminBusinessPartnerInSAP_Set`(
	IN `var_Method_Name` varchar(255),
	IN `var_Org_Id` varchar(10),
    IN `var_BusinessPartner_Type` varchar(20),
	IN `var_BusinessPartner_Id` varchar(20),	-- Primary key from MilkIn i.e. Farmer_Id or MCC_Id or Transporter_Id
	IN `var_SAP_Code` varchar(50),
	IN `var_Status` varchar(20),
	IN `var_Param1` varchar(100),
	IN `var_Parem2` varchar(100)
)
BEGIN
	if (var_Method_Name = 'SetFlag') then
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
				Update mu04_farmer
				set Is_Posted = var_Status
				where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'Farmer') then
				Update m005_mcc
				set Is_Posted = var_Status
				where Org_Id = var_Org_Id and MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				Update m009_transporter
				set Is_Posted = var_Status
				where Org_Id = var_Org_Id and Transporter_Id = var_BusinessPartner_Id;
                
            end if;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Get_BPName') then
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
				select 
				left(mu04.Farmer_Name,40) as FullName
				from mu04_farmer mu04
				where mu04.Org_Id = var_Org_Id 
				and mu04.Farmer_Id = var_BusinessPartner_Id;
			elseif (var_BusinessPartner_Type = 'MCC') then
				select 
				left(m005.MCC_Name,40) as FullName
				from m005_mcc m005
				where m005.Org_Id = var_Org_Id 
				and m005.MCC_Id = var_BusinessPartner_Id;
			elseif (var_BusinessPartner_Type = 'Transporter') then
				select 
				left(m009.Transporter_Name,40) as FullName
				from m009_transporter m009
				where m009.Org_Id = var_Org_Id
				and m009.Transporter_Id = var_BusinessPartner_Id;
            end if;
		end;
	elseif (var_Method_Name = 'Get_BPMobile') then
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
				select 
				ifnull(mu04.Mobile_No, ifnull(mu04.AlternateMobile_No,'')) as PhoneNumber
				from mu04_farmer mu04
				where mu04.Org_Id = var_Org_Id 
				and mu04.Farmer_Id = var_BusinessPartner_Id;
			elseif (var_BusinessPartner_Type = 'MCC') then
				select 
				ifnull(m005.Mobile_No, '') as PhoneNumber
				from m005_mcc m005
				where m005.Org_Id = var_Org_Id 
				and m005.MCC_Id = var_BusinessPartner_Id;
			elseif (var_BusinessPartner_Type = 'Transporter') then
				select 
				ifnull(t009.Mobile_No, '') as PhoneNumber
				from m009_transporter m009
				where m009.Org_Id = var_Org_Id
				and m009.Transporter_Id = var_BusinessPartner_Id;
            end if;
		end;
     
     elseif (var_Method_Name = 'Get_BPIdentification') then
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
				Farmer_Code as BusinessPartner,
				'ZADHAR' as BPIdentificationType,
				Aadhar_No as BPIdentificationNumber
				from mu04_farmer mu04
				where mu04.Org_Id = var_Org_Id 
				and mu04.Farmer_Id = var_BusinessPartner_Id

				union all

				select 
				Farmer_Code as BusinessPartner,
				'ZPAN' as BPIdentificationType,
				ifnull(Pan_No,'') as BPIdentificationNumber
				from mu04_farmer mu04
				where mu04.Org_Id = var_Org_Id 
				and mu04.Farmer_Id = var_BusinessPartner_Id;
                
			elseif (var_BusinessPartner_Type = 'MCC') then
				select 
				MCC_Code as BusinessPartner,
				'ZFFSAI' as BPIdentificationType,
				FSSAILicense_No as BPIdentificationNumber
				from m005_mcc m005
				where m005.Org_Id = var_Org_Id 
				and m005.MCC_Id = var_BusinessPartner_Id

				union all

				select 
				MCC_Code as BusinessPartner,
				'ZPAN' as BPIdentificationType,
				ifnull(Pan_No,'') as BPIdentificationNumber
				from m005_mcc m005
				where m005.Org_Id = var_Org_Id 
				and m005.MCC_Id = var_BusinessPartner_Id;
			elseif (var_BusinessPartner_Type = 'Transporter') then
				select 
				Transporter_Code as BusinessPartner,
				'ZFFSAI' as BPIdentificationType,
				FSSAI_License_No as BPIdentificationNumber
				from m009_transporter m009
				where m009.Org_Id = var_Org_Id 
				and m009.Transporter_Id = var_BusinessPartner_Id

				union all

				select 
				Transporter_Code as BusinessPartner,
				'ZPAN' as BPIdentificationType,
				ifnull(Company_Pan_No,0) as BPIdentificationNumber
				from m009_transporter m009
				where m009.Org_Id = var_Org_Id 
				and m009.Transporter_Id = var_BusinessPartner_Id;
            end if;
		end;
        
	elseif (var_Method_Name = 'Get_BPAddress') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
				select 
                mu04.Farmer_Code as BusinessPartner, 
                '' as AddressID, 
                '' as AuthorizationGroup, 
                -- '' as AddressUUID, 
                '' as AdditionalStreetPrefixName,
				'' as AdditionalStreetSuffixName, 
                'INDIA' as AddressTimeZone, 
                '' as CareOfName, 
                '' as CityCode, 
                ifnull(ml04.Taluka_Name,'') as CityName,
				'' as CompanyPostalCode, 
                'IN' as Country, 
                '' as County, 
                '' as DeliveryServiceNumber, 
                '' as DeliveryServiceTypeCode,
                ifnull(ml03.District_Name,'') as District, 
				'' as FormOfAddress, 
                ifnull(mu04.Farmer_Name,'') as FullName, 
                ifnull(ml05.Village_Name,'') as HomeCityName, 
                '' as HouseNumber, 
                '' as HouseNumberSupplementText,
				'EN' as Language, 
                '' as POBox, 
                '' as POBoxDeviatingCityName, 
                '' as POBoxDeviatingCountry, 
                '' as POBoxDeviatingRegion,	
                false as POBoxIsWithoutNumber, 
                '' as POBoxLobbyName, 
                '' as POBoxPostalCode, 
                '' as Person, 
                ifnull(ml05.Pin_Code,'') as PostalCode,	
                '' as PrfrdCommMediumType, 
                'MH' as Region, 
                ifnull(mu04.Address_Text,'') as StreetName, 
                '' as StreetPrefixName, 
                '' as StreetSuffixName,
				'' as TaxJurisdiction, 
                '' as TransportZone, 
                '' as AddressIDByExternalSystem, 
                '' as CountyCode, 
                '' as TownshipCode, 
                '' as TownshipName
                from mu04_farmer mu04
                left join ml03_district ml03 on
                ml03.Org_Id	= mu04.Org_Id
                and ml03.State_Id = mu04.State_Id
                and ml03.District_Id = mu04.District_Id
                left join ml04_taluka ml04 on
                ml04.Org_Id	= mu04.Org_Id
                and ml04.State_Id = mu04.State_Id
                and ml04.District_Id = mu04.District_Id
                and ml04.Taluka_Id = mu04.Taluka_Id
                left join ml05_village ml05 on
                ml05.Org_Id	= mu04.Org_Id
                and ml05.State_Id = mu04.State_Id
                and ml05.District_Id = mu04.District_Id
                and ml05.Taluka_Id = mu04.Taluka_Id
                and ml05.Village_Id = mu04.Village_Id
                where mu04.Org_Id = var_Org_Id 
                and mu04.Farmer_Id = var_BusinessPartner_Id;
                
                
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				select 
                m005.MCC_Code as BusinessPartner, 
                '' as AddressID, 
                '' as AuthorizationGroup, 
                -- '' as AddressUUID, 
                '' as AdditionalStreetPrefixName,
				'' as AdditionalStreetSuffixName, 
                'INDIA' as AddressTimeZone, 
                '' as CareOfName, 
                '' as CityCode, 
                ifnull(ml04.Taluka_Name,'') as CityName,
				'' as CompanyPostalCode, 
                'IN' as Country, 
                '' as County, 
                '' as DeliveryServiceNumber, 
                '' as DeliveryServiceTypeCode,
                ifnull(ml03.District_Name,'') as District, 
				'' as FormOfAddress, 
                ifnull(m005.MCC_Name,'') as FullName, 
                ifnull(ml05.Village_Name,'') as HomeCityName, 
                '' as HouseNumber, 
                '' as HouseNumberSupplementText,
				'EN' as Language, 
                '' as POBox, 
                '' as POBoxDeviatingCityName, 
                '' as POBoxDeviatingCountry, 
                '' as POBoxDeviatingRegion,	
                false as POBoxIsWithoutNumber, 
                '' as POBoxLobbyName, 
                '' as POBoxPostalCode, 
                '' as Person, 
                ifnull(ml05.Pin_Code,'') as PostalCode,	
                '' as PrfrdCommMediumType, 
                'MH' as Region, 
                ifnull(m005.Address_Text,'') as StreetName, 
                '' as StreetPrefixName, 
                '' as StreetSuffixName,
				'' as TaxJurisdiction, 
                '' as TransportZone, 
                '' as AddressIDByExternalSystem, 
                '' as CountyCode, 
                '' as TownshipCode, 
                '' as TownshipName
                from m005_mcc m005
                left join ml03_district ml03 on
                ml03.Org_Id	= m005.Org_Id
                and ml03.State_Id = m005.State_Id
                and ml03.District_Id = m005.District_Id
                left join ml04_taluka ml04 on
                ml04.Org_Id	= m005.Org_Id
                and ml04.State_Id = m005.State_Id
                and ml04.District_Id = m005.District_Id
                and ml04.Taluka_Id = m005.Taluka_Id
                left join ml05_village ml05 on
                ml05.Org_Id	= m005.Org_Id
                and ml05.State_Id = m005.State_Id
                and ml05.District_Id = m005.District_Id
                and ml05.Taluka_Id = m005.Taluka_Id
                and ml05.Village_Id = m005.Village_Id
                where m005.Org_Id = var_Org_Id 
                and m005.MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				
                select 
                m009.Transporter_Code as BusinessPartner, 
                '' as AddressID, 
                '' as AuthorizationGroup, 
                -- '' as AddressUUID, 
                '' as AdditionalStreetPrefixName,
				'' as AdditionalStreetSuffixName, 
                'INDIA' as AddressTimeZone, 
                '' as CareOfName, 
                '' as CityCode, 
                ifnull(ml04.Taluka_Name,'') as CityName,
				'' as CompanyPostalCode, 
                'IN' as Country, 
                '' as County, 
                '' as DeliveryServiceNumber, 
                '' as DeliveryServiceTypeCode,
                ifnull(ml03.District_Name,'') as District, 
				'' as FormOfAddress, 
                ifnull(m009.Transporter_Name,'') as FullName, 
                ifnull(ml05.Village_Name,'') as HomeCityName, 
                '' as HouseNumber, 
                '' as HouseNumberSupplementText,
				'EN' as Language, 
                '' as POBox, 
                '' as POBoxDeviatingCityName, 
                '' as POBoxDeviatingCountry, 
                '' as POBoxDeviatingRegion,	
                false as POBoxIsWithoutNumber, 
                '' as POBoxLobbyName, 
                '' as POBoxPostalCode, 
                '' as Person, 
                ifnull(ml05.Pin_Code,'') as PostalCode,	
                '' as PrfrdCommMediumType, 
                'MH' as Region, 
                ifnull(m009.Address_Text,'') as StreetName, 
                '' as StreetPrefixName, 
                '' as StreetSuffixName,
				'' as TaxJurisdiction, 
                '' as TransportZone, 
                '' as AddressIDByExternalSystem, 
                '' as CountyCode, 
                '' as TownshipCode, 
                '' as TownshipName
                from m009_transporter m009
                left join ml03_district ml03 on
                ml03.Org_Id	= m009.Org_Id
                and ml03.State_Id = m009.State_Id
                and ml03.District_Id = m009.District_Id
                left join ml04_taluka ml04 on
                ml04.Org_Id	= m009.Org_Id
                and ml04.State_Id = m009.State_Id
                and ml04.District_Id = m009.District_Id
                and ml04.Taluka_Id = m009.Taluka_Id
                left join ml05_village ml05 on
                ml05.Org_Id	= m009.Org_Id
                and ml05.State_Id = m009.State_Id
                and ml05.District_Id = m009.District_Id
                and ml05.Taluka_Id = m009.Taluka_Id
                and ml05.Village_Id = m009.Village_Id
                where m009.Org_Id = var_Org_Id 
                and m009.Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        
        end;
	elseif (var_Method_Name = 'Get_BPBank') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                'IN' as BankCountryKey ,
				-- m016.IFSC_Code as BankNumber ,
                m016.IFSC_Code as BankNumber ,
				'' as BankControlKey ,
				ifnull(mu04.Account_Name,'') as BankAccountHolderName , 
				'' as BankAccountName ,
				'' as IBAN ,
				ifnull(mu04.Account_No,'') as BankAccount ,
				'' as BankAccountReferenceText ,
				true as CollectionAuthInd ,
				'' as AuthorizationGroup,
				m015.Bank_Name as BankName,
                '' as SWIFTCode,
                m016.Branch_Name as CityName
                from mu04_farmer mu04
                inner join m015_bank m015 on m015.Org_Id = mu04.Org_Id and m015.Bank_Id = mu04.Bank_Id
				inner join m016_branch m016 on m016.Org_Id = m015.Org_Id 
                and m016.Bank_Id = m015.Bank_Id
                and m016.Branch_Id = mu04.Branch_Id
                where mu04.Org_Id = var_Org_Id and mu04.Farmer_Id = var_BusinessPartner_Id;
                
                
            elseif (var_BusinessPartner_Type = 'MCC') then
            
				select 
                'IN' as BankCountryKey ,
				m016.IFSC_Code as BankNumber ,
				'' as BankControlKey ,
				ifnull(m005.Account_Name,'') as BankAccountHolderName , 
				'' as BankAccountName ,
				'' as IBAN ,
				ifnull(m005.Account_No,'') as BankAccount ,
				'' as BankAccountReferenceText ,
				true as CollectionAuthInd ,
				'' as AuthorizationGroup ,
                m015.Bank_Name as BankName,
                '' as SWIFTCode,
                m016.Branch_Name as CityName
                from m005_mcc m005
                inner join m015_bank m015 on m015.Org_Id = m005.Org_Id and m015.Bank_Id = m005.Bank_Id
				inner join m016_branch m016 on m016.Org_Id = m005.Org_Id 
                and m016.Branch_Id = m005.Branch_Id
                and m016.Bank_Id = m005.Bank_Id
                where m005.Org_Id = var_Org_Id and m005.MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
            
				select 
                'IN' as BankCountryKey ,
				m016.IFSC_Code as BankNumber ,
				'' as BankControlKey ,
				ifnull(m009.Account_Name,'') as BankAccountHolderName , 
				'' as BankAccountName ,
				'' as IBAN ,
				ifnull(m009.Account_No,'') as BankAccount ,
				'' as BankAccountReferenceText ,
				true as CollectionAuthInd ,
				'' as AuthorizationGroup ,
                m015.Bank_Name as BankName,
                '' as SWIFTCode,
                m016.Branch_Name as CityName
                from m009_transporter m009
                inner join m015_bank m015 on m015.Org_Id = m009.Org_Id and m015.Bank_Id = m009.Bank_Id
				inner join m016_branch m016 on m016.Org_Id = m009.Org_Id 
                and m016.Bank_Id = m015.Bank_Id
                and m016.Branch_Id = m009.Branch_Id
                where m009.Org_Id = var_Org_Id and m009.Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        
        end;
	elseif (var_Method_Name = 'Get_To_AddressUsage') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                Farmer_Code as BusinessPartner, 
                '' as ValidityEndDate, 
                'XXDEFAULT' as AddressUsage, 
                '' as AddressID, 
                '' as ValidityStartDate,
                false as StandardUsage,
                '' as AuthorizationGroup
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				
                select 
                MCC_Code as BusinessPartner, 
                '' as ValidityEndDate, 
                'XXDEFAULT' as AddressUsage, 
                '' as AddressID, 
                '' as ValidityStartDate,
                false as StandardUsage,
                '' as AuthorizationGroup
                from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				
                select 
                Transporter_Code as BusinessPartner, 
                '' as ValidityEndDate, 
                'XXDEFAULT' as AddressUsage, 
                '' as AddressID, 
                '' as ValidityStartDate,
                false as StandardUsage,
                '' as AuthorizationGroup
                from m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        end;
        elseif (var_Method_Name = 'Get_To_BPIntlAddressVersion') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                var_SAP_Code as BusinessPartner, 
                ''  as AddressID,
				''  as AddressRepresentationCode,
				''  as AddressSearchTerm1,
				''  as AddressSearchTerm2,
				''  as CareOfName,
				''  as CityName,
				''  as DistrictName,
				''  as FormOfAddress,
				''  as HouseNumber,
				''  as HouseNumberSupplementText,
				''  as OrganizationName1,
				''  as OrganizationName2,
				''  as OrganizationName3,
				''  as OrganizationName4,
				''  as PersonFamilyName,
				''  as PersonGivenName,
				''  as POBoxDeviatingCityName,
				''  as POBoxLobbyName,
				''  as SecondaryRegionName,
				''  as StreetName,
				''  as StreetPrefixName1,
				''  as StreetPrefixName2,
				''  as StreetSuffixName1,
				''  as StreetSuffixName2,
				''  as TertiaryRegionName,
				''  as VillageName
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				select 1;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				select 1;
                
            end if;
        end;
	elseif (var_Method_Name = 'Get_To_EmailAddress') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultEmailAddress,
				ifnull(Email_Id,'') as EmailAddress,
				'' as AddressCommunicationRemarkText
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				
                select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultEmailAddress,
				'' as EmailAddress,
				'' as AddressCommunicationRemarkText
                from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				
                select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultEmailAddress,
				'' as EmailAddress,
				'' as AddressCommunicationRemarkText
                from m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        end;
	elseif (var_Method_Name = 'Get_To_FaxNumber') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                '' as AddressID,
				'' as Person,
				'' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				'' as FaxCountry,
				'' as FaxNumber,
				'' as FaxNumberExtension,
				'' as AddressCommunicationRemarkText
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				select 1;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				select 1;
                
            end if;
        end;
        
	elseif (var_Method_Name = 'Get_To_MobilePhoneNumber') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
            
				select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				
                select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        end;
	elseif (var_Method_Name = 'Get_To_PhoneNumber') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				
                select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_BusinessPartner_Id;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				
                 select 
                '' as AddressID,
				'' as Person,
				'1' as OrdinalNumber,
				true as IsDefaultFaxNumber,
				ifnull(Mobile_No,'') as PhoneNumber,
				IF(Mobile_No IS NOT NULL AND Mobile_No <> '', CONCAT('+91', Mobile_No), '') as PhoneNumberExtension,
				'1' as PhoneNumberType,
				'' as AddressCommunicationRemarkText
                from m009_transporter where Org_Id = var_Org_Id and Transporter_Id = var_BusinessPartner_Id;
                
            end if;
        end;
	elseif (var_Method_Name = 'Get_To_URLAddress') then	-- Get Address details for Business Partner
		begin
			if (var_BusinessPartner_Type = 'Farmer') then
            
				select 
                '' as AddressID,
				'' as Person,
				'' as OrdinalNumber,
				'' as ValidityStartDate ,
				true as IsDefaultURLAddress,
				'' as AddressCommunicationRemarkText,
				'' as WebsiteURL
                from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_BusinessPartner_Id;
                
            elseif (var_BusinessPartner_Type = 'MCC') then
				select 1;
			
            elseif (var_BusinessPartner_Type = 'Transporter') then
				select 1;
                
            end if;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
