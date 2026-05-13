namespace MilkOUT_API.Areas.AdminConsole_API.Models
{

    public class ReqSalesOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }

        public string? sales_area { get; set; }
        public string dealer_id { get; set; }
        // public string? search_period { get; set; }

        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }
        public string? salesorder_id { get; set; }
        public string? salesorderitem { get; set; }
    }

    public class ResSalesOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
    }


    public class ResGetSalesOrderHeader
    {

        public string? SalesOrder { get; set; }
        public string? CreationDate { get; set; }
        public string? OverallSDProcessStatus { get; set; }
        public string? PurchaseOrderByCustomer { get; set; }
        public string? TotalNetAmount { get; set; }
        public string? TransactionCurrency { get; set; }

        public string? soldtoparty { get; set; }

        public string? SalesArea { get; set; }
        public string? SalesGroup { get; set; }
        public string? SalesOffice { get; set; }
        public string? SalesOrganization { get; set; }
        public string? DistributionChannel { get; set; }
        public string? OrganizationDivision { get; set; }

    }


    public class ResGetSalesOrderItem
    {

        public string? SalesOrderItem { get; set; }
        public string? SalesOrderItemText { get; set; }
        public string? RequestedQuantity { get; set; }
        public string? RequestedQuantityUnit { get; set; }
        public string? NetAmount { get; set; }

        public string Material { get; set; }

        public string? Subtotal1Amount { get; set; }

         public string? Rate { get; set; }
         public string? TaxAmount { get; set; }


    }

    public class ResGetSalesOrderItemPricing
    {

        public string? SalesOrder { get; set; }
        public string? SalesOrderItem { get; set; }
        public string? ConditionType { get; set; }
        public string? ConditionBaseValue { get; set; }
        public string? ConditionRateValue { get; set; }
        public string? ConditionAmount { get; set; }

        public string ConditionCurrency { get; set; }

        public string TransactionCurrency { get; set; }

    }



    public class RootSalesOrderObject
    {
        public D_SalesOrder D { get; set; }
    }

    public class D_SalesOrder
    {
        public List<ResGetSalesOrderItem> Results { get; set; }
    }


    public class ReqSalesOrderNew : SalesOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }

        public string? salesorder_id { get; set; }
        public string? SoldToParty { get; set; }
    }
    public class SalesOrder
    {
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

        public List<To_Item> to_Item { get; set; }
    }

    public class To_Item
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

        public string RequestedQuantityUnit { get; set; }
        public string RequestedQuantitySAPUnit { get; set; }


        public string RequestedQuantityISOUnit { get; set; }
        public string OrderQuantityUnit { get; set; }

        public string OrderQuantitySAPUnit { get; set; }
        public string OrderQuantityISOUnit { get; set; }

        public List<To_Pricingelement> to_PricingElement { get; set; }
    }

    public class To_Pricingelement
    {
        public string SalesOrderItem { get; set; }
        public string ConditionType { get; set; }
        public string ConditionRateValue { get; set; }
    }


    public class ReqSalesOrderNewHeader : SalesOrderHeader
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }

        public string? salesorder_id { get; set; }
        public string? dealer_id { get; set; }
    }

    public class SalesOrderHeader
    {
        public string SalesOrderType { get; set; }
        public string SalesOrganization { get; set; }
        public string DistributionChannel { get; set; }
        public string OrganizationDivision { get; set; }
        public string SalesGroup { get; set; }
        public string SalesOffice { get; set; }
        public string SalesDistrict { get; set; }
        public string SoldToParty { get; set; }
        public string PurchaseOrderByCustomer { get; set; }
        public string PurchaseOrderByShipToParty { get; set; }
        public string CustomerPurchaseOrderType { get; set; }
        public object CustomerPurchaseOrderDate { get; set; }
        public string SalesOrderDate { get; set; }
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
        public string BillingDocumentDate { get; set; }
        public string ContractAccount { get; set; }
        public string AdditionalValueDays { get; set; }
        public string CustomerPurchaseOrderSuplmnt { get; set; }
        public object ServicesRenderedDate { get; set; }
    }

    public class ReqSalesOrderNewItems : SalesOrderItems
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }

        public string? salesorder_id { get; set; }
        public string? dealer_id { get; set; }
    }


    public class SalesOrderItems
    {
        public string SalesOrder { get; set; }
        public string SalesOrderItem { get; set; }
        public string Material { get; set; }
        public string PricingDate { get; set; }
        public string RequestedQuantity { get; set; }
        public string ConfdDelivQtyInOrderQtyUnit { get; set; }
        public string BillingDocumentDate { get; set; }
        public bool DeliveryDateQuantityIsFixed { get; set; }
        public bool SlsDocIsRlvtForProofOfDeliv { get; set; }

        public string RequestedQuantityUnit { get; set; }
        public string RequestedQuantitySAPUnit { get; set; }


        public string RequestedQuantityISOUnit { get; set; }
        public string OrderQuantityUnit { get; set; }

        public string OrderQuantitySAPUnit { get; set; }
        public string OrderQuantityISOUnit { get; set; }

        public List<To_Pricingelement> to_PricingElement { get; set; }
    }

     public class ResQualityNotification
    {

        public string? QualityNotification { get; set; }
        public string? NotifProcessingPhase { get; set; }
        public string? NotifProcessingPhaseText { get; set; }


    }


}
