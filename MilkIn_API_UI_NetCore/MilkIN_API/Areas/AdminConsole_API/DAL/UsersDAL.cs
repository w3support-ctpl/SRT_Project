using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MySqlX.XDevAPI.Common;
using Newtonsoft.Json;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class UsersDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        private string ConnectionName;

        public UsersDAL(string Destination)
        {
            //string ConnectionName;
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

        /*----  ----    ----    ----    Farmer Get & Save   ----    ----    ----    ----*/

        public List<ResFarmer> GetFarmer(ReqFarmer farmerSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSearch.method_name,
                var_Org_Id = farmerSearch.org_id,
                var_Farmer_Id = farmerSearch.farmer_id,
                var_Search_Text = farmerSearch.search_text,
                var_MCC_Id = farmerSearch.mcc_id,
                var_User_Id = farmerSearch.user_id
            });

            return this.db.Query<ResFarmer>("USP_AdminFarmer_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveFarmer(ReqFarmer farmerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSave.method_name,
                var_Org_Id = farmerSave.org_id,
                var_Farmer_Id = farmerSave.farmer_id,
                var_Farmer_Code = farmerSave.farmer_code,
                var_Farmer_Name = farmerSave.farmer_name,
                var_Birth_Date = farmerSave.birth_date,
                var_Mobile_No = farmerSave.mobile_no,
                var_Email_Id = farmerSave.email_id,
                var_Agent_Id = farmerSave.agent_id,
                var_MCC_Id = farmerSave.mcc_id,
                var_Pan_No = farmerSave.pan_no,
                var_Aadhar_No = farmerSave.aadhar_no,
                var_AlternateMobile_No = farmerSave.alternatemobile_no,
                var_Cow_Count = farmerSave.cow_count,
                var_Buffalo_Count = farmerSave.buffalo_count,
                var_Calf_Count = farmerSave.calf_count,
                var_Milk_Capacity = farmerSave.milk_capacity,
                var_State_Id = farmerSave.state_id,
                var_District_Id = farmerSave.district_id,
                var_Taluka_Id = farmerSave.taluka_id,
                var_Village_Id = farmerSave.village_id,
                var_Address_Text = farmerSave.address_text,
                var_Bank_Id = farmerSave.bank_id,
                var_Branch_Id = farmerSave.branch_id,
                var_Account_Name = farmerSave.account_name,
                var_Account_No = farmerSave.account_no,
                var_Nominee_Name = farmerSave.nominee_name,
                var_Nominee_Relation = farmerSave.nominee_relation,
                var_Nominee_Mobile_No = farmerSave.nomineemobile_no,
                var_Nominee_Aadhar_No = farmerSave.nomineeaadhar_no,
                var_Is_Active = farmerSave.is_active,
                var_Is_Deleted = farmerSave.is_deleted,
                var_Profile_Photo = "",
                var_Pan_Card_Photo = "",
                var_Aadhar_Card_Photo = "",
                var_Ration_Card_Photo = "",
                var_Bank_Cheque_PBook_Photo = "",
                var_CreatedBy_Id = farmerSave.user_id,
                var_CreatedBy_Name = farmerSave.user_name,
                var_MCC_Farmer_Code = farmerSave.mcc_farmer_code,
                var_WithholdingTaxType_Id = farmerSave.withholdingtaxtype_id,
                var_Gov_Farmer_Id = farmerSave.gov_farmer_id,
                var_Gov_Farmer_Name = farmerSave.gov_farmer_name,

            });
            if ( string.IsNullOrEmpty(farmerSave.farmer_code))
            {
                var SuccessResult = this.db.Query<CommonOutput>("USP_AdminFarmer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                var result_id = SuccessResult[0].result_id.ToString();
                if (result_id == "1" && farmerSave.method_name != "Delete")
                {


                    var Farmer_Id = SuccessResult[0].result_extra_key.ToString();

                    var parameterOrg = new DynamicParameters(new
                    {
                        var_Method_Name = "Get",
                        var_Org_Id = farmerSave.org_id,
                    }); 

                    var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

                    var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

                    ReqSAPBusinessParenerNew parameter = new ReqSAPBusinessParenerNew();

                    var parameterBusinessPartner = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartner",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    var parameterData = this.db.Query<ReqSAPBusinessParenerNew>("USP_AdminFarmer_Get", parameterBusinessPartner, commandType: CommandType.StoredProcedure).ToList();


                    parameter = parameterData[0];
                    //parameter.Org_Id = farmerSave.org_id;



                    var parameterBusinessPartnerAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddress",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress = this.db.Query<To_Businesspartneraddress>("USP_AdminFarmer_Get", parameterBusinessPartnerAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerEmailAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerEmailAddress",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_EmailAddress = this.db.Query<To_Emailaddress>("USP_AdminFarmer_Get", parameterBusinessPartnerEmailAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerMobilePhoneNumber = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerMobilePhoneNumber",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_MobilePhoneNumber = this.db.Query<To_Mobilephonenumber>("USP_AdminFarmer_Get", parameterBusinessPartnerMobilePhoneNumber, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerAddressUsage = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddressUsage",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_AddressUsage = this.db.Query<To_Addressusage>("USP_AdminFarmer_Get", parameterBusinessPartnerAddressUsage, commandType: CommandType.StoredProcedure).ToList();



                    //var parameterBusinessPartnerTax = new DynamicParameters(new
                    //{
                    //    var_Method_Name = "Get_BusinessPartnerTax",
                    //    var_Org_Id = farmerSave.org_id,
                    //    var_Farmer_Id = Farmer_Id,
                    //    var_Search_Text = "",
                    //    var_MCC_Id = "",
                    //    var_User_Id = ""
                    //});

                    //parameter.to_BusinessPartnerTax = this.db.Query<To_Businesspartnertax>("USP_AdminFarmer_Get", parameterBusinessPartnerTax, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerIdentification = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerIdentification",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BuPaIdentification = this.db.Query<To_Bupaidentification>("USP_AdminFarmer_Get", parameterBusinessPartnerIdentification, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerRole = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerRole",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerRole = this.db.Query<To_Businesspartnerrole>("USP_AdminFarmer_Get", parameterBusinessPartnerRole, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerBank = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerBank",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerBank = this.db.Query<To_Businesspartnerbank>("USP_AdminFarmer_Get", parameterBusinessPartnerBank, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerSupplier = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplier",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier = this.db.Query<To_Supplier>("USP_AdminFarmer_Get", parameterBusinessPartnerSupplier, commandType: CommandType.StoredProcedure).FirstOrDefault();


                    var parameterBusinessPartnerSupplierCompany = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplierCompany",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany = this.db.Query<To_Suppliercompany>("USP_AdminFarmer_Get", parameterBusinessPartnerSupplierCompany, commandType: CommandType.StoredProcedure).ToList();


                    var parameterSupplierWithHoldingTax = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_SupplierWithHoldingTax",
                        var_Org_Id = farmerSave.org_id,
                        var_Farmer_Id = Farmer_Id,
                        var_Search_Text = "",
                        var_MCC_Id = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany[0].to_SupplierWithHoldingTax = this.db.Query<To_SupplierWithHoldingTax>("USP_AdminFarmer_Get", parameterSupplierWithHoldingTax, commandType: CommandType.StoredProcedure).ToList();

                    var dynamic = new BusinessPartnerSAP(Connection_Name).SaveBusinessPartner(parameter, farmerSave.org_id);

                    JObject jsonResponse = JObject.Parse(dynamic);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        string BusinessPartner = jsonResponse["d"]["BusinessPartner"].ToString();


                        var parameterSet = new DynamicParameters(new
                        {
                            var_Method_Name = "UpdateFarmerCode",
                            var_Org_Id = farmerSave.org_id,
                            var_Farmer_Id = Farmer_Id,
                            var_Farmer_Code = BusinessPartner,
                            var_Farmer_Name = farmerSave.farmer_name,
                            var_Birth_Date = farmerSave.birth_date,
                            var_Mobile_No = farmerSave.mobile_no,
                            var_Email_Id = farmerSave.email_id,
                            var_Agent_Id = farmerSave.agent_id,
                            var_MCC_Id = farmerSave.mcc_id,
                            var_Pan_No = farmerSave.pan_no,
                            var_Aadhar_No = farmerSave.aadhar_no,
                            var_AlternateMobile_No = farmerSave.alternatemobile_no,
                            var_Cow_Count = farmerSave.cow_count,
                            var_Buffalo_Count = farmerSave.buffalo_count,
                            var_Calf_Count = farmerSave.calf_count,
                            var_Milk_Capacity = farmerSave.milk_capacity,
                            var_State_Id = farmerSave.state_id,
                            var_District_Id = farmerSave.district_id,
                            var_Taluka_Id = farmerSave.taluka_id,
                            var_Village_Id = farmerSave.village_id,
                            var_Address_Text = farmerSave.address_text,
                            var_Bank_Id = farmerSave.bank_id,
                            var_Branch_Id = farmerSave.branch_id,
                            var_Account_Name = farmerSave.account_name,
                            var_Account_No = farmerSave.account_no,
                            var_Nominee_Name = farmerSave.nominee_name,
                            var_Nominee_Relation = farmerSave.nominee_relation,
                            var_Nominee_Mobile_No = farmerSave.nomineemobile_no,
                            var_Nominee_Aadhar_No = farmerSave.nomineeaadhar_no,
                            var_Is_Active = farmerSave.is_active,
                            var_Is_Deleted = farmerSave.is_deleted,
                            var_Profile_Photo = "",
                            var_Pan_Card_Photo = "",
                            var_Aadhar_Card_Photo = "",
                            var_Ration_Card_Photo = "",
                            var_Bank_Cheque_PBook_Photo = "",
                            var_CreatedBy_Id = farmerSave.user_id,
                            var_CreatedBy_Name = farmerSave.user_name,
                            var_MCC_Farmer_Code = farmerSave.mcc_farmer_code,
                            var_WithholdingTaxType_Id = farmerSave.withholdingtaxtype_id,
                            var_Gov_Farmer_Id = farmerSave.gov_farmer_id,
                            var_Gov_Farmer_Name = farmerSave.gov_farmer_name,
                        });

                        return this.db.Query<CommonOutput>("USP_AdminFarmer_Set", parameterSet, commandType: CommandType.StoredProcedure).ToList();

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = 2, // Assuming result_id is an integer
                            result_description = jsonResponse["error"]["message"]["value"].ToString(),
                            result_extra_key = Farmer_Id
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };
                    }
                    else
                    {

                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = -1, // Assuming result_id is an integer
                            result_description = "Farmer Not Created In SAP",
                            result_extra_key = ""
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };


                    }

                    return new List<CommonOutput>();

                    

                }


                return SuccessResult;

            }


            return this.db.Query<CommonOutput>("USP_AdminFarmer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

        }

        /*----  ----    ----    ----    Agent Get & Save   ----    ----    ----    ----*/

        public List<ResAgent> GetAgent(ReqAgent agentSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentSearch.method_name,
                var_Org_Id = agentSearch.org_id,
                var_Agent_Id = agentSearch.agent_id,
                var_Search_Text = agentSearch.search_text,
                var_User_Id = agentSearch.user_id
            });

            return this.db.Query<ResAgent>("USP_AdminAgent_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveAgent(ReqAgent agentSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentSave.method_name,
                var_Org_Id = agentSave.org_id,
                var_Agent_Id = agentSave.agent_id,
                var_Agent_Name = agentSave.agent_name,
                var_Birth_Date = agentSave.birth_date,
                var_Mobile_No = agentSave.mobile_no,
                var_Joining_Date = agentSave.joining_date,
                var_Pan_No = agentSave.pan_no,
                var_Aadhar_No = agentSave.aadhar_no,
                var_State_Id = agentSave.state_id,
                var_District_Id = agentSave.district_id,
                var_Taluka_Id = agentSave.taluka_id,
                var_Village_Id = agentSave.village_id,
                var_Address_Text = agentSave.address_text,
                var_Is_Active = agentSave.is_active,
                var_Is_Deleted = agentSave.is_deleted,
                var_Online_App_Flag = agentSave.onlineapp_flag,
                var_Profile_Photo = "",
                var_Pan_Card_Photo = "",
                var_Aadhar_Card_Photo = "",
                var_CreatedBy_Id = agentSave.user_id,
                var_CreatedBy_Name = agentSave.user_name,
                var_Email_Id = agentSave.email_id,
            });

            return this.db.Query<CommonOutput>("USP_AdminAgent_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Driver Get & Save   ----    ----    ----    ----*/

        public List<ResDriver> GetDriver(ReqDriver driverSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = driverSearch.method_name,
                var_Org_Id = driverSearch.org_id,
                var_Driver_Id = driverSearch.driver_id,
                var_Search_Text = driverSearch.search_text,
                var_DriverType_Id = driverSearch.drivertype_id,
                var_User_Id = driverSearch.user_id
            });

            return this.db.Query<ResDriver>("USP_AdminDriver_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveDriver(ReqDriver driverSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = driverSave.method_name,
                var_Org_Id = driverSave.org_id,
                var_Driver_Id = driverSave.driver_id,
                var_Driver_Name = driverSave.driver_name,
                var_Birth_Date = driverSave.birth_date,
                var_Mobile_No = driverSave.mobile_no,
                var_Joining_Date = driverSave.joining_date,
                var_DriverType_Id = driverSave.drivertype_id,
                var_DrivingLicense_No = driverSave.license_no,
                var_Pan_No = driverSave.pan_no,
                var_Aadhar_No = driverSave.aadhar_no,
                var_Is_Active = driverSave.is_active,
                var_Is_Deleted = driverSave.is_deleted,
                var_Online_App_Flag = driverSave.onlineapp_flag,
                var_CreatedBy_Id = driverSave.user_id,
                var_CreatedBy_Name = driverSave.user_name
            });

            return this.db.Query<CommonOutput>("USP_AdminDriver_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Chemist Get & Save   ----    ----    ----    ----*/

        public List<ResChemist> GetChemist(ReqChemist chemistSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = chemistSearch.method_name,
                var_Org_Id = chemistSearch.org_id,
                var_Chemist_Id = chemistSearch.chemist_id,
                var_Search_Text = chemistSearch.search_text,
                var_User_Id = chemistSearch.user_id
            });

            return this.db.Query<ResChemist>("USP_AdminChemist_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveChemist(ReqChemist chemistSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = chemistSave.method_name,
                var_Org_Id = chemistSave.org_id,
                var_Chemist_Code = chemistSave.chemist_code,
                var_Chemist_Id = chemistSave.chemist_id,
                var_Chemist_Name = chemistSave.chemist_name,
                var_Birth_Date = chemistSave.birth_date,
                var_Mobile_No = chemistSave.mobile_no,
                var_Joining_Date = chemistSave.joining_date,
                var_Pan_No = chemistSave.pan_no,
                var_Aadhar_No = chemistSave.aadhar_no,
                var_Is_Active = chemistSave.is_active,
                var_Is_Deleted = chemistSave.is_deleted,
                var_CreatedBy_Id = chemistSave.user_id,
                var_CreatedBy_Name = chemistSave.user_name,
                var_Online_App_Flag = chemistSave.onlineapp_flag,
            });

            return this.db.Query<CommonOutput>("USP_AdminChemist_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    User Get & Save   ----    ----    ----    ----*/

        public List<ResUser> GetUser(ReqUser userSearch)
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

            return this.db.Query<ResUser>("USP_AdminUser_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveUser(ReqUser userSave)
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

        public List<CommonOutput> SavePassword(ReqChangePassword userPassword)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "UpdatePassword",
                var_Org_Id = userPassword.org_id,
                var_User_Id = userPassword.user_id,
                var_User_Name = userPassword.current_password,
                var_Joining_Date = "2024-04-02",
                var_Mobile_No = "",
                var_Role_Id = "",
                var_Email_Id = userPassword.new_password,
                var_Pan_No = "",
                var_Aadhar_No = "",
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_CreatedBy_Id = userPassword.user_id,
                var_CreatedBy_Name = userPassword.user_name,
                var_Employee_Id = ""
            });

            return this.db.Query<CommonOutput>("USP_AdminUser_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<ResUser> GetUserMaster()
        {
            return this.db.Query<ResUser>(
                "USP_AdminUserMaster_Get",
                commandType: CommandType.StoredProcedure
            ).ToList();
        }
    }
}
