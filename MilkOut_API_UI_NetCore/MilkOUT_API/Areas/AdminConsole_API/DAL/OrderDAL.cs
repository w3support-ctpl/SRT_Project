
using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Microsoft.AspNetCore.Components;
using static System.Net.Mime.MediaTypeNames;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class OrderDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public OrderDAL(string Destination)
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


        public List<ResProductMaster> GetSalesOrderProduct(ReqInquiry inquirySearch)
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
