//using Dapper;
//using MilkOUT_API.Areas.AdminConsole_API.Models;
//using System.Data;
//using MySql.Data.MySqlClient;
//using Dapper;

//namespace MilkOUT_API.Areas.AdminConsole_API.DAL
//{
//    public class InvoiceDAL
//    {
//        private IConfigurationRoot configuration = new ConfigurationBuilder()
//          .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
//          .AddJsonFile("appsettings.json")
//          .Build();

//        private IDbConnection db;

//        public InvoiceDAL(string Destination)
//        {
//            string ConnectionName;
//            switch (Destination)
//            {
//                case "MIP":
//                    ConnectionName = "ConnectionPRD";
//                    break;
//                case "MIU":
//                    ConnectionName = "ConnectionUAT";
//                    break;
//                default:
//                    ConnectionName = "ConnectionDEV";
//                    break;

//            }
//            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
//        }
//        public List<ResInvoice> GetInvoice(ReqInvoice InvoiceSearch)
//        {
//            var parameters = new DynamicParameters(new
//            {
//                var_Method_Name = InvoiceSearch.method_name,
//                var_Org_Id = InvoiceSearch.org_id,
//                var_User_Id = InvoiceSearch.user_id,
//                var_Destination_name = InvoiceSearch.destination_name,

//                var_Invoice_Id = InvoiceSearch.invoice_id,
//                var_Invoice_Account = InvoiceSearch.invoice_account,
//                var_Invoice_Date = InvoiceSearch.invoice_date,
//                var_Payment_Term = InvoiceSearch.payment_term,
//                var_Order_Details = InvoiceSearch.order_details,
//                var_Tem_Description = InvoiceSearch.item_description,
//                var_Billing_Quality = InvoiceSearch.billing_quality,
//                var_Billing_Uom = InvoiceSearch.billing_uom,
//                var_Plant = InvoiceSearch.plant,
//                var_Net_Amount = InvoiceSearch.net_amount
//            });

//            var result = this.db.Query<ResInvoice>("USP_AdminRetailer_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
//            return result;
//        }
//    }
    
//}
