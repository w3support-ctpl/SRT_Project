namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
	public class ReqInvoice
	{
		public string? method_name { get; set; }
		public string? org_id { get; set; }
		public string? user_id { get; set; }
		public string? destination_name { get; set; }
		public string? api_end_point { get; set; }
		public string dealer_id { get; set; }
		public string? start_date { get; set; }
		public string? end_date { get; set; }
		public string invoice_no { get; set; }

	}

	public class ResInvoice
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


	public class ResGetInvoiceItem
	{


		public string? ReferenceSDDocument { get; set; }
		public string? BillingDocument { get; set; }
		public string? BillingDocumentItem { get; set; }
		public string? BillingDocumentItemText { get; set; }
		public string? Material { get; set; }
		public string? Plant { get; set; }
		public string? ItemWeightUnit { get; set; }
		public decimal? NetAmount { get; set; }
		public string? BillingDocumentDate { get; set; }
		public string? BillingQuantity { get; set; }


		public string? SalesOrganization { get; set; }
		public string? DistributionChannel { get; set; }
		public string? OrganizationDivision { get; set; }
		public string? SalesGroup { get; set; }
		public string? SalesOffice { get; set; }
		public string? SoldToParty { get; set; }

		public decimal? TaxAmount { get; set; }

	}

	public class ResGetInvoicePricing
	{


		public string? BillingDocument { get; set; }
		public string? BillingDocumentItem { get; set; }
		public string? ConditionRateValue { get; set; }
		public string? ConditionType { get; set; }

		public string? ConditionAmount { get; set; }

		public string? ConditionBaseValue { get; set; }

	}



	public class ResGetInvoice
	{

		public string? DocumentReferenceID { get; set; }
		public string? BillingDocument { get; set; }
		public string? BillingDocumentDate { get; set; }
		public string? CustomerPaymentTerms { get; set; }
		public string? TotalNetAmount { get; set; }
		public string? TransactionCurrency { get; set; }

		public string? BillingDocumentType { get; set; }

		public string? ReferenceDocument { get; set; }
		public string? TotalTaxAmount { get; set; }

	}





	public class PricingElement
	{
		public string? PricingProcedureStep { get; set; }
		public string? ConditionType { get; set; }
		public string? ConditionRateValue { get; set; }
	}

	public class Item
	{
		public string? CustomerReturnItem { get; set; }
		public string? HigherLevelItem { get; set; }
		public string? CustomerReturnItemCategory { get; set; }
		public string? Material { get; set; }
		public string? CustomerReturnItemText { get; set; }
		public string? RequestedQuantity { get; set; }
		public string? RequestedQuantityUnit { get; set; }
		public string? TransactionCurrency { get; set; }
		public string? NetAmount { get; set; }
		public string? MaterialGroup { get; set; }
		public string? Batch { get; set; }
		public string? ProductionPlant { get; set; }
		public string? StorageLocation { get; set; }
		public string? ShippingPoint { get; set; }
		public string? ShippingType { get; set; }
		public string? DeliveryPriority { get; set; }
		public string? IncotermsClassification { get; set; }
		public string? IncotermsTransferLocation { get; set; }
		public string? IncotermsLocation1 { get; set; }
		public string? IncotermsLocation2 { get; set; }
		public string? CustomerPaymentTerms { get; set; }
		public string? ProfitCenter { get; set; }
		public string? ReferenceSDDocument { get; set; }
		public string? ReferenceSDDocumentItem { get; set; }
		public string? SDProcessStatus { get; set; }
		public string? Subtotal1Amount { get; set; }
		public string? Subtotal2Amount { get; set; }
		public string? Subtotal3Amount { get; set; }
		public string? Subtotal4Amount { get; set; }
		public string? Subtotal5Amount { get; set; }
		public string? Subtotal6Amount { get; set; }
		public List<PricingElement> to_PricingElement { get; set; }
	}

	public class Root
	{
		public string? CustomerReturn { get; set; }
		public string? CustomerReturnType { get; set; }
		public string? SalesOrganization { get; set; }
		public string? DistributionChannel { get; set; }
		public string? OrganizationDivision { get; set; }
		public string? SalesGroup { get; set; }
		public string? SalesOffice { get; set; }
		public string? SalesDistrict { get; set; }
		public string? SoldToParty { get; set; }
		public string? CreationDate { get; set; }
		public string? CreatedByUser { get; set; }
		public string? LastChangeDate { get; set; }
		public string? SenderBusinessSystemName { get; set; }
		public string? LastChangeDateTime { get; set; }
		public string? PurchaseOrderByCustomer { get; set; }
		public string? CustomerPurchaseOrderType { get; set; }
		public object CustomerPurchaseOrderDate { get; set; }
		public string? CustomerReturnDate { get; set; }
		public string? TotalNetAmount { get; set; }
		public string? TransactionCurrency { get; set; }
		public string? SDDocumentReason { get; set; }
		public string? PricingDate { get; set; }
		public string? RequestedDeliveryDate { get; set; }
		public string? ShippingType { get; set; }
		public string? HeaderBillingBlockReason { get; set; }
		public string? DeliveryBlockReason { get; set; }
		public string? IncotermsClassification { get; set; }
		public string? IncotermsTransferLocation { get; set; }
		public string? IncotermsLocation1 { get; set; }
		public string? IncotermsLocation2 { get; set; }
		public string? IncotermsVersion { get; set; }
		public string? CustomerPaymentTerms { get; set; }
		public string? PaymentMethod { get; set; }
		public string? RetsMgmtProcess { get; set; }
		public string? ReferenceSDDocument { get; set; }
		public string? ReferenceSDDocumentCategory { get; set; }
		public string? AccountingDocExternalReference { get; set; }
		public string? AssignmentReference { get; set; }
		public string? CustomerReturnApprovalReason { get; set; }
		public string? SalesDocApprovalStatus { get; set; }
		public string? RetsMgmtLogProcgStatus { get; set; }
		public string? RetsMgmtCompnProcgStatus { get; set; }
		public string? RetsMgmtProcessingStatus { get; set; }
		public string? OverallSDProcessStatus { get; set; }
		public string? TotalCreditCheckStatus { get; set; }
		public string? OverallSDDocumentRejectionSts { get; set; }
		public List<Item> to_Item { get; set; }
	}



	public class Roots
	{
		public string? CustomerReturn { get; set; }
		public string? CustomerReturnType { get; set; }
		public string? SalesOrganization { get; set; }
		public string? DistributionChannel { get; set; }
		public string? OrganizationDivision { get; set; }
		public string? SalesGroup { get; set; }
		public string? SalesOffice { get; set; }
		public string? SalesDistrict { get; set; }
		public string? SoldToParty { get; set; }
		public string? CreationDate { get; set; }
		public string? CreatedByUser { get; set; }
		public string? LastChangeDate { get; set; }
		public string? SenderBusinessSystemName { get; set; }
		public string? LastChangeDateTime { get; set; }
		public string? PurchaseOrderByCustomer { get; set; }
		public string? CustomerPurchaseOrderType { get; set; }
		public object CustomerPurchaseOrderDate { get; set; }
		public string? CustomerReturnDate { get; set; }
		public string? TotalNetAmount { get; set; }
		public string? TransactionCurrency { get; set; }
		public string? SDDocumentReason { get; set; }
		public string? PricingDate { get; set; }
		public string? RequestedDeliveryDate { get; set; }
		public string? ShippingType { get; set; }
		public string? HeaderBillingBlockReason { get; set; }
		public string? DeliveryBlockReason { get; set; }
		public string? IncotermsClassification { get; set; }
		public string? IncotermsTransferLocation { get; set; }
		public string? IncotermsLocation1 { get; set; }
		public string? IncotermsLocation2 { get; set; }
		public string? IncotermsVersion { get; set; }
		public string? CustomerPaymentTerms { get; set; }
		public string? PaymentMethod { get; set; }
		public string? RetsMgmtProcess { get; set; }
		public string? ReferenceSDDocument { get; set; }
		public string? ReferenceSDDocumentCategory { get; set; }
		public string? AccountingDocExternalReference { get; set; }
		public string? AssignmentReference { get; set; }
		public string? CustomerReturnApprovalReason { get; set; }
		public string? SalesDocApprovalStatus { get; set; }
		public string? RetsMgmtLogProcgStatus { get; set; }
		public string? RetsMgmtCompnProcgStatus { get; set; }
		public string? RetsMgmtProcessingStatus { get; set; }
		public string? OverallSDProcessStatus { get; set; }
		public string? TotalCreditCheckStatus { get; set; }
		public string? OverallSDDocumentRejectionSts { get; set; }
		public List<Item> to_Item { get; set; }
	}








	public class ReqNewHeader : Root
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

	public class QRCodeAmount
	{
		public string? AmountInBalanceTransacCrcy { get; set; }

	}








}
