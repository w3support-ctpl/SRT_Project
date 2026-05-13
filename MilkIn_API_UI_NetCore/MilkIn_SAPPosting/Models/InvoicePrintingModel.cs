using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkIn_SAPPosting.Models
{
    public class ReqPrintInvoiceFarmerList
    {

        public string? org_id { get; set; }
        public string? voucher_id { get; set; }
        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }
        public string? InvoiceTitle { get; set; }
        public string? MCCCode { get; set; }
        public string? MCCName { get; set; }
        public string? AgentName { get; set; }
        public string? AgentMobileNo { get; set; }
        public string? FarmerCode { get; set; }
        public string? FarmerName { get; set; }

        public string? FarmerMobileNo { get; set; }
        public string? FarmerAccountNo { get; set; }
        public string? FarmerBankName { get; set; }
        public string? FarmerIFSCCode { get; set; }
        public string? InvoiceNo { get; set; }
        public string? InvoiceDate { get; set; }
        public string? MilkType { get; set; }
        public string? TotalMilkPayment { get; set; }
        public string? TotalIncentive { get; set; }
        public string? TotalDeductions { get; set; }
        public string? TotalNetPayment { get; set; }
        public string? FarmerRowDisplay { get; set; }
    }

    public class ReqPrintInvoiceFarmerData
    {
        public string? CollectionDate { get; set; }
        public string? CollectionShift { get; set; }
        public string? QtyLts { get; set; }
        public string? FAT { get; set; }
        public string? SNF { get; set; }
        public string? Rate { get; set; }
        public string? BaseAmt { get; set; }
    }

    public class ReqPrintInvoiceFarmerSummary
    {
        public string? TotalMilkQty { get; set; }
        public string? TotalMilkPayment { get; set; }
        public string? TotalIncentive { get; set; }
        public string? TotalDeductions { get; set; }
        public string? TotalNetPayment { get; set; }

        public string? BankEMI_Amount { get; set; }
        public string? DairyAnamat_Amount { get; set; }
        public string? Transport_Amount { get; set; }
        public string? ProductSales_Amount { get; set; }
        public string? TMSales_Amount { get; set; }
        public string? MCCAdvance_Amount { get; set; }
        public string? DairyAdvance_Amount { get; set; }
        public string? DairyAnamat_OpenBal { get; set; }

        public string? TotalTDS { get; set; }

    }

    public class ReqPrintInvoiceMCCList
    {

        public string? org_id { get; set; }
        public string? voucher_id { get; set; }
        public string? mcc_id { get; set; }
        public string? InvoiceTitle { get; set; }
        public string? MCCCode { get; set; }
        public string? MCCName { get; set; }
        public string? AgentName { get; set; }
        public string? AgentMobileNo { get; set; }
        public string? MCCAccountNo { get; set; }
        public string? MCCBankName { get; set; }
        public string? MCCIFSCCode { get; set; }
        public string? InvoiceNo { get; set; }
        public string? InvoiceDate { get; set; }
    }

    public class ReqPrintInvoiceMCCSummary
    {
        public string? TotalMilkQty { get; set; }
        public string? TotalMPPIPayment { get; set; }
        public string? MCCAdvance_Amount_From_Farmer { get; set; }
        public string? OtherIncentive { get; set; }
        public string? DairyAnamat { get; set; }
        public string? BankEMI_Amount { get; set; }
        public string? ProductSales_Amount { get; set; }
        public string? TMSales_Amount { get; set; }
        public string? DairyAdvance_Amount { get; set; }
        public string? GainLoss_Amount { get; set; }
        public string? PMRecovery_Amount { get; set; }
        public string? TotalDeductions { get; set; }
        public string? TotalIncentive { get; set; }
        public string? TotalNetPayment { get; set; }
        public string? TotalNetPaymentInWord { get; set; }

        public string? Transport_Amount { get; set; }

        public string? TotalTDS { get; set; }

        public string? TotalProtein { get; set; }
        public string? TotalAsh { get; set; }
        public string? TotalSodium { get; set; }
        public string? TotalIncentives { get; set; }
    }


}




