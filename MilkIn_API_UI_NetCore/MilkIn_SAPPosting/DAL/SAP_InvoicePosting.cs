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
    internal class SAP_InvoicePosting
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public SAP_InvoicePosting(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public List<CommonOutput> SaveInvoiceMCCInSapIncome(ReqInvoiceMCC invoiceMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceMCCSave.method_name,
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
                var_Date = invoiceMCCSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCSave.approvalstatus_id,
                var_MCC_Id = invoiceMCCSave.mcc_id,
                var_MCCType_Id = invoiceMCCSave.mcctype_id


            });

            var parametersMCC = this.db.Query<ResInvoiceFarmer>("USP_AdminMCCInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersMCC[0].amount;
            //parametersSOAP.Invoice_Id = parametersMCC[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersMCC[0].farmer_code;
            parametersSOAP.xmlData = parametersMCC[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceMCCSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = SaveMilkSOAP(parametersSOAP, invoiceMCCSave.org_id);

            // Load the XML string
            XDocument xmlDoc = XDocument.Parse(dynamic);

            // Convert the XML to JSON
            string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

            // Deserialize the JSON to a JObject
            JObject json = JObject.Parse(jsonResponse);

            // You can now work with the JSON object (json)



            //JObject jsonResponse = JObject.Parse(dynamic);

            // Assuming you already have the JSON object named 'json'
            string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

            string AccountingDocument =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
            {



                string FiscalYear =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();


                // Save the Invoice File to decided location
                //string InvoiceHTML = "This is a test invoice";
                //string InvoiceFileName = "MI" + invoiceMCCSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                //string FilePhysicalPath = configuration.GetValue<string>("AppSettings:UploadFolderPath", "") + "" + InvoiceFileName;   // Physical location of file on server
                //HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "2",  // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                //CommonOutput commonOutput = new CommonOutput
                //{
                //    result_id = 1, // Assuming result_id is an integer
                //    result_description = "Farmer Invoice Posted",
                //    result_extra_key = "Farmer Invoice Posted"
                //};

                //// Return the CommonOutput instance as a list with a single item
                //return new List<CommonOutput> { commonOutput };
            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "3",  // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();


                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
        }


        public List<CommonOutput> SaveInvoiceMCCInSapIncomeJson(ReqInvoiceMCC invoiceMCCSave)
        {




            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceMCCSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();


            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_Income_Header",
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
                var_Date = invoiceMCCSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCSave.approvalstatus_id,
                var_MCC_Id = invoiceMCCSave.mcc_id,
                var_MCCType_Id = invoiceMCCSave.mcctype_id


            });

            var parameterData = this.db.Query<ReqSAPMilkSOAPIncome>("USP_AdminMCCInSAP_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterSupplierInvoiceItemGLAcct = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceItemGLAcct",
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
                var_Date = invoiceMCCSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCSave.approvalstatus_id,
                var_MCC_Id = invoiceMCCSave.mcc_id,
                var_MCCType_Id = invoiceMCCSave.mcctype_id
            });

            parameter.to_SupplierInvoiceItemGLAcct = this.db.Query<To_Supplierinvoiceitemglacct>("USP_AdminMCCInSAP_Get", parameterSupplierInvoiceItemGLAcct, commandType: CommandType.StoredProcedure).ToList();

            var parameterSupplierInvoiceWhldgTax = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceWhldgTax",
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
                var_Date = invoiceMCCSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCSave.approvalstatus_id,
                var_MCC_Id = invoiceMCCSave.mcc_id,
                var_MCCType_Id = invoiceMCCSave.mcctype_id
            });

            parameter.to_SupplierInvoiceWhldgTax = this.db.Query<To_Supplierinvoicewhldgtax>("USP_AdminMCCInSAP_Get", parameterSupplierInvoiceWhldgTax, commandType: CommandType.StoredProcedure).ToList();

            var dynamic = SaveMilkSOAPJson(parameter, invoiceMCCSave.org_id);
            JObject jsonResponse = JObject.Parse(dynamic);

            if (jsonResponse.ContainsKey("d"))
            {
                // Extract MaterialDocumentYear and MaterialDocument
                string FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                string AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();

                //Save the Invoice File to decided location
                // Read template from the location
                var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                string InvoiceHTML = "";
                using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                {
                    InvoiceHTML = SourceReader.ReadToEnd();
                }

                // Replace placeholders with actual data


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "FI" + invoiceMCCSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

                var parameter_s = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "2",  // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter_s, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (jsonResponse.ContainsKey("error"))
            {
                var parameter_e = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "3",  // Success
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter_e, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }




        }

        public List<CommonOutput> SaveInvoiceMCCInSapDeduction(ReqInvoiceMCC invoiceMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceMCCSave.method_name,
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
                var_Date = invoiceMCCSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCSave.approvalstatus_id,
                var_MCC_Id = invoiceMCCSave.mcc_id,
                var_MCCType_Id = invoiceMCCSave.mcctype_id


            });

            var parametersMCC = this.db.Query<ResInvoiceFarmer>("USP_AdminMCCInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersMCC[0].amount;
            //parametersSOAP.Invoice_Id = parametersMCC[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersMCC[0].farmer_code;
            parametersSOAP.xmlData = parametersMCC[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceMCCSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = SaveMilkSOAP(parametersSOAP, invoiceMCCSave.org_id);

            // Load the XML string
            XDocument xmlDoc = XDocument.Parse(dynamic);

            // Convert the XML to JSON
            string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

            // Deserialize the JSON to a JObject
            JObject json = JObject.Parse(jsonResponse);

            // You can now work with the JSON object (json)



            //JObject jsonResponse = JObject.Parse(dynamic);

            // Assuming you already have the JSON object named 'json'
            string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();


            string AccountingDocument =

               json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
            {



                string FiscalYear =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();


                // Save the Invoice File to decided location
                //string InvoiceHTML = "This is a test invoice";
                //string InvoiceFileName = "MI" + invoiceMCCSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                //string FilePhysicalPath = configuration.GetValue<string>("AppSettings:UploadFolderPath", "") + "" + InvoiceFileName;   // Physical location of file on server
                //HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Deduction",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "2",  // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                //CommonOutput commonOutput = new CommonOutput
                //{
                //    result_id = 1, // Assuming result_id is an integer
                //    result_description = "Farmer Invoice Posted",
                //    result_extra_key = "Farmer Invoice Posted"
                //};

                //// Return the CommonOutput instance as a list with a single item
                //return new List<CommonOutput> { commonOutput };
            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Deduction",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "3",  // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceMCCSave.invoice_id,
                    var_User_Id = invoiceMCCSave.user_id,
                    var_User_Name = invoiceMCCSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();


                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Invoice does't Posted",
                    result_extra_key = "MCC Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
        }


        public List<CommonOutput> SaveInvoiceMCCInSapRebate(ReqInvoiceMCC invoiceMCCRebateSave)
        {
            var parameters = new DynamicParameters(new
            {

                var_Method_Name = invoiceMCCRebateSave.method_name,
                var_Org_Id = invoiceMCCRebateSave.org_id,
                var_User_id = invoiceMCCRebateSave.user_id,
                var_MCCType_Id = invoiceMCCRebateSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_MCC_Id = invoiceMCCRebateSave.mcc_id,
                var_Date = invoiceMCCRebateSave.search_period,
                var_ApprovalStatus_Id = invoiceMCCRebateSave.approvalstatus_id,
                var_Invoice_Id = invoiceMCCRebateSave.invoice_id,


            });

            var parametersMCC = this.db.Query<ResInvoiceFarmer>("USP_AdminRebate_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersMCC[0].amount;
            //parametersSOAP.Invoice_Id = parametersMCC[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersMCC[0].farmer_code;
            parametersSOAP.xmlData = parametersMCC[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceMCCRebateSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = SaveMilkSOAP(parametersSOAP, invoiceMCCRebateSave.org_id);

            // Load the XML string
            XDocument xmlDoc = XDocument.Parse(dynamic);

            // Convert the XML to JSON
            string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

            // Deserialize the JSON to a JObject
            JObject json = JObject.Parse(jsonResponse);

            // You can now work with the JSON object (json)



            //JObject jsonResponse = JObject.Parse(dynamic);

            // Assuming you already have the JSON object named 'json'
            string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();


            string AccountingDocument =

               json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
            {

                string FiscalYear =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();

                var parameter = new DynamicParameters(new
                {
                    var_Method_Name = "Update",
                    var_Org_Id = invoiceMCCRebateSave.org_id,
                    var_User_id = invoiceMCCRebateSave.user_id,
                    var_User_Name = invoiceMCCRebateSave.user_name,
                    var_InvoiceData = "2",
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceMCCRebateSave.invoice_id,
                    var_Date = "",
                });

                return this.db.Query<CommonOutput>("USP_AdminRebate_Set", parameter, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceMCCRebateSave.org_id,
                    var_User_id = invoiceMCCRebateSave.user_id,
                    var_User_Name = invoiceMCCRebateSave.user_name,
                    var_InvoiceData = "3",
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceMCCRebateSave.invoice_id,
                    var_Date = "",
                });

                this.db.Query<CommonOutput>("USP_AdminRebate_Set", parameter, commandType: CommandType.StoredProcedure).ToList();


                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Rebate does't Posted",
                    result_extra_key = "MCC Rebate does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "MCC Rebate does't Posted",
                    result_extra_key = "MCC Rebate does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
        }

        public List<CommonOutput> SaveInvoiceFarmerInSapIncome(ReqInvoiceFarmer invoiceFarmerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSave.method_name,
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""

            });

            var parametersFarmer = this.db.Query<ResInvoiceFarmer>("USP_AdminFarmerInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersFarmer[0].amount;
            //parametersSOAP.Invoice_Id = parametersFarmer[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersFarmer[0].farmer_code;
            parametersSOAP.xmlData = parametersFarmer[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = SaveMilkSOAP(parametersSOAP, invoiceFarmerSave.org_id);

            // Load the XML string
            XDocument xmlDoc = XDocument.Parse(dynamic);

            // Convert the XML to JSON
            string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

            // Deserialize the JSON to a JObject
            JObject json = JObject.Parse(jsonResponse);

            // You can now work with the JSON object (json)



            //JObject jsonResponse = JObject.Parse(dynamic);

            // Assuming you already have the JSON object named 'json'
            string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

            string AccountingDocument = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
            {


                string FiscalYear = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();

                //// Save the Invoice File to decided location
                //// Read template from the location
                //var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                //var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                //string InvoiceHTML = "";
                //using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                //{
                //    InvoiceHTML = SourceReader.ReadToEnd();
                //}

                //// Replace placeholders with actual data


                //// Save file to desired location
                //var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                //string InvoiceFileName = "FI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                //string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                //HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                //CommonOutput commonOutput = new CommonOutput
                //{
                //    result_id = 1, // Assuming result_id is an integer
                //    result_description = "Farmer Invoice Posted",
                //    result_extra_key = "Farmer Invoice Posted"
                //};

                //// Return the CommonOutput instance as a list with a single item
                //return new List<CommonOutput> { commonOutput };
            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }



        }


        public List<CommonOutput> SaveInvoiceFarmerInSapIncomeJson(ReqInvoiceFarmer invoiceFarmerSave)
        {





            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();


            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_Income_Header",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""


            });

            var parameterData = this.db.Query<ReqSAPMilkSOAPIncome>("USP_AdminFarmerInSAP_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterSupplierInvoiceItemGLAcct = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceItemGLAcct",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""
            });

            parameter.to_SupplierInvoiceItemGLAcct = this.db.Query<To_Supplierinvoiceitemglacct>("USP_AdminFarmerInSAP_Get", parameterSupplierInvoiceItemGLAcct, commandType: CommandType.StoredProcedure).ToList();

            var parameterSupplierInvoiceWhldgTax = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceWhldgTax",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""
            });

            parameter.to_SupplierInvoiceWhldgTax = this.db.Query<To_Supplierinvoicewhldgtax>("USP_AdminFarmerInSAP_Get", parameterSupplierInvoiceWhldgTax, commandType: CommandType.StoredProcedure).ToList();

            string FiscalYear = "";
            string AccountingDocument = "";
            int IsPostedSuccessfully = 0;

            if (invoiceFarmerSave.approvalstatus_id == "1")
            {
                var dynamic = SaveMilkSOAPJson(parameter, invoiceFarmerSave.org_id);
                JObject jsonResponse = JObject.Parse(dynamic);
                if (jsonResponse.ContainsKey("d"))
                {
                    FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                    AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();
                    IsPostedSuccessfully = 1;
                }
                else if (jsonResponse.ContainsKey("error"))
                {
                    IsPostedSuccessfully = -1;
                }
                else
                {
                    IsPostedSuccessfully = 0;
                }

            }
            else
            {
                IsPostedSuccessfully = 1;
                FiscalYear = DateTime.Now.Year.ToString();
                AccountingDocument = "DUMMYPOSTING";
            }


            if (IsPostedSuccessfully == 1)
            {
                // Extract MaterialDocumentYear and MaterialDocument
                // string FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                // string AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();

                //Save the Invoice File to decided location
                // Read template from the location
                var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                string InvoiceHTML = "";
                using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                {
                    InvoiceHTML = SourceReader.ReadToEnd();
                }

                // Replace placeholders with actual data


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "FI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

                var parameter_s = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter_s, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (IsPostedSuccessfully == -1)
            {
                var parameter_e = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter_e, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }




        }


        public List<CommonOutput> SaveInvoiceSAPPostingInSapIncomeJson(ReqInvoiceFarmer invoiceFarmerSave)
        {





            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();


            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_Income_Header",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id

            });

            var parameterData = this.db.Query<ReqSAPMilkSOAPIncome>("USP_AdminSAPPosting_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterSupplierInvoiceItemGLAcct = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceItemGLAcct",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id
            });

            parameter.to_SupplierInvoiceItemGLAcct = this.db.Query<To_Supplierinvoiceitemglacct>("USP_AdminSAPPosting_Get", parameterSupplierInvoiceItemGLAcct, commandType: CommandType.StoredProcedure).ToList();

            var parameterSupplierInvoiceWhldgTax = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceWhldgTax",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id
            });

            parameter.to_SupplierInvoiceWhldgTax = this.db.Query<To_Supplierinvoicewhldgtax>("USP_AdminSAPPosting_Get", parameterSupplierInvoiceWhldgTax, commandType: CommandType.StoredProcedure).ToList();

            string FiscalYear = "";
            string AccountingDocument = "";
            int IsPostedSuccessfully = 0;

            if (invoiceFarmerSave.approvalstatus_id == "1")
            {
                var dynamic = SaveMilkSOAPJson(parameter, invoiceFarmerSave.org_id);
                JObject jsonResponse = JObject.Parse(dynamic);
                if (jsonResponse.ContainsKey("d"))
                {
                    FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                    AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();
                    IsPostedSuccessfully = 1;
                }
                else if (jsonResponse.ContainsKey("error"))
                {
                    IsPostedSuccessfully = -1;
                }
                else
                {
                    IsPostedSuccessfully = 0;
                }

            }
            else
            {
                IsPostedSuccessfully = 1;
                FiscalYear = DateTime.Now.Year.ToString();
                AccountingDocument = "DUMMYPOSTING";
            }


            if (IsPostedSuccessfully == 1)
            {
                // Extract MaterialDocumentYear and MaterialDocument
                // string FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                // string AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();

                //Save the Invoice File to decided location
                // Read template from the location
                var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                string InvoiceHTML = "";
                using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                {
                    InvoiceHTML = SourceReader.ReadToEnd();
                }

                // Replace placeholders with actual data


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "SI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

                var parameter_s = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_MCC_Id = invoiceFarmerSave.mcc_id,
                    var_Farmer_Id = "",
                    var_Date = "",
                    var_Amount = "",
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_IncomeFor = "",
                    var_Remark = "",
                    var_MilkPayment = ""
                });

                return this.db.Query<CommonOutput>("USP_AdminSAPPosting_Set", parameter_s, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (IsPostedSuccessfully == -1)
            {
                var parameter_e = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Success
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_MCC_Id = invoiceFarmerSave.mcc_id,
                    var_Farmer_Id = "",
                    var_Date = "",
                    var_Amount = "",
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_IncomeFor = "",
                    var_Remark = "",
                    var_MilkPayment = ""
                });

                this.db.Query<CommonOutput>("USP_AdminSAPPosting_Set", parameter_e, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }




        }

        public List<CommonOutput> SaveInvoiceSAPPostingDebitInSapIncomeJson(ReqInvoiceFarmer invoiceFarmerSave)
        {





            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();


            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_Income_Header",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,

            });

            var parameterData = this.db.Query<ReqSAPMilkSOAPIncome>("USP_AdminSAPPostingDebit_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterSupplierInvoiceItemGLAcct = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceItemGLAcct",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
            });

            parameter.to_SupplierInvoiceItemGLAcct = this.db.Query<To_Supplierinvoiceitemglacct>("USP_AdminSAPPostingDebit_Get", parameterSupplierInvoiceItemGLAcct, commandType: CommandType.StoredProcedure).ToList();

            var parameterSupplierInvoiceWhldgTax = new DynamicParameters(new
            {
                var_Method_Name = "Get_SupplierInvoiceWhldgTax",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
            });

            parameter.to_SupplierInvoiceWhldgTax = this.db.Query<To_Supplierinvoicewhldgtax>("USP_AdminSAPPostingDebit_Get", parameterSupplierInvoiceWhldgTax, commandType: CommandType.StoredProcedure).ToList();

            string FiscalYear = "";
            string AccountingDocument = "";
            int IsPostedSuccessfully = 0;

            if (invoiceFarmerSave.approvalstatus_id == "1")
            {
                var dynamic = SaveMilkSOAPJson(parameter, invoiceFarmerSave.org_id);
                JObject jsonResponse = JObject.Parse(dynamic);
                if (jsonResponse.ContainsKey("d"))
                {
                    FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                    AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();
                    IsPostedSuccessfully = 1;
                }
                else if (jsonResponse.ContainsKey("error"))
                {
                    IsPostedSuccessfully = -1;
                }
                else
                {
                    IsPostedSuccessfully = 0;
                }

            }
            else
            {
                IsPostedSuccessfully = 1;
                FiscalYear = DateTime.Now.Year.ToString();
                AccountingDocument = "DUMMYPOSTING";
            }


            if (IsPostedSuccessfully == 1)
            {
                // Extract MaterialDocumentYear and MaterialDocument
                // string FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                // string AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();

                //Save the Invoice File to decided location
                // Read template from the location
                var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                string InvoiceHTML = "";
                using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                {
                    InvoiceHTML = SourceReader.ReadToEnd();
                }

                // Replace placeholders with actual data


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "DI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

                var parameter_s = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id
                });

                return this.db.Query<CommonOutput>("USP_AdminSAPPostingDebit_Set", parameter_s, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (IsPostedSuccessfully == -1)
            {
                var parameter_e = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Success
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                });

                this.db.Query<CommonOutput>("USP_AdminSAPPostingDebit_Set", parameter_e, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }




        }

        public List<CommonOutput> SaveInvoiceRateChangeFarmerInSapIncomeJson(ReqInvoiceFarmer invoiceFarmerSave)
        {





            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();


            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_Rate_Change_Income_Header",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""


            });

            var parameterData = this.db.Query<ReqSAPMilkSOAPIncome>("USP_AdminFarmerInSAP_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterSupplierInvoiceItemGLAcct = new DynamicParameters(new
            {
                var_Method_Name = "Get_Rate_Change_SupplierInvoiceItemGLAcct",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""
            });

            parameter.to_SupplierInvoiceItemGLAcct = this.db.Query<To_Supplierinvoiceitemglacct>("USP_AdminFarmerInSAP_Get", parameterSupplierInvoiceItemGLAcct, commandType: CommandType.StoredProcedure).ToList();

            var parameterSupplierInvoiceWhldgTax = new DynamicParameters(new
            {
                var_Method_Name = "Get_Rate_Change_SupplierInvoiceWhldgTax",
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""
            });

            parameter.to_SupplierInvoiceWhldgTax = this.db.Query<To_Supplierinvoicewhldgtax>("USP_AdminFarmerInSAP_Get", parameterSupplierInvoiceWhldgTax, commandType: CommandType.StoredProcedure).ToList();

            string FiscalYear = "";
            string AccountingDocument = "";
            int IsPostedSuccessfully = 0;

            if (invoiceFarmerSave.approvalstatus_id == "1")
            {
                var dynamic = SaveRateChangeMilkSOAPJson(parameter, invoiceFarmerSave.org_id);
                JObject jsonResponse = JObject.Parse(dynamic);
                if (jsonResponse.ContainsKey("d"))
                {
                    FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                    AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();
                    IsPostedSuccessfully = 1;
                }
                else if (jsonResponse.ContainsKey("error"))
                {
                    IsPostedSuccessfully = -1;
                }
                else
                {
                    IsPostedSuccessfully = 0;
                }

            }
            else
            {
                IsPostedSuccessfully = 1;
                FiscalYear = DateTime.Now.Year.ToString();
                AccountingDocument = "DUMMYPOSTING";
            }


            if (IsPostedSuccessfully == 1)
            {
                // Extract MaterialDocumentYear and MaterialDocument
                // string FiscalYear = jsonResponse["d"]["FiscalYear"].ToString();
                // string AccountingDocument = jsonResponse["d"]["SupplierInvoice"].ToString();

                //Save the Invoice File to decided location
                // Read template from the location
                var InvoiceTemplatePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceTemplatePath"].ToString();
                var pathToFile = InvoiceTemplatePath + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                string InvoiceHTML = "";
                using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                {
                    InvoiceHTML = SourceReader.ReadToEnd();
                }

                // Replace placeholders with actual data


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "FI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));

                var parameter_s = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter_s, commandType: CommandType.StoredProcedure).ToList();


            }
            else if (IsPostedSuccessfully == -1)
            {
                var parameter_e = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Income",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter_e, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }




        }

        public List<CommonOutput> SaveInvoiceFarmerInSapDeduction(ReqInvoiceFarmer invoiceFarmerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSave.method_name,
                var_Org_Id = invoiceFarmerSave.org_id,
                var_User_id = invoiceFarmerSave.user_id,
                var_Invoice_Id = invoiceFarmerSave.invoice_id,
                var_Date = invoiceFarmerSave.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSave.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSave.mcc_id,
                var_MCCType_Id = invoiceFarmerSave.mcctype_id,
                var_MCCWorkType_Id = "",
                var_Farmer_Id = ""

            });

            var parametersFarmer = this.db.Query<ResInvoiceFarmer>("USP_AdminFarmerInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersFarmer[0].amount;
            //parametersSOAP.Invoice_Id = parametersFarmer[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersFarmer[0].farmer_code;
            parametersSOAP.xmlData = parametersFarmer[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceFarmerSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();
            string severityCode = "";
            string AccountingDocument = "";
            string FiscalYear = "";

            if (invoiceFarmerSave.approvalstatus_id == "1")
            {
                var dynamic = SaveMilkSOAP(parametersSOAP, invoiceFarmerSave.org_id);

                // Load the XML string
                XDocument xmlDoc = XDocument.Parse(dynamic);

                // Convert the XML to JSON
                string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

                // Deserialize the JSON to a JObject
                JObject json = JObject.Parse(jsonResponse);

                // Assuming you already have the JSON object named 'json'
                severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

                AccountingDocument = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();
                FiscalYear = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();
            }
            else
            {
                severityCode = "1";
                AccountingDocument = "DUMMYPOSTING";
                FiscalYear = DateTime.Now.Year.ToString();
            }



            //JObject jsonResponse = JObject.Parse(dynamic);

            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
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


                // Save file to desired location
                var InvoiceFilePath = System.Configuration.ConfigurationManager.AppSettings["InvoiceFilePath"].ToString();
                string InvoiceFileName = "FI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = InvoiceFilePath + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Deduction",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "2",      // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                //CommonOutput commonOutput = new CommonOutput
                //{
                //    result_id = 1, // Assuming result_id is an integer
                //    result_description = "Farmer Invoice Posted",
                //    result_extra_key = "Farmer Invoice Posted"
                //};

                //// Return the CommonOutput instance as a list with a single item
                //return new List<CommonOutput> { commonOutput };
            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update_Deduction",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "3",      // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Farmer Invoice does't Posted",
                    result_extra_key = "Farmer Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }



        }

        public List<CommonOutput> SaveInvoiceTransporterInSap(ReqInvoiceTransporter invoiceTransporterSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceTransporterSave.method_name,
                var_Org_Id = invoiceTransporterSave.org_id,
                var_User_id = invoiceTransporterSave.user_id,
                var_Invoice_Id = invoiceTransporterSave.invoice_id,
                var_Date = invoiceTransporterSave.search_period,
                var_ApprovalStatus_Id = invoiceTransporterSave.approvalstatus_id


            });

            var parametersTransporter = this.db.Query<ResInvoiceFarmer>("USP_AdminTransporterInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            ReqSAPMilkSOAP parametersSOAP = new ReqSAPMilkSOAP();

            //parametersSOAP.Amount = parametersMCC[0].amount;
            //parametersSOAP.Invoice_Id = parametersMCC[0].invoice_no;
            //parametersSOAP.Farmer_Code = parametersMCC[0].farmer_code;
            parametersSOAP.xmlData = parametersTransporter[0].xmlData;

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = invoiceTransporterSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = SaveMilkSOAP(parametersSOAP, invoiceTransporterSave.org_id);

            // Load the XML string
            XDocument xmlDoc = XDocument.Parse(dynamic);

            // Convert the XML to JSON
            string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

            // Deserialize the JSON to a JObject
            JObject json = JObject.Parse(jsonResponse);

            // You can now work with the JSON object (json)



            //JObject jsonResponse = JObject.Parse(dynamic);

            // Assuming you already have the JSON object named 'json'
            string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

            string AccountingDocument = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();


            if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
            {

                string FiscalYear =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceTransporterSave.org_id,
                    var_InvoiceData = "2",  // Success
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceTransporterSave.invoice_id,
                    var_User_Id = invoiceTransporterSave.user_id,
                    var_User_Name = invoiceTransporterSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminTransporterInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();

                //CommonOutput commonOutput = new CommonOutput
                //{
                //    result_id = 1, // Assuming result_id is an integer
                //    result_description = "Farmer Invoice Posted",
                //    result_extra_key = "Farmer Invoice Posted"
                //};

                //// Return the CommonOutput instance as a list with a single item
                //return new List<CommonOutput> { commonOutput };
            }
            else if (severityCode == "3" || AccountingDocument == "0000000000")
            {
                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceTransporterSave.org_id,
                    var_InvoiceData = "3",  // Error
                    var_SAP_Document_Id = "",
                    var_SAP_Document_Year = "",
                    var_Invoice_Id = invoiceTransporterSave.invoice_id,
                    var_User_Id = invoiceTransporterSave.user_id,
                    var_User_Name = invoiceTransporterSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                this.db.Query<CommonOutput>("USP_AdminTransporterInSAP_Set", parameter, commandType: CommandType.StoredProcedure).ToList();


                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Transporter Invoice does't Posted",
                    result_extra_key = "Transporter Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Transporter Invoice does't Posted",
                    result_extra_key = "Transporter Invoice does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }

        }

        public string SaveMilkSOAP(ReqSAPMilkSOAP ReqObj, string Org_Id)
        {
            var request = new HttpRequestMessage(HttpMethod.Post, "sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi");
            try
            {
                var CreationDateTime = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
                var CurrentDate = DateTime.Now.ToString("yyyy-MM-dd");

                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                var client = new HttpClient();
                client.DefaultRequestHeaders.Add("SOAPAction", "http://sap.com/xi/SAPSCORE/SFIN/JournalEntryCreateRequestConfirmation_In/JournalEntryCreateRequestConfirmation_InRequest");
                client.DefaultRequestHeaders.Add("Authorization", "Basic " + svcCredentials);

                //client.DefaultRequestHeaders.Add("Cookie", "sap-usercontext=sap-client=100");

                var content = new StringContent(ReqObj.xmlData, Encoding.UTF8, "text/xml");

                var response = client.PostAsync(SAPAPIURL + "sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi", content).Result;
                response.EnsureSuccessStatusCode();

                XDocument xmlDoc = XDocument.Parse(response.Content.ReadAsStringAsync().Result);

                // Convert the XML to JSON
                string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

                // Deserialize the JSON to a JObject
                JObject json = JObject.Parse(jsonResponse);

                string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

                string AccountingDocument = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

                if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
                {
                    new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "200", response.Content.ReadAsStringAsync().Result);
                }
                else if (severityCode == "3" || AccountingDocument == "0000000000")
                {
                    new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "500", response.Content.ReadAsStringAsync().Result);
                }

                return response.Content.ReadAsStringAsync().Result;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }


        public string SaveMilkSOAPJson(ReqSAPMilkSOAPIncome ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice");
            string resString;

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();
            parameter.FiscalYear = ReqObj.FiscalYear;
            parameter.CompanyCode = ReqObj.CompanyCode;
            parameter.DocumentDate = ReqObj.DocumentDate;
            parameter.PostingDate = ReqObj.PostingDate;
            parameter.CreationDate = ReqObj.CreationDate;
            parameter.SupplierInvoiceIDByInvcgParty = ReqObj.SupplierInvoiceIDByInvcgParty;
            parameter.InvoicingParty = ReqObj.InvoicingParty;
            parameter.DocumentCurrency = ReqObj.DocumentCurrency;
            parameter.InvoiceGrossAmount = ReqObj.InvoiceGrossAmount;
            parameter.PaymentTerms = ReqObj.PaymentTerms;
            parameter.AccountingDocumentType = ReqObj.AccountingDocumentType;
            parameter.SupplierInvoiceStatus = ReqObj.SupplierInvoiceStatus;
            parameter.TaxIsCalculatedAutomatically = ReqObj.TaxIsCalculatedAutomatically;
            parameter.BusinessPlace = ReqObj.BusinessPlace;
            parameter.BusinessSectionCode = ReqObj.BusinessSectionCode;
            parameter.SuplrInvcIsCapitalGoodsRelated = ReqObj.SuplrInvcIsCapitalGoodsRelated;
            parameter.TaxDeterminationDate = ReqObj.TaxDeterminationDate;
            parameter.TaxReportingDate = ReqObj.TaxReportingDate;
            parameter.TaxFulfillmentDate = ReqObj.TaxFulfillmentDate;
            parameter.InvoiceReceiptDate = ReqObj.InvoiceReceiptDate;
            parameter.IsEUTriangularDeal = ReqObj.IsEUTriangularDeal;
            parameter.RetentionDueDate = ReqObj.RetentionDueDate;
            parameter.IsReversal = ReqObj.IsReversal;
            parameter.IsReversed = ReqObj.IsReversed;
            parameter.SupplierPostingLineItemText = ReqObj.SupplierPostingLineItemText;
            parameter.to_SupplierInvoiceItemGLAcct = ReqObj.to_SupplierInvoiceItemGLAcct;


            // if (double.Parse(ReqObj.InvoiceGrossAmount) < 0)      // Amount to be deducted for Gain Loss is more than MPPI
            // {
            //     parameter.SupplierInvoiceIsCreditMemo = "2";
            // }
            // else
            // {
            //     parameter.to_SupplierInvoiceWhldgTax = ReqObj.to_SupplierInvoiceWhldgTax;
            //     parameter.SupplierInvoiceIsCreditMemo = ReqObj.SupplierInvoiceIsCreditMemo;
            // }


            if (ReqObj.SupplierInvoiceIsCreditMemo == "X")
            {
                parameter.to_SupplierInvoiceWhldgTax = new List<To_Supplierinvoicewhldgtax>();
                parameter.SupplierInvoiceIsCreditMemo = ReqObj.SupplierInvoiceIsCreditMemo;
            }
            else
            {
                parameter.to_SupplierInvoiceWhldgTax = ReqObj.to_SupplierInvoiceWhldgTax;
                parameter.SupplierInvoiceIsCreditMemo = ReqObj.SupplierInvoiceIsCreditMemo;
            }

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice?expand=$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(parameter), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }

        }

        public string SaveRateChangeMilkSOAPJson(ReqSAPMilkSOAPIncome ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice");
            string resString;

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();
            parameter.FiscalYear = ReqObj.FiscalYear;
            parameter.CompanyCode = ReqObj.CompanyCode;
            parameter.DocumentDate = ReqObj.DocumentDate;
            parameter.PostingDate = ReqObj.PostingDate;
            parameter.CreationDate = ReqObj.CreationDate;
            parameter.SupplierInvoiceIDByInvcgParty = ReqObj.SupplierInvoiceIDByInvcgParty;
            parameter.InvoicingParty = ReqObj.InvoicingParty;
            parameter.DocumentCurrency = ReqObj.DocumentCurrency;
            parameter.InvoiceGrossAmount = ReqObj.InvoiceGrossAmount;
            parameter.PaymentTerms = ReqObj.PaymentTerms;
            parameter.AccountingDocumentType = ReqObj.AccountingDocumentType;
            parameter.SupplierInvoiceStatus = ReqObj.SupplierInvoiceStatus;
            parameter.TaxIsCalculatedAutomatically = ReqObj.TaxIsCalculatedAutomatically;
            parameter.BusinessPlace = ReqObj.BusinessPlace;
            parameter.BusinessSectionCode = ReqObj.BusinessSectionCode;
            parameter.SuplrInvcIsCapitalGoodsRelated = ReqObj.SuplrInvcIsCapitalGoodsRelated;
            parameter.TaxDeterminationDate = ReqObj.TaxDeterminationDate;
            parameter.TaxReportingDate = ReqObj.TaxReportingDate;
            parameter.TaxFulfillmentDate = ReqObj.TaxFulfillmentDate;
            parameter.InvoiceReceiptDate = ReqObj.InvoiceReceiptDate;
            parameter.IsEUTriangularDeal = ReqObj.IsEUTriangularDeal;
            parameter.RetentionDueDate = ReqObj.RetentionDueDate;
            parameter.IsReversal = ReqObj.IsReversal;
            parameter.IsReversed = ReqObj.IsReversed;
            parameter.SupplierPostingLineItemText = ReqObj.SupplierPostingLineItemText;
            parameter.to_SupplierInvoiceItemGLAcct = ReqObj.to_SupplierInvoiceItemGLAcct;
            parameter.SupplierInvoiceIsCreditMemo = ReqObj.SupplierInvoiceIsCreditMemo;
            parameter.to_SupplierInvoiceWhldgTax = ReqObj.to_SupplierInvoiceWhldgTax;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(parameter), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }

        }

        //public List<CommonOutput> GetTDSDetailsFromSap(ReqInvoiceTDS invoiceTDS)
        //{


        //}

        public string GetTDSDetailsFromSap(ReqInvoiceTDS invoiceTDS)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_TDSMP_CDS/YY1_TDSMP?$filter=TransactionTypeDetermination eq 'WIT' and AccountingDocumentType eq 'ZM' and ReferenceDocument eq '" + invoiceTDS.income_sap_document_id + "' and Ledger eq '0L'");
            string resString;
            string AmountInBalanceTransacCrcy = "0";

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_TDSMP_CDS/YY1_TDSMP?$filter=TransactionTypeDetermination eq 'WIT' and AccountingDocumentType eq 'ZM' and ReferenceDocument eq '" + invoiceTDS.income_sap_document_id + "' and Ledger eq '0L'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var results = jsonResponse["d"]["results"];
                        if (results != null && results.HasValues)
                        {
                            AmountInBalanceTransacCrcy = jsonResponse["d"]["results"][0]["AmountInBalanceTransacCrcy"].ToString();

                        }
                        else
                        {
                            AmountInBalanceTransacCrcy = "0";
                        }

                        var parameters = new DynamicParameters(new
                        {
                            var_Method_Name = invoiceTDS.method_name,
                            var_Org_Id = invoiceTDS.org_id,
                            var_User_id = "",
                            var_User_Name = "",
                            var_InvoiceData = AmountInBalanceTransacCrcy,
                            var_Is_Active = 1,
                            var_Is_Deleted = 0,
                            var_SAP_Document_Id = "",
                            var_SAP_Document_Year = "",
                            var_Invoice_Id = invoiceTDS.voucher_id,
                        });

                        if (invoiceTDS.type == "Farmer")
                        {
                            dynamic resObj = this.db.Query<dynamic>("USP_AdminFarmerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

                        }
                        if (invoiceTDS.type == "MCC")
                        {
                            dynamic resObj = this.db.Query<dynamic>("USP_AdminMCCInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
                        }

                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }

        }

        public List<CommonOutput> GetTradingMaterialDetailsFromSap(ReqTradingMaterial tmDetails)
        {
            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = tmDetails.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            SalesOrder parameter = new SalesOrder();

            var parameterHeader = new DynamicParameters(new
            {
                var_Method_Name = "Get_SalesOrder",
                var_Org_Id = tmDetails.org_id,
                var_Product_Id = tmDetails.product_id,
                var_Order_Id = tmDetails.order_id,

            });

            var parameterData = this.db.Query<SalesOrder>("USP_AdminTradingMaterialIssueSAP_Get", parameterHeader, commandType: CommandType.StoredProcedure).ToList();

            parameter = parameterData[0];

            var parameterToItem = new DynamicParameters(new
            {
                var_Method_Name = "Get_To_Item",
                var_Org_Id = tmDetails.org_id,
                var_Product_Id = tmDetails.product_id,
                var_Order_Id = tmDetails.order_id,
            });

            parameter.to_Item = this.db.Query<To_Item>("USP_AdminTradingMaterialIssueSAP_Get", parameterToItem, commandType: CommandType.StoredProcedure).ToList();

            var parameterToPricingelement = new DynamicParameters(new
            {
                var_Method_Name = "Get_To_Pricingelement",
                var_Org_Id = tmDetails.org_id,
                var_Product_Id = tmDetails.product_id,
                var_Order_Id = tmDetails.order_id,
            });

            parameter.to_Item[0].to_PricingElement = this.db.Query<To_Pricingelement>("USP_AdminTradingMaterialIssueSAP_Get", parameterToPricingelement, commandType: CommandType.StoredProcedure).ToList();

            var dynamic = SaveSalesOrder(parameter, tmDetails.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);
            string SalesOrder = "";
            string NetAmount = "";
            if (jsonResponse.ContainsKey("d"))
            {
                SalesOrder = jsonResponse["d"]["SalesOrder"].ToString();
                var dynamic_get = GetSalesOrderItem(SalesOrder, tmDetails.org_id);

                JObject jsonResponse_get = JObject.Parse(dynamic_get);

                if (jsonResponse_get.ContainsKey("d"))
                {
                    JArray results = (JArray)jsonResponse_get["d"]["results"];

                    foreach (JObject item in results)
                    {
                        if (item["SalesOrderItem"].ToString() == "10")
                        {
                            NetAmount = item["NetAmount"].ToString();
                            break;
                        }
                    }
                }

                var parameterSuccess = new DynamicParameters(new
                {


                    var_Method_Name = "Success",
                    var_Org_Id = tmDetails.org_id,
                    var_Product_Id = tmDetails.product_id,
                    var_Order_Id = tmDetails.order_id,
                    var_SalesOrder = SalesOrder,
                    var_NetAmount = NetAmount,
                });

                return this.db.Query<CommonOutput>("USP_AdminTradingMaterialIssueSAP_Set", parameterSuccess, commandType: CommandType.StoredProcedure).ToList();





            }
            else if (jsonResponse.ContainsKey("error"))
            {
                var parameterSuccess = new DynamicParameters(new
                {


                    var_Method_Name = "Error",
                    var_Org_Id = tmDetails.org_id,
                    var_Product_Id = tmDetails.product_id,
                    var_Order_Id = tmDetails.order_id,
                    var_SalesOrder = "",
                    var_NetAmount = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminTradingMaterialIssueSAP_Set", parameterSuccess, commandType: CommandType.StoredProcedure).ToList();
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Sales Order does't Posted",
                    result_extra_key = "Sales Order does't Posted"
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
        }

        public string SaveSalesOrder(SalesOrder ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "A_SalesOrder", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "A_SalesOrder", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }



        }

        public string GetSalesOrderItem(string SalesOrderId, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();


                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }



                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    var resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "A_SalesOrderItem", request1, "", "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "A_SalesOrderItem", request1, "", "500", resString);
                    }


                    return resString;

                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }
    }
}
