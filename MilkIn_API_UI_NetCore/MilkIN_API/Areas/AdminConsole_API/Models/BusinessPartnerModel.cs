namespace MilkIN_API.Areas.AdminConsole_API.Models
{

    public class ReqSAPBusinessParenerNew : ReqSAPBusinessPartner
    {
        public string Org_Id { get; set; }
        public string Destination { get; set; }
    }
    public class ReqSAPBusinessPartner
    {
        public string BusinessPartner { get; set; }
        public string AcademicTitle { get; set; }
        public string FormOfAddress { get; set; }
        public string BusinessPartnerGrouping { get; set; }
        public string BusinessPartnerCategory { get; set; }
        public string OrganizationBPName1 { get; set; }
        public string OrganizationBPName2 { get; set; }
        public string OrganizationBPName3 { get; set; }
        public string OrganizationBPName4 { get; set; }
        public string SearchTerm1 { get; set; }
        public string AuthorizationGroup { get; set; }
        public string LegalForm { get; set; }
        public string BusinessPartnerType { get; set; }
        public bool BusinessPartnerIsBlocked { get; set; }
        public List<To_Businesspartneraddress> to_BusinessPartnerAddress { get; set; }
        public List<To_Bupaidentification> to_BuPaIdentification { get; set; }
        public List<To_Businesspartnerrole> to_BusinessPartnerRole { get; set; }
        public List<To_Businesspartnerbank> to_BusinessPartnerBank { get; set; }
        public To_Supplier to_Supplier { get; set; }
    }

    public class To_Supplier
    {
        public string BusinessPartnerPanNumber { get; set; }
        public bool PaymentIsBlockedForSupplier { get; set; }
        public bool PostingIsBlocked { get; set; }
        public bool PurchasingIsBlocked { get; set; }
        public bool DeletionIndicator { get; set; }
        public string IsNaturalPerson { get; set; }
        public string TaxNumberResponsible { get; set; }
        public List<To_Suppliercompany> to_SupplierCompany { get; set; }
    }

    public class To_Suppliercompany
    {
        public string CompanyCode { get; set; }
        public string ReconciliationAccount { get; set; }
        public string SupplierHeadOffice { get; set; }
        public string CashPlanningGroup { get; set; }
        public bool PaymentIsToBeSentByEDI { get; set; }
        public string SupplierAccountNote { get; set; }
        public bool IsToBeCheckedForDuplicates { get; set; }
        public bool DeletionIndicator { get; set; }
        public bool SupplierIsBlockedForPosting { get; set; }
        public bool IsToBeLocallyProcessed { get; set; }
        public bool ItemIsToBePaidSeparately { get; set; }
        public bool ClearCustomerSupplier { get; set; }

        public List<To_SupplierWithHoldingTax> to_SupplierWithHoldingTax { get; set; }
    }


    public class To_SupplierWithHoldingTax
    {
        public string Supplier { get; set; }
        public string CompanyCode { get; set; }
        public string WithholdingTaxType { get; set; }
        public string ExemptionDateBegin { get; set; }
        public string ExemptionDateEnd { get; set; }
        public string ExemptionReason { get; set; }
        public bool IsWithholdingTaxSubject { get; set; }
        public string RecipientType { get; set; }
        public string WithholdingTaxCertificate { get; set; }
        public string WithholdingTaxCode { get; set; }
        public string WithholdingTaxExmptPercent { get; set; }
        public string WithholdingTaxNumber { get; set; }
        public string AuthorizationGroup { get; set; }
    }

    public class To_Businesspartneraddress
    {
        public string Country { get; set; }
        public string HouseNumber { get; set; }
        public string StreetName { get; set; }
        public string PostalCode { get; set; }
        public string CityName { get; set; }
        public string District { get; set; }
        public string Region { get; set; }
        public string POBox { get; set; }
        public string Language { get; set; }
        public string AdditionalStreetPrefixName { get; set; }
        public List<To_Emailaddress> to_EmailAddress { get; set; }
        public List<To_Mobilephonenumber> to_MobilePhoneNumber { get; set; }
        public List<To_Addressusage> to_AddressUsage { get; set; }
    }

    public class To_Emailaddress
    {
        public string OrdinalNumber { get; set; }
        public bool IsDefaultEmailAddress { get; set; }
        public string EmailAddress { get; set; }
        public string SearchEmailAddress { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Mobilephonenumber
    {
        public string OrdinalNumber { get; set; }
        public string DestinationLocationCountry { get; set; }
        public bool IsDefaultPhoneNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string PhoneNumberExtension { get; set; }
        public string InternationalPhoneNumber { get; set; }
        public string PhoneNumberType { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Addressusage
    {
        public string AddressUsage { get; set; }
    }

    public class To_Bupaidentification
    {
        public string BPIdentificationType { get; set; }
        public string BPIdentificationNumber { get; set; }
        public string BPIdnNmbrIssuingInstitute { get; set; }
        public object BPIdentificationEntryDate { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public object ValidityStartDate { get; set; }
        public object ValidityEndDate { get; set; }
        public string AuthorizationGroup { get; set; }
    }

    public class To_Businesspartnerrole
    {
        public string BusinessPartnerRole { get; set; }
    }

    public class To_Businesspartnerbank
    {
        public string BankIdentification { get; set; }
        public string BankCountryKey { get; set; }
        public string BankName { get; set; }
        public string BankNumber { get; set; }
        public string SWIFTCode { get; set; }
        public string BankControlKey { get; set; }
        public string BankAccountHolderName { get; set; }
        public string BankAccountName { get; set; }
        public string IBAN { get; set; }
        public object IBANValidityStartDate { get; set; }
        public string BankAccount { get; set; }
        public string BankAccountReferenceText { get; set; }
        public bool CollectionAuthInd { get; set; }
        public string CityName { get; set; }
        public string AuthorizationGroup { get; set; }
    }



    public class BusinessPartner_List
    {
        public string BusinessPartner { get; set; }
        public string AddressID { get; set; }
        public object ValidityStartDate { get; set; }
        public object ValidityEndDate { get; set; }
        public string AuthorizationGroup { get; set; }
        public string AdditionalStreetPrefixName { get; set; }
        public string AdditionalStreetSuffixName { get; set; }
        public string AddressTimeZone { get; set; }
        public string CareOfName { get; set; }
        public string CityCode { get; set; }
        public string CityName { get; set; }
        public string CompanyPostalCode { get; set; }
        public string Country { get; set; }
        public string County { get; set; }
        public string DeliveryServiceNumber { get; set; }
        public string DeliveryServiceTypeCode { get; set; }
        public string District { get; set; }
        public string HomeCityName { get; set; }
        public string HouseNumber { get; set; }
        public string HouseNumberSupplementText { get; set; }
        public string Language { get; set; }
        public string POBox { get; set; }
        public string POBoxDeviatingCityName { get; set; }
        public string POBoxDeviatingCountry { get; set; }
        public string POBoxDeviatingRegion { get; set; }
        public bool POBoxIsWithoutNumber { get; set; }
        public string POBoxLobbyName { get; set; }
        public string POBoxPostalCode { get; set; }
        public string PostalCode { get; set; }
        public string PrfrdCommMediumType { get; set; }
        public string Region { get; set; }
        public string StreetName { get; set; }
        public string StreetPrefixName { get; set; }
        public string StreetSuffixName { get; set; }
        public string TaxJurisdiction { get; set; }
        public string TransportZone { get; set; }
        public string AddressIDByExternalSystem { get; set; }
        public string CountyCode { get; set; }
        public string TownshipCode { get; set; }
        public string TownshipName { get; set; }
        public string to_BPAddrDepdntIntlLocNumber { get; set; }

        public To_Addressusage_List to_Addressusage { get; set; }
        public To_Bpintladdressversion_List to_Bpintladdressversion { get; set; }
        public To_Emailaddress_List to_Emailaddress { get; set; }
        public To_Faxnumber_List to_Faxnumber { get; set; }
        public To_Mobilephonenumber_List to_Mobilephonenumber { get; set; }
        public To_Phonenumber_List to_Phonenumber { get; set; }
        public To_Urladdress_List to_Urladdress { get; set; }


    }

    public class To_Addressusage_List
    {
        public List<Result> results { get; set; }
    }

    public class Result
    {
        public string BusinessPartner { get; set; }
        public object ValidityEndDate { get; set; }
        public string AddressUsage { get; set; }
        public string AddressID { get; set; }
        public object ValidityStartDate { get; set; }
        public bool StandardUsage { get; set; }
        public string AuthorizationGroup { get; set; }
    }

    public class To_Bpintladdressversion_List
    {
        public List<Result1> results { get; set; }
    }

    public class Result1
    {
        public string BusinessPartner { get; set; }
        public string AddressID { get; set; }
        public string AddressRepresentationCode { get; set; }
        public string AddressSearchTerm1 { get; set; }
        public string AddressSearchTerm2 { get; set; }
        public string CareOfName { get; set; }
        public string CityName { get; set; }
        public string DistrictName { get; set; }
        public string FormOfAddress { get; set; }
        public string HouseNumber { get; set; }
        public string HouseNumberSupplementText { get; set; }
        public string OrganizationName1 { get; set; }
        public string OrganizationName2 { get; set; }
        public string OrganizationName3 { get; set; }
        public string OrganizationName4 { get; set; }
        public string PersonFamilyName { get; set; }
        public string PersonGivenName { get; set; }
        public string POBoxDeviatingCityName { get; set; }
        public string POBoxLobbyName { get; set; }
        public string SecondaryRegionName { get; set; }
        public string StreetName { get; set; }
        public string StreetPrefixName1 { get; set; }
        public string StreetPrefixName2 { get; set; }
        public string StreetSuffixName1 { get; set; }
        public string StreetSuffixName2 { get; set; }
        public string TertiaryRegionName { get; set; }
        public string VillageName { get; set; }
    }

    public class To_Emailaddress_List
    {
        public List<Result2> results { get; set; }
    }

    public class Result2
    {
        public string AddressID { get; set; }
        public string Person { get; set; }
        public string OrdinalNumber { get; set; }
        public bool IsDefaultEmailAddress { get; set; }
        public string EmailAddress { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Faxnumber_List
    {
        public List<Result3> results { get; set; }
    }

    public class Result3
    {
        public string AddressID { get; set; }
        public string Person { get; set; }
        public string OrdinalNumber { get; set; }
        public bool IsDefaultFaxNumber { get; set; }
        public string FaxCountry { get; set; }
        public string FaxNumber { get; set; }
        public string FaxNumberExtension { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Mobilephonenumber_List
    {
        public List<Result4> results { get; set; }
    }

    public class Result4
    {
        public string AddressID { get; set; }
        public string Person { get; set; }
        public string OrdinalNumber { get; set; }
        public string DestinationLocationCountry { get; set; }
        public bool IsDefaultPhoneNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string PhoneNumberExtension { get; set; }
        public string PhoneNumberType { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Phonenumber_List
    {
        public List<Result5> results { get; set; }
    }

    public class Result5
    {
        public string AddressID { get; set; }
        public string Person { get; set; }
        public string OrdinalNumber { get; set; }
        public string DestinationLocationCountry { get; set; }
        public bool IsDefaultPhoneNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string PhoneNumberExtension { get; set; }
        public string PhoneNumberType { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
    }

    public class To_Urladdress_List
    {
        public List<Result6> results { get; set; }
    }

    public class Result6
    {
        public string AddressID { get; set; }
        public string Person { get; set; }
        public string OrdinalNumber { get; set; }
        public object ValidityStartDate { get; set; }
        public bool IsDefaultURLAddress { get; set; }
        public string AddressCommunicationRemarkText { get; set; }
        public string WebsiteURL { get; set; }
    }





}
