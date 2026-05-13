

using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Microsoft.AspNetCore.Components;
using static System.Net.Mime.MediaTypeNames;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class InquiryDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public InquiryDAL(string Destination)
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


        public List<CommonOutput> SaveInquiry(ReqInquiry inquirySave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = inquirySave.org_id,
                var_Method_Name = inquirySave.method_name,
                var_User_Id = inquirySave.user_id,
                var_User_Name = inquirySave.user_name,
                var_SalesInquiry = inquirySave.salesinquiry,
                var_SalesArea = inquirySave.salesarea,
                var_Destination = inquirySave.destination,
                var_CustomerReference = inquirySave.customerreference,
                var_SalesNote = inquirySave.salesnote,
                var_Item_Id = inquirySave.item_id,
                var_Rate = inquirySave.rate,
                var_Quantity = inquirySave.quantity,
                var_UOM = inquirySave.uom,
                var_Price = inquirySave.price,
                var_LrDetails = inquirySave.lrdetails,
                var_ProductionInstructions = inquirySave.productioninstructions,
                var_Is_Active = inquirySave.is_active,
                var_Is_Deleted = inquirySave.is_deleted,
                var_Entry_Item_Id = inquirySave.entry_item_id,
                var_Dealer_Id = inquirySave.dealer_id,
                var_Inquiry_Status = inquirySave.inquiry_status,
                var_sales_person = inquirySave.sales_person,
                var_Retailer_Id = inquirySave.retailer_id,
                var_SalesUser_Id = inquirySave.salesuser_id,
            });

            var result = this.db.Query<CommonOutput>("USP_SAdminSalesInquiry_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            return result;
        }

        public List<ResInquiry> GetInquiry(ReqInquiry inquirySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = inquirySearch.method_name,
                var_Org_Id = inquirySearch.org_id,
                var_SalesInquiry = inquirySearch.salesinquiry,
                var_Date = inquirySearch.search_period,
                var_Item_Id = inquirySearch.item_id,
                var_Dealer_Id = inquirySearch.dealer_id,

            });

            var result = this.db.Query<ResInquiry>("USP_SAdminSalesInquiry_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }


        public List<ResProductMaster> GetInquiryProduct(ReqInquiry inquirySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = inquirySearch.method_name,
                var_Org_Id = inquirySearch.org_id,
                var_SalesInquiry = inquirySearch.salesinquiry,
                var_Date = inquirySearch.search_period,
                var_Item_Id = inquirySearch.item_id,
                var_Dealer_Id = inquirySearch.dealer_id,

            });

            var result = this.db.Query<ResProductMaster>("USP_SAdminSalesInquiry_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }



    }
}
