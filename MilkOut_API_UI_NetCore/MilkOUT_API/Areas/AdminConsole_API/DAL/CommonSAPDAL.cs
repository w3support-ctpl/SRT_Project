using Dapper;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MySql.Data.MySqlClient;
using MySqlX.XDevAPI.Common;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Xml;
using System.Xml.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class CommonSAPDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;
        public CommonSAPDAL(string Destination, IConfigurationRoot configuration)
        {

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


        // public List<CommonOutput> SaveSAPDealerMaster(string method, string org_id, string resString, string DealerDatastr)
        // {

        //     JObject jsonResponse = JObject.Parse(resString);


        //     dynamic res_obj = JsonConvert.DeserializeObject(DealerDatastr.ToString());

        //     List<string> CodeList = new List<string>();

        //     for (int i = 0; i < res_obj.Count; i++)
        //     {

        //         CodeList.Add(res_obj[i].Dealer_Code.ToString());

        //     }



        //     if (jsonResponse.ContainsKey("d"))
        //     {
        //         var results = jsonResponse["d"]["results"];

        //         var rescount = results.Count();

        //         if (results != null)
        //         {
        //             //XDocument xmlDocument = new XDocument(new XElement("Dealer"));

        //             var xmlDocument = "";

        //             foreach (var result in results)
        //             {

        //                 if (CodeList.Contains(result["Customer"].ToString()) == false)
        //                 {

        //                     //for (int i = 0; i < res_obj.Count; i++)
        //                     //{
        //                     //    if (res_obj[i].Dealer_Code != result["Customer"].ToString())
        //                     //    {

        //                     String DealerCode = result["Customer"].ToString();
        //                     String DealerName = result["CustomerName"].ToString();
        //                     String SalesGroup = ""; /*result["SalesGroup"].ToString();*/
        //                     String SalesUser = "";
        //                     String PANNo = result["BPIdentificationNumber"].ToString();
        //                     String PhoneNo = result["TelephoneNumber1"].ToString();
        //                     String EmailId = ""; /*result["EmailAddress"].ToString();*/
        //                     String AddressLine1 = result["StreetName"].ToString();
        //                     String AddressLine2 = ""; /*result["StreetName_1"].ToString();*/
        //                     String AddressLine3 = result["BPAddrStreetName"].ToString();
        //                     String State = result["Region"].ToString();
        //                     String District = ""; /*result["DistrictName"].ToString();*/
        //                     String CityTaluka = ""; /*result["VillageName"].ToString();*/
        //                     String PinCode = result["PostalCode"].ToString();
        //                     String ContactPerson = "";
        //                     String MobileNo = result["TelephoneNumber2"].ToString();
        //                     String BankName = result["BankName"].ToString();
        //                     String BranchName = result["BankAccountName"].ToString();
        //                     String AccountName = result["BankAccountHolderName"].ToString();
        //                     String AccountNo = result["BankAccount"].ToString();
        //                     String IFSCCode = result["BPIdentificationNumber_2"].ToString();
        //                     String MSMENo = result["BPIdentificationNumber_3"].ToString();
        //                     String FSSAILicenseNo = "";
        //                     String FSSAILicenseValidityDate = "";
        //                     String GSTNo = "";/*result["TaxNumber3"].ToString();*/
        //                     String SecurityDepositAmount = "";


        //                     xmlDocument += "<DealerData><DealerCode>" + DealerCode + "</DealerCode>" +
        //                                    "<DealerName>" + DealerName + "</DealerName>" +
        //                                    "<SalesGroup>" + SalesGroup + "</SalesGroup>" +
        //                                    "<SalesUser>" + SalesUser + "</SalesUser>" +
        //                                     "<PANNo>" + PANNo + "</PANNo>" +
        //                                    "<PhoneNo>" + PhoneNo + "</PhoneNo>" +
        //                                    "<EmailId>" + EmailId + "</EmailId>" +
        //                                     "<AddressLine1>" + AddressLine1 + "</AddressLine1>" +
        //                                    "<AddressLine2>" + AddressLine2 + "</AddressLine2>" +
        //                                    "<AddressLine3>" + AddressLine3 + "</AddressLine3>" +
        //                                     "<State>" + State + "</State>" +
        //                                    "<District>" + District + "</District>" +
        //                                    "<CityTaluka>" + CityTaluka + "</CityTaluka>" +
        //                                     "<PinCode>" + PinCode + "</PinCode>" +
        //                                    "<ContactPerson>" + ContactPerson + "</ContactPerson>" +
        //                                     "<MobileNo>" + MobileNo + "</MobileNo>" +
        //                                    "<BankName>" + BankName + "</BankName>" +
        //                                    "<AccountName>" + AccountName + "</AccountName>" +
        //                                     "<AccountNo>" + AccountNo + "</AccountNo>" +
        //                                     "<IFSCCode>" + IFSCCode + "</IFSCCode>" +
        //                                    "<MSMENo>" + MSMENo + "</MSMENo>" +
        //                                     "<BranchName>" + BranchName + "</BranchName>" +
        //                                    "<FSSAILicenseNo>" + FSSAILicenseNo + "</FSSAILicenseNo>" +
        //                                     "<FSSAILicenseValidityDate>" + FSSAILicenseValidityDate + "</FSSAILicenseValidityDate>" +
        //                                    "<GSTNo>" + GSTNo + "</GSTNo>" +
        //                                    "<SecurityDepositAmount>" + SecurityDepositAmount + "</SecurityDepositAmount></DealerData>";


        //                     //XElement DealerData = new XElement("DealerData",
        //                     //    new XElement("DealerCode", DealerCode),
        //                     //    new XElement("DealerName", DealerName),
        //                     //    new XElement("SalesGroup", SalesGroup),
        //                     //    new XElement("SalesUser", SalesUser),
        //                     //    new XElement("PANNo", PANNo),
        //                     //    new XElement("PhoneNo", PhoneNo),
        //                     //    new XElement("EmailId", EmailId),
        //                     //    new XElement("AddressLine1", AddressLine1),
        //                     //    new XElement("AddressLine2", AddressLine2),
        //                     //    new XElement("AddressLine3", AddressLine3),
        //                     //    new XElement("State", State),
        //                     //    new XElement("District", District),
        //                     //    new XElement("CityTaluka", CityTaluka),
        //                     //    new XElement("PinCode", PinCode),
        //                     //    new XElement("ContactPerson", ContactPerson),
        //                     //    new XElement("MobileNo", MobileNo),
        //                     //    new XElement("BankName", BankName),
        //                     //    new XElement("BranchName", BranchName),
        //                     //    new XElement("AccountName", AccountName),
        //                     //    new XElement("AccountNo", AccountNo),
        //                     //    new XElement("IFSCCode", IFSCCode),
        //                     //    new XElement("MSMENo", MSMENo),
        //                     //    new XElement("FSSAILicenseNo", FSSAILicenseNo),
        //                     //    new XElement("FSSAILicenseValidityDate", FSSAILicenseValidityDate),
        //                     //    new XElement("GSTNo", GSTNo),
        //                     //    new XElement("SecurityDepositAmount", SecurityDepositAmount)
        //                     //);

        //                     //xmlDocument.Root.Add(DealerData);


        //                     //   }
        //                 }


        //             }

        //             var XML_Data = "<Dealer>" + xmlDocument + "</Dealer>";

        //             var parameters = new DynamicParameters(new
        //             {
        //                 var_Method_Name = method,
        //                 var_Org_Id = org_id,
        //                 var_XML_Data = XML_Data
        //             });



        //             var output = this.db.Query<CommonOutput>("USP_SAdminDealerMaster_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


        //             // Return the CommonOutput instance as a list with a single item
        //             return output;

        //         }
        //     }
        //     else if (jsonResponse.ContainsKey("error"))
        //     {
        //         CommonOutput commonOutput = new CommonOutput
        //         {
        //             result_id = -1, // Assuming result_id is an integer
        //             result_description = jsonResponse["error"]["message"]["value"].ToString(),
        //             result_extra_key = jsonResponse["error"]["code"].ToString()
        //         };

        //         // Return the CommonOutput instance as a list with a single item
        //         return new List<CommonOutput> { commonOutput };
        //     }
        //     else
        //     {

        //         CommonOutput commonOutput = new CommonOutput
        //         {
        //             result_id = -1, // Assuming result_id is an integer
        //             result_description = "Product Not Getting From SAP",
        //             result_extra_key = ""
        //         };

        //         // Return the CommonOutput instance as a list with a single item
        //         return new List<CommonOutput> { commonOutput };


        //     }

        //     return new List<CommonOutput>();

        // }

        public List<CommonOutput> SaveSAPDealerMaster(string method, string org_id, string resString, string DealerDatastr)
        {

            JObject jsonResponse = JObject.Parse(resString);


            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                var rescount = results.Count();

                if (results != null)
                {


                    foreach (var result in results)
                    {

                        var xmlDocument = "";


                        String DealerCode = result["Customer"].ToString();
                        String DealerName = result["CustomerName"].ToString();
                        String SalesGroup = ""; /*result["SalesGroup"].ToString();*/
                        String SalesUser = "";
                        String PANNo = result["BPIdentificationNumber"].ToString();
                        String PhoneNo = result["TelephoneNumber1"].ToString();
                        String EmailId = ""; /*result["EmailAddress"].ToString();*/
                        String AddressLine1 = result["StreetName"].ToString();
                        String AddressLine2 = ""; /*result["StreetName_1"].ToString();*/
                        String AddressLine3 = result["BPAddrStreetName"].ToString();
                        String State = result["Region"].ToString();
                        String District = ""; /*result["DistrictName"].ToString();*/
                        String CityTaluka = ""; /*result["VillageName"].ToString();*/
                        String PinCode = result["PostalCode"].ToString();
                        String ContactPerson = "";
                        String MobileNo = result["TelephoneNumber2"].ToString();
                        String BankName = result["BankName"].ToString();
                        String BranchName = result["BankAccountName"].ToString();
                        String AccountName = result["BankAccountHolderName"].ToString();
                        String AccountNo = result["BankAccount"].ToString();
                        String IFSCCode = result["BPIdentificationNumber_2"].ToString();
                        String MSMENo = result["BPIdentificationNumber_3"].ToString();
                        String FSSAILicenseNo = "";
                        String FSSAILicenseValidityDate = "";
                        String GSTNo = "";/*result["TaxNumber3"].ToString();*/
                        String SecurityDepositAmount = "";


                        xmlDocument += "<DealerData><DealerCode>" + DealerCode + "</DealerCode>" +
                                       "<DealerName>" + DealerName + "</DealerName>" +
                                       "<SalesGroup>" + SalesGroup + "</SalesGroup>" +
                                       "<SalesUser>" + SalesUser + "</SalesUser>" +
                                        "<PANNo>" + PANNo + "</PANNo>" +
                                       "<PhoneNo>" + PhoneNo + "</PhoneNo>" +
                                       "<EmailId>" + EmailId + "</EmailId>" +
                                        "<AddressLine1>" + AddressLine1 + "</AddressLine1>" +
                                       "<AddressLine2>" + AddressLine2 + "</AddressLine2>" +
                                       "<AddressLine3>" + AddressLine3 + "</AddressLine3>" +
                                        "<State>" + State + "</State>" +
                                       "<District>" + District + "</District>" +
                                       "<CityTaluka>" + CityTaluka + "</CityTaluka>" +
                                        "<PinCode>" + PinCode + "</PinCode>" +
                                       "<ContactPerson>" + ContactPerson + "</ContactPerson>" +
                                        "<MobileNo>" + MobileNo + "</MobileNo>" +
                                       "<BankName>" + BankName + "</BankName>" +
                                       "<AccountName>" + AccountName + "</AccountName>" +
                                        "<AccountNo>" + AccountNo + "</AccountNo>" +
                                        "<IFSCCode>" + IFSCCode + "</IFSCCode>" +
                                       "<MSMENo>" + MSMENo + "</MSMENo>" +
                                        "<BranchName>" + BranchName + "</BranchName>" +
                                       "<FSSAILicenseNo>" + FSSAILicenseNo + "</FSSAILicenseNo>" +
                                        "<FSSAILicenseValidityDate>" + FSSAILicenseValidityDate + "</FSSAILicenseValidityDate>" +
                                       "<GSTNo>" + GSTNo + "</GSTNo>" +
                                       "<SecurityDepositAmount>" + SecurityDepositAmount + "</SecurityDepositAmount></DealerData>";

                        var XML_Data = "<Dealer>" + xmlDocument + "</Dealer>";

                        var parameters = new DynamicParameters(new
                        {
                            var_Method_Name = method,
                            var_Org_Id = org_id,
                            var_XML_Data = XML_Data
                        });



                        var output = this.db.Query<CommonOutput>("USP_SAdminDealerMaster_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



                    }


                    CommonOutput commonOutput = new CommonOutput
                    {
                        result_id = 1, // Assuming result_id is an integer
                        result_description = "Downloaded",
                        result_extra_key = ""
                    };

                    // Return the CommonOutput instance as a list with a single item
                    return new List<CommonOutput> { commonOutput };

                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Product Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();

        }

        public List<CommonOutput> SaveSAPDealerCrateLimit(string method, string org_id, string Dealer_Code, string CrateLimit)
        {




            var parameters = new DynamicParameters(new
            {
                var_Method_Name = method,
                var_Org_Id = org_id,
                var_Dealer_Code = Dealer_Code,
                var_CrateLimit = CrateLimit
            });



            var output = this.db.Query<CommonOutput>("USP_SAdminDealerCrateLimit_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


            CommonOutput commonOutput = new CommonOutput
            {
                result_id = 1, // Assuming result_id is an integer
                result_description = "Downloaded",
                result_extra_key = ""
            };


            return new List<CommonOutput>();

        }


        public List<CommonOutput> SaveSAPDealerSalesArea(string method, string org_id, string resString, string DealerDatastr)
        {

            JObject jsonResponse = JObject.Parse(resString);


            dynamic res_obj = JsonConvert.DeserializeObject(DealerDatastr.ToString());

            List<string> CodeList = new List<string>();

            for (int i = 0; i < res_obj.Count; i++)
            {

                CodeList.Add(res_obj[i].Dealer_Code.ToString());

            }



            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                var rescount = results.Count();

                if (results != null)
                {
                    // //XDocument xmlDocument = new XDocument(new XElement("Dealer"));

                    // var xmlDocument = "";

                    // foreach (var result in results)
                    // {

                    //     if (CodeList.Contains(result["Customer"].ToString()) == false)
                    //     {

                    //         //for (int i = 0; i < res_obj.Count; i++)
                    //         //{
                    //         //    if (res_obj[i].Dealer_Code != result["Customer"].ToString())
                    //         //    {

                    //         String DealerCode = result["Customer"].ToString();

                    //         String SalesOrganization = result["SalesOrganization"].ToString();
                    //         String DistributionChannel = result["DistributionChannel"].ToString();
                    //         String Division = result["Division"].ToString();
                    //         String SalesGroup = result["SalesGroup"].ToString();


                    //         xmlDocument += "<DealerData><DealerCode>" + DealerCode + "</DealerCode>" +
                    //                        "<SalesOrganization>" + SalesOrganization + "</SalesOrganization>" +
                    //                        "<DistributionChannel>" + DistributionChannel + "</DistributionChannel>" +
                    //                        "<Division>" + Division + "</Division>" +
                    //                        "<SalesGroup>" + SalesGroup + "</SalesGroup></DealerData>";



                    //     }


                    // }

                    // var XML_Data = "<Dealer>" + xmlDocument + "</Dealer>";

                    XDocument xmlDocument = new XDocument(new XElement("Dealer"));
                    foreach (var result in results)
                    {
                        String DealerCode = result["Customer"]?.ToString();

                        // ✅ CONDITION: Only include if exists in DealerDatastr
                        if (string.IsNullOrEmpty(DealerCode) || !CodeList.Contains(DealerCode))
                            continue;

                        //String DealerCode = result["Customer"].ToString();
                        String SalesOrganization = result["SalesOrganization"].ToString();
                        String DistributionChannel = result["DistributionChannel"].ToString();
                        String Division = result["Division"].ToString();
                        String SalesGroup = result["SalesGroup"].ToString();

                        XElement DealerData = new XElement("DealerData",
                            new XElement("DealerCode", DealerCode),
                            new XElement("SalesOrganization", SalesOrganization),
                            new XElement("DistributionChannel", DistributionChannel),
                            new XElement("Division", Division),
                            new XElement("SalesGroup", SalesGroup)
                        );

                        xmlDocument.Root.Add(DealerData);
                    }

                    var parameters = new DynamicParameters(new
                    {
                        var_Method_Name = method,
                        var_Org_Id = org_id,
                        var_XML_Data = xmlDocument
                    });



                    var output = this.db.Query<CommonOutput>("USP_SAdminDealerSalesGroup_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                    // Return the CommonOutput instance as a list with a single item
                    return output;

                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Sales Area Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();

        }

        // public List<CommonOutput> SaveSAPSalesArea(string method, string org_id, string resString, string SalesAreaDatastr)
        //         {

        //             JObject jsonResponse = JObject.Parse(resString);


        //             dynamic res_obj = JsonConvert.DeserializeObject(SalesAreaDatastr.ToString());

        //             List<string> CodeList = new List<string>();

        //             for (int i = 0; i < res_obj.Count; i++)
        //             {

        //                 CodeList.Add(res_obj[i].SalesGroup.ToString());

        //             }



        //             if (jsonResponse.ContainsKey("d"))
        //             {
        //                 var results = jsonResponse["d"]["results"];

        //                 var rescount = results.Count();

        //                 if (results != null)
        //                 {
        //                     XDocument xmlDocument = new XDocument(new XElement("SalesArea"));
        //                     foreach (var result in results)
        //                     {
        //                         String SalesGroup = result["SalesGroup"].ToString();
        //                         String SalesOffice = result["SalesOffice"].ToString();
        //                         String SalesOfficeName = result["SalesOfficeName"].ToString();

        //                         XElement SalesAreaData = new XElement("SalesAreaData",
        //                             new XElement("SalesGroup", SalesGroup),
        //                             new XElement("SalesOffice", SalesOffice),
        //                             new XElement("SalesOfficeName", SalesOfficeName)
        //                         );

        //                         xmlDocument.Root.Add(SalesAreaData);
        //                     }

        //                     var parameters = new DynamicParameters(new
        //                     {
        //                         var_Method_Name = method,
        //                         var_Org_Id = org_id,
        //                         var_XML_Data = xmlDocument
        //                     });



        //                     var output = this.db.Query<CommonOutput>("USP_SAdminDealerSalesGroup_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


        //                     return output;

        //                 }
        //             }
        //             else if (jsonResponse.ContainsKey("error"))
        //             {
        //                 CommonOutput commonOutput = new CommonOutput
        //                 {
        //                     result_id = -1, // Assuming result_id is an integer
        //                     result_description = jsonResponse["error"]["message"]["value"].ToString(),
        //                     result_extra_key = jsonResponse["error"]["code"].ToString()
        //                 };

        //                 // Return the CommonOutput instance as a list with a single item
        //                 return new List<CommonOutput> { commonOutput };
        //             }
        //             else
        //             {

        //                 CommonOutput commonOutput = new CommonOutput
        //                 {
        //                     result_id = -1, // Assuming result_id is an integer
        //                     result_description = "Sales Area Not Getting From SAP",
        //                     result_extra_key = ""
        //                 };

        //                 // Return the CommonOutput instance as a list with a single item
        //                 return new List<CommonOutput> { commonOutput };


        //             }

        //             return new List<CommonOutput>();

        //         }

        public List<CommonOutput> SaveSAPSalesArea(string method, string org_id, string resString, string SalesAreaDatastr)
        {
            // Parse the SAP response
            JObject jsonResponse = JObject.Parse(resString);

            // Deserialize SalesAreaDatastr (input data with multiple SalesGroup and SalesOffice entries)
            dynamic res_obj = JsonConvert.DeserializeObject(SalesAreaDatastr.ToString());

            // Initialize a list of sales area codes and sales office codes to check against
            List<(string SalesGroup, string SalesOffice)> CodeList = new List<(string, string)>();

            // HashSet to keep track of unique SalesGroup and SalesOffice pairs
            HashSet<(string SalesGroup, string SalesOffice)> uniqueEntries = new HashSet<(string SalesGroup, string SalesOffice)>();

            // Loop through each entry in SalesAreaDatastr to populate the CodeList
            for (int i = 0; i < res_obj.Count; i++)
            {
                string salesAreaCode = res_obj[i].SalesGroup.ToString(); // SalesArea_Code
                string salesOfficeCode = res_obj[i].SalesOffice.ToString(); // SalesOffice_Code

                CodeList.Add((salesAreaCode, salesOfficeCode)); // Add to the list for comparison
            }

            // Check if 'd' key exists in the jsonResponse
            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                if (results != null)
                {
                    // Create an XML document to store unmatched SalesArea data
                    XDocument xmlDocument = new XDocument(new XElement("SalesArea"));

                    // Loop through each result from the SAP response
                    foreach (var result in results)
                    {
                        string SalesGroup = result["SalesGroup"].ToString();
                        string SalesOffice = result["SalesOffice"].ToString();
                        string SalesOfficeName = result["SalesOfficeName"].ToString();

                        // Check if this SalesGroup and SalesOffice are present in the CodeList
                        bool matchFound = CodeList.Any(c => c.SalesGroup == SalesGroup && c.SalesOffice == SalesOffice);

                        // If no match found and not already in the unique set, add to XML document
                        if (!matchFound && uniqueEntries.Add((SalesGroup, SalesOffice)))
                        {
                            XElement SalesAreaData = new XElement("SalesAreaData",
                                new XElement("SalesGroup", SalesGroup),
                                new XElement("SalesOffice", SalesOffice),
                                new XElement("SalesOfficeName", SalesOfficeName)
                            );
                            xmlDocument.Root.Add(SalesAreaData); // Add the unique data to the XML
                        }
                    }

                    // If XML contains data, pass it to the stored procedure
                    if (xmlDocument.Root.HasElements)
                    {
                        var parameters = new DynamicParameters(new
                        {
                            var_Method_Name = method,
                            var_Org_Id = org_id,
                            var_XML_Data = xmlDocument
                        });

                        // Call stored procedure and return the output
                        var output = this.db.Query<CommonOutput>("USP_SAdminSalesArea_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
                        return output;
                    }
                    else
                    {
                        // No data to insert, return a success message or empty list
                        return new List<CommonOutput> { new CommonOutput { result_id = 0, result_description = "No unmatched or duplicate data found" } };
                    }
                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                // Handle error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1,
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                return new List<CommonOutput> { commonOutput };
            }
            else
            {
                // Handle case where no results are found
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1,
                    result_description = "Sales Area Not Getting From SAP",
                    result_extra_key = ""
                };

                return new List<CommonOutput> { commonOutput };
            }

            return new List<CommonOutput>();
        }

        // public List<CommonOutput> SaveSAPSalesArea(string method, string org_id, string resString, string SalesAreaDatastr)
        // {
        //     // Parse the SAP response
        //     JObject jsonResponse = JObject.Parse(resString);

        //     // Deserialize SalesAreaDatastr (input data with multiple SalesGroup and SalesOffice entries)
        //     dynamic res_obj = JsonConvert.DeserializeObject(SalesAreaDatastr.ToString());

        //     // Initialize a list of sales area codes and sales office codes to check against
        //     List<(string SalesGroup, string SalesOffice)> CodeList = new List<(string, string)>();

        //     // Loop through each entry in SalesAreaDatastr to populate the CodeList
        //     for (int i = 0; i < res_obj.Count; i++)
        //     {
        //         string salesAreaCode = res_obj[i].SalesGroup.ToString(); // SalesArea_Code
        //         string salesOfficeCode = res_obj[i].SalesOffice.ToString(); // SalesOffice_Code

        //         CodeList.Add((salesAreaCode, salesOfficeCode)); // Add to the list for comparison
        //     }

        //     // Check if 'd' key exists in the jsonResponse
        //     if (jsonResponse.ContainsKey("d"))
        //     {
        //         var results = jsonResponse["d"]["results"];

        //         if (results != null)
        //         {
        //             // Create an XML document to store unmatched SalesArea data
        //             XDocument xmlDocument = new XDocument(new XElement("SalesArea"));

        //             // Loop through each result from the SAP response
        //             foreach (var result in results)
        //             {
        //                 string SalesGroup = result["SalesGroup"].ToString();
        //                 string SalesOffice = result["SalesOffice"].ToString();
        //                 string SalesOfficeName = result["SalesOfficeName"].ToString();

        //                 // Check if this SalesGroup and SalesOffice are present in the CodeList
        //                 bool matchFound = CodeList.Any(c => c.SalesGroup == SalesGroup && c.SalesOffice == SalesOffice);

        //                 // If no match found, add to XML document
        //                 if (!matchFound)
        //                 {
        //                     XElement SalesAreaData = new XElement("SalesAreaData",
        //                         new XElement("SalesGroup", SalesGroup),
        //                         new XElement("SalesOffice", SalesOffice),
        //                         new XElement("SalesOfficeName", SalesOfficeName)
        //                     );
        //                     xmlDocument.Root.Add(SalesAreaData); // Add the unmatched data to the XML
        //                 }
        //             }

        //             // If XML contains data, pass it to the stored procedure
        //             if (xmlDocument.Root.HasElements)
        //             {
        //                 var parameters = new DynamicParameters(new
        //                 {
        //                     var_Method_Name = method,
        //                     var_Org_Id = org_id,
        //                     var_XML_Data = xmlDocument
        //                 });

        //                 // Call stored procedure and return the output
        //                 var output = this.db.Query<CommonOutput>("USP_SAdminDealerSalesGroup_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        //                 return output;
        //             }
        //             else
        //             {
        //                 // No data to insert, return a success message or empty list
        //                 return new List<CommonOutput> { new CommonOutput { result_id = 0, result_description = "No unmatched data found" } };
        //             }
        //         }
        //     }
        //     else if (jsonResponse.ContainsKey("error"))
        //     {
        //         // Handle error case
        //         CommonOutput commonOutput = new CommonOutput
        //         {
        //             result_id = -1,
        //             result_description = jsonResponse["error"]["message"]["value"].ToString(),
        //             result_extra_key = jsonResponse["error"]["code"].ToString()
        //         };

        //         return new List<CommonOutput> { commonOutput };
        //     }
        //     else
        //     {
        //         // Handle case where no results are found
        //         CommonOutput commonOutput = new CommonOutput
        //         {
        //             result_id = -1,
        //             result_description = "Sales Area Not Getting From SAP",
        //             result_extra_key = ""
        //         };

        //         return new List<CommonOutput> { commonOutput };
        //     }

        //     return new List<CommonOutput>();
        // }

        public List<CommonOutput> SaveSAPSalesAreaItem(string method, string org_id, string resString)
        {

            JObject jsonResponse = JObject.Parse(resString);


            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                var rescount = results.Count();

                if (results != null)
                {


                    foreach (var result in results)
                    {

                        var xmlDocument = "";


                        String SalesOrganization = result["SalesOrganization"].ToString();
                        String DistributionChannel = result["DistributionChannel"].ToString();
                        String OrganizationDivision = result["OrganizationDivision"].ToString();
                        String SalesOffice = result["SalesOffice"].ToString();
                        String SalesGroup = result["SalesGroup"].ToString();
                        String SalesOrganizationName = result["SalesOrganizationName"].ToString();
                        String DistributionChannelName = result["DistributionChannelName"].ToString();
                        String DivisionName = result["DivisionName"].ToString();
                        String SalesOfficeName = result["SalesOfficeName"].ToString();


                        xmlDocument += "<SalesAreaData><SalesOrganization>" + SalesOrganization + "</SalesOrganization>" +
                                       "<DistributionChannel>" + DistributionChannel + "</DistributionChannel>" +
                                       "<OrganizationDivision>" + OrganizationDivision + "</OrganizationDivision>" +
                                       "<SalesOffice>" + SalesOffice + "</SalesOffice>" +
                                        "<SalesGroup>" + SalesGroup + "</SalesGroup>" +
                                       "<SalesOrganizationName>" + SalesOrganizationName + "</SalesOrganizationName>" +
                                       "<DistributionChannelName>" + DistributionChannelName + "</DistributionChannelName>" +
                                        "<DivisionName>" + DivisionName + "</DivisionName>" +
                                       "<SalesOfficeName>" + SalesOfficeName + "</SalesOfficeName></SalesAreaData>";

                        var XML_Data = "<SalesArea>" + xmlDocument + "</SalesArea>";

                        var parameters = new DynamicParameters(new
                        {
                            var_Method_Name = method,
                            var_Org_Id = org_id,
                            var_XML_Data = XML_Data
                        });



                        var output = this.db.Query<CommonOutput>("USP_SAdminSalesAreaItem_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



                    }


                    CommonOutput commonOutput = new CommonOutput
                    {
                        result_id = 1, // Assuming result_id is an integer
                        result_description = "Downloaded",
                        result_extra_key = ""
                    };

                    // Return the CommonOutput instance as a list with a single item
                    return new List<CommonOutput> { commonOutput };

                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Sales Area Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();

        }

        public int SAPApiLog(
      string method_name,
      string org_id,
      string transaction_name,
      object request_url,
      object request_body,
      string response_code,
      object response_body

      )
        {

            try
            {

                var parameters = new
                {
                    var_Method_Name = method_name,
                    var_Org_Id = org_id,
                    var_Transaction_Name = transaction_name,
                    var_Request_URL = request_url,
                    var_Request_Body = request_body,
                    var_Response_Code = response_code,
                    var_Response_Body = response_body,
                };

                string ReqParams = JsonConvert.SerializeObject(parameters);

                dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());


                //string destination_name = "";
                //return new CommonDAL(destination_name, configuration).RunDBQuery(inputParam, "USP_AdminSAPApiLog_Set");

                dynamic resObj = this.db.Query<dynamic>("USP_AdminSAPApiLog_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



                return 1;

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;


                return 1;
            }

        }

    }
}
