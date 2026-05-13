using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using System.Xml;
using System;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using System.Linq;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Xml.Linq;
using static System.Net.Mime.MediaTypeNames;
using iText.Html2pdf;


namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class InvoiceDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public InvoiceDAL(string Destination)
        {
            string ConnectionName;
            switch (Destination)
            {
                case "MIP":
                    ConnectionName = "ConnectionPRD";
                    break;
                case "MIU":
                    ConnectionName = "ConnectionUAT";
                    break;
                default:
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
        }

        /*----  ----    ----    ----    Invoice Farmer Get & Save   ----    ----    ----    ----*/


        public List<ResInvoiceFarmer> GetInvoiceFarmer(ReqInvoiceFarmer invoiceFarmerSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSearch.method_name,
                var_Org_Id = invoiceFarmerSearch.org_id,
                var_User_id = invoiceFarmerSearch.user_id,
                var_Invoice_Id = invoiceFarmerSearch.invoice_id,
                var_Date = invoiceFarmerSearch.search_period,
                var_ApprovalStatus_Id = invoiceFarmerSearch.approvalstatus_id,
                var_MCC_Id = invoiceFarmerSearch.mcc_id,
                var_MCCType_Id = invoiceFarmerSearch.mcctype_id,
                var_MCCWorkType_Id = invoiceFarmerSearch.mccworktype_id,
                var_Farmer_Id = invoiceFarmerSearch.farmer_id,
            });

           
                return this.db.Query<ResInvoiceFarmer>("USP_AdminFarmerInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

        }


        public List<CommonOutput> SaveInvoiceFarmer(ReqInvoiceFarmer invoiceFarmerSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSearch.method_name,
                var_Org_Id = invoiceFarmerSearch.org_id,
                var_User_id = invoiceFarmerSearch.user_id,
                var_User_Name = invoiceFarmerSearch.user_name,
                var_InvoiceData = invoiceFarmerSearch.invoicedata,
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_SAP_Document_Id = invoiceFarmerSearch.sap_document_id,
                var_SAP_Document_Year = invoiceFarmerSearch.sap_document_year,
                var_Invoice_Id = invoiceFarmerSearch.invoice_id,
            });

            return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        public List<CommonOutput> SaveInvoiceFarmerInSap(ReqInvoiceFarmer invoiceFarmerSave)
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
                var_MCCWorkType_Id = invoiceFarmerSave.mccworktype_id,
                var_Farmer_Id = invoiceFarmerSave.farmer_id,


            });

            var parametersFarmer = this.db.Query<ResInvoiceFarmer>("USP_AdminFarmerInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

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

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = new CollectionSAP(Connection_Name).SaveMilkSOAP(parametersSOAP, invoiceFarmerSave.org_id);

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
                //var pathToFile = env.WebRootPath + Path.DirectorySeparatorChar.ToString() + "InvoiceTemplate" + Path.DirectorySeparatorChar.ToString() + "FarmerInvoice.html";
                //string InvoiceHTML = "";
                //using (StreamReader SourceReader = System.IO.File.OpenText(pathToFile))
                //{
                //    InvoiceHTML = SourceReader.ReadToEnd();
                //}

                //// Replace placeholders with actual data


                //// Save file to desired location
                //string InvoiceFileName = "FI" + invoiceFarmerSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                //string FilePhysicalPath = configuration.GetValue<string>("UploadFolderPath", "") + "\\" + InvoiceFileName;   // Physical location of file on server
                //HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceFarmerSave.org_id,
                    var_InvoiceData = "",
                    var_SAP_Document_Id = AccountingDocument,
                    var_SAP_Document_Year = FiscalYear,
                    var_Invoice_Id = invoiceFarmerSave.invoice_id,
                    var_User_Id = invoiceFarmerSave.user_id,
                    var_User_Name = invoiceFarmerSave.user_name,
                    var_Is_Active = 1,
                    var_Is_Deleted = 0,
                });

                return this.db.Query<CommonOutput>("USP_AdminFarmerInSAP_Set", parameter, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

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


            return new List<CommonOutput>();
        }

        /*----  ----    ----    ----    Invoice MCC Get & Save   ----    ----    ----    ----*/

        public List<ResInvoiceMCC> GetInvoiceMCC(ReqInvoiceMCC invoiceMCCSearch)
        {
            var parameters = new DynamicParameters(new
            {

                var_Method_Name = invoiceMCCSearch.method_name,
                var_Org_Id = invoiceMCCSearch.org_id,
                var_User_id = invoiceMCCSearch.user_id,
                var_Invoice_Id = invoiceMCCSearch.invoice_id,
                var_Date = invoiceMCCSearch.search_period,
                var_ApprovalStatus_Id = invoiceMCCSearch.approvalstatus_id,
                var_MCC_Id = invoiceMCCSearch.mcc_id,
                var_MCCType_Id = invoiceMCCSearch.mcctype_id
            });

            return this.db.Query<ResInvoiceMCC>("USP_AdminMCCInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveInvoiceMCC(ReqInvoiceMCC invoiceMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceMCCSave.method_name,
                var_Org_Id = invoiceMCCSave.org_id,
                var_User_id = invoiceMCCSave.user_id,
                var_User_Name = invoiceMCCSave.user_name,
                var_InvoiceData = invoiceMCCSave.invoicedata,
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_SAP_Document_Id = invoiceMCCSave.sap_document_id,
                var_SAP_Document_Year = invoiceMCCSave.sap_document_year,
                var_Invoice_Id = invoiceMCCSave.invoice_id,
            });

            return this.db.Query<CommonOutput>("USP_AdminMCCInSAP_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveInvoiceMCCInSap(ReqInvoiceMCC invoiceMCCSave)
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

            var parametersMCC = this.db.Query<ResInvoiceFarmer>("USP_AdminMCCInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

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

            var dynamic = new CollectionSAP(Connection_Name).SaveMilkSOAP(parametersSOAP, invoiceMCCSave.org_id);

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


            if (severityCode == "1" || severityCode == "2")
            {

                string AccountingDocument =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

                string FiscalYear =

                json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["FiscalYear"]?.ToString();


                // Save the Invoice File to decided location
                string InvoiceHTML = "This is a test invoice";
                string InvoiceFileName = "MI" + invoiceMCCSave.org_id + AccountingDocument + FiscalYear + ".pdf";
                string FilePhysicalPath = configuration.GetValue<string>("AppSettings:UploadFolderPath", "") + "" + InvoiceFileName;   // Physical location of file on server
                HtmlConverter.ConvertToPdf(InvoiceHTML, new FileStream(FilePhysicalPath, FileMode.Create));


                var parameter = new DynamicParameters(new
                {


                    var_Method_Name = "Update",
                    var_Org_Id = invoiceMCCSave.org_id,
                    var_InvoiceData = "",
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
            else if (severityCode == "3")
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


            return new List<CommonOutput>();
        }



        /*----  ----    ----    ----    Invoice Transporter Get & Save   ----    ----    ----    ----*/

        //public List<ResInvoiceTransporter> GetInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSearch)
        //{
        //    var parameters = new DynamicParameters(new
        //    {
        //        var_Method_Name = invoiceTransporterSearch.method_name,
        //        var_Org_Id = invoiceTransporterSearch.org_id,
        //        var_User_id = invoiceTransporterSearch.user_id,
        //    });

        //    return this.db.Query<ResInvoiceTransporter>("USP_AdminInvoiceTransporter_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        //}

        //public List<CommonOutput> SaveInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSave)
        //{
        //    var parameters = new DynamicParameters(new
        //    {
        //        var_Method_Name = invoiceTransporterSave.method_name,
        //        var_Org_Id = invoiceTransporterSave.org_id,
        //        var_User_Id = invoiceTransporterSave.user_id,
        //        var_User_Name = invoiceTransporterSave.user_name,
        //        var_Is_Active = invoiceTransporterSave.is_active,
        //        var_Is_Deleted = invoiceTransporterSave.is_deleted,
        //        var_Destination_name = invoiceTransporterSave.destination_name,
        //    });

        //    return this.db.Query<CommonOutput>("USP_AdminInvoiceTransporter_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        //}

        public List<ResInvoiceTransporter> GetInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSearch)
        {
            var parameters = new DynamicParameters(new
            {

                var_Method_Name = invoiceTransporterSearch.method_name,
                var_Org_Id = invoiceTransporterSearch.org_id,
                var_User_id = invoiceTransporterSearch.user_id,
                var_Invoice_Id = invoiceTransporterSearch.invoice_id,
                var_Date = invoiceTransporterSearch.search_period,
                var_ApprovalStatus_Id = invoiceTransporterSearch.approvalstatus_id
            });

            return this.db.Query<ResInvoiceTransporter>("USP_AdminTransporterInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceTransporterSave.method_name,
                var_Org_Id = invoiceTransporterSave.org_id,
                var_User_id = invoiceTransporterSave.user_id,
                var_User_Name = invoiceTransporterSave.user_name,
                var_InvoiceData = invoiceTransporterSave.invoicedata,
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_SAP_Document_Id = invoiceTransporterSave.sap_document_id,
                var_SAP_Document_Year = invoiceTransporterSave.sap_document_year,
                var_Invoice_Id = invoiceTransporterSave.invoice_id,
            });

            return this.db.Query<CommonOutput>("USP_AdminTransporterInSAP_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
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

            var parametersTransporter = this.db.Query<ResInvoiceFarmer>("USP_AdminTransporterInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

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

            var dynamic = new CollectionSAP(Connection_Name).SaveMilkSOAP(parametersSOAP, invoiceTransporterSave.org_id);

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
                    var_InvoiceData = "",
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


            return new List<CommonOutput>();
        }




        /*----  ----    ----    ----    Invoice Farmer Income Get & Save   ----    ----    ----    ----*/


        public List<ResInvoiceFarmerIncome> GetInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerIncomeSearch.method_name,
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_User_id = invoiceFarmerIncomeSearch.user_id,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_MCCType_Id = invoiceFarmerIncomeSearch.mcctype_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id
            });

            return this.db.Query<ResInvoiceFarmerIncome>("USP_AdminFarmerIncome_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        public List<CommonOutput> SaveInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerIncomeSearch.method_name,
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            var ResData = this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            if (invoiceFarmerIncomeSearch.method_name == "ExcelUpload")
            {

                var parametersUpdate_Rate = new DynamicParameters(new
                {
                    var_Method_Name = "Update_Rate",
                    var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                    var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                    var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                    var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                    var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                    var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                    var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                    var_Weight = invoiceFarmerIncomeSearch.weight,
                    var_SNF = invoiceFarmerIncomeSearch.snf,
                    var_Fat = invoiceFarmerIncomeSearch.fat,
                    var_Protein = invoiceFarmerIncomeSearch.protein,
                    var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                    var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                    var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                    var_Date = invoiceFarmerIncomeSearch.search_period,
                    var_User_Id = invoiceFarmerIncomeSearch.user_id,
                    var_User_Name = invoiceFarmerIncomeSearch.user_name,
                });

                this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parametersUpdate_Rate, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            }
            return ResData;


        }

        public List<CommonOutput> SavedInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSearch)
        {

            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerIncomeSearch.method_name,
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_set_farmer = new DynamicParameters(new
            {
                var_Method_Name = "Set_Approval_V1",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_set_farmer, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_set_agent = new DynamicParameters(new
            {
                var_Method_Name = "Set_Agent",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_set_agent, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_set_flat = new DynamicParameters(new
            {
                var_Method_Name = "Update_flat",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

             this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_set_flat, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_delete_commission = new DynamicParameters(new
            {
                var_Method_Name = "Delete_Commission",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

             this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_delete_commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_create_commission = new DynamicParameters(new
            {
                var_Method_Name = "Create_Commission",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            return this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_create_commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


        }


        public List<CommonOutput> SavedInvoicedFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSearch)
        {

            var parameters_set_agent = new DynamicParameters(new
            {
                var_Method_Name = "Set_Agent",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_set_agent, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_set_flat = new DynamicParameters(new
            {
                var_Method_Name = "Update_flat",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_set_flat, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_delete_commission = new DynamicParameters(new
            {
                var_Method_Name = "Delete_Commission",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_delete_commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_create_commission = new DynamicParameters(new
            {
                var_Method_Name = "Create_Commission",
                var_Org_Id = invoiceFarmerIncomeSearch.org_id,
                var_Entry_Id = invoiceFarmerIncomeSearch.entry_id,
                var_MilkCollectionDairy_Id = invoiceFarmerIncomeSearch.milkcollectiondairy_id,
                var_TripDocument_Id = invoiceFarmerIncomeSearch.tripdocument_id,
                var_MCCCollectionShift_Id = invoiceFarmerIncomeSearch.mcccollectionshift_id,
                var_MCC_Id = invoiceFarmerIncomeSearch.mcc_id,
                var_Farmer_Id = invoiceFarmerIncomeSearch.farmer_id,
                var_Weight = invoiceFarmerIncomeSearch.weight,
                var_SNF = invoiceFarmerIncomeSearch.snf,
                var_Fat = invoiceFarmerIncomeSearch.fat,
                var_Protein = invoiceFarmerIncomeSearch.protein,
                var_MilkType_Id = invoiceFarmerIncomeSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerIncomeSearch.milkstatus_id,
                var_CollectionData = invoiceFarmerIncomeSearch.collection_data,
                var_Date = invoiceFarmerIncomeSearch.search_period,
                var_User_Id = invoiceFarmerIncomeSearch.user_id,
                var_User_Name = invoiceFarmerIncomeSearch.user_name,
            });

            return this.db.Query<CommonOutput>("USP_AdminFarmerIncome_Set", parameters_create_commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


        }


        /*----  ----    ----    ----    Invoice Farmer Income Get & Save   ----    ----    ----    ----*/


        public List<ResInvoicePublish> GetInvoicePublish(ReqInvoicePublish invoicePublishSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoicePublishSearch.method_name,
                var_Org_Id = invoicePublishSearch.org_id,
                var_User_id = invoicePublishSearch.user_id,
                var_Date = invoicePublishSearch.search_period,
                var_VoucherType_Id = invoicePublishSearch.vouchertype_id,
                var_MCCType_Id = invoicePublishSearch.mcctype_id,
                var_MCCWorkType_Id = invoicePublishSearch.mccworktype_id,
                var_MCC_Id = invoicePublishSearch.mcc_id,
                var_Invoice_Id = invoicePublishSearch.invoice_id
            });

            return this.db.Query<ResInvoicePublish>("USP_AdminInvoicePublish_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        public List<CommonOutput> SaveInvoicePublish(ReqInvoicePublish invoicePublishSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoicePublishSearch.method_name,
                var_Org_Id = invoicePublishSearch.org_id,
                var_User_id = invoicePublishSearch.user_id,
                var_User_Name = invoicePublishSearch.user_name,
                var_VoucherType_Id = invoicePublishSearch.vouchertype_id,
                var_Invoice_Id = invoicePublishSearch.invoice_id,
                var_Date = invoicePublishSearch.search_period,
            });

            return this.db.Query<CommonOutput>("USP_AdminInvoicePublish_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }

        /*----  ----    ----    ----    Invoice Farmer Get & Save   ----    ----    ----    ----*/


        public List<ResMissingFarmer> GetMissingFarmer(ReqMissingFarmer invoiceFarmerSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSearch.method_name,
                var_Org_Id = invoiceFarmerSearch.org_id,
                var_User_id = invoiceFarmerSearch.user_id,
                var_FarmerCollection_Id = invoiceFarmerSearch.farmercollection_id,
                var_Date = invoiceFarmerSearch.search_period,
            });

            return this.db.Query<ResMissingFarmer>("USP_AdminMissingFarmer_Get", parameters, commandType: CommandType.StoredProcedure).ToList();




        }


        public List<CommonOutput> SaveMissingFarmer(ReqMissingFarmer invoiceFarmerSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceFarmerSearch.method_name,
                var_Org_Id = invoiceFarmerSearch.org_id,
                var_User_id = invoiceFarmerSearch.user_id,
                var_User_Name = invoiceFarmerSearch.user_name,
                var_Farmer_Id = invoiceFarmerSearch.farmer_id,
                var_Weight = invoiceFarmerSearch.weight,
                var_SNF = invoiceFarmerSearch.snf,
                var_Fat = invoiceFarmerSearch.fat,
                var_MilkType_Id = invoiceFarmerSearch.milktype_id,
                var_MilkStatus_Id = invoiceFarmerSearch.milkstatus_id,
                var_Date = invoiceFarmerSearch.search_period,
                var_CollectionShift_Id = invoiceFarmerSearch.collectionshift_id,

            });

            return this.db.Query<CommonOutput>("USP_AdminMissingFarmer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();




        }

        /*----  ----    ----    ----    Invoice Rebate Get & Save   ----    ----    ----    ----*/
        public List<ResRebate> GetRebate(ReqRebate invoiceRebate)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceRebate.method_name,
                var_Org_Id = invoiceRebate.org_id,
                var_User_id = invoiceRebate.user_id,
                var_MCCType_Id = invoiceRebate.mcctype_id,
                var_MCCWorkType_Id = invoiceRebate.mccworktype_id,
                var_MCC_Id = invoiceRebate.mcc_id,
                var_Date = invoiceRebate.search_period,
                var_ApprovalStatus_Id = invoiceRebate.approvalstatus_id,
                var_Invoice_Id = invoiceRebate.invoice_id,
            });

            return this.db.Query<ResRebate>("USP_AdminRebate_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }

        public List<CommonOutput> SaveRebate(ReqRebate rebateSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = rebateSearch.method_name,
                var_Org_Id = rebateSearch.org_id,
                var_User_id = rebateSearch.user_id,
                var_User_Name = rebateSearch.user_name,
                var_InvoiceData = rebateSearch.invoicedata,
                var_SAP_Document_Id = rebateSearch.sap_document_id,
                var_SAP_Document_Year = rebateSearch.sap_document_year,
                var_Invoice_Id = rebateSearch.invoice_id,
                var_Date = rebateSearch.search_period,
            });

            return this.db.Query<CommonOutput>("USP_AdminRebate_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }

        /*----  ----    ----    ----    Invoice Farmer Get & Save   ----    ----    ----    ----*/


        public List<ResInvoiceRateChange> GetInvoiceRateChange(ReqInvoiceRateChange invoiceRateChangeSearch)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceRateChangeSearch.method_name,
                var_Org_Id = invoiceRateChangeSearch.org_id,
                var_User_id = invoiceRateChangeSearch.user_id,
                var_Date = invoiceRateChangeSearch.search_period,
                var_MCC_Id = invoiceRateChangeSearch.mcc_id,
                var_MCCType_Id = invoiceRateChangeSearch.mcctype_id,
                var_Chart_Id = invoiceRateChangeSearch.chart_id,
                var_Invoice_Id= invoiceRateChangeSearch.invoice_id,
            });

            return this.db.Query<ResInvoiceRateChange>("USP_AdminRateChange_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        public List<CommonOutput> SaveInvoiceRateChange(ReqInvoiceRateChange invoiceRateChangeSearch)
        {



           var parameters = new DynamicParameters(new
           {
               var_Method_Name = invoiceRateChangeSearch.method_name,
                var_Org_Id = invoiceRateChangeSearch.org_id,
                var_User_id = invoiceRateChangeSearch.user_id,
                var_User_Name = invoiceRateChangeSearch.user_name,
                var_InvoiceData = invoiceRateChangeSearch.invoicedata,
           });

           return this.db.Query<CommonOutput>("USP_AdminRateChange_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        /*----  ----    ----    ----    Invoice SAP Posting Get & Save   ----    ----    ----    ----*/


        public List<ResInvoiceSAPPosting> GetInvoiceSAPPosting(ReqInvoiceSAPPosting invoiceSAPPosting)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceSAPPosting.method_name,
                var_Org_Id = invoiceSAPPosting.org_id,
                var_User_id = invoiceSAPPosting.user_id,
                var_Date = invoiceSAPPosting.search_period,
                var_Invoice_Id = invoiceSAPPosting.invoice_id,
                var_MCC_Id = invoiceSAPPosting.mcc_id,
                var_MCCType_Id = invoiceSAPPosting.mcctype_id,

            });

            return this.db.Query<ResInvoiceSAPPosting>("USP_AdminSAPPosting_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }


        public List<CommonOutput> SaveInvoiceSAPPosting(ReqInvoiceSAPPosting invoiceSAPPosting)
        {



            var parameters = new DynamicParameters(new
            {
                var_Method_Name = invoiceSAPPosting.method_name,
                var_Org_Id = invoiceSAPPosting.org_id,
                var_InvoiceData = invoiceSAPPosting.invoicedata,
                var_SAP_Document_Id = invoiceSAPPosting.sap_document_id,
                var_SAP_Document_Year = invoiceSAPPosting.sap_document_year,
                var_Invoice_Id = invoiceSAPPosting.invoice_id,
                var_MCC_Id = invoiceSAPPosting.mcc_id,
                var_Farmer_Id = invoiceSAPPosting.farmer_id,
                var_Date = invoiceSAPPosting.search_period,
                var_Amount = invoiceSAPPosting.amount,
                var_User_Id = invoiceSAPPosting.user_id,
                var_User_Name = invoiceSAPPosting.user_name,
                var_IncomeFor = invoiceSAPPosting.incomefor,
                var_Remark = invoiceSAPPosting.remark,
                var_MilkPayment = invoiceSAPPosting.milkpayment,
            });

            return this.db.Query<CommonOutput>("USP_AdminSAPPosting_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();




        }
    }
}
