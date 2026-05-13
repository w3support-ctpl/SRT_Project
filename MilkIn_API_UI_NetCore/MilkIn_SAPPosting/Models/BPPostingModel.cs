using System;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkIn_SAPPosting.Models
{
    public class ReqBusinessParterList
    {
        public string? Org_Id { get; set; }
        public string? BPType { get; set; }
        public string? User_Id { get; set; }
        public string? SAP_Code { get; set; }

    }

    //public class ResBusinessPartnerAddress
    //{
    //    public string? BusinessPartner { get; set; }
    //    public string? AddressID { get; set; }
    //    public string? AuthorizationGroup { get; set; }
    //    public string? AddressUUID { get; set; }
    //    public string? AdditionalStreetPrefixName { get; set; }
    //    public string? AdditionalStreetSuffixName { get; set; }
    //    public string? AddressTimeZone { get; set; }
    //    public string? CareOfName { get; set; }
    //    public string? CityCode { get; set; }
    //    public string? CityName { get; set; }
    //    public string? CompanyPostalCode { get; set; }
    //    public string? Country { get; set; }
    //    public string? County { get; set; }
    //    public string? DeliveryServiceNumber { get; set; }
    //    public string? DeliveryServiceTypeCode { get; set; }
    //    public string? District { get; set; }
    //    public string? FormOfAddress { get; set; }
    //    public string? FullName { get; set; }
    //    public string? HomeCityName { get; set; }
    //    public string? HouseNumber { get; set; }
    //    public string? HouseNumberSupplementText { get; set; }
    //    public string? Language { get; set; }
    //    public string? POBox { get; set; }
    //    public string? POBoxDeviatingCityName { get; set; }
    //    public string? POBoxDeviatingCountry { get; set; }
    //    public string? POBoxDeviatingRegion { get; set; }
    //    public string? POBoxIsWithoutNumber { get; set; }
    //    public string? POBoxLobbyName { get; set; }
    //    public string? POBoxPostalCode { get; set; }
    //    public string? Person { get; set; }
    //    public string? PostalCode { get; set; }
    //    public string? PrfrdCommMediumType { get; set; }
    //    public string? Region { get; set; }
    //    public string? StreetName { get; set; }
    //    public string? StreetPrefixName { get; set; }
    //    public string? StreetSuffixName { get; set; }
    //    public string? TaxJurisdiction { get; set; }
    //    public string? TransportZone { get; set; }
    //    public string? AddressIDByExternalSystem { get; set; }
    //    public string? CountyCode { get; set; }
    //    public string? TownshipCode { get; set; }
    //    public string? TownshipName { get; set; }
    //}

    public class ResBusinessPartnerBank
    {
        public string BankCountryKey { get; set; }
        public string BankNumber { get; set; }
        public string BankControlKey { get; set; }
        public string BankAccountHolderName { get; set; }
        public string BankAccountName { get; set; }
        public string IBAN { get; set; }
        public string BankAccount { get; set; }
        public string BankAccountReferenceText { get; set; }
        public bool CollectionAuthInd { get; set; }
        public string AuthorizationGroup { get; set; }
        public string BankIdentification { get; set; }

        public string BankName { get; set; }
        public string SWIFTCode { get; set; }
        public string IBANValidityStartDate { get; set; }

        public string CityName { get; set; }
    }


    // public class BusinessPartner_List
    // {
    //     public string BusinessPartner { get; set; }
    //     public string AddressID { get; set; }
    //     public object ValidityStartDate { get; set; }
    //     public object ValidityEndDate { get; set; }
    //     public string AuthorizationGroup { get; set; }
    //     public string AdditionalStreetPrefixName { get; set; }
    //     public string AdditionalStreetSuffixName { get; set; }
    //     public string AddressTimeZone { get; set; }
    //     public string CareOfName { get; set; }
    //     public string CityCode { get; set; }
    //     public string CityName { get; set; }
    //     public string CompanyPostalCode { get; set; }
    //     public string Country { get; set; }
    //     public string County { get; set; }
    //     public string DeliveryServiceNumber { get; set; }
    //     public string DeliveryServiceTypeCode { get; set; }
    //     public string District { get; set; }
    //     public string HomeCityName { get; set; }
    //     public string HouseNumber { get; set; }
    //     public string HouseNumberSupplementText { get; set; }
    //     public string Language { get; set; }
    //     public string POBox { get; set; }
    //     public string POBoxDeviatingCityName { get; set; }
    //     public string POBoxDeviatingCountry { get; set; }
    //     public string POBoxDeviatingRegion { get; set; }
    //     public bool POBoxIsWithoutNumber { get; set; }
    //     public string POBoxLobbyName { get; set; }
    //     public string POBoxPostalCode { get; set; }
    //     public string PostalCode { get; set; }
    //     public string PrfrdCommMediumType { get; set; }
    //     public string Region { get; set; }
    //     public string StreetName { get; set; }
    //     public string StreetPrefixName { get; set; }
    //     public string StreetSuffixName { get; set; }
    //     public string TaxJurisdiction { get; set; }
    //     public string TransportZone { get; set; }
    //     public string AddressIDByExternalSystem { get; set; }
    //     public string CountyCode { get; set; }
    //     public string TownshipCode { get; set; }
    //     public string TownshipName { get; set; }
    //     public string to_BPAddrDepdntIntlLocNumber { get; set; }

    //     public To_Addressusage_List to_Addressusage { get; set; }
    //     public To_Bpintladdressversion_List to_Bpintladdressversion { get; set; }
    //     public To_Emailaddress_List to_Emailaddress { get; set; }
    //     public To_Faxnumber_List to_Faxnumber { get; set; }
    //     public To_Mobilephonenumber_List to_Mobilephonenumber { get; set; }
    //     public To_Phonenumber_List to_Phonenumber { get; set; }
    //     public To_Urladdress_List to_Urladdress { get; set; }


    // }

    // public class To_Addressusage_List
    // {
    //     public List<Result> results { get; set; }
    // }

    // public class Result
    // {
    //     public string BusinessPartner { get; set; }
    //     public object ValidityEndDate { get; set; }
    //     public string AddressUsage { get; set; }
    //     public string AddressID { get; set; }
    //     public object ValidityStartDate { get; set; }
    //     public bool StandardUsage { get; set; }
    //     public string AuthorizationGroup { get; set; }
    // }

    // public class To_Bpintladdressversion_List
    // {
    //     public List<Result1> results { get; set; }
    // }

    // public class Result1
    // {
    //     public string BusinessPartner { get; set; }
    //     public string AddressID { get; set; }
    //     public string AddressRepresentationCode { get; set; }
    //     public string AddressSearchTerm1 { get; set; }
    //     public string AddressSearchTerm2 { get; set; }
    //     public string CareOfName { get; set; }
    //     public string CityName { get; set; }
    //     public string DistrictName { get; set; }
    //     public string FormOfAddress { get; set; }
    //     public string HouseNumber { get; set; }
    //     public string HouseNumberSupplementText { get; set; }
    //     public string OrganizationName1 { get; set; }
    //     public string OrganizationName2 { get; set; }
    //     public string OrganizationName3 { get; set; }
    //     public string OrganizationName4 { get; set; }
    //     public string PersonFamilyName { get; set; }
    //     public string PersonGivenName { get; set; }
    //     public string POBoxDeviatingCityName { get; set; }
    //     public string POBoxLobbyName { get; set; }
    //     public string SecondaryRegionName { get; set; }
    //     public string StreetName { get; set; }
    //     public string StreetPrefixName1 { get; set; }
    //     public string StreetPrefixName2 { get; set; }
    //     public string StreetSuffixName1 { get; set; }
    //     public string StreetSuffixName2 { get; set; }
    //     public string TertiaryRegionName { get; set; }
    //     public string VillageName { get; set; }
    // }

    // public class To_Emailaddress_List
    // {
    //     public List<Result2> results { get; set; }
    // }

    // public class Result2
    // {
    //     public string AddressID { get; set; }
    //     public string Person { get; set; }
    //     public string OrdinalNumber { get; set; }
    //     public bool IsDefaultEmailAddress { get; set; }
    //     public string EmailAddress { get; set; }
    //     public string AddressCommunicationRemarkText { get; set; }
    // }

    // public class To_Faxnumber_List
    // {
    //     public List<Result3> results { get; set; }
    // }

    // public class Result3
    // {
    //     public string AddressID { get; set; }
    //     public string Person { get; set; }
    //     public string OrdinalNumber { get; set; }
    //     public bool IsDefaultFaxNumber { get; set; }
    //     public string FaxCountry { get; set; }
    //     public string FaxNumber { get; set; }
    //     public string FaxNumberExtension { get; set; }
    //     public string AddressCommunicationRemarkText { get; set; }
    // }

    // public class To_Mobilephonenumber_List
    // {
    //     public List<Result4> results { get; set; }
    // }

    // public class Result4
    // {
    //     public string AddressID { get; set; }
    //     public string Person { get; set; }
    //     public string OrdinalNumber { get; set; }
    //     public string DestinationLocationCountry { get; set; }
    //     public bool IsDefaultPhoneNumber { get; set; }
    //     public string PhoneNumber { get; set; }
    //     public string PhoneNumberExtension { get; set; }
    //     public string PhoneNumberType { get; set; }
    //     public string AddressCommunicationRemarkText { get; set; }
    // }

    // public class To_Phonenumber_List
    // {
    //     public List<Result5> results { get; set; }
    // }

    // public class Result5
    // {
    //     public string AddressID { get; set; }
    //     public string Person { get; set; }
    //     public string OrdinalNumber { get; set; }
    //     public string DestinationLocationCountry { get; set; }
    //     public bool IsDefaultPhoneNumber { get; set; }
    //     public string PhoneNumber { get; set; }
    //     public string PhoneNumberExtension { get; set; }
    //     public string PhoneNumberType { get; set; }
    //     public string AddressCommunicationRemarkText { get; set; }
    // }

    // public class To_Urladdress_List
    // {
    //     public List<Result6> results { get; set; }
    // }

    // public class Result6
    // {
    //     public string AddressID { get; set; }
    //     public string Person { get; set; }
    //     public string OrdinalNumber { get; set; }
    //     public object ValidityStartDate { get; set; }
    //     public bool IsDefaultURLAddress { get; set; }
    //     public string AddressCommunicationRemarkText { get; set; }
    //     public string WebsiteURL { get; set; }
    // }

     public class ResBusinessPartnerName
    {
        public string FullName { get; set; }
    }

    public class ResBusinessPartnerIdentification
    {
        public string BusinessPartner { get; set; }
        public string BPIdentificationType { get; set; }
        public string BPIdentificationNumber { get; set; }
    }

public class ResBusinessPartnerMobile
    {
        public string PhoneNumber { get; set; }
    }

    public class ResBusinessPartnerAddress
    {
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
    }



}
