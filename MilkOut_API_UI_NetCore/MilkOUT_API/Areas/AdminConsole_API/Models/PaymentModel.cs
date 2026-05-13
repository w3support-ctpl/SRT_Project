namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class ReqPayment
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }


        public string? start_date { get; set; }
        public string? end_date { get; set; }
        public string? dealer_id { get; set; }

        public string? delivery_no { get; set; }
    }
    public class ResPayment
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

    public class ResGetPaymentTermsHeader
    {

        public string? PaymentTerms { get; set; }

        public string? CustomerPaymentTermsName { get; set; }

    }


    public class ResGetPaymentHeader
    {

        public string? AccountingDocument { get; set; }
        public string? PostingDate { get; set; }
        public string? Customer { get; set; }
        public string? CustomerName { get; set; }
        public string? GLAccount { get; set; }
        public string? AmountInBalanceTransacCrcy { get; set; }

        public string? AmountInTransactionCurrency { get; set; }

        public string? AmountInCompanyCodeCurrency { get; set; }
        public string? AmountInGlobalCurrency { get; set; }

        public string? BalanceTransactionCurrency { get; set; }

         public string? AccountingDocumentType { get; set; }
        public string? DebitCreditCode { get; set; }
        public string? ReferenceDocument { get; set; }

        
        

    }
}
