namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class ReqQuotation
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public string dealer_id { get; set; }

        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }
        public string? quotation_id { get; set; }
    }

    public class ResQuotation
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

    public class ResGetQuotationHeader
    {

        public string? SalesQuotation { get; set; }
        public string? CreationDate { get; set; }
        public string? BindingPeriodValidityEndDate { get; set; }
        public string? PurchaseOrderByCustomer { get; set; }
        public string? OverallSDProcessStatus { get; set; }
        public string? TotalNetAmount { get; set; }
        public string? TransactionCurrency { get; set; }
        public string? SalesQuotationType { get; set; }



    }

    public class ResGetQuotationItem
    {

        public string? SalesQuotationItem { get; set; }
        public string? SalesQuotationItemCategory { get; set; }
        public string? SalesQuotationItemText { get; set; }
        public string? RequestedQuantity { get; set; }
        // public string? RequestedQuantityUnit { get; set; }
        public string? ItemNetWeight { get; set; }
        public string? NetAmount { get; set; }

        public string? TransactionCurrency { get; set; }

        public string? ItemWeightUnit { get; set; }

        public string? RequestedQuantityUnit { get; set; }

    }



    public class RootQuotationObject
    {
        public D_Quotation D { get; set; }
    }

    public class D_Quotation
    {
        public List<ResGetQuotationItem> Results { get; set; }
    }


}
