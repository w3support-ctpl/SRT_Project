using Dapper;
using iText.Html2pdf;
using MilkIn_SAPPosting.Models;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace MilkIn_SAPPosting.DAL
{
    internal class PDF_InvoicePrinting
    {
        private IDbConnection db;

        public PDF_InvoicePrinting()
        {
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public void PrintFarmerInvoice(ReqPrintInvoiceFarmerList invoiceFarmer)
        {
            // Save the Invoice File to decided location
            // Read template from the location
            var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
            var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
            string InvoiceHTML = "";
            using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
            {
                InvoiceHTML = SourceReader.ReadToEnd();
            }

            // Replace placeholders with actual data
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceTitle", invoiceFarmer.InvoiceTitle);
            InvoiceHTML = InvoiceHTML.Replace("#MCCCode", invoiceFarmer.MCCCode);
            InvoiceHTML = InvoiceHTML.Replace("#MCCName", invoiceFarmer.MCCName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentName", invoiceFarmer.AgentName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentMobileNo", invoiceFarmer.AgentMobileNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerCode", invoiceFarmer.FarmerCode);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerName", invoiceFarmer.FarmerName);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerMobileNo", invoiceFarmer.FarmerMobileNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerAccountNo", invoiceFarmer.FarmerAccountNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerBankName", invoiceFarmer.FarmerBankName);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerIFSCCode", invoiceFarmer.FarmerIFSCCode);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceNo", invoiceFarmer.InvoiceNo);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceDate", invoiceFarmer.InvoiceDate);
            InvoiceHTML = InvoiceHTML.Replace("#MilkType", invoiceFarmer.MilkType);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", invoiceFarmer.TotalMilkPayment);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", invoiceFarmer.TotalIncentive);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", invoiceFarmer.TotalDeductions);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", invoiceFarmer.TotalNetPayment);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerRowDisplay", invoiceFarmer.FarmerRowDisplay);


            // Get Milk Collection Data for the Voucher
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_Farmer_Invoice_Data",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = ""
            });
            List<ReqPrintInvoiceFarmerData> PrintInvoiceData = new List<ReqPrintInvoiceFarmerData>();
            PrintInvoiceData = this.db.Query<ReqPrintInvoiceFarmerData>("USP_AdminInvoicePrint_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            // Read Template for filling milk records
            var CollectionHTMLTemp = "";
            int TemplateStart = 0;  
            int TemplateEnd = 0;
            if (InvoiceHTML.Contains("<template>") && InvoiceHTML.Contains("</template>"))
            {
                TemplateStart = InvoiceHTML.IndexOf("<template>", 0) + "<template>".Length;
                TemplateEnd = InvoiceHTML.IndexOf("</template>", TemplateStart);
                CollectionHTMLTemp = InvoiceHTML.Substring(TemplateStart, TemplateEnd - TemplateStart);
            }
            
            var CollectionHTMLRow = "";
            var CollectionHTMLFinal = "";
            for (int i = 0; i < PrintInvoiceData.Count; i++)
            {
                // Generate Collection Row
                CollectionHTMLRow = CollectionHTMLTemp;
                CollectionHTMLRow = CollectionHTMLRow.Replace("#CollectionDate", PrintInvoiceData[i].CollectionDate);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#CollectionShift", PrintInvoiceData[i].CollectionShift);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#QtyLts", PrintInvoiceData[i].QtyLts);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#FAT", PrintInvoiceData[i].FAT);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#SNF", PrintInvoiceData[i].SNF);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#Rate", PrintInvoiceData[i].Rate);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#BaseAmt", PrintInvoiceData[i].BaseAmt);

                CollectionHTMLFinal = CollectionHTMLFinal + CollectionHTMLRow;
            }

            // Replace Template with actual collection data
            InvoiceHTML = InvoiceHTML.Substring(0, TemplateStart) + CollectionHTMLFinal + InvoiceHTML.Substring(TemplateEnd) ;

            // Get Summary Data of Deduction and Incentives
            var parameters1 = new DynamicParameters(new
            {
                var_Method_Name = "Get_Farmer_Invoice_Summary",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = invoiceFarmer.farmer_id
            });

            List<ReqPrintInvoiceFarmerSummary> PrintInvoiceSummary = new List<ReqPrintInvoiceFarmerSummary>();
            PrintInvoiceSummary = this.db.Query<ReqPrintInvoiceFarmerSummary>("USP_AdminInvoicePrint_Get", parameters1, commandType: CommandType.StoredProcedure).ToList();

            if (PrintInvoiceSummary.Count > 0)
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", PrintInvoiceSummary[0].TotalMilkQty);
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentBasic", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentTotal", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", PrintInvoiceSummary[0].TotalIncentive);
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", PrintInvoiceSummary[0].TotalDeductions);
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", PrintInvoiceSummary[0].TotalNetPayment);

                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtOpenBal", PrintInvoiceSummary[0].DairyAnamat_OpenBal);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtDebit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtCredit", PrintInvoiceSummary[0].DairyAnamat_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtBal", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#BankEMICredit", PrintInvoiceSummary[0].BankEMI_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#ProductSalesCredit", PrintInvoiceSummary[0].ProductSales_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TMSalesCredit", PrintInvoiceSummary[0].TMSales_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", PrintInvoiceSummary[0].Transport_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvanceCredit", PrintInvoiceSummary[0].MCCAdvance_Amount);

                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", PrintInvoiceSummary[0].TotalTDS);
            }
            else
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentBasic", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentTotal", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtOpenBal", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtDebit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtBal", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#BankEMICredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#ProductSalesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TMSalesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvanceCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", "0.00");
            }

            // Save file to desired location
            var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
            string InvoiceFileName = "FI" + invoiceFarmer.org_id + invoiceFarmer.InvoiceNo + ".pdf";
            // string InvoiceFileName = "FI " + invoiceFarmer.FarmerName + " " + invoiceFarmer.InvoiceDate + " " + invoiceFarmer.org_id + invoiceFarmer.InvoiceNo + ".pdf";
            string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
            HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

            // Update Flag as Printed in the table
            var parameters2 = new DynamicParameters(new
            {
                var_Method_Name = "Set_Farmer_Invoice_Status",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = invoiceFarmer.farmer_id,
            });

            this.db.Query<CommonOutput>("USP_AdminInvoicePrint_Get", parameters2, commandType: CommandType.StoredProcedure).ToList();


        }

        public void PrintMCCInvoice(ReqPrintInvoiceMCCList invoiceMCC)
        {
            // Save the Invoice File to decided location
            // Read template from the location
            var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
            var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "AgentInvoice.html";
            string InvoiceHTML = "";
            using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
            {
                InvoiceHTML = SourceReader.ReadToEnd();
            }

            // Replace placeholders with actual data
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceTitle", invoiceMCC.InvoiceTitle);
            InvoiceHTML = InvoiceHTML.Replace("#MCCCode", invoiceMCC.MCCCode);
            InvoiceHTML = InvoiceHTML.Replace("#MCCName", invoiceMCC.MCCName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentName", invoiceMCC.AgentName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentMobileNo", invoiceMCC.AgentMobileNo);
            InvoiceHTML = InvoiceHTML.Replace("#MCCAccountNo", invoiceMCC.MCCAccountNo);
            InvoiceHTML = InvoiceHTML.Replace("#MCCBankName", invoiceMCC.MCCBankName);
            InvoiceHTML = InvoiceHTML.Replace("#MCCIFSCCode", invoiceMCC.MCCIFSCCode);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceNo", invoiceMCC.InvoiceNo);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceDate", invoiceMCC.InvoiceDate);

            // Get Summary Data of Deduction and Incentives
            var parameters1 = new DynamicParameters(new
            {
                var_Method_Name = "Get_MCC_Invoice_Summary",
                var_Org_Id = invoiceMCC.org_id,
                var_Param1 = invoiceMCC.voucher_id,
                var_Param2 = invoiceMCC.mcc_id
            });

            List<ReqPrintInvoiceMCCSummary> PrintInvoiceSummary = new List<ReqPrintInvoiceMCCSummary>();
            PrintInvoiceSummary = this.db.Query<ReqPrintInvoiceMCCSummary>("USP_AdminInvoicePrint_Get", parameters1, commandType: CommandType.StoredProcedure).ToList();

            if (PrintInvoiceSummary.Count > 0)
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", PrintInvoiceSummary[0].TotalMilkQty);
                InvoiceHTML = InvoiceHTML.Replace("#TotalMPPIPayment", PrintInvoiceSummary[0].TotalMPPIPayment);
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvance_Amount_From_Farmer", PrintInvoiceSummary[0].MCCAdvance_Amount_From_Farmer);
                InvoiceHTML = InvoiceHTML.Replace("#OtherIncentive", PrintInvoiceSummary[0].OtherIncentive);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamat", PrintInvoiceSummary[0].DairyAnamat);
                InvoiceHTML = InvoiceHTML.Replace("#BankEMI_Amount", PrintInvoiceSummary[0].BankEMI_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#ProductSales_Amount", PrintInvoiceSummary[0].ProductSales_Amount);

                InvoiceHTML = InvoiceHTML.Replace("#TMSales_Amount", PrintInvoiceSummary[0].TMSales_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAdvance_Amount", PrintInvoiceSummary[0].DairyAdvance_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#GainLoss_Amount", PrintInvoiceSummary[0].GainLoss_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#PMRecovery_Amount", PrintInvoiceSummary[0].PMRecovery_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", PrintInvoiceSummary[0].TotalDeductions);
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", PrintInvoiceSummary[0].TotalIncentive);
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", PrintInvoiceSummary[0].TotalNetPayment);
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayInWord", PrintInvoiceSummary[0].TotalNetPaymentInWord);

                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", PrintInvoiceSummary[0].Transport_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", PrintInvoiceSummary[0].TotalTDS);


                InvoiceHTML = InvoiceHTML.Replace("#TotalProtein", PrintInvoiceSummary[0].TotalProtein);
                InvoiceHTML = InvoiceHTML.Replace("#TotalAsh", PrintInvoiceSummary[0].TotalAsh);
                InvoiceHTML = InvoiceHTML.Replace("#TotalSodium", PrintInvoiceSummary[0].TotalSodium);
                // InvoiceHTML = InvoiceHTML.Replace("#TotalIncentives", PrintInvoiceSummary[0].TotalIncentives);

            }
            else
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalMPPIPayment", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvance_Amount_From_Farmer", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#OtherIncentive", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamat", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#BankEMI_Amount", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#ProductSales_Amount", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#TMSales_Amount", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAdvance_Amount", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#GainLoss_Amount", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#PMRecovery_Amount", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayInWord", "");
                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#TotalProtein", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalAsh", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalSodium", "0.00");
                // InvoiceHTML = InvoiceHTML.Replace("#TotalIncentives", "0.00");
            }

            // Save file to desired location
            var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
            string InvoiceFileName = "MI" + invoiceMCC.org_id + invoiceMCC.InvoiceNo + ".pdf";
            string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
            HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

            // Update Flag as Printed in the table
            var parameters2 = new DynamicParameters(new
            {
                var_Method_Name = "Set_MCC_Invoice_Status",
                var_Org_Id = invoiceMCC.org_id,
                var_Param1 = invoiceMCC.voucher_id,
                var_Param2 = invoiceMCC.mcc_id
            });

            this.db.Query<CommonOutput>("USP_AdminInvoicePrint_Get", parameters2, commandType: CommandType.StoredProcedure).ToList();


        }

        public void PrintOfflineFarmerInvoice(ReqPrintInvoiceFarmerList invoiceFarmer)
        {
            // Save the Invoice File to decided location
            // Read template from the location
            var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
            var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
            string InvoiceHTML = "";
            using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
            {
                InvoiceHTML = SourceReader.ReadToEnd();
            }

            // Replace placeholders with actual data
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceTitle", invoiceFarmer.InvoiceTitle);
            InvoiceHTML = InvoiceHTML.Replace("#MCCCode", invoiceFarmer.MCCCode);
            InvoiceHTML = InvoiceHTML.Replace("#MCCName", invoiceFarmer.MCCName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentName", invoiceFarmer.AgentName);
            InvoiceHTML = InvoiceHTML.Replace("#AgentMobileNo", invoiceFarmer.AgentMobileNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerCode", invoiceFarmer.FarmerCode);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerName", invoiceFarmer.FarmerName);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerMobileNo", invoiceFarmer.FarmerMobileNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerAccountNo", invoiceFarmer.FarmerAccountNo);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerBankName", invoiceFarmer.FarmerBankName);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerIFSCCode", invoiceFarmer.FarmerIFSCCode);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceNo", invoiceFarmer.InvoiceNo);
            InvoiceHTML = InvoiceHTML.Replace("#InvoiceDate", invoiceFarmer.InvoiceDate);
            InvoiceHTML = InvoiceHTML.Replace("#MilkType", invoiceFarmer.MilkType);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", invoiceFarmer.TotalMilkPayment);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", invoiceFarmer.TotalIncentive);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", invoiceFarmer.TotalDeductions);
            //InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", invoiceFarmer.TotalNetPayment);
            InvoiceHTML = InvoiceHTML.Replace("#FarmerRowDisplay", invoiceFarmer.FarmerRowDisplay);


            // Get Milk Collection Data for the Voucher
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_Farmer_Invoice_Data",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = ""
            });
            List<ReqPrintInvoiceFarmerData> PrintInvoiceData = new List<ReqPrintInvoiceFarmerData>();
            PrintInvoiceData = this.db.Query<ReqPrintInvoiceFarmerData>("USP_AdminOfflineInvoicePrint_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            // Read Template for filling milk records
            var CollectionHTMLTemp = "";
            int TemplateStart = 0;  
            int TemplateEnd = 0;
            if (InvoiceHTML.Contains("<template>") && InvoiceHTML.Contains("</template>"))
            {
                TemplateStart = InvoiceHTML.IndexOf("<template>", 0) + "<template>".Length;
                TemplateEnd = InvoiceHTML.IndexOf("</template>", TemplateStart);
                CollectionHTMLTemp = InvoiceHTML.Substring(TemplateStart, TemplateEnd - TemplateStart);
            }
            
            var CollectionHTMLRow = "";
            var CollectionHTMLFinal = "";
            for (int i = 0; i < PrintInvoiceData.Count; i++)
            {
                // Generate Collection Row
                CollectionHTMLRow = CollectionHTMLTemp;
                CollectionHTMLRow = CollectionHTMLRow.Replace("#CollectionDate", PrintInvoiceData[i].CollectionDate);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#CollectionShift", PrintInvoiceData[i].CollectionShift);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#QtyLts", PrintInvoiceData[i].QtyLts);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#FAT", PrintInvoiceData[i].FAT);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#SNF", PrintInvoiceData[i].SNF);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#Rate", PrintInvoiceData[i].Rate);
                CollectionHTMLRow = CollectionHTMLRow.Replace("#BaseAmt", PrintInvoiceData[i].BaseAmt);

                CollectionHTMLFinal = CollectionHTMLFinal + CollectionHTMLRow;
            }

            // Replace Template with actual collection data
            InvoiceHTML = InvoiceHTML.Substring(0, TemplateStart) + CollectionHTMLFinal + InvoiceHTML.Substring(TemplateEnd) ;

            // Get Summary Data of Deduction and Incentives
            var parameters1 = new DynamicParameters(new
            {
                var_Method_Name = "Get_Farmer_Invoice_Summary",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = invoiceFarmer.farmer_id
            });

            List<ReqPrintInvoiceFarmerSummary> PrintInvoiceSummary = new List<ReqPrintInvoiceFarmerSummary>();
            PrintInvoiceSummary = this.db.Query<ReqPrintInvoiceFarmerSummary>("USP_AdminOfflineInvoicePrint_Get", parameters1, commandType: CommandType.StoredProcedure).ToList();

            if (PrintInvoiceSummary.Count > 0)
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", PrintInvoiceSummary[0].TotalMilkQty);
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentBasic", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentTotal", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", PrintInvoiceSummary[0].TotalMilkPayment);
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", PrintInvoiceSummary[0].TotalIncentive);
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", PrintInvoiceSummary[0].TotalDeductions);
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", PrintInvoiceSummary[0].TotalNetPayment);

                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtOpenBal", PrintInvoiceSummary[0].DairyAnamat_OpenBal);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtDebit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtCredit", PrintInvoiceSummary[0].DairyAnamat_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtBal", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#BankEMICredit", PrintInvoiceSummary[0].BankEMI_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#ProductSalesCredit", PrintInvoiceSummary[0].ProductSales_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TMSalesCredit", PrintInvoiceSummary[0].TMSales_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", PrintInvoiceSummary[0].Transport_Amount);
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvanceCredit", PrintInvoiceSummary[0].MCCAdvance_Amount);

                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", PrintInvoiceSummary[0].TotalTDS);
            }
            else
            {
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkQty", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentBasic", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#SumMilkPaymentTotal", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalMilkPayment", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalIncentive", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalDeductions", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalNetPayment", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtOpenBal", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtDebit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#DairyAnamtBal", "0.00");

                InvoiceHTML = InvoiceHTML.Replace("#BankEMICredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#ProductSalesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TMSalesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TransportChargesCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#MCCAdvanceCredit", "0.00");
                InvoiceHTML = InvoiceHTML.Replace("#TotalTDS", "0.00");
            }

            // Save file to desired location
            var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
            string InvoiceFileName = "FOI" + invoiceFarmer.org_id + invoiceFarmer.InvoiceNo + ".pdf";
            // string InvoiceFileName = "FI " + invoiceFarmer.FarmerName + " " + invoiceFarmer.InvoiceDate + " " + invoiceFarmer.org_id + invoiceFarmer.InvoiceNo + ".pdf";
            string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
            HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

            // Update Flag as Printed in the table
            var parameters2 = new DynamicParameters(new
            {
                var_Method_Name = "Set_Farmer_Invoice_Status",
                var_Org_Id = invoiceFarmer.org_id,
                var_Param1 = invoiceFarmer.voucher_id,
                var_Param2 = invoiceFarmer.farmer_id,
            });

            this.db.Query<CommonOutput>("USP_AdminOfflineInvoicePrint_Get", parameters2, commandType: CommandType.StoredProcedure).ToList();


        }


    }
}
