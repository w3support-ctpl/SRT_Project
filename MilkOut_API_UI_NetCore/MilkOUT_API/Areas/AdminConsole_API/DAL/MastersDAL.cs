using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class MastersDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public MastersDAL(string Destination)
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







        /*----  ----    ----    ----    Retailer - Send and receive data through API   ----    ----    ----    ----*/
        public List<CommonOutput> SaveRetailer(ReqRetailer retailerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = retailerSave.method_name,
                var_Org_Id = retailerSave.org_id,
                var_Retailer_Id = retailerSave.retailer_id,
                var_Retailer_Name = retailerSave.retailer_name,
                var_Dealer_Id = retailerSave.dealer_id,
                var_SalesArea_Id = retailerSave.salesarea_id,
                var_Route_Id = retailerSave.route_id,
                var_Mobile_No = retailerSave.mobile_no,
                var_Contact_Person = retailerSave.contact_person,
                var_Email_Id = retailerSave.email_id,
                var_Address_Line_1_Text = retailerSave.address_line_1_text,
                var_Address_Line_2_Text = retailerSave.address_line_2_text,
                var_Address_Line_3_Text = retailerSave.address_line_3_text,
                var_State_Id = retailerSave.state_id,
                var_District_Id = retailerSave.district_id,
                var_Taluka_Id = retailerSave.taluka_id,
                var_Pincode = retailerSave.pincode,
                var_Pan_No = retailerSave.pan_no,
                var_Bank_Id = retailerSave.bank_id,
                var_Branch_Id = retailerSave.branch_id,
                var_FSSAI_License_No = retailerSave.fssai_license_no,
                var_FSSAI_LicenseValidity_On = retailerSave.fssai_licensevalidity_on,
                var_GST_No = retailerSave.gst_no,
                var_AgreementValidityPeriod = retailerSave.agreement_validity_period,
                var_AgreementDoneFlag = retailerSave.is_agreement_done,
                var_Account_No = retailerSave.account_no,
                var_IFSC_Code = retailerSave.ifsc_code,
                var_Account_Name = retailerSave.account_name,
                var_Shop_License_No = retailerSave.shop_license_no,
                var_MSME = retailerSave.msme,
                var_Pan_Card_Photo = "",
                var_Shop_License_Photo = "",
                var_Cheque_Leaf_Photo = "",
                var_Shop_Name_Photo = "",
                var_UdyamAadhar_Card_Photo = "",
                var_FSSAI_License_Photo = "",
                var_GST_Certificate_Photo = "",
                var_User_Id = retailerSave.user_id,
                var_User_Name = retailerSave.user_name,
                var_Is_Active = retailerSave.is_active,
                var_Is_Deleted = retailerSave.is_deleted,
                var_Is_Approved = retailerSave.is_approved,

                var_Aadhar_No = retailerSave.aadhar_no,
                var_ASME = retailerSave.asme,
                var_Landline_Number = retailerSave.landline_number


            });
            return this.db.Query<CommonOutput>("USP_AdminRetailer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<ResRetailer> GetRetailer(ReqRetailer retailerSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = retailerSearch.method_name,
                var_Org_Id = retailerSearch.org_id,
                var_User_Id = retailerSearch.user_id,
                var_Retailer_Id = retailerSearch.retailer_id,
                var_Retailer_Name = retailerSearch.retailer_name,
                var_SalesArea_Id = retailerSearch.salesarea_id,
                var_Dealer_Id = retailerSearch.dealer_id

            });

            var result = this.db.Query<ResRetailer>("USP_AdminRetailer_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }







        /*----  ----    ----    ----    Dealer - Send and receive data through API   ----    ----    ----    ----*/
        public List<CommonOutput> SaveDealer(ReqDealer dealerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dealerSave.method_name,
                var_Org_Id = dealerSave.org_id,
                var_Dealer_Id = dealerSave.dealer_id,
                var_Dealer_Name = dealerSave.dealer_name,
                var_Dealer_Code = dealerSave.dealer_code,
                var_SalesArea_Id = dealerSave.salesarea_id,
                var_SalesUser_Id = dealerSave.salesuser_id,
                var_Mobile_No = dealerSave.mobile_no,
                var_Phone_No = dealerSave.phone_no,
                var_Contact_Person = dealerSave.contact_person,
                var_Email_Id = dealerSave.email_id,
                var_Address_Line_1_Text = dealerSave.address_line_1_text,
                var_Address_Line_2_Text = dealerSave.address_line_2_text,
                var_State_Id = dealerSave.state_id,
                var_District_Id = dealerSave.district_id,
                var_Taluka_Id = dealerSave.taluka_id,
                var_Pincode = dealerSave.pincode,
                var_Pan_No = dealerSave.pan_no,
                var_Bank_Id = dealerSave.bank_id,
                var_Branch_Id = dealerSave.branch_id,
                var_MSME_No = dealerSave.msme_no,
                var_FSSAI_License_No = dealerSave.fssai_license_no,
                var_FSSAI_LicenseValidity_On = dealerSave.fssai_licensevalidity_on,
                var_GST_No = dealerSave.gst_no,
                var_AgreementValidityPeriod = dealerSave.agreement_validity_period,
                var_AgreementDoneFlag = dealerSave.is_agreement_done,
                var_Account_No = dealerSave.account_no,
                var_IFSC_Code = dealerSave.ifsc_code,
                var_Account_Name = dealerSave.account_name,

                var_Profile_Photo = "",
                var_Pan_Card_Photo = "",
                var_Aadhar_Card_Photo = "",
                var_Shop_License_Photo = "",
                var_Cheque_Leaf_Photo = "",
                var_UdyamAadhar_Card_Photo = "",
                var_FSSAI_License_Photo = "",
                var_GST_Certificate_Photo = "",

                var_User_Id = dealerSave.user_id,
                var_User_Name = dealerSave.user_name,
                var_Is_Active = dealerSave.is_active,
                var_Is_Deleted = dealerSave.is_deleted,

                var_Shop_Latitude = dealerSave.shoplatitude,
                var_Shop_Longitude = dealerSave.shoplongitude,


                 var_Is_Payment = dealerSave.is_payment,
                var_Payment_Url = dealerSave.payment_url,
                 var_Login_Password = dealerSave.login_password

            });
            return this.db.Query<CommonOutput>("USP_AdminDealer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<ResDealer> GetDealer(ReqDealer dealerSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dealerSearch.method_name,
                var_Org_Id = dealerSearch.org_id,
                var_User_Id = dealerSearch.user_id,
                var_Dealer_Id = dealerSearch.dealer_id,
                var_Dealer_Code = dealerSearch.dealer_code,
                var_Dealer_Name = dealerSearch.dealer_name,
                var_SalesArea_Id = dealerSearch.salesarea_id
            });

            var result = this.db.Query<ResDealer>("USP_AdminDealer_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            return result;
        }

         public List<CommonOutput> SaveDealerSecurityDepositAmount(string org_id,string dealer_code,string SecurityDepositAmount)
        {
            var parameters = new DynamicParameters(new
            {
               var_Method_Name = "Update",
                var_Org_Id = org_id,
                var_Dealer_Code = dealer_code,
                var_SecurityDepositAmount = SecurityDepositAmount,

            });
            return this.db.Query<CommonOutput>("USP_SAdminDealerSecurityDepositAmount_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        /*----  ----    ----    ----    Sales Area - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResSalesGroup> GetSalesGroup(ReqSalesGroup salesAreaSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesAreaSearch.method_name,
                var_Org_Id = salesAreaSearch.org_id,
                var_Destination_name = salesAreaSearch.destination_name,
                var_SalesArea_Id = salesAreaSearch.salesarea_id,
                var_SalesArea_Code = salesAreaSearch.salesarea_code,
                var_SalesArea_Name = salesAreaSearch.salesarea_name,
                var_User_Id = salesAreaSearch.user_id
            });

            var result = this.db.Query<ResSalesGroup>("USP_AdminSalesArea_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveSalesGroup(ReqSalesGroup salesAreaSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesAreaSave.method_name,
                var_Org_Id = salesAreaSave.org_id,
                var_User_Id = salesAreaSave.user_id,
                var_Destination_name = salesAreaSave.destination_name,
                var_User_Name = salesAreaSave.user_name,
                var_SalesArea_Id = salesAreaSave.salesarea_id,
                var_SalesArea_Code = salesAreaSave.salesarea_code,
                var_SalesArea_Name = salesAreaSave.salesarea_name,
                var_Is_Active = salesAreaSave.is_active,
                var_Is_Deleted = salesAreaSave.is_deleted
            });

            return this.db.Query<CommonOutput>("USP_AdminSalesArea_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Sales User - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResSalesUser> GetSalesUser(ReqSalesUser salesUserSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesUserSearch.method_name,
                var_Org_Id = salesUserSearch.org_id,
                var_User_Id = salesUserSearch.user_id,
                var_SalesUser_Id = salesUserSearch.salesuser_id,
                var_Search_Text = salesUserSearch.search_text
            });

            var result = this.db.Query<ResSalesUser>("USP_SAdminSalesUser_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveSalesUser(ReqSalesUser salesUserSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesUserSave.method_name,
                var_Org_Id = salesUserSave.org_id,
                var_User_Id = salesUserSave.user_id,
                var_User_Name = salesUserSave.user_name,
                var_Is_Active = salesUserSave.is_active,
                var_Is_Deleted = salesUserSave.is_deleted,
                var_SalesUser_Id = salesUserSave.salesuser_id,
                var_SalesUser_Name = salesUserSave.salesuser_name,
                var_SalesUser_Code = "",
                var_SAP_BP_Partner_Code = salesUserSave.sap_bp_partner_code,
                var_Mobile_No = salesUserSave.mobile_no,
                var_Joining_Date = salesUserSave.joining_date,
                var_Email_Id = salesUserSave.email_id,
                var_ReportingTo_Id = salesUserSave.reportingto_id,
                var_SalesUserRole_Id = salesUserSave.salesuserrole_id,
                var_Pan_No = salesUserSave.pan_no,
                var_Aadhar_No = salesUserSave.aadhar_no,
                var_State_Id = salesUserSave.state_id,
                var_District_Id = salesUserSave.district_id,
                var_Taluka_Id = salesUserSave.taluka_id,
                var_Village_Id = salesUserSave.village_id,
                var_Address_Text = salesUserSave.address_text,
                var_Online_App_Flag = salesUserSave.online_app_flag,
                var_SalesEmployee = salesUserSave.salesemployee,
                var_SalesArea_Id = salesUserSave.salesarea_id,
                var_Login_Password = salesUserSave.login_password
            });

            return this.db.Query<CommonOutput>("USP_SAdminSalesUser_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }




        /*----  ----    ----    ----    Sales User ReOpen - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResSalesUserReOpen> GetSalesUserReOpen(ReqSalesUserReOpen salesUserReOpenSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesUserReOpenSearch.method_name,
                var_Org_Id = salesUserReOpenSearch.org_id,
                var_User_Id = salesUserReOpenSearch.user_id
            });

            var result = this.db.Query<ResSalesUserReOpen>("USP_SAdminDateReOpen_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveSalesUserReOpen(ReqSalesUserReOpen salesUserReOpenSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = salesUserReOpenSave.method_name,
                var_Org_Id = salesUserReOpenSave.org_id,
                var_User_Id = salesUserReOpenSave.user_id,
                var_User_Name = salesUserReOpenSave.user_name,
                var_Entry_Id = salesUserReOpenSave.entry_id
            });

            return this.db.Query<CommonOutput>("USP_SAdminDateReOpen_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Product Get & Save   ----    ----    ----    ----*/
        public List<ResProduct> GetProduct(ReqProduct productSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = productSearch.method_name,
                var_Org_Id = productSearch.org_id,
                var_Destination_name = productSearch.destination_name,
                var_Search_Text = productSearch.search_text,
                var_Product_Id = productSearch.product_id,
                var_User_Id = productSearch.user_id
            });

            return this.db.Query<ResProduct>("USP_SAdminProduct_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveProduct(ReqProduct productSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = productSave.method_name,
                var_Org_Id = productSave.org_id,
                var_Destination_name = productSave.destination_name,
                var_Search_Text = productSave.search_text,
                var_Product_Id = productSave.product_id,
                var_User_Id = productSave.user_id,
                var_User_Name = productSave.user_name,
                var_Is_Active = productSave.is_active,
                var_Is_Deleted = productSave.is_deleted,
                var_Photo = productSave.product_photo,
                var_ProductData = ""
            });

            return this.db.Query<CommonOutput>("USP_SAdminProduct_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*
        public List<CommonOutput> SaveSAPProductMaster(ReqProduct productSave)
        {

            var dynamic = new MasterSAP(ConnectionName).SaveProductMaster(productSave.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);

            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                if (results != null)
                {
                    XDocument xmlDocument = new XDocument(new XElement("Product"));
                    foreach (var result in results)
                    {
                        string productCode = result["Product"].ToString();
                        string productDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string productGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("ProductData",
                            new XElement("Product_Code", productCode),
                            new XElement("Product_Name", productDescription),
                            new XElement("Product_Group", productGroup),
                            new XElement("BaseUnit", baseUnit)
                        );

                        xmlDocument.Root.Add(productData);
                    }

                    var parameters = new DynamicParameters(new
                    {
                        var_Method_Name = productSave.method_name,
                        var_Org_Id = productSave.org_id,
                        var_Destination_name = productSave.destination_name,
                        var_Search_Text = productSave.search_text,
                        var_Product_Id = productSave.product_id,
                        var_User_Id = productSave.user_id,
                        var_User_Name = productSave.user_name,
                        var_Is_Active = productSave.is_active,
                        var_Is_Deleted = productSave.is_deleted,
                        var_Photo = productSave.product_photo,
                        var_ProductData = xmlDocument
                    });

                    return this.db.Query<CommonOutput>("USP_AdminProduct_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
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
        */


        public string SaveProductUOM(Reqproductuom productSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = productSave.method_name,
                var_Org_Id = productSave.org_id,
                var_xml_data = productSave.xml_data
            });

            dynamic resObj =  this.db.Query<dynamic>("USP_SAdmin_ProductUOM", parameters, commandType: CommandType.StoredProcedure).ToList();

            return JsonConvert.SerializeObject(resObj);
        }


              public string SaveProductXML(ReqProduct productSave)
        {
             var parameters = new DynamicParameters(new
            {
                var_Method_Name = productSave.method_name,
                var_Org_Id = productSave.org_id,
                var_Destination_name = productSave.destination_name,
                var_Search_Text = productSave.search_text,
                var_Product_Id = productSave.product_id,
                var_User_Id = productSave.user_id,
                var_User_Name = productSave.user_name,
                var_Is_Active = productSave.is_active,
                var_Is_Deleted = productSave.is_deleted,
                var_Photo = productSave.product_photo,
                var_ProductData = productSave.product_data
             });

            dynamic resObj =  this.db.Query<dynamic>("USP_SAdminProduct_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            return JsonConvert.SerializeObject(resObj);
            
        }




        /*----  ----    ----    ----    Role Get & Save   ----    ----    ----    ----*/
        public List<ResRole> GetRole(ReqRole roleSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = roleSearch.method_name,
                var_Org_Id = roleSearch.org_id,
                var_User_Id = roleSearch.user_id,
                var_Application_Id = roleSearch.application_id,
                var_Role_Id = roleSearch.role_id,
                var_Role_Name = roleSearch.role_name
            });

            var result = this.db.Query<ResRole>("USP_AdminRole_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveRole(ReqRole roleSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = roleSave.method_name,
                var_Org_Id = roleSave.org_id,
                var_User_Id = roleSave.user_id,
                var_Application_Id = roleSave.application_id,
                var_User_Name = roleSave.user_name,
                var_Is_Active = roleSave.is_active,
                var_Is_Deleted = roleSave.is_deleted,
                var_Role_Id = roleSave.role_id,
                var_Role_Name = roleSave.role_name,
                var_Role_Menu = roleSave.role_menu
            });

            return this.db.Query<CommonOutput>("USP_AdminRole_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    OfficeUsers Get & Save   ----    ----    ----    ----*/

        public List<ResOfficeUsers> GetOfficeUsers(ReqOfficeUsers userSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = userSearch.method_name,
                var_Org_Id = userSearch.org_id,
                var_Entry_User_Id = userSearch.user_id,
                var_User_Id = userSearch.officeuser_id,
                var_User_Name = userSearch.officeuser_name,
                var_Role_Id = userSearch.role_id
            });

            return this.db.Query<ResOfficeUsers>("USP_AdminUser_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveOfficeUsers(ReqOfficeUsers userSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = userSave.method_name,
                var_Org_Id = userSave.org_id,
                var_User_Id = userSave.officeuser_id,
                var_User_Name = userSave.officeuser_name,
                var_Joining_Date = userSave.joining_date,
                var_Mobile_No = userSave.mobile_no,
                var_Role_Id = userSave.role_id,
                var_Email_Id = userSave.email_id,
                var_Pan_No = userSave.pan_no,
                var_Aadhar_No = userSave.aadhar_no,
                var_Is_Active = userSave.is_active,
                var_Is_Deleted = userSave.is_deleted,
                var_CreatedBy_Id = userSave.user_id,
                var_CreatedBy_Name = userSave.user_name,
                var_Employee_Id = userSave.employee_id
            });

            return this.db.Query<CommonOutput>("USP_AdminUser_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        public List<CommonOutput> GetDealer(ReqRole roleSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = roleSave.method_name,
                var_Org_Id = roleSave.org_id,
                var_User_Id = roleSave.user_id,
                var_Application_Id = roleSave.application_id,
                var_User_Name = roleSave.user_name,
                var_Is_Active = roleSave.is_active,
                var_Is_Deleted = roleSave.is_deleted,
                var_Role_Id = roleSave.role_id,
                var_Role_Name = roleSave.role_name,
                var_Role_Menu = roleSave.role_menu
            });

            return this.db.Query<CommonOutput>("USP_AdminRole_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

         /*----  ----    ----    ----    Complaint Type Get & Save   ----    ----    ----    ----*/


        public List<ResComplaintType> GetComplaintType(ReqComplaintType complainttypeSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = complainttypeSearch.method_name,
                var_Org_Id = complainttypeSearch.org_id,
                var_ComplaintType_Id = complainttypeSearch.complainttype_id,
                var_User_Id = complainttypeSearch.user_id,
            });

            return this.db.Query<ResComplaintType>("USP_SAdminComplaintType_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveComplaintType(ReqComplaintType complainttypeSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = complainttypeSave.method_name,
                var_Org_Id = complainttypeSave.org_id,
                var_User_Id = complainttypeSave.user_id,
                var_User_Name = complainttypeSave.user_name,
                var_ComplaintType_Id = complainttypeSave.complainttype_id,
                var_ComplaintType_Name = complainttypeSave.complainttype_name,
            });

            return this.db.Query<CommonOutput>("USP_SAdminComplaintType_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        /*----  ----    ----    ----    Route - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResRouteSU> GetRouteSU(ReqRouteSU RouteSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = RouteSearch.method_name,
                var_Org_Id = RouteSearch.org_id,
                var_User_Id = RouteSearch.user_id,
                var_Route_Id = RouteSearch.route_id,
                var_Search_Text = RouteSearch.search_text
            });

            var result = this.db.Query<ResRouteSU>("USP_SAdminRoute_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveRouteSU(ReqRouteSU RouteSave)
        {
            // Following your reference style for creating parameters
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = RouteSave.method_name,
                var_Org_Id = RouteSave.org_id,
                var_Entry_Id = RouteSave.entry_id, // This is the Route_Id/Primary Key
                var_SalesArea_Id = RouteSave.salesarea_id,
                var_Dealer_Id = RouteSave.dealer_id,
                var_Route_Name = RouteSave.route_name,
                var_Retailer_List = RouteSave.retailer_list,
                var_Working_Status = RouteSave.working_status,
                var_Is_Active = RouteSave.is_active,
                var_Remarks = RouteSave.remarks,
                var_User_Id = RouteSave.user_id,
                var_User_Name = RouteSave.user_name
            });

            // Executing using the same pattern as your GetRouteSU
            var result = this.db.Query<CommonOutput>(
                "USP_SAdminRoute_Set",
                parameters,
                commandType: CommandType.StoredProcedure
            ).ToList();

            return result;
        }




    }

}
