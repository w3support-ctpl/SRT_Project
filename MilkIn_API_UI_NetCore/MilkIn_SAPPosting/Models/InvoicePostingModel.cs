using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkIn_SAPPosting.Models
{
    public class ReqSAPMilkSOAP
    {

        //public string? Amount { get; set; }
        //public string? Farmer_Code { get; set; }
        //public string? Invoice_Id { get; set; }

        public string? xmlData { get; set; }

    }

    public class ReqInvoiceMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }

        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }


        public string? mcctype_id { get; set; }
    }

    public class ResInvoiceFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcctype_id { get; set; }

    }

    public class ReqInvoiceFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

    }


    public class ReqInvoiceTransporter
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }



        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }

        public string? transporter_code { get; set; }
        public string? transporter_id { get; set; }

        public string? transporter_name { get; set; }

    }

    public class ReqInvoiceTDS
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? type { get; set; }
        public string? mcc_id { get; set; }
        public string? voucher_id { get; set; }
        public string? income_sap_document_id { get; set; }
        public string? income_sap_document_year { get; set; }
        public string? deduction_sap_document_id { get; set; }
        public string? deduction_sap_document_year { get; set; }

    }

    public class ReqSAPMilkSOAPIncome
    {
        public string FiscalYear { get; set; }
        public string CompanyCode { get; set; }
        public object DocumentDate { get; set; }
        public object PostingDate { get; set; }
        public object CreationDate { get; set; }
        public string SupplierInvoiceIDByInvcgParty { get; set; }
        public string InvoicingParty { get; set; }
        public string DocumentCurrency { get; set; }
        public string InvoiceGrossAmount { get; set; }
        public string PaymentTerms { get; set; }
        public string AccountingDocumentType { get; set; }
        public string SupplierInvoiceStatus { get; set; }
        public bool TaxIsCalculatedAutomatically { get; set; }
        public string BusinessPlace { get; set; }
        public string BusinessSectionCode { get; set; }
        public bool SuplrInvcIsCapitalGoodsRelated { get; set; }
        public object TaxDeterminationDate { get; set; }
        public object TaxReportingDate { get; set; }
        public object TaxFulfillmentDate { get; set; }
        public object InvoiceReceiptDate { get; set; }
        public bool IsEUTriangularDeal { get; set; }
        public object RetentionDueDate { get; set; }
        public bool IsReversal { get; set; }
        public bool IsReversed { get; set; }

        public object SupplierPostingLineItemText { get; set; }

        public List<To_Supplierinvoiceitemglacct> to_SupplierInvoiceItemGLAcct { get; set; }
        public List<To_Supplierinvoicewhldgtax> to_SupplierInvoiceWhldgTax { get; set; }
        public string SupplierInvoiceIsCreditMemo { get; set; }
    }

    public class To_Supplierinvoiceitemglacct
    {
        public string FiscalYear { get; set; }
        public string SupplierInvoiceItem { get; set; }
        public string CompanyCode { get; set; }
        public string CostCenter { get; set; }
        public string ProfitCenter { get; set; }
        public string GLAccount { get; set; }
        public string DocumentCurrency { get; set; }
        public string SupplierInvoiceItemAmount { get; set; }
        public string TaxCode { get; set; }
        public string DebitCreditCode { get; set; }
        public bool IsNotCashDiscountLiable { get; set; }
        public string TaxBaseAmountInTransCrcy { get; set; }

        public object SupplierInvoiceItemText { get; set; }
    }

    public class To_Supplierinvoicewhldgtax
    {
        public string WithholdingTaxType { get; set; }
        public string DocumentCurrency { get; set; }
        public string WithholdingTaxCode { get; set; }
        public string WithholdingTaxBaseAmount { get; set; }
    }

    public class ReqTradingMaterial
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? product_id { get; set; }
        public string? order_id { get; set; }

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
        public string PricingDate { get; set; }
        public string RequestedQuantity { get; set; }
        public string ConfdDelivQtyInOrderQtyUnit { get; set; }
        public string BillingDocumentDate { get; set; }
        public bool DeliveryDateQuantityIsFixed { get; set; }
        public bool SlsDocIsRlvtForProofOfDeliv { get; set; }
        public List<To_Pricingelement> to_PricingElement { get; set; }
    }

    public class To_Pricingelement
    {
        // public string SalesOrderItem { get; set; }
        // public string ConditionType { get; set; }
        // public string ConditionRateValue { get; set; }
    }

}