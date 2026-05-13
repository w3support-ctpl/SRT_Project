using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Xml.Linq;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
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







        /*----  ----    ----    ----    MCC Get & Save   ----    ----    ----    ----*/
        public List<ResMCC> GetMCC(ReqMCC mccSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccSearch.method_name,
                var_Org_Id = mccSearch.org_id,
                var_User_Id = mccSearch.user_id,
                var_MCC_Id = mccSearch.mcc_id,
                var_Search_Text = mccSearch.search_text
            });

            return this.db.Query<ResMCC>("USP_AdminMCC_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMCC(ReqMCC mccSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccSave.method_name,
                var_Org_Id = mccSave.org_id,
                var_User_Id = mccSave.user_id,
                var_User_Name = mccSave.user_name,
                var_MCC_Id = mccSave.mcc_id,
                var_MCC_Code = mccSave.mcc_code,
                var_MCC_Name = mccSave.mcc_name,
                var_MCCCategory_Id = mccSave.mcccategory_id,
                var_MCCType_Id = mccSave.mcctype_id,
                var_Agent_Id = mccSave.agent_id,
                var_Mobile_No = mccSave.mobile_no,
                var_State_Id = mccSave.state_id,
                var_District_Id = mccSave.district_id,
                var_Taluka_Id = mccSave.taluka_id,
                var_Village_Id = mccSave.village_id,
                var_Address_Text = mccSave.address_text,
                var_Bank_Id = mccSave.bank_id,
                var_Branch_Id = mccSave.branch_id,
                var_Account_Name = mccSave.account_name,
                var_Account_No = mccSave.account_no,
                var_IFSC_Code = mccSave.ifsc_code,
                var_MusterType_Id = mccSave.mustertype_id,
                var_MCCWorkType_Id = mccSave.mccworktype_id,
                var_PaymentCycle_Id = mccSave.paymentcycle_id,
                var_MilkType_Id = mccSave.milktype_id,
                var_CollectionShift_Id = mccSave.collectionshift_id,
                var_FSSAILicense_No = mccSave.fssailicense_no,
                var_FSSAILicenseValidity_On = mccSave.fssailicensevalidity_on,
                var_Latitude = mccSave.latitude,
                var_Longitude = mccSave.longitude,
                var_PaymentType_Id = mccSave.paymenttype_id,
                var_Is_Active = mccSave.is_active,
                var_Is_Deleted = mccSave.is_deleted,
                var_Profile_Photo = "",
                var_Pan_Card_Photo = "",
                var_FSSAILicense_Photo = "",
                var_DateCheck = 1,
                var_Is_ManualWeight = mccSave.is_manualweight,
                var_Is_ManualQuality = mccSave.is_manualquality,
                var_Is_ManualShiftEnd = mccSave.is_manualshiftend,
                var_Pan_No = mccSave.pan_no,
                var_Anamat = mccSave.anamat,
                var_Freight = mccSave.freight,
                var_Anamat_TDS = mccSave.anamat_tds,
                var_Freight_TDS = mccSave.freight_tds,
                var_Rebate = mccSave.rebate,
                var_WithholdingTaxType_Id = mccSave.withholdingtaxtype_id,
                var_Plant_Code = mccSave.plant_code,
                var_Is_Alternate = mccSave.alternate,
            });

            if (string.IsNullOrEmpty(mccSave.mcc_code))
            {
                var SuccessResult = this.db.Query<CommonOutput>("USP_AdminMCC_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                var result_id = SuccessResult[0].result_id.ToString();
                if (result_id == "1")
                {

                    var MCC_Id = SuccessResult[0].result_extra_key.ToString();

                    var parameterOrg = new DynamicParameters(new
                    {
                        var_Method_Name = "Get",
                        var_Org_Id = mccSave.org_id,
                    });

                    var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

                    var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

                    ReqSAPBusinessPartner parameter = new ReqSAPBusinessPartner();

                    var parameterBusinessPartner = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartner",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    var parameterData = this.db.Query<ReqSAPBusinessPartner>("USP_AdminMCC_Get", parameterBusinessPartner, commandType: CommandType.StoredProcedure).ToList();


                    parameter = parameterData[0];


                    var parameterBusinessPartnerAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddress",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress = this.db.Query<To_Businesspartneraddress>("USP_AdminMCC_Get", parameterBusinessPartnerAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerEmailAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerEmailAddress",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_EmailAddress = this.db.Query<To_Emailaddress>("USP_AdminMCC_Get", parameterBusinessPartnerEmailAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerMobilePhoneNumber = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerMobilePhoneNumber",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_MobilePhoneNumber = this.db.Query<To_Mobilephonenumber>("USP_AdminMCC_Get", parameterBusinessPartnerMobilePhoneNumber, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerAddressUsage = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddressUsage",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_AddressUsage = this.db.Query<To_Addressusage>("USP_AdminMCC_Get", parameterBusinessPartnerAddressUsage, commandType: CommandType.StoredProcedure).ToList();



                    //var parameterBusinessPartnerTax = new DynamicParameters(new
                    //{
                    //    var_Method_Name = "Get_BusinessPartnerTax",
                    //    var_Org_Id = mccSave.org_id,
                    //    var_MCC_Id = MCC_Id,
                    //    var_Search_Text = "",
                    //    var_User_Id = ""
                    //});

                    //parameter.to_BusinessPartnerTax = this.db.Query<To_Businesspartnertax>("USP_AdminMCC_Get", parameterBusinessPartnerTax, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerIdentification = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerIdentification",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BuPaIdentification = this.db.Query<To_Bupaidentification>("USP_AdminMCC_Get", parameterBusinessPartnerIdentification, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerRole = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerRole",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerRole = this.db.Query<To_Businesspartnerrole>("USP_AdminMCC_Get", parameterBusinessPartnerRole, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerBank = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerBank",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerBank = this.db.Query<To_Businesspartnerbank>("USP_AdminMCC_Get", parameterBusinessPartnerBank, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerSupplier = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplier",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier = this.db.Query<To_Supplier>("USP_AdminMCC_Get", parameterBusinessPartnerSupplier, commandType: CommandType.StoredProcedure).FirstOrDefault();


                    var parameterBusinessPartnerSupplierCompany = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplierCompany",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany = this.db.Query<To_Suppliercompany>("USP_AdminMCC_Get", parameterBusinessPartnerSupplierCompany, commandType: CommandType.StoredProcedure).ToList();


                    var parameterSupplierWithHoldingTax = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_SupplierWithHoldingTax",
                        var_Org_Id = mccSave.org_id,
                        var_MCC_Id = MCC_Id,
                        var_Search_Text = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany[0].to_SupplierWithHoldingTax = this.db.Query<To_SupplierWithHoldingTax>("USP_AdminMCC_Get", parameterSupplierWithHoldingTax, commandType: CommandType.StoredProcedure).ToList();


                    var dynamic = new BusinessPartnerSAP(Connection_Name).SaveBusinessPartner(parameter, mccSave.org_id);

                    JObject jsonResponse = JObject.Parse(dynamic);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        string BusinessPartner = jsonResponse["d"]["BusinessPartner"].ToString();

                        var parametersSet = new DynamicParameters(new
                        {
                            var_Method_Name = "UpdateMCCCode",
                            var_Org_Id = mccSave.org_id,
                            var_User_Id = mccSave.user_id,
                            var_User_Name = mccSave.user_name,
                            var_MCC_Id = MCC_Id,
                            var_MCC_Code = BusinessPartner,
                            var_MCC_Name = mccSave.mcc_name,
                            var_MCCCategory_Id = mccSave.mcccategory_id,
                            var_MCCType_Id = mccSave.mcctype_id,
                            var_Agent_Id = mccSave.agent_id,
                            var_Mobile_No = mccSave.mobile_no,
                            var_State_Id = mccSave.state_id,
                            var_District_Id = mccSave.district_id,
                            var_Taluka_Id = mccSave.taluka_id,
                            var_Village_Id = mccSave.village_id,
                            var_Address_Text = mccSave.address_text,
                            var_Bank_Id = mccSave.bank_id,
                            var_Branch_Id = mccSave.branch_id,
                            var_Account_Name = mccSave.account_name,
                            var_Account_No = mccSave.account_no,
                            var_IFSC_Code = mccSave.ifsc_code,
                            var_MusterType_Id = mccSave.mustertype_id,
                            var_MCCWorkType_Id = mccSave.mccworktype_id,
                            var_PaymentCycle_Id = mccSave.paymentcycle_id,
                            var_MilkType_Id = mccSave.milktype_id,
                            var_CollectionShift_Id = mccSave.collectionshift_id,
                            var_FSSAILicense_No = mccSave.fssailicense_no,
                            var_FSSAILicenseValidity_On = mccSave.fssailicensevalidity_on,
                            var_Latitude = mccSave.latitude,
                            var_Longitude = mccSave.longitude,
                            var_PaymentType_Id = mccSave.paymenttype_id,
                            var_Is_Active = mccSave.is_active,
                            var_Is_Deleted = mccSave.is_deleted,
                            var_Profile_Photo = "",
                            var_Pan_Card_Photo = "",
                            var_FSSAILicense_Photo = "",
                            var_DateCheck = 1,
                            var_Is_ManualWeight = mccSave.is_manualweight,
                            var_Is_ManualQuality = mccSave.is_manualquality,
                            var_Is_ManualShiftEnd = mccSave.is_manualshiftend,
                            var_Pan_No = mccSave.pan_no,
                            var_Anamat = mccSave.anamat,
                            var_Freight = mccSave.freight,
                            var_Anamat_TDS = mccSave.anamat_tds,
                            var_Freight_TDS = mccSave.freight_tds,
                            var_Rebate = mccSave.rebate,
                            var_WithholdingTaxType_Id = mccSave.withholdingtaxtype_id,
                            var_Plant_Code = mccSave.plant_code,
                            var_Is_Alternate = mccSave.alternate,
                        });

                        return this.db.Query<CommonOutput>("USP_AdminMCC_Set", parametersSet, commandType: CommandType.StoredProcedure).ToList();


                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = 2, // Assuming result_id is an integer
                            result_description = jsonResponse["error"]["message"]["value"].ToString(),
                            result_extra_key = MCC_Id
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };
                    }
                    else
                    {

                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = -1, // Assuming result_id is an integer
                            result_description = "MCC Not Created In SAP",
                            result_extra_key = ""
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };


                    }

                    return new List<CommonOutput>();


                }


                return SuccessResult;

            }



            var result = this.db.Query<CommonOutput>("USP_AdminMCC_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }







        /*----  ----    ----    ----    Payment Settings Get & Save   ----    ----    ----    ----*/
        public List<ResPaymentSettings> GetPaymentSettings(ReqPaymentSettings paymentSettingsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = paymentSettingsSearch.method_name,
                var_Org_Id = paymentSettingsSearch.org_id,
                var_User_Id = paymentSettingsSearch.user_id,
                var_MCC_Id = paymentSettingsSearch.mcc_id,
                var_Version_No = paymentSettingsSearch.version_no
            });

            return this.db.Query<ResPaymentSettings>("USP_AdminMCCVersion_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SavePaymentSettings(ReqPaymentSettings paymentSettingsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = paymentSettingsSave.method_name,
                var_Org_Id = paymentSettingsSave.org_id,
                var_User_Id = paymentSettingsSave.user_id,
                var_User_Name = paymentSettingsSave.user_name,
                var_MCC_Id = paymentSettingsSave.mcc_id,
                var_Version_No = paymentSettingsSave.version_no,
                var_MusterType_Id = paymentSettingsSave.mustertype_id,
                var_PaymentCycle_Id = paymentSettingsSave.paymentcycle_id,
                var_MilkType_Id = paymentSettingsSave.milktype_id,
                var_CollectionShift_Id = paymentSettingsSave.collectionshift_id,
                var_Is_Active = paymentSettingsSave.is_active,
                var_Is_Deleted = paymentSettingsSave.is_deleted,
                var_Applicable_Date = paymentSettingsSave.applicable_date,
                var_To_Date = paymentSettingsSave.to_date,
                var_DateCheck = 1,
                var_Anamat = paymentSettingsSave.anamat,
                var_Freight = paymentSettingsSave.freight,
                var_Anamat_TDS = paymentSettingsSave.anamat_tds,
                var_Freight_TDS = paymentSettingsSave.freight_tds,
                var_Rebate = paymentSettingsSave.rebate,

            });

            return this.db.Query<CommonOutput>("USP_AdminMCCVersion_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }








        /*----  ----    ----    ----    Transporter Get & Save   ----    ----    ----    ----*/

        public List<ResTransporter> GetTransporter(ReqTransporter transporterSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = transporterSearch.method_name,
                var_Org_Id = transporterSearch.org_id,
                var_User_Id = transporterSearch.user_id,
                var_Transporter_Name = transporterSearch.transporter_name,
                var_Transporter_Id = transporterSearch.transporter_id
            });

            return this.db.Query<ResTransporter>("USP_AdminTransporter_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveTransporter(ReqTransporter transporterSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = transporterSave.method_name,
                var_Org_Id = transporterSave.org_id,
                var_User_Id = transporterSave.user_id,
                var_User_Name = transporterSave.user_name,
                var_Transporter_Id = transporterSave.transporter_id,
                var_Transporter_Code = transporterSave.transporter_code,
                var_Transporter_Name = transporterSave.transporter_name,
                var_ContactPerson_Name = transporterSave.contactperson_name,
                var_Mobile_No = transporterSave.mobile_no,
                var_State_Id = transporterSave.state_id,
                var_District_Id = transporterSave.district_id,
                var_Taluka_Id = transporterSave.taluka_id,
                var_Village_Id = transporterSave.village_id,
                var_Address_Text = transporterSave.address_text,
                var_Bank_Id = transporterSave.bank_id,
                var_Branch_Id = transporterSave.branch_id,
                var_Account_Name = transporterSave.account_name,
                var_Account_No = transporterSave.account_no,
                var_IFSC_Code = transporterSave.ifsc_code,
                var_Company_Pan_No = transporterSave.company_pan_no,
                var_FSSAI_License_No = transporterSave.fssai_license_no,
                var_LicenseValidity_On = transporterSave.licensevalidity_on,
                var_Is_Active = transporterSave.is_active,
                var_Is_Deleted = transporterSave.is_deleted,
                var_Pan_Card_Photo = "",
                var_Aadhar_Card_Photo = "",
                var_Profile_Photo = "",
                var_Company_Pan_Card_Photo = "",
                var_FSSAI_License_Photo = "",
                var_WithholdingTaxType_Id = transporterSave.withholdingtaxtype_id,

            });

            if (string.IsNullOrEmpty(transporterSave.transporter_code))
            {
                var SuccessResult = this.db.Query<CommonOutput>("USP_AdminTransporter_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                var result_id = SuccessResult[0].result_id.ToString();
                if (result_id == "1")
                {

                    var Transporter_Id = SuccessResult[0].result_extra_key.ToString();

                    var parameterOrg = new DynamicParameters(new
                    {
                        var_Method_Name = "Get",
                        var_Org_Id = transporterSave.org_id,
                    });

                    var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

                    var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

                    ReqSAPBusinessPartner parameter = new ReqSAPBusinessPartner();

                    var parameterBusinessPartner = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartner",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    var parameterData = this.db.Query<ReqSAPBusinessPartner>("USP_AdminTransporter_Get", parameterBusinessPartner, commandType: CommandType.StoredProcedure).ToList();


                    parameter = parameterData[0];


                    var parameterBusinessPartnerAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddress",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress = this.db.Query<To_Businesspartneraddress>("USP_AdminTransporter_Get", parameterBusinessPartnerAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerEmailAddress = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerEmailAddress",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_EmailAddress = this.db.Query<To_Emailaddress>("USP_AdminTransporter_Get", parameterBusinessPartnerEmailAddress, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerMobilePhoneNumber = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerMobilePhoneNumber",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_MobilePhoneNumber = this.db.Query<To_Mobilephonenumber>("USP_AdminTransporter_Get", parameterBusinessPartnerMobilePhoneNumber, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerAddressUsage = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerAddressUsage",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerAddress[0].to_AddressUsage = this.db.Query<To_Addressusage>("USP_AdminTransporter_Get", parameterBusinessPartnerAddressUsage, commandType: CommandType.StoredProcedure).ToList();



                    //var parameterBusinessPartnerTax = new DynamicParameters(new
                    //{
                    //    var_Method_Name = "Get_BusinessPartnerTax",
                    //    var_Org_Id = transporterSave.org_id,
                    //    var_Transporter_Id = Transporter_Id,
                    //    var_Transporter_Name = "",
                    //    var_User_Id = ""
                    //});

                    //parameter.to_BusinessPartnerTax = this.db.Query<To_Businesspartnertax>("USP_AdminTransporter_Get", parameterBusinessPartnerTax, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerIdentification = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerIdentification",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BuPaIdentification = this.db.Query<To_Bupaidentification>("USP_AdminTransporter_Get", parameterBusinessPartnerIdentification, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerRole = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerRole",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerRole = this.db.Query<To_Businesspartnerrole>("USP_AdminTransporter_Get", parameterBusinessPartnerRole, commandType: CommandType.StoredProcedure).ToList();

                    var parameterBusinessPartnerBank = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerBank",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_BusinessPartnerBank = this.db.Query<To_Businesspartnerbank>("USP_AdminTransporter_Get", parameterBusinessPartnerBank, commandType: CommandType.StoredProcedure).ToList();


                    var parameterBusinessPartnerSupplier = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplier",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier = this.db.Query<To_Supplier>("USP_AdminTransporter_Get", parameterBusinessPartnerSupplier, commandType: CommandType.StoredProcedure).FirstOrDefault();


                    var parameterBusinessPartnerSupplierCompany = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_BusinessPartnerSupplierCompany",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany = this.db.Query<To_Suppliercompany>("USP_AdminTransporter_Get", parameterBusinessPartnerSupplierCompany, commandType: CommandType.StoredProcedure).ToList();


                    var parameterSupplierWithHoldingTax = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_SupplierWithHoldingTax",
                        var_Org_Id = transporterSave.org_id,
                        var_Transporter_Id = Transporter_Id,
                        var_Transporter_Name = "",
                        var_User_Id = ""
                    });

                    parameter.to_Supplier.to_SupplierCompany[0].to_SupplierWithHoldingTax = this.db.Query<To_SupplierWithHoldingTax>("USP_AdminTransporter_Get", parameterSupplierWithHoldingTax, commandType: CommandType.StoredProcedure).ToList();


                    var dynamic = new BusinessPartnerSAP(Connection_Name).SaveBusinessPartner(parameter, transporterSave.org_id);

                    JObject jsonResponse = JObject.Parse(dynamic);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        string BusinessPartner = jsonResponse["d"]["BusinessPartner"].ToString();



                        var parametersSet = new DynamicParameters(new
                        {
                            var_Method_Name = "UpdateTransporterCode",
                            var_Org_Id = transporterSave.org_id,
                            var_User_Id = transporterSave.user_id,
                            var_User_Name = transporterSave.user_name,
                            var_Transporter_Id = Transporter_Id,
                            var_Transporter_Code = BusinessPartner,
                            var_Transporter_Name = transporterSave.transporter_name,
                            var_ContactPerson_Name = transporterSave.contactperson_name,
                            var_Mobile_No = transporterSave.mobile_no,
                            var_State_Id = transporterSave.state_id,
                            var_District_Id = transporterSave.district_id,
                            var_Taluka_Id = transporterSave.taluka_id,
                            var_Village_Id = transporterSave.village_id,
                            var_Address_Text = transporterSave.address_text,
                            var_Bank_Id = transporterSave.bank_id,
                            var_Branch_Id = transporterSave.branch_id,
                            var_Account_Name = transporterSave.account_name,
                            var_Account_No = transporterSave.account_no,
                            var_IFSC_Code = transporterSave.ifsc_code,
                            var_Company_Pan_No = transporterSave.company_pan_no,
                            var_FSSAI_License_No = transporterSave.fssai_license_no,
                            var_LicenseValidity_On = transporterSave.licensevalidity_on,
                            var_Is_Active = transporterSave.is_active,
                            var_Is_Deleted = transporterSave.is_deleted,
                            var_Pan_Card_Photo = "",
                            var_Aadhar_Card_Photo = "",
                            var_Profile_Photo = "",
                            var_Company_Pan_Card_Photo = "",
                            var_FSSAI_License_Photo = "",
                            var_WithholdingTaxType_Id = transporterSave.withholdingtaxtype_id,

                        });

                        return this.db.Query<CommonOutput>("USP_AdminTransporter_Set", parametersSet, commandType: CommandType.StoredProcedure).ToList();


                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = 2, // Assuming result_id is an integer
                            result_description = jsonResponse["error"]["message"]["value"].ToString(),
                            result_extra_key = Transporter_Id
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };
                    }
                    else
                    {

                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = -1, // Assuming result_id is an integer
                            result_description = "Transporter Not Created In SAP",
                            result_extra_key = ""
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };


                    }

                    return new List<CommonOutput>();

                    // return this.db.Query<CommonOutput>("USP_AdminTransporter_Set", parametersSet, commandType: CommandType.StoredProcedure).ToList();
                }


                return SuccessResult;

            }



            return this.db.Query<CommonOutput>("USP_AdminTransporter_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }








        /*----  ----    ----    ----    Vehicle Get & Save   ----    ----    ----    ----*/
        public List<ResVehicle> GetVehicle(ReqVehicle vehicleSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = vehicleSearch.method_name,
                var_Org_Id = vehicleSearch.org_id,
                var_Vehicle_No = vehicleSearch.vehicle_no,
                var_VehicleOwnershipType_Id = vehicleSearch.vehicleownershiptype_id,
                var_Vehicle_Id = vehicleSearch.vehicle_id,
                var_User_Id = vehicleSearch.user_id
            });

            var result = this.db.Query<ResVehicle>("USP_AdminVehicle_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveVehicle(ReqVehicle vehicleSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = vehicleSave.method_name,
                var_Org_Id = vehicleSave.org_id,
                var_User_Id = vehicleSave.user_id,
                var_User_Name = vehicleSave.user_name,
                var_Vehicle_Id = vehicleSave.vehicle_id,
                var_Vehicle_No = vehicleSave.vehicle_no,
                var_VehicleMake_Id = vehicleSave.vehiclemake_id,
                var_VehicleType_Id = vehicleSave.vehicletype_id,
                var_Chassis_No = vehicleSave.chassis_no,
                var_Owner_Name = vehicleSave.ownername,
                var_VehicleOwnershipType_Id = vehicleSave.vehicleownershiptype_id,
                var_Transporter_Id = vehicleSave.transporter_id,
                var_Capacity_In_KG = vehicleSave.capacityinkg,
                var_No_Of_Cells_In_Tanker = vehicleSave.noofcellsintanker,
                var_Labour_Charge = vehicleSave.laborcharge,
                var_Is_Active = vehicleSave.is_active,
                var_Is_Deleted = vehicleSave.is_deleted,
                var_VehicleAverage = vehicleSave.vehicleaverage,
                var_XMLData = vehicleSave.celldata,
                var_FSSAILicense_No = vehicleSave.fssailicense_no,
                var_FSSAILicenseValidity_On = vehicleSave.fssailicensevalidity_on,
            });

            return this.db.Query<CommonOutput>("USP_AdminVehicle_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }




        /*----  ----    ----    ----    Material Get & Save   ----    ----    ----    ----*/
        public List<ResMaterial> GetMaterial(ReqMaterial materialSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialSearch.method_name,
                var_Org_Id = materialSearch.org_id,
                var_Destination_name = materialSearch.destination_name,
                var_Search_Text = materialSearch.search_text,
                var_Material_Id = materialSearch.material_id,
                var_User_Id = materialSearch.user_id
            });

            return this.db.Query<ResMaterial>("USP_AdminMaterial_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMaterial(ReqMaterial materialSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialSave.method_name,
                var_Org_Id = materialSave.org_id,
                var_Material_Id = materialSave.material_id,
                var_MaterialType_Id = materialSave.materialtype_id,
                var_User_Id = materialSave.user_id,
                var_User_Name = materialSave.user_name,
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_MaterialData = ""
            }); ;

            return this.db.Query<CommonOutput>("USP_AdminMaterial_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveSAPMaterialMaster(ReqMaterial materialSave)
        {
            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = materialSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = new MasterSAP(Connection_Name).SaveMaterialMaster(materialSave.org_id, "ZRMK");

            JObject jsonResponse = JObject.Parse(dynamic);

            var dynamic2 = new MasterSAP(Connection_Name).SaveMaterialMaster(materialSave.org_id, "ZRTP");

            JObject jsonResponse2 = JObject.Parse(dynamic2);

            var dynamic3 = new MasterSAP(Connection_Name).SaveMaterialMaster(materialSave.org_id, "ZTDM");

            JObject jsonResponse3 = JObject.Parse(dynamic3);

            var dynamic4 = new MasterSAP(Connection_Name).SaveMaterialMaster(materialSave.org_id, "ZFG2");

            JObject jsonResponse4 = JObject.Parse(dynamic4);

            var dynamic5 = new MasterSAP(Connection_Name).SaveMaterialMaster(materialSave.org_id, "ZFG3");

            JObject jsonResponse5 = JObject.Parse(dynamic5);

            if (jsonResponse.ContainsKey("d") || jsonResponse2.ContainsKey("d") || jsonResponse3.ContainsKey("d")
            || jsonResponse4.ContainsKey("d") || jsonResponse5.ContainsKey("d")
            )
            {
                var results = new
                {
                    data = jsonResponse["d"]["results"],
                    data2 = jsonResponse2["d"]["results"],
                    data3 = jsonResponse3["d"]["results"]
                ,
                    data4 = jsonResponse4["d"]["results"],
                    data5 = jsonResponse5["d"]["results"]
                };

                if (results != null)
                {
                    XDocument xmlDocument = new XDocument(new XElement("Material"));
                    foreach (var result in results.data)
                    {
                        string materialCode = result["Product"].ToString();
                        string materialDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string materialGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("MaterialData",
                            new XElement("Material_Code", materialCode),
                            new XElement("Material_Name", materialDescription),
                            new XElement("Material_Group", materialGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Is_TradingMaterial", 0)
                        );

                        xmlDocument.Root.Add(productData);
                    }
                    foreach (var result in results.data2)
                    {
                        string materialCode = result["Product"].ToString();
                        string materialDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string materialGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("MaterialData",
                            new XElement("Material_Code", materialCode),
                            new XElement("Material_Name", materialDescription),
                            new XElement("Material_Group", materialGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Is_TradingMaterial", 0)
                        );

                        xmlDocument.Root.Add(productData);
                    }
                    foreach (var result in results.data3)
                    {
                        string materialCode = result["Product"].ToString();
                        string materialDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string materialGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("MaterialData",
                            new XElement("Material_Code", materialCode),
                            new XElement("Material_Name", materialDescription),
                            new XElement("Material_Group", materialGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Is_TradingMaterial", 1)
                        );

                        xmlDocument.Root.Add(productData);
                    }

                    foreach (var result in results.data4)
                    {
                        string materialCode = result["Product"].ToString();
                        string materialDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string materialGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("MaterialData",
                            new XElement("Material_Code", materialCode),
                            new XElement("Material_Name", materialDescription),
                            new XElement("Material_Group", materialGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Is_TradingMaterial", 0)
                        );

                        xmlDocument.Root.Add(productData);
                    }

                    foreach (var result in results.data5)
                    {
                        string materialCode = result["Product"].ToString();
                        string materialDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                        string materialGroup = result["ProductGroup"].ToString();
                        string baseUnit = result["BaseUnit"].ToString();

                        XElement productData = new XElement("MaterialData",
                            new XElement("Material_Code", materialCode),
                            new XElement("Material_Name", materialDescription),
                            new XElement("Material_Group", materialGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Is_TradingMaterial", 0)
                        );

                        xmlDocument.Root.Add(productData);
                    }


                    var parameters = new DynamicParameters(new
                    {
                        var_Method_Name = materialSave.method_name,
                        var_Org_Id = materialSave.org_id,
                        var_Material_Id = materialSave.material_id,
                        var_MaterialType_Id = materialSave.materialtype_id,
                        var_User_Id = materialSave.user_id,
                        var_User_Name = materialSave.user_name,
                        var_Is_Active = 1,
                        var_Is_Deleted = 0,
                        var_MaterialData = xmlDocument
                    });

                    return this.db.Query<CommonOutput>("USP_AdminMaterial_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            else if (jsonResponse.ContainsKey("error") || jsonResponse2.ContainsKey("error")
            || jsonResponse3.ContainsKey("error")
            || jsonResponse4.ContainsKey("error")
            || jsonResponse5.ContainsKey("error"))
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
                    result_description = "Material Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();
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

            return this.db.Query<ResProduct>("USP_AdminProduct_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
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

            return this.db.Query<CommonOutput>("USP_AdminProduct_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveSAPProductMaster(ReqProduct productSave)
        {

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = productSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

            var dynamic = new MasterSAP(Connection_Name).SaveProductMaster(productSave.org_id);

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
                        string division = result["Division"].ToString();
                        string productType = result["ProductType"].ToString();

                        XElement productData = new XElement("ProductData",
                            new XElement("Product_Code", productCode),
                            new XElement("Product_Name", productDescription),
                            new XElement("Product_Group", productGroup),
                            new XElement("BaseUnit", baseUnit),
                            new XElement("Division", division),
                            new XElement("ProductType", productType)
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







        /*----  ----    ----    ----    Incentive Scheme Get & Save   ----    ----    ----    ----*/
        public List<ResIncentiveScheme> GetIncentiveScheme(ReqIncentiveScheme incentiveSchemeSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSchemeSearch.method_name,
                var_Org_Id = incentiveSchemeSearch.org_id,
                var_User_Id = incentiveSchemeSearch.user_id,
                //var_Destination_name = incentiveSchemeSearch.destination_name,
                var_IncentiveScheme_Id = incentiveSchemeSearch.incentivescheme_id,
                var_IncentiveType_Id = incentiveSchemeSearch.incentivetype_id,
                var_Date = incentiveSchemeSearch.duration
            });

            var result = this.db.Query<ResIncentiveScheme>("USP_AdminIncentiveScheme_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveIncentiveScheme(ReqIncentiveScheme incentiveSchemeSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSchemeSave.method_name,
                var_Org_Id = incentiveSchemeSave.org_id,
                var_User_Id = incentiveSchemeSave.user_id,
                var_Destination_name = incentiveSchemeSave.destination_name,
                var_User_Name = incentiveSchemeSave.user_name,
                var_IncentiveScheme_Id = incentiveSchemeSave.incentivescheme_id,
                var_Scheme_Name = incentiveSchemeSave.scheme_name,
                var_IncentiveType_Id = incentiveSchemeSave.incentivetype_id,
                var_From_Date = incentiveSchemeSave.from_date,
                var_To_Date = incentiveSchemeSave.to_date,
                var_IncentiveFrequency_Id = incentiveSchemeSave.incentivefrequency_id,
                var_Criteria = incentiveSchemeSave.criteria,
                var_Scheme_Description = incentiveSchemeSave.scheme_description,
                var_Is_For_Farmer = incentiveSchemeSave.is_for_farmer,
                var_Is_For_Agent = incentiveSchemeSave.is_for_agent,
                var_Is_Active = incentiveSchemeSave.is_active,
                var_Is_Deleted = incentiveSchemeSave.is_deleted,
                var_Photo = ""
            });

            return this.db.Query<CommonOutput>("USP_AdminIncentiveScheme_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<ResIncentiveScheme> GetIncentiveSchemeMCC(ReqIncentiveScheme incentiveSchemeSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSchemeSearch.method_name,
                var_Org_Id = incentiveSchemeSearch.org_id,
                var_User_Id = incentiveSchemeSearch.user_id,
                var_IncentiveScheme_Id = incentiveSchemeSearch.incentivescheme_id,
            });

            var result = this.db.Query<ResIncentiveScheme>("USP_AdminIncentiveSchemeMCC_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveIncentiveSchemeMCC(ReqIncentiveScheme incentiveSchemeSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSchemeSave.method_name,
                var_Org_Id = incentiveSchemeSave.org_id,
                var_User_Id = incentiveSchemeSave.user_id,
                var_Destination_name = incentiveSchemeSave.destination_name,
                var_User_Name = incentiveSchemeSave.user_name,
                var_IncentiveScheme_Id = incentiveSchemeSave.incentivescheme_id,
                var_Entry_Id = incentiveSchemeSave.entry_id,
                var_MCC_Id = incentiveSchemeSave.mcc_id,
            });

            return this.db.Query<CommonOutput>("USP_AdminIncentiveSchemeMCC_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Services Get & Save   ----    ----    ----    ----*/
        public List<ResServices> GetServices(ReqServices servicesSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = servicesSearch.method_name,
                var_Org_Id = servicesSearch.org_id,
                var_User_Id = servicesSearch.user_id,
                var_Service_Id = servicesSearch.service_id,
                var_Service_Name = servicesSearch.service_name,
                var_ServiceType_Id = servicesSearch.servicetype_id
            });

            return this.db.Query<ResServices>("USP_AdminService_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveServices(ReqServices servicesSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = servicesSave.method_name,
                var_Org_Id = servicesSave.org_id,
                var_User_Id = servicesSave.user_id,
                var_User_Name = servicesSave.user_name,
                var_Service_Id = servicesSave.service_id,
                var_Service_Name = servicesSave.service_name,
                var_Material_Id = servicesSave.material_id,
                var_ServiceType_Id = servicesSave.servicetype_id,
                var_Service_Description = servicesSave.service_description,
                var_Is_Active = servicesSave.is_active,
                var_Is_Deleted = servicesSave.is_deleted,
                var_Is_For_Farmer = servicesSave.is_for_farmer,
                var_Is_For_Agent = servicesSave.is_for_agent,
                var_Condition_1 = servicesSave.condition_1,
                var_Condition_2 = servicesSave.condition_2,
                var_Condition_3 = servicesSave.condition_3,
                var_Condition_4 = servicesSave.condition_4,
                var_Condition_5 = servicesSave.condition_5,


            });

            return this.db.Query<CommonOutput>("USP_AdminService_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
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







        /*----  ----    ----    ----    Bank Get & Save   ----    ----    ----    ----*/
        public List<ResBank> GetBank(ReqBank bankSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = bankSearch.method_name,
                var_Org_Id = bankSearch.org_id,
                var_Search_Text = bankSearch.search_text,
                var_Bank_Id = bankSearch.bank_id,
                var_User_Id = bankSearch.user_id
            });

            var result = this.db.Query<ResBank>("USP_AdminBank_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveBank(ReqBank bankSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = bankSave.method_name,
                var_Org_Id = bankSave.org_id,
                var_User_Id = bankSave.user_id,
                var_User_Name = bankSave.user_name,
                var_Is_Active = bankSave.is_active,
                var_Is_Deleted = bankSave.is_deleted,
                var_Bank_Id = bankSave.bank_id,
                var_Bank_Name = bankSave.bank_name,
            });

            return this.db.Query<CommonOutput>("USP_AdminBank_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Bank Branch Get & Save   ----    ----    ----    ----*/
        public List<ResBankBranch> GetBankBranch(ReqBankBranch bankBranchSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = bankBranchSearch.method_name,
                var_Org_Id = bankBranchSearch.org_id,
                var_Bank_Id = bankBranchSearch.bank_id,
                var_Branch_Id = bankBranchSearch.branch_id,
                var_User_Id = bankBranchSearch.user_id
            });

            var result = this.db.Query<ResBankBranch>("USP_AdminBranch_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        public List<CommonOutput> SaveBankBranch(ReqBankBranch bankBranchSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = bankBranchSave.method_name,
                var_Org_Id = bankBranchSave.org_id,
                var_User_Id = bankBranchSave.user_id,
                var_Bank_Id = bankBranchSave.bank_id,
                var_Branch_Id = bankBranchSave.branch_id,
                var_Branch_Name = bankBranchSave.branch_name,
                var_IFSC_Code = bankBranchSave.ifsc_code,
                var_Address_Text = bankBranchSave.address_text,
                var_User_Name = bankBranchSave.user_name,
                var_Is_Active = bankBranchSave.is_active,
                var_Is_Deleted = bankBranchSave.is_deleted
            });
            if (bankBranchSave.method_name == "Create")
            {
                var SuccessResult = this.db.Query<CommonOutput>("USP_AdminBranch_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

                var result_id = SuccessResult[0].result_id.ToString();
                if (result_id == "1")
                {
                    var Branch_Id = SuccessResult[0].result_extra_key.ToString();
                    Rootobject parameter = new Rootobject();

                    var parameterBankBranch = new DynamicParameters(new
                    {
                        var_Method_Name = "Get_One_SAP",
                        var_Org_Id = bankBranchSave.org_id,
                        var_Bank_Id = bankBranchSave.bank_id,
                        var_Branch_Id = Branch_Id,
                        var_User_Id = ""
                    });

                    var parameterData = this.db.Query<Rootobject>("USP_AdminBranch_Get", parameterBankBranch, commandType: CommandType.StoredProcedure).ToList();

                    parameter = parameterData[0];
                    var sap__messages = new List<string>();
                    parameter.SAP__Messages = sap__messages;


                    var parameterOrg = new DynamicParameters(new
                    {
                        var_Method_Name = "Get",
                        var_Org_Id = bankBranchSave.org_id,
                    });

                    var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

                    var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

                    //var sap__messages = parameterData[0].SAP__Messages;

                    // if (sap__messages != null && sap__messages.length > 0 && sap__messages[0] is string)
                    // {
                    //  sap__messages = jsonconvert.deserializeobject<object[]>(sap__messages[0].tostring());
                    // }

                    // parameter.sap__messages = sap__messages;

                    var dynamic = new MasterSAP(Connection_Name).SaveBankMaster(parameter, bankBranchSave.org_id);
                    JObject jsonResponse = JObject.Parse(dynamic);
                    if (jsonResponse.ContainsKey("BankCountry"))
                    {
                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = 1, // Assuming result_id is an integer
                            result_description = "Branch Created In SAP",
                            result_extra_key = ""
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };
                    }

                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CommonOutput commonOutput = new CommonOutput
                        {
                            result_id = -1, // Assuming result_id is an integer
                            result_description = jsonResponse["error"]["message"].ToString(),
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
                            result_description = "Branch Not Created In SAP",
                            result_extra_key = ""
                        };

                        // Return the CommonOutput instance as a list with a single item
                        return new List<CommonOutput> { commonOutput };
                    }



                }

            }

            return this.db.Query<CommonOutput>("USP_AdminBranch_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






    }
}
