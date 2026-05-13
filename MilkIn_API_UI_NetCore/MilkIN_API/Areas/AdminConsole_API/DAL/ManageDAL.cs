using Dapper;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class ManageDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public ManageDAL(string Destination)
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


        /*----  ----    ----    ----    Material Issue to MCC Get & Save   ----    ----    ----    ----*/

        public List<ResMaterialIssueToMCC> GetMaterialIssueToMCC(ReqMaterialIssueToMCC materialIssueToMCCSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialIssueToMCCSearch.method_name,
                var_Org_Id = materialIssueToMCCSearch.org_id,
                var_User_Id = materialIssueToMCCSearch.user_id,
                var_IssueStocks_Id = materialIssueToMCCSearch.issuestocks_id,
                var_Route_Id = materialIssueToMCCSearch.route_id,
                var_CollectionShift_Id = materialIssueToMCCSearch.collectionshift_id,
                var_MCC_Id = materialIssueToMCCSearch.mcc_id,
                var_IssueStocks_Date = materialIssueToMCCSearch.issuestocks_date,
                var_IssueStock_Type = "Material",
                var_Date = materialIssueToMCCSearch.issuestocks_date,
                var_Search_Id = materialIssueToMCCSearch.search_id
            });

            return this.db.Query<ResMaterialIssueToMCC>("USP_AdminIssueStocks_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveMaterialIssueToMCC(ReqMaterialIssueToMCC materialIssueToMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialIssueToMCCSave.method_name,
                var_Org_Id = materialIssueToMCCSave.org_id,
                var_IssueStocks_Id = materialIssueToMCCSave.issuestocks_id,
                Var_IssueStock_Type = "Material", //materialIssueToMCCSave.issuestock_type,
                var_Route_Id = materialIssueToMCCSave.route_id,
                Var_MCC_Id = materialIssueToMCCSave.mcc_id,
                var_Vehicle_Id = materialIssueToMCCSave.vehicle_id,
                var_CollectionShift_Id = materialIssueToMCCSave.collectionshift_id,
                var_IssueStocks_Date = materialIssueToMCCSave.issuestocks_date,
                var_Driver_Id = materialIssueToMCCSave.driver_id,
                Var_Driver_Name = materialIssueToMCCSave.driver_name,
                Var_Vehicle_No = materialIssueToMCCSave.vehicle_no,
                Var_DriverMobile_No = materialIssueToMCCSave.drivermobile_no,
                Var_Profile_Id = materialIssueToMCCSave.user_id,
                var_Profile_Name = materialIssueToMCCSave.user_name,
                Var_XMLData = materialIssueToMCCSave.xmldata,
                var_Mobile_No = materialIssueToMCCSave.drivermobile_no
            });

            return this.db.Query<CommonOutput>("USP_AdminIssueStocks_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        /*----  ----    ----    ----    Material Return from MCC Get & Save   ----    ----    ----    ----*/

        public List<ResMaterialReturnFromMCC> GetMaterialReturnFromMCC(ReqMaterialReturnFromMCC materialReturnFromMCCSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialReturnFromMCCSearch.method_name,
                var_Org_Id = materialReturnFromMCCSearch.org_id,
                var_User_Id = materialReturnFromMCCSearch.user_id,
                var_User_Name = materialReturnFromMCCSearch.user_name,
                var_Entry_Period = materialReturnFromMCCSearch.search_period,
                var_DispatchStock_Id = materialReturnFromMCCSearch.dispatchstock_id,
                var_MCC_Id = materialReturnFromMCCSearch.search_mcc_id,
                var_Approval_Status = materialReturnFromMCCSearch.approvalstatus_id
            });

            return this.db.Query<ResMaterialReturnFromMCC>("USP_AdminDispatchStock_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveMaterialReturnFromMCC(ReqMaterialReturnFromMCC materialReturnFromMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = materialReturnFromMCCSave.method_name,
                var_Org_Id = materialReturnFromMCCSave.org_id,
                var_User_Id = materialReturnFromMCCSave.user_id,
                var_User_Name = materialReturnFromMCCSave.user_name,
                var_Approval_Remarks = materialReturnFromMCCSave.approval_remarks,
                var_DispatchStock_Id = materialReturnFromMCCSave.dispatchstock_id,
                var_ApprovalStatus_Id = materialReturnFromMCCSave.approvalstatus_id
            });

            return this.db.Query<CommonOutput>("USP_AdminDispatchStock_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }





        /*----  ----    ----    ----    Deductions Get & Save   ----    ----    ----    ----*/

        public List<ResDeductions> GetDeductions(ReqDeductions deductionsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = deductionsSearch.org_id,
                var_Method_Name = deductionsSearch.method_name,
                var_User_Id = deductionsSearch.user_id,
                var_User_Name = deductionsSearch.user_name,
                var_Ledger_Status = deductionsSearch.ledger_status,
                var_Entry_Period = deductionsSearch.search_period,
                var_Deductions_Id = deductionsSearch.deductions_id
            });

            return this.db.Query<ResDeductions>("USP_AdminDeductions_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveDeductions(ReqDeductions deductionsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = deductionsSave.org_id,
                var_Method_Name = deductionsSave.method_name,
                var_Deductions_Id = deductionsSave.deductions_id,
                var_Deduction_Data = deductionsSave.deduction_data,
                var_No_Of_Installments = deductionsSave.no_of_installments,
                var_UserType_Id = deductionsSave.usertype_id,
                var_UserName_Id = deductionsSave.username_id,
                var_RequestType_Id = deductionsSave.requesttype_id,
                var_Amount = deductionsSave.amount,
                var_EntryDate = deductionsSave.date,
                var_User_Id = deductionsSave.user_id,
                var_User_Name = deductionsSave.user_name,
            });

            return this.db.Query<CommonOutput>("USP_AdminDeductions_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<ResDeductions> SaveDeduction(ReqDeductions deductionsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = deductionsSave.org_id,
                var_Method_Name = deductionsSave.method_name,
                var_Deductions_Id = deductionsSave.deductions_id,
                var_Deduction_Data = deductionsSave.deduction_data,
                var_No_Of_Installments = deductionsSave.no_of_installments,
                var_UserType_Id = deductionsSave.usertype_id,
                var_UserName_Id = deductionsSave.username_id,
                var_RequestType_Id = deductionsSave.requesttype_id,
                var_Amount = deductionsSave.amount,
                var_EntryDate = deductionsSave.date,
                var_User_Id = deductionsSave.user_id,
                var_User_Name = deductionsSave.user_name,
            });

            return this.db.Query<ResDeductions>("USP_AdminDeductions_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }


        /*----  ----    ----    ----    Incentives Get & Save   ----    ----    ----    ----*/

        public List<ResIncentives> GetIncentives(ReqIncentives IncentivesSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IncentivesSearch.org_id,
                var_Method_Name = IncentivesSearch.method_name,
                var_User_Id = IncentivesSearch.user_id,
                var_User_Name = IncentivesSearch.user_name,
                var_Ledger_Status = IncentivesSearch.ledger_status,
                var_Entry_Period = IncentivesSearch.search_period,
                var_Incentives_Id = IncentivesSearch.Incentives_id
            });

            return this.db.Query<ResIncentives>("USP_AdminIncentives_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveIncentives(ReqIncentives IncentivesSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IncentivesSave.org_id,
                var_Method_Name = IncentivesSave.method_name,
                var_Incentives_Id = IncentivesSave.Incentives_id,
                var_Incentive_Data = IncentivesSave.Incentive_data,
                var_No_Of_Installments = IncentivesSave.no_of_installments,
                var_UserType_Id = IncentivesSave.usertype_id,
                var_UserName_Id = IncentivesSave.username_id,
                var_RequestType_Id = IncentivesSave.requesttype_id,
                var_Amount = IncentivesSave.amount,
                var_EntryDate = IncentivesSave.date,
                var_User_Id = IncentivesSave.user_id,
                var_User_Name = IncentivesSave.user_name,
                var_Remarks = IncentivesSave.remarks
            });

            return this.db.Query<CommonOutput>("USP_AdminIncentives_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<ResIncentives> SaveIncentive(ReqIncentives IncentivesSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IncentivesSave.org_id,
                var_Method_Name = IncentivesSave.method_name,
                var_Incentives_Id = IncentivesSave.Incentives_id,
                var_Incentive_Data = IncentivesSave.Incentive_data,
                var_No_Of_Installments = IncentivesSave.no_of_installments,
                var_UserType_Id = IncentivesSave.usertype_id,
                var_UserName_Id = IncentivesSave.username_id,
                var_RequestType_Id = IncentivesSave.requesttype_id,
                var_Amount = IncentivesSave.amount,
                var_EntryDate = IncentivesSave.date,
                var_User_Id = IncentivesSave.user_id,
                var_User_Name = IncentivesSave.user_name,
            });

            return this.db.Query<ResIncentives>("USP_AdminIncentives_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        /*----  ----    ----    ----    Complaints Get & Save   ----    ----    ----    ----*/

        public List<ResComplaints> GetComplaints(ReqComplaints complaintsSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSearch.org_id,
                var_Method_Name = complaintsSearch.method_name,
                var_Complaint_Id = complaintsSearch.complaint_id,
                var_Complaint_Period = complaintsSearch.complaint_period,
                var_ComplaintType_Id = complaintsSearch.complainttype_id,
                var_ComplaintStatus_Id = complaintsSearch.complaintstatus_id
            });

            return this.db.Query<ResComplaints>("USP_AdminComplaints_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveComplaints(ReqComplaints complaintsSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = complaintsSave.org_id,
                var_Method_Name = complaintsSave.method_name,
                var_Complaint_Id = complaintsSave.complaint_id,
                var_Remarks = complaintsSave.remarks,
                var_Display_Flag = complaintsSave.display_flag,
                var_NewStatus_Id = complaintsSave.newstatus_id,
                var_User_Id = complaintsSave.user_id,
                var_User_Name = complaintsSave.user_name
            });

            return this.db.Query<CommonOutput>("USP_AdminComplaints_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        /*----  ----    ----    ----    Issue Empty Cans Get & Save   ----    ----    ----    ----*/

        public List<ResIssueEmptyCans> GetIssueEmptyCans(ReqIssueEmptyCans issueEmptyCansSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = issueEmptyCansSearch.method_name,
                var_Org_Id = issueEmptyCansSearch.org_id,
                var_User_Id = issueEmptyCansSearch.user_id,
                var_IssueStocks_Id = issueEmptyCansSearch.issuestocks_id,
                var_Route_Id = issueEmptyCansSearch.route_id,
                var_CollectionShift_Id = issueEmptyCansSearch.collectionshift_id,
                var_MCC_Id = "%%",
                var_IssueStock_Type = "Cans",
                var_IssueStocks_Date = issueEmptyCansSearch.issuestocks_date,
                var_Date = issueEmptyCansSearch.issuestocks_date,
                var_Search_Id = issueEmptyCansSearch.search_id

            });

            return this.db.Query<ResIssueEmptyCans>("USP_AdminIssueStocks_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveIssueEmptyCans(ReqIssueEmptyCans issueEmptyCansSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = issueEmptyCansSave.method_name,
                var_Org_Id = issueEmptyCansSave.org_id,
                var_IssueStocks_Id = issueEmptyCansSave.issuestocks_id,
                Var_IssueStock_Type = "Cans", //issueEmptyCansSave.issuestock_type,
                var_Route_Id = issueEmptyCansSave.route_id,
                Var_MCC_Id = issueEmptyCansSave.mcc_id,
                var_Vehicle_Id = issueEmptyCansSave.vehicle_id,
                var_CollectionShift_Id = issueEmptyCansSave.collectionshift_id,
                var_IssueStocks_Date = issueEmptyCansSave.issuestocks_date,
                var_Driver_Id = issueEmptyCansSave.driver_id,
                Var_Driver_Name = issueEmptyCansSave.driver_name,
                Var_Vehicle_No = issueEmptyCansSave.vehicle_no,
                Var_DriverMobile_No = issueEmptyCansSave.drivermobile_no,
                Var_Profile_Id = issueEmptyCansSave.user_id,
                var_Profile_Name = issueEmptyCansSave.user_name,
                Var_XMLData = issueEmptyCansSave.xmldata,
                var_Mobile_No = ""
            });

            return this.db.Query<CommonOutput>("USP_AdminIssueStocks_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }





        /*----  ----    ----    ----    Farmer Incentive Schemes Get & Save   ----    ----    ----    ----*/

        public List<ResFarmerIncentiveSchemes> GetFarmerIncentiveSchemes(ReqFarmerIncentiveSchemes farmerIncentiveSchemesSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerIncentiveSchemesSearch.method_name,
                var_Org_Id = farmerIncentiveSchemesSearch.org_id,
                var_User_Id = farmerIncentiveSchemesSearch.user_id,
                var_IncentiveStatus_Id = farmerIncentiveSchemesSearch.incentivestatus_id,
                var_Scheme_Period = farmerIncentiveSchemesSearch.scheme_period,
                var_IncentiveScheme_Id = farmerIncentiveSchemesSearch.incentivescheme_id

            });

            return this.db.Query<ResFarmerIncentiveSchemes>("USP_AdminManageFarmerIncentiveSchemes_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveFarmerIncentiveSchemes(ReqFarmerIncentiveSchemes farmerIncentiveSchemesSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerIncentiveSchemesSave.method_name,
                var_Org_Id = farmerIncentiveSchemesSave.org_id,
                var_User_Id = farmerIncentiveSchemesSave.user_id,
                var_User_Name = farmerIncentiveSchemesSave.user_name,
                var_IncentiveScheme_Id = farmerIncentiveSchemesSave.incentivescheme_id
            });

            return this.db.Query<CommonOutput>("USP_AdminManageFarmerIncentiveSchemes_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }





        /*----  ----    ----    ----    Agent Incentive Schemes Get & Save   ----    ----    ----    ----*/

        public List<ResAgentIncentiveSchemes> GetAgentIncentiveSchemes(ReqAgentIncentiveSchemes agentIncentiveSchemesSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentIncentiveSchemesSearch.method_name,
                var_Org_Id = agentIncentiveSchemesSearch.org_id,
                var_User_Id = agentIncentiveSchemesSearch.user_id,
                var_IncentiveStatus_Id = agentIncentiveSchemesSearch.incentivestatus_id,
                var_Scheme_Period = agentIncentiveSchemesSearch.scheme_period,
                var_IncentiveScheme_Id = agentIncentiveSchemesSearch.incentivescheme_id

            });

            return this.db.Query<ResAgentIncentiveSchemes>("USP_AdminManageAgentIncentiveSchemes_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveAgentIncentiveSchemes(ReqAgentIncentiveSchemes agentIncentiveSchemesSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentIncentiveSchemesSave.method_name,
                var_Org_Id = agentIncentiveSchemesSave.org_id,
                var_User_Id = agentIncentiveSchemesSave.user_id,
                var_User_Name = agentIncentiveSchemesSave.user_name,
                var_IncentiveScheme_Id = agentIncentiveSchemesSave.incentivescheme_id
            });

            return this.db.Query<CommonOutput>("USP_AdminManageAgentIncentiveSchemes_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



    }
}
