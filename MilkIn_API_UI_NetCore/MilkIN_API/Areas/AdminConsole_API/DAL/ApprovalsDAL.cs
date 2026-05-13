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
    public class ApprovalsDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        private string ConnectionName;

        public ApprovalsDAL(string Destination)
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






        /*----  ----    ----    ----    Farmer Registration Get & Save   ----    ----    ----    ----*/
        public List<ResFarmerRegistration> GetFarmerRegistration(ReqFarmerRegistration farmerSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSearch.method_name,
                var_Org_Id = farmerSearch.org_id,
                var_Date = farmerSearch.request_date,
                var_ApprovalStatus_Id = farmerSearch.approvalstatus_id,
                var_User_Id = farmerSearch.user_id,
                var_Farmer_Id = farmerSearch.farmer_id
            });

            return this.db.Query<ResFarmerRegistration>("USP_AdminFarmerRegistration_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveFarmerRegistration(ReqFarmerRegistration farmerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSave.method_name,
                var_Org_Id = farmerSave.org_id,
                var_ApprovalStatus_Id = farmerSave.approvalstatus_id,
                var_ApprovalRemarks = farmerSave.approval_remarks,
                var_Farmer_Id = farmerSave.farmer_id,
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
                var_Profile_Photo = "",
                var_Pan_Card_Photo = "",
                var_Aadhar_Card_Photo = "",
                var_Ration_Card_Photo = "",
                var_Bank_Cheque_PBook_Photo = "",
                var_User_Id = farmerSave.user_id,
                var_User_Name = farmerSave.user_name,
                var_Request_Date = new DateTime(),
                var_MCC_Farmer_Code = farmerSave.mcc_farmer_code,
                var_WithholdingTaxType_Id = farmerSave.withholdingtaxtype_id,
                var_Gov_Farmer_Id = farmerSave.gov_farmer_id,
                var_Gov_Farmer_Name = farmerSave.gov_farmer_name,
            });

            if (farmerSave.approvalstatus_id == "1")
            {
                var SuccessResult = this.db.Query<CommonOutput>("USP_AdminFarmerRegistration_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                var result_id = SuccessResult[0].result_id.ToString();
                var result_description = SuccessResult[0].result_description.ToString();
                if (result_id == "1" && result_description == "Approved")
                {


                    var Farmer_Id = SuccessResult[0].result_extra_key.ToString();

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

                    var parameterOrg = new DynamicParameters(new
                    {
                        var_Method_Name = "Get",
                        var_Org_Id = farmerSave.org_id,
                    });

                    var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

                    var Connection_Name = parameterOrgData[0].ConnectionName.ToString();

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
                            var_MCC_Farmer_Code = farmerSave.mcc_farmer_code
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


            return this.db.Query<CommonOutput>("USP_AdminFarmerRegistration_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Farmer Service Get & Save   ----    ----    ----    ----*/
        public List<ResFarmerService> GetFarmerService(ReqFarmerService serviceSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSearch.method_name,
                var_Org_Id = serviceSearch.org_id,
                var_Date = serviceSearch.request_date,
                var_ApprovalStatus_Id = serviceSearch.approvalstatus_id,
                var_User_Id = "",
                var_Request_Id = serviceSearch.request_id,
                var_Request_For = "farmer",
                var_Order_Type = serviceSearch.order_type,
                var_ServiceType_Id = serviceSearch.servicetype_id

            });

            return this.db.Query<ResFarmerService>("USP_AdminServiceRequest_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveFarmerService(ReqFarmerService serviceSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSave.method_name,
                var_Org_Id = serviceSave.org_id,
                var_User_Id = serviceSave.user_id,
                var_User_Name = serviceSave.user_name,
                var_Request_Id = serviceSave.request_id,
                var_ApprovalStatus_Id = serviceSave.approvalstatus_id,
                var_ApprovalRemarks = serviceSave.approval_remarks,
                var_Approved_Amount = serviceSave.approved_amount,
                var_VeterinaryService_Date = serviceSave.veterinaryservice_date,
                var_Request_For = "farmer",
                var_Order_Type = serviceSave.order_type,
                var_ServiceType_Id = serviceSave.servicetype_id,
                var_Order_Data = serviceSave.order_data,

                var_Quantity = serviceSave.quantity,
                var_Product_Id = serviceSave.product_id,
                var_MCC_Id = serviceSave.mcc_id

            });

            return this.db.Query<CommonOutput>("USP_AdminServiceRequest_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Agent Service Get & Save   ----    ----    ----    ----*/
        public List<ResAgentService> GetAgentService(ReqAgentService serviceSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSearch.method_name,
                var_Org_Id = serviceSearch.org_id,
                var_Date = serviceSearch.request_date,
                var_ApprovalStatus_Id = serviceSearch.approvalstatus_id,
                var_User_Id = "",
                var_Request_Id = serviceSearch.request_id,
                var_Request_For = "agent",
                var_Order_Type = serviceSearch.order_type,
                var_ServiceType_Id = serviceSearch.servicetype_id

            });

            return this.db.Query<ResAgentService>("USP_AdminServiceRequest_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveAgentService(ReqAgentService serviceSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSave.method_name,
                var_Org_Id = serviceSave.org_id,
                var_User_Id = serviceSave.user_id,
                var_User_Name = serviceSave.user_name,
                var_Request_Id = serviceSave.request_id,
                var_ApprovalStatus_Id = serviceSave.approvalstatus_id,
                var_ApprovalRemarks = serviceSave.approval_remarks,
                var_Approved_Amount = serviceSave.approved_amount,
                var_VeterinaryService_Date = serviceSave.veterinaryservice_date,
                var_Request_For = "agent",
                var_Order_Type = serviceSave.order_type,
                var_ServiceType_Id = serviceSave.servicetype_id,
                var_Order_Data = serviceSave.order_data,

                var_Quantity = serviceSave.quantity,
                var_Product_Id = serviceSave.product_id,
                var_MCC_Id = serviceSave.mcc_id

            });

            return this.db.Query<CommonOutput>("USP_AdminServiceRequest_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Collection Request Get & Save   ----    ----    ----    ----*/
        public List<ResCollectionRequest> GetCollectionRequest(ReqCollectionRequest requestSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = requestSearch.method_name,
                var_Org_Id = requestSearch.org_id,
                var_Date = requestSearch.request_date,
                var_ApprovalStatus_Id = requestSearch.approvalstatus_id,
                var_User_Id = requestSearch.user_id,
                var_CollectionRequest_Id = requestSearch.collectionrequest_id
            });

            return this.db.Query<ResCollectionRequest>("USP_AdminCollectionRequest_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveCollectionRequest(ReqCollectionRequest requestSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = requestSave.method_name,
                var_Org_Id = requestSave.org_id,
                var_CollectionRequest_Id = requestSave.collectionrequest_id,
                var_ApprovalStatus_Id = requestSave.approvalstatus_id,
                var_Expected_Time = requestSave.expected_time,
                var_User_Id = requestSave.user_id,
                var_User_Name = requestSave.user_name,
                var_MCCCollectionShift_Id = requestSave.mcccollectionshift_id
            });

            return this.db.Query<CommonOutput>("USP_AdminCollectionRequest_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Correction L1 Get & Save   ----    ----    ----    ----*/
        public List<ResCorrectionL1> GetCorrectionL1(ReqCorrectionL1 correctionL1Search)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = correctionL1Search.method_name,
                var_Org_Id = correctionL1Search.org_id,
                var_ApprovalStatus_Id = correctionL1Search.approvalstatus_id,
                var_User_Id = correctionL1Search.user_id,
                var_CorrectionRequest_Id = correctionL1Search.correction_request_id,
                var_Date = correctionL1Search.date
            });

            return this.db.Query<ResCorrectionL1>("USP_AdminCorrection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveCorrectionL1(ReqCorrectionL1 correctionL1Save)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = correctionL1Save.method_name,
                var_Org_Id = correctionL1Save.org_id,
                var_ApprovalStatus_Id = correctionL1Save.approvalstatus_id,
                var_User_Id = correctionL1Save.user_id,
                var_User_Name = correctionL1Save.user_name,
                var_CorrectionRequest_Id = correctionL1Save.correction_request_id,
                var_Approved_Quantity_Ltr = correctionL1Save.approved_quantity_ltr,
                var_Approved_Fat = correctionL1Save.approved_fat,
                var_Approved_SNF = correctionL1Save.approved_snf,
                var_ApprovalRemarks = correctionL1Save.approved_remarks

            });

            return this.db.Query<CommonOutput>("USP_AdminCorrection_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Correction L2 Get & Save   ----    ----    ----    ----*/
        public List<ResCorrectionL2> GetCorrectionL2(ReqCorrectionL2 correctionL2Search)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = correctionL2Search.method_name,
                var_Org_Id = correctionL2Search.org_id,
                var_ApprovalStatus_Id = correctionL2Search.approvalstatus_id,
                var_User_Id = correctionL2Search.user_id,
                var_CorrectionRequest_Id = correctionL2Search.correction_request_id,
                var_Date = correctionL2Search.date
            });

            return this.db.Query<ResCorrectionL2>("USP_AdminCorrection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveCorrectionL2(ReqCorrectionL2 correctionL2Save)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = correctionL2Save.method_name,
                var_Org_Id = correctionL2Save.org_id,
                var_ApprovalStatus_Id = correctionL2Save.approvalstatus_id,
                var_User_Id = correctionL2Save.user_id,
                var_User_Name = correctionL2Save.user_name,
                var_CorrectionRequest_Id = correctionL2Save.correction_request_id,
                var_Approved_Quantity_Ltr = correctionL2Save.approved_quantity_ltr,
                var_Approved_Fat = correctionL2Save.approved_fat,
                var_Approved_SNF = correctionL2Save.approved_snf,
                var_ApprovalRemarks = correctionL2Save.approved_remarks

            });

            return this.db.Query<CommonOutput>("USP_AdminCorrection_Set", parameters, commandType: CommandType.StoredProcedure, commandTimeout: 0).ToList();
        }








        /*----  ----    ----    ----    Data Correction Get & Save   ----    ----    ----    ----*/
        public List<ResDataCorrection> GetDataCorrection(ReqDataCorrection dataCorrectionSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dataCorrectionSearch.method_name,
                var_Org_Id = dataCorrectionSearch.org_id,
                var_Date = dataCorrectionSearch.request_date,
                var_ApprovalStatus_Id = dataCorrectionSearch.approvalstatus_id,
                var_User_Id = dataCorrectionSearch.user_id,
                var_Farmer_Id = dataCorrectionSearch.request_for_user_id,
                var_Request_Id = dataCorrectionSearch.request_id,
                var_Request_For = dataCorrectionSearch.request_for
            });

            return this.db.Query<ResDataCorrection>("USP_AdminDataCorrection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveDataCorrection(ReqDataCorrection dataCorrectionSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dataCorrectionSave.method_name,
                var_Org_Id = dataCorrectionSave.org_id,
                var_User_Id = dataCorrectionSave.user_id,
                var_User_Name = dataCorrectionSave.user_name,
                var_ApprovalStatus_Id = dataCorrectionSave.approvalstatus_id,
                var_Approval_Remarks = dataCorrectionSave.approval_remarks,
                var_Request_Id = dataCorrectionSave.request_id,
                var_Request_Type = dataCorrectionSave.request_type,
                var_Request_Data = dataCorrectionSave.request_data,
                var_Mobile_No = dataCorrectionSave.mobile_no,
                var_Bank_Id = dataCorrectionSave.bank_id,
                var_Branch_Id = dataCorrectionSave.branch_id,
                var_Account_Name = dataCorrectionSave.account_name,
                var_Account_No = dataCorrectionSave.account_no,
                var_IFSC_Code = dataCorrectionSave.ifsc_code,
                var_Nominee_Name = dataCorrectionSave.nominee_name,
                var_NomineeRelation_Id = dataCorrectionSave.nominee_relation,
                var_Nominee_Mobile_No = dataCorrectionSave.nominee_mobile_no,
                var_Nominee_Aadhar_No = dataCorrectionSave.nominee_aadhar_no,
                var_Request_For = dataCorrectionSave.request_for
            });

            return this.db.Query<CommonOutput>("USP_AdminDataCorrection_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Farmer Order Get & Save   ----    ----    ----    ----*/
        public List<ResFarmerOrder> GetFarmerOrder(ReqFarmerOrder serviceSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSearch.method_name,
                var_Org_Id = serviceSearch.org_id,
                var_Date = serviceSearch.order_date,
                var_ApprovalStatus_Id = serviceSearch.approvalstatus_id,
                var_User_Id = "",
                var_Order_Id = serviceSearch.order_id,
                var_Order_For = "Farmer",
                var_Order_Type = "Product"
            });

            return this.db.Query<ResFarmerOrder>("USP_AdminOrder_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveFarmerOrder(ReqFarmerOrder serviceSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSave.method_name,
                var_Org_Id = serviceSave.org_id,
                var_User_Id = serviceSave.user_id,
                var_User_Name = serviceSave.user_name,
                var_Order_Id = serviceSave.order_id,
                var_ApprovalStatus_Id = serviceSave.approvalstatus_id,
                var_ApprovalRemarks = serviceSave.approval_remarks,
                var_Order_Data = serviceSave.order_data,
                var_Order_For = "Farmer",
                var_Order_Type = "Product"
            });

            return this.db.Query<CommonOutput>("USP_AdminOrder_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Agent Order Get & Save   ----    ----    ----    ----*/
        public List<ResAgentOrder> GetAgentOrder(ReqAgentOrder serviceSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSearch.method_name,
                var_Org_Id = serviceSearch.org_id,
                var_Date = serviceSearch.order_date,
                var_ApprovalStatus_Id = serviceSearch.approvalstatus_id,
                var_User_Id = "",
                var_Order_Id = serviceSearch.order_id,
                var_Order_For = "Agent",
                var_Order_Type = "Product"
            });

            return this.db.Query<ResAgentOrder>("USP_AdminOrder_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveAgentOrder(ReqAgentOrder serviceSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = serviceSave.method_name,
                var_Org_Id = serviceSave.org_id,
                var_Order_Id = serviceSave.order_id,
                var_ApprovalStatus_Id = serviceSave.approvalstatus_id,
                var_ApprovalRemarks = serviceSave.approval_remarks,
                var_User_Id = serviceSave.user_id,
                var_User_Name = serviceSave.user_name,
                var_Order_Data = serviceSave.order_data,
                var_Order_For = "Agent",
                var_Order_Type = "Product"
            });

            return this.db.Query<CommonOutput>("USP_AdminOrder_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Farmer Incentive Get & Save   ----    ----    ----    ----*/
        public List<ResFarmerIncentive> GetFarmerIncentive(ReqFarmerIncentive incentiveSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSearch.method_name,
                var_Org_Id = incentiveSearch.org_id,
                var_Date = incentiveSearch.request_date,
                var_ApprovalStatus_Id = incentiveSearch.approvalstatus_id,
                var_User_Id = incentiveSearch.user_id,
                var_Request_Id = incentiveSearch.request_id,
                var_Request_For = "farmer"

            });

            return this.db.Query<ResFarmerIncentive>("USP_AdminIncentiveRequest_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveFarmerIncentive(ReqFarmerIncentive incentiveSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSave.method_name,
                var_Org_Id = incentiveSave.org_id,
                var_User_Id = incentiveSave.user_id,
                var_User_Name = incentiveSave.user_name,
                var_Request_Id = incentiveSave.request_id,
                var_ApprovalStatus_Id = incentiveSave.approvalstatus_id,
                var_ApprovalRemarks = incentiveSave.approval_remarks,
                var_Request_For = "farmer"

            });

            return this.db.Query<CommonOutput>("USP_AdminIncentiveRequest_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Agent Incentive Get & Save   ----    ----    ----    ----*/
        public List<ResAgentIncentive> GetAgentIncentive(ReqAgentIncentive incentiveSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSearch.method_name,
                var_Org_Id = incentiveSearch.org_id,
                var_Date = incentiveSearch.request_date,
                var_ApprovalStatus_Id = incentiveSearch.approvalstatus_id,
                var_User_Id = incentiveSearch.user_id,
                var_Request_Id = incentiveSearch.request_id,
                var_Request_For = "agent"

            });

            return this.db.Query<ResAgentIncentive>("USP_AdminIncentiveRequest_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveAgentIncentive(ReqAgentIncentive incentiveSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = incentiveSave.method_name,
                var_Org_Id = incentiveSave.org_id,
                var_User_Id = incentiveSave.user_id,
                var_User_Name = incentiveSave.user_name,
                var_Request_Id = incentiveSave.request_id,
                var_ApprovalStatus_Id = incentiveSave.approvalstatus_id,
                var_ApprovalRemarks = incentiveSave.approval_remarks,
                var_Request_For = "agent",
            });

            return this.db.Query<CommonOutput>("USP_AdminIncentiveRequest_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






    }
}

