

using Newtonsoft.Json;
namespace MilkOUT_API.Areas.SalesApp_API.Models
{

    public class RqSalesOrder
    {

        public string SalesOrder { get; set; }
        public string SalesOrderType { get; set; }
        public string SalesOrganization { get; set; }
        public string DistributionChannel { get; set; }
        public string OrganizationDivision { get; set; }
        public string SalesGroup { get; set; }
        public string SalesOffice { get; set; }
        public string SalesDistrict { get; set; }
        public string SoldToParty { get; set; }
        public string CreationDate { get; set; }
        public string CreatedByUser { get; set; }
        public string LastChangeDate { get; set; }
        public string SenderBusinessSystemName { get; set; }
        public string ExternalDocumentID { get; set; }
        public string LastChangeDateTime { get; set; }
        public object ExternalDocLastChangeDateTime { get; set; }
        public string PurchaseOrderByCustomer { get; set; }
        public string PurchaseOrderByShipToParty { get; set; }
        public string CustomerPurchaseOrderType { get; set; }
        public object CustomerPurchaseOrderDate { get; set; }
        public string SalesOrderDate { get; set; }
        public string TotalNetAmount { get; set; }
        public string OverallDeliveryStatus { get; set; }
        public string TotalBlockStatus { get; set; }
        public string OverallOrdReltdBillgStatus { get; set; }
        public string OverallSDDocReferenceStatus { get; set; }
        public string TransactionCurrency { get; set; }
        public string SDDocumentReason { get; set; }
        public string PricingDate { get; set; }
        public string PriceDetnExchangeRate { get; set; }
        public string BillingPlan { get; set; }
        public string RequestedDeliveryDate { get; set; }
        public string ShippingCondition { get; set; }
        public bool CompleteDeliveryIsDefined { get; set; }
        public string ShippingType { get; set; }
        public string HeaderBillingBlockReason { get; set; }
        public string DeliveryBlockReason { get; set; }
        public string DeliveryDateTypeRule { get; set; }
        public string IncotermsClassification { get; set; }
        public string IncotermsTransferLocation { get; set; }
        public string IncotermsLocation1 { get; set; }
        public string IncotermsLocation2 { get; set; }
        public string IncotermsVersion { get; set; }
        public string CustomerPriceGroup { get; set; }
        public string PriceListType { get; set; }
        public string CustomerPaymentTerms { get; set; }
        public string PaymentMethod { get; set; }
        public object FixedValueDate { get; set; }
        public string AssignmentReference { get; set; }
        public string ReferenceSDDocument { get; set; }
        public string ReferenceSDDocumentCategory { get; set; }
        public string AccountingDocExternalReference { get; set; }
        public string CustomerAccountAssignmentGroup { get; set; }
        public string AccountingExchangeRate { get; set; }
        public string CustomerGroup { get; set; }
        public string AdditionalCustomerGroup1 { get; set; }
        public string AdditionalCustomerGroup2 { get; set; }
        public string AdditionalCustomerGroup3 { get; set; }
        public string AdditionalCustomerGroup4 { get; set; }
        public string AdditionalCustomerGroup5 { get; set; }
        public bool SlsDocIsRlvtForProofOfDeliv { get; set; }
        public string CustomerTaxClassification1 { get; set; }
        public string CustomerTaxClassification2 { get; set; }
        public string CustomerTaxClassification3 { get; set; }
        public string CustomerTaxClassification4 { get; set; }
        public string CustomerTaxClassification5 { get; set; }
        public string CustomerTaxClassification6 { get; set; }
        public string CustomerTaxClassification7 { get; set; }
        public string CustomerTaxClassification8 { get; set; }
        public string CustomerTaxClassification9 { get; set; }
        public string TaxDepartureCountry { get; set; }
        public string VATRegistrationCountry { get; set; }
        public string SalesOrderApprovalReason { get; set; }
        public string SalesDocApprovalStatus { get; set; }
        public string OverallSDProcessStatus { get; set; }
        public string TotalCreditCheckStatus { get; set; }
        public string OverallTotalDeliveryStatus { get; set; }
        public string OverallSDDocumentRejectionSts { get; set; }
        public string BillingDocumentDate { get; set; }
        public string ContractAccount { get; set; }
        public string AdditionalValueDays { get; set; }
        public string CustomerPurchaseOrderSuplmnt { get; set; }
        public object ServicesRenderedDate { get; set; }

        public List<RqTo_Item> to_Item { get; set; }
    }

    public class RqTo_Item
    {
        public string SalesOrderItem { get; set; }

        public string Material { get; set; }
        // public string MaterialByCustomer { get; set; }
        public string PricingDate { get; set; }

        public string RequestedQuantity { get; set; }

        public string ConfdDelivQtyInOrderQtyUnit { get; set; }
        public string BillingDocumentDate { get; set; }
        public bool DeliveryDateQuantityIsFixed { get; set; }

        public bool SlsDocIsRlvtForProofOfDeliv { get; set; }
        public List<RqTo_Pricingelement> to_PricingElement { get; set; }
    }

    public class RqTo_Pricingelement
    {
        public string SalesOrderItem { get; set; }
        public string ConditionType { get; set; }
        public string ConditionRateValue { get; set; }
    }

    public class NotificationHeader
    {

        [JsonProperty("@odata.etag")]
        public string? odataetag { get; set; }
        public string? QualityNotification { get; set; }
        public string? NotificationOrigin { get; set; }
        public string? NotificationType { get; set; }
        public string? MasterLanguage { get; set; }
        public string? NotificationText { get; set; }
        public string? NotificationPriorityType { get; set; }
        public string? NotificationPriority { get; set; }
        public string? NotificationStatusObject { get; set; }
        public string? NotifProcessingPhase { get; set; }
        public string? NotificationCatalog { get; set; }
        public string? NotificationCodeGroup { get; set; }
        public string? NotificationCodeID { get; set; }
        public object? NotificationReportingDate { get; set; }
        public object? NotificationCompletionDate { get; set; }
        public object? NotificationRequiredStartDate { get; set; }
        public string? NotificationRequiredStartTime { get; set; }
        public object? NotificationRequiredEndDate { get; set; }
        public string? NotificationRequiredEndTime { get; set; }
        public string? NotificationTimeZone { get; set; }
        public string? Supplier { get; set; }
        public string? Customer { get; set; }
        public string? Material { get; set; }
        public string? MaterialGroup { get; set; }
        public string? Plant { get; set; }
        public string? PurchasingDocument { get; set; }
        public string? PurchasingDocumentItem { get; set; }
        public string? PurchasingOrganization { get; set; }
        public string? PurchasingGroup { get; set; }
        public string? ActiveDivision { get; set; }
        public string? SalesOrganization { get; set; }
        public string? DistributionChannel { get; set; }
        public string? WBSElementInternalID { get; set; }
        public string? WorkCenterTypeCode { get; set; }
        public string? MainWorkCenterInternalID { get; set; }
        public string? MainWorkCenterPlant { get; set; }
        public string? InspectionLot { get; set; }
        public string? Batch { get; set; }
        public string? MaterialDocumentYear { get; set; }
        public string? MaterialDocument { get; set; }
        public string? MaterialDocumentItem { get; set; }
        public bool? IsBusinessPurposeCompleted { get; set; }
        public bool? IsDeleted { get; set; }
        public string? CreatedByUser { get; set; }
        public object? CreationDate { get; set; }
        public string? LastChangedByUser { get; set; }
        public string? LastChangedDate { get; set; }
        public string? ChangedDateTime { get; set; }
        public List<_QltyNotificationPartner> _QltyNotificationPartner { get; set; }
    }

    public class _QltyNotificationPartner
    {
        public string? PartnerFunction { get; set; }
        public string? NotificationPartner { get; set; }
    }




    public class ReqQualityNotification
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }

        public string? sales_area { get; set; }
        public string dealer_id { get; set; }
        public string? qualitynotification { get; set; }

        public string? parentfield_id { get; set; }

    }


}

