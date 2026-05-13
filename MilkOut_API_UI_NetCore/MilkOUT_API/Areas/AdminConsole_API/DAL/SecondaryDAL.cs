using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class SecondaryDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public SecondaryDAL(string Destination)
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







        /*----  ----    ----    ----    Retailer Order - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResRetailerOrder> GetRetailerOrder(ReqRetailerOrder retailerOrderSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailerOrderSearch.org_id,
                var_Method_Name = retailerOrderSearch.method_name,
                var_User_Id = retailerOrderSearch.user_id,
                var_User_Name = retailerOrderSearch.user_name,
                var_RetailerOrder_Id = retailerOrderSearch.retailerorder_id,
                var_RetailerOrderItem_Id = retailerOrderSearch.retailerorderitem_id,
                var_Order_Period = retailerOrderSearch.search_period,
                var_SalesUser_Id = retailerOrderSearch.salesuser_id,
                var_SalesArea_Id = retailerOrderSearch.salesarea_id,
                var_Dealer_Id = retailerOrderSearch.dealer_id

            });

            var result = this.db.Query<ResRetailerOrder>("USP_SAdminRetailerOrder_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveRetailerOrder(ReqRetailerOrder retailerOrderSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailerOrderSave.org_id,
                var_Method_Name = retailerOrderSave.method_name,
                var_User_Id = retailerOrderSave.user_id,
                var_User_Name = retailerOrderSave.user_name,
                var_RetailerOrder_Id = retailerOrderSave.retailerorder_id,
                var_RetailerOrderItem_Id = retailerOrderSave.retailerorderitem_id,
                var_Retailer_Id = retailerOrderSave.retailer_id,
                var_Dealer_Id = retailerOrderSave.dealer_id,
                var_SalesUser_Id = retailerOrderSave.salesuser_id,
                var_Remarks = retailerOrderSave.remarks,
                var_Product_Id = retailerOrderSave.product_id,
                var_UOM = retailerOrderSave.uom,
                var_Quantity = retailerOrderSave.quantity,
                var_Request_For = retailerOrderSave.request_for,
                var_Is_Active = retailerOrderSave.is_active,
                var_Is_Deleted = retailerOrderSave.is_deleted
            });
            return this.db.Query<CommonOutput>("USP_SAdminRetailerOrder_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        
        public List<CommonOutput> SaveRetailerOrders(ReqRetailerOrder retailerOrderSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailerOrderSave.org_id,
                var_Method_Name = retailerOrderSave.method_name,
                var_User_Id = retailerOrderSave.user_id,
                var_RetailerOrder_Id = retailerOrderSave.retailerorder_id,
                var_Status = retailerOrderSave.status,
            });
            return this.db.Query<CommonOutput>("USP_SAdminRetailerOrders_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        /*----  ----    ----    ----    Dealer Stock - Send and receive data through API   ----    ----    ----    ----*/
        public List<ResDealerStock> GetDealerStock(ReqDealerStock dealerStockSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = dealerStockSearch.org_id,
                var_Method_Name = dealerStockSearch.method_name,
                var_User_Id = dealerStockSearch.user_id,
                var_User_Name = dealerStockSearch.user_name,
                var_DealerStock_Id = dealerStockSearch.dealerstock_id,
                var_Entry_Period = dealerStockSearch.entry_period,
                var_Dealer_Id = dealerStockSearch.dealer_id


            });

            var result = this.db.Query<ResDealerStock>("USP_SAdminDealerStock_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveDealerStock(ReqDealerStock dealerStockSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = dealerStockSave.org_id,
                var_Method_Name = dealerStockSave.method_name,
                var_User_Id = dealerStockSave.user_id,
                var_User_Name = dealerStockSave.user_name,
                var_DealerStock_Id = dealerStockSave.dealerstock_id,
                var_Dealer_Id = dealerStockSave.dealer_id,
                var_Date = dealerStockSave.dealerstock_date,
                var_Product_Data = dealerStockSave.product_data,
                var_Is_Active = dealerStockSave.is_active,
                var_Is_Deleted = dealerStockSave.is_deleted
            });
            return this.db.Query<CommonOutput>("USP_SAdminDealerStock_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
    }
}
