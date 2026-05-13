using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class TransactionsDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public TransactionsDAL(string Destination)
        {
            switch (Destination)
            {
                case "PRD":
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT":
                    ConnectionName = "ConnectionUAT";
                    break;
                default:
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
        }







        /*----  ----    ----    ----    Retailers Authorization - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResRetailersAuthorization> GetRetailersAuthorization(ReqRetailersAuthorization retailersAuthorizationSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailersAuthorizationSearch.org_id,
                var_Method_Name = retailersAuthorizationSearch.method_name,
                var_User_Id = retailersAuthorizationSearch.user_id,
                var_SalesUser_Id = retailersAuthorizationSearch.salesuser_id,
                var_ApprovalStatus_Id = retailersAuthorizationSearch.approvalstatus_id,
                var_Request_Period = retailersAuthorizationSearch.request_period,
                var_Retailer_Id = retailersAuthorizationSearch.retailer_id

            });

            var result = this.db.Query<ResRetailersAuthorization>("USP_SAdminRetailersAuthorization_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveRetailersAuthorization(ReqRetailersAuthorization retailersAuthorizationSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailersAuthorizationSave.org_id,
                var_Method_Name = retailersAuthorizationSave.method_name,
                var_User_Id = retailersAuthorizationSave.user_id,
                var_User_Name = retailersAuthorizationSave.user_name,
                var_Retailer_Id = retailersAuthorizationSave.retailer_id,
                var_Approval_Remarks = retailersAuthorizationSave.approval_remarks,
                var_Retailer_Name = retailersAuthorizationSave.retailer_name,
                var_Dealer_Id = retailersAuthorizationSave.dealer_id,
                var_SalesArea_Id = retailersAuthorizationSave.salesarea_id,
                var_SalesUser_Id = retailersAuthorizationSave.salesuser_id,
                var_Mobile_No = retailersAuthorizationSave.mobile_no,
                var_Contact_Person = retailersAuthorizationSave.contact_person,
                var_Email_Id = retailersAuthorizationSave.email_id,
                var_Address_Line_1_Text = retailersAuthorizationSave.address_line_1_text,
                var_Address_Line_2_Text = retailersAuthorizationSave.address_line_2_text,
                var_State_Id = retailersAuthorizationSave.state_id,
                var_District_Id = retailersAuthorizationSave.district_id,
                var_Taluka_Id = retailersAuthorizationSave.taluka_id,
                var_Pincode = retailersAuthorizationSave.pincode,
                var_Pan_No = retailersAuthorizationSave.pan_no,
                var_Bank_Id = retailersAuthorizationSave.bank_id,
                var_Branch_Id = retailersAuthorizationSave.branch_id,
                var_FSSAI_License_No = retailersAuthorizationSave.fssai_license_no,
                var_FSSAI_LicenseValidity_On = retailersAuthorizationSave.fssai_licensevalidity_on,
                var_GST_No = retailersAuthorizationSave.gst_no,
                var_AgreementValidityPeriod = retailersAuthorizationSave.agreement_validity_period,
                var_AgreementDoneFlag = retailersAuthorizationSave.is_agreement_done,
                var_Account_No = retailersAuthorizationSave.account_no,
                var_IFSC_Code = retailersAuthorizationSave.ifsc_code,
                var_Account_Name = retailersAuthorizationSave.account_name,
                var_Shop_License_No = retailersAuthorizationSave.shop_license_no,
                var_Pan_Card_Photo = "",
                var_Shop_License_Photo = "",
                var_Cheque_Leaf_Photo = "",
                var_Shop_Name_Photo = "",
                var_UdyamAadhar_Card_Photo = "",
                var_FSSAI_License_Photo = "",
                var_GST_Certificate_Photo = "",
                var_Is_Active = retailersAuthorizationSave.is_active,
                var_Is_Deleted = retailersAuthorizationSave.is_deleted,
                var_Is_Approved = retailersAuthorizationSave.is_approved
            });
            return this.db.Query<CommonOutput>("USP_SAdminRetailersAuthorization_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






        /*----  ----    ----    ----    Sales User Route - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResSalesUserRoute> GetSalesUserRoute(ReqSalesUserRoute salesUserRouteSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = salesUserRouteSearch.org_id,
                var_Method_Name = salesUserRouteSearch.method_name,
                var_User_Id = salesUserRouteSearch.user_id,
                var_SalesUser_Id = salesUserRouteSearch.salesuser_id,
                var_Route_Id = salesUserRouteSearch.route_id,
                Var_RouteDay_Id = salesUserRouteSearch.routeday_id,
                var_Dealer_Id = salesUserRouteSearch.dealer_id,
                var_SalesArea_Id = salesUserRouteSearch.salesarea_id,
                var_Entry_Id = salesUserRouteSearch.rid

            });

             var result = this.db.Query<ResSalesUserRoute>("USP_SAdminSalesUserRoute_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveSalesUserRoute(ReqSalesUserRoute salesUserRouteSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = salesUserRouteSave.org_id,
                var_Method_Name = salesUserRouteSave.method_name,
                var_User_Id = salesUserRouteSave.user_id,
                var_Is_Active = salesUserRouteSave.is_active,
                var_Is_Deleted = salesUserRouteSave.is_deleted,
                var_Route_Id = salesUserRouteSave.route_id,
                var_SalesUser_Id = salesUserRouteSave.salesuser_id,
                var_Remarks = salesUserRouteSave.remarks,
                var_Working_Status = salesUserRouteSave.working_status,
                var_Total_Retailers = salesUserRouteSave.total_retailers,
                var_Retailer_List = salesUserRouteSave.retailer_list,
                var_RouteDay_Id = salesUserRouteSave.routeday_id,
                var_Route_Name = salesUserRouteSave.route_name,
                Var_SalesArea_Id = salesUserRouteSave.salesarea_id
            });
            return this.db.Query<CommonOutput>("USP_SAdminSalesUserRoute_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }







        /*----  ----    ----    ----    Targets - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResTargets> GetTargets(ReqTargets targetsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = targetsSearch.org_id,
                var_Method_Name = targetsSearch.method_name,
                var_User_Id = targetsSearch.user_id,
                var_Entry_Id = targetsSearch.entry_id,
                var_SalesUser_Id = targetsSearch.salesuser_id,
                var_FinancialYear_Id = targetsSearch.financialyear_id

            });

            var result = this.db.Query<ResTargets>("USP_SAdminTargets_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveTargets(ReqTargets targetsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = targetsSave.org_id,
                var_Method_Name = targetsSave.method_name,
                var_User_Id = targetsSave.user_id,
                var_User_Name = targetsSave.user_name,
                var_Is_Active = targetsSave.is_active,
                var_Is_Deleted = targetsSave.is_deleted,
                var_Entry_Id = targetsSave.entry_id,
                var_SalesUSer_Id = targetsSave.salesuser_id,
                var_FinancialYear_Id = targetsSave.financialyear_id,
                var_Dealer_Id = targetsSave.dealer_id,
                var_ProductGroup_Id = targetsSave.productgroup_id,
                var_Product_Id = targetsSave.product_id,
                var_ProductUOM = targetsSave.productuom,
                var_Quantity = targetsSave.quantity,
                var_Date = targetsSave.target_date
            });
            return this.db.Query<CommonOutput>("USP_SAdminTargets_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }








        /*----  ----    ----    ----    Complaints - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResComplaints> GetComplaints(ReqComplaints complaintsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSearch.org_id,
                var_Method_Name = complaintsSearch.method_name,
                var_User_Id = complaintsSearch.user_id,
                var_Complaint_Id = complaintsSearch.complaint_id,
                var_ComplaintType_Id = complaintsSearch.complainttype_id,
                var_ComplaintStatus_Id = complaintsSearch.complaintstatus_id,
                var_Complaint_Period = complaintsSearch.complaint_period
            });

            var result = this.db.Query<ResComplaints>("USP_SAdminComplaints_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveComplaints(ReqComplaints complaintsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSave.org_id,
                var_Method_Name = complaintsSave.method_name,
                var_User_Id = complaintsSave.user_id,
                var_User_Name = complaintsSave.user_name,
                var_Is_Active = complaintsSave.is_active,
                var_Is_Deleted = complaintsSave.is_deleted
            });
            return this.db.Query<CommonOutput>("USP_SAdminComplaints_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<CommonOutput> SaveComplaintsRemarks(ReqComplaints complaintsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSave.org_id,
                var_Method_Name = complaintsSave.method_name,
                var_User_Id = complaintsSave.user_id,
                var_User_Name = complaintsSave.user_name,
                Var_Complaint_Id = complaintsSave.complaint_id,
                var_Complaint_Remark = complaintsSave.complaint_remark
            });
            return this.db.Query<CommonOutput>("USP_SAdminComplaints_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



         public List<CommonOutput> SaveComplaintsStatus(ReqComplaints complaintsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSave.org_id,
                var_Method_Name = complaintsSave.method_name,
                var_User_Id = complaintsSave.user_id,
                var_User_Name = complaintsSave.user_name,
                var_Is_Active = complaintsSave.is_active,
                var_Is_Deleted = complaintsSave.is_deleted
            });
            return this.db.Query<CommonOutput>("USP_SAdminComplaints_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        /*----  ----    ----    ----    CrateReceived - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResCrateReceived> GetCrateReceived(ReqCrateReceived crateReceivedSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = crateReceivedSearch.org_id,
                var_Method_Name = crateReceivedSearch.method_name,
                var_User_Id = crateReceivedSearch.user_id,
                var_ReceivedCrate_Id = crateReceivedSearch.receivedcrate_id,
                var_Received_Period = crateReceivedSearch.received_period,
                var_Dealer_Id = crateReceivedSearch.dealer_id,
                var_Is_Approved = crateReceivedSearch.is_approved
            });

            var result = this.db.Query<ResCrateReceived>("USP_SAdminReceivedCrate_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveCrateReceived(ReqCrateReceived crateReceivedSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = crateReceivedSave.org_id,
                var_Method_Name = crateReceivedSave.method_name,
                var_User_Id = crateReceivedSave.user_id,
                var_User_Name = crateReceivedSave.user_name,
                var_ReceivedCrate_Id = crateReceivedSave.receivedcrate_id,
                var_Is_Approved = crateReceivedSave.is_approved,
                var_Approved_Data = crateReceivedSave.approved_data,
                var_Dealer_Id  = crateReceivedSave.dealer_id,
                var_Date = crateReceivedSave.received_period
            });
            return this.db.Query<CommonOutput>("USP_SAdminReceivedCrate_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<CommonOutput> SaveGoodsInwardPosting(ReqCrateReceived GoodsInwardPostingSave)
        {


            ReqSAPMilkBatch parameter = new ReqSAPMilkBatch();

            var parameterGoodsMovementCode = new DynamicParameters(new
            {

                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_Method_Name = "Get_GoodsMovementCode",
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_ReceivedCrate_Id = GoodsInwardPostingSave.receivedcrate_id,
                var_Received_Period = GoodsInwardPostingSave.received_period,
                var_Dealer_Id = GoodsInwardPostingSave.dealer_id,
                var_Is_Approved = 0
            });

            var GoodsMovementCodeResult = this.db.Query<ReqSAPMilkBatchGoodsMovementCode>("USP_SAdminReceivedCrate_Get", parameterGoodsMovementCode, commandType: CommandType.StoredProcedure).ToList();

            parameter.PostingDate = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss");
            /* parameter.PostingDate = "2023-11-15T00:00:00";      */
            parameter.MaterialDocumentHeaderText = "Crate inward";
            parameter.ReferenceDocument = GoodsInwardPostingSave.receivedcrate_id;
            parameter.GoodsMovementCode = GoodsMovementCodeResult[0].GoodsMovementCode;

            var parameterItem = new DynamicParameters(new
            {


                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_Method_Name = "Get_Quantity_SAP",
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_ReceivedCrate_Id = GoodsInwardPostingSave.receivedcrate_id,
                var_Received_Period = GoodsInwardPostingSave.received_period,
                var_Dealer_Id = GoodsInwardPostingSave.dealer_id,
                var_Is_Approved = 0
            });

            parameter.to_MaterialDocumentItem = this.db.Query<ReqSAPMilkBatchItem>("USP_SAdminReceivedCrate_Get", parameterItem, commandType: CommandType.StoredProcedure).ToList();

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = GoodsInwardPostingSave.org_id,
            });

            var parameterOrgData = this.db.Query<ResOrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();
            var dynamic = new CrateSAP(Connection_Name).SaveMilkBatch(parameter, GoodsInwardPostingSave.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);


            if (jsonResponse.ContainsKey("d"))
            {
                // Extract MaterialDocumentYear and MaterialDocument
                string MaterialDocumentYear = jsonResponse["d"]["MaterialDocumentYear"].ToString();
                string MaterialDocument = jsonResponse["d"]["MaterialDocument"].ToString();

                // var parameters = new DynamicParameters(new
                // {
                //     var_Method_Name = GoodsInwardPostingSave.method_name,
                //     var_Org_Id = GoodsInwardPostingSave.org_id,
                //     // var_Entry_Id = GoodsInwardPostingSave.entry_id,
                //     var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                //     var_Year = MaterialDocumentYear,
                //     var_SAP_Document_Id = MaterialDocument,
                //     var_User_Id = GoodsInwardPostingSave.user_id,
                //     var_User_Name = GoodsInwardPostingSave.user_name,
                // });

                // return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = MaterialDocument,
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
                    result_description = "SAP not Posted",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            //return new List<CommonOutput>();
        }









        /*----  ----    ----    ----    CrateDispatched - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResCrateDispatched> GetCrateDispatched(ReqCrateDispatched crateDispatchedSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = crateDispatchedSearch.org_id,
                var_Method_Name = crateDispatchedSearch.method_name,
                var_Dealer_Id = crateDispatchedSearch.dealer_id,
                var_Received_Period = crateDispatchedSearch.dispatch_period,
            });

            var result = this.db.Query<ResCrateDispatched>("USP_SAdminCrateDispatch", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveCrateDispatched(ReqCrateDispatched crateDispatchedSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = crateDispatchedSave.org_id,
                var_Method_Name = crateDispatchedSave.method_name,
                var_Dealer_Id = crateDispatchedSave.dealer_id,
                var_Received_Period = crateDispatchedSave.dispatch_period,
            });
            return this.db.Query<CommonOutput>("USP_SAdminCrateDispatch", parameters, commandType: CommandType.StoredProcedure).ToList();
        }








        /*----  ----    ----    ----    Notification - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResNotification> GetNotification(ReqNotification notificationSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = notificationSearch.org_id,
                var_Method_Name = notificationSearch.method_name,
                var_Date = notificationSearch.notification_period,
                var_Notification_Id = notificationSearch.notification_id
               
            });

            var result = this.db.Query<ResNotification>("USP_SAdminNotification_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveNotification(ReqNotification notificationSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = notificationSave.org_id,
                var_Method_Name = notificationSave.method_name,
                var_Notification_Id = notificationSave.notification_id,
                var_NotificationFor_Id = notificationSave.notificationfor_id,
                var_NotificationType_Id = notificationSave.notificationtype_id,
                var_ScheduleDate = notificationSave.schedule_date,
                var_Subject = notificationSave.notification_subject,
                var_Message = notificationSave.notification_message,
                var_User_Id = notificationSave.user_id,
                var_User_Name = notificationSave.user_name,
                var_Is_Active = notificationSave.is_active,
                var_Is_Deleted = notificationSave.is_deleted
                
            });
            return this.db.Query<CommonOutput>("USP_SAdminNotification_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }





        public List<ResCrateReceived> GetCrateApproval(ReqCrateApprove CrateApprove)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = CrateApprove.org_id,
                var_Method_Name = CrateApprove.method_name,
                var_User_Id = CrateApprove.user_id,
                var_User_Name = CrateApprove.user_name,
                var_ReceivedCrate_Id = CrateApprove.receivedcrate_id,
                var_Is_Approved = CrateApprove.is_approved,
                var_Approved_Data = CrateApprove.approved_data,
                var_Dealer_Id = CrateApprove.dealer_id,
                var_Date = CrateApprove.received_period
            });
            return this.db.Query<ResCrateReceived>("USP_SAdminCrateApprove_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<CommonOutput> SaveCrateApproval(ReqCrateApprove CrateApprove)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = CrateApprove.org_id,
                var_Method_Name = CrateApprove.method_name,
                var_User_Id = CrateApprove.user_id,
                var_User_Name = CrateApprove.user_name,
                var_ReceivedCrate_Id = CrateApprove.receivedcrate_id,
                var_Is_Approved = CrateApprove.is_approved,
                var_Approved_Data = CrateApprove.approved_data,
                var_Dealer_Id = CrateApprove.dealer_id,
                var_Date = CrateApprove.received_period
            });
            return this.db.Query<CommonOutput>("USP_SAdminCrateApprove_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



          /*----  ----    ----    ----    Targets - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResTargets> GetTarget(ReqTargets targetsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = targetsSearch.org_id,
                var_Method_Name = targetsSearch.method_name,
                var_User_Id = targetsSearch.user_id,
                var_Target_Id = targetsSearch.target_id,
                var_Entry_Id = targetsSearch.entry_id,
                var_SalesUser_Id = targetsSearch.salesuser_id,
                var_FinancialYear_Id = targetsSearch.financialyear_id

            });

            var result = this.db.Query<ResTargets>("USP_SAdminTarget_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveTarget(ReqTargets targetsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = targetsSave.org_id,
                var_Method_Name = targetsSave.method_name,
                var_User_Id = targetsSave.user_id,
                var_User_Name = targetsSave.user_name,
                var_Is_Active = targetsSave.is_active,
                var_Is_Deleted = targetsSave.is_deleted,
                var_Target_Id = targetsSave.target_id,
                var_Entry_Id = targetsSave.entry_id,
                var_Type = targetsSave.type,
                var_SalesUSer_Id = targetsSave.salesuser_id,
                var_FinancialYear_Id = targetsSave.financialyear_id,
                var_Dealer_Id = targetsSave.dealer_id,
                var_ProductGroup_Id = targetsSave.productgroup_id,
                var_Product_Id = targetsSave.product_id,
                var_ProductUOM = targetsSave.productuom,
                var_Quantity = targetsSave.quantity,
                var_Date = targetsSave.target_date
            });
            return this.db.Query<CommonOutput>("USP_SAdminTarget_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }






    }
}
