using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Security.Cryptography;
using System.Data;
using Dapper;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using MilkOUT_DayEnd_Jobs.Models;

namespace MilkOUT_DayEnd_Jobs.DAL
{
    internal class DayEnd
    {
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;
        private string ConnectionName;
        private string Environment;
        private string OrgId;
        private IDbConnection db;

        public DayEnd()
        {

            OrgId = System.Configuration.ConfigurationManager.AppSettings["OrgId"].ToString();
            Environment = System.Configuration.ConfigurationManager.AppSettings["SAPEnvironment"].ToString();

            switch (Environment)
            {
                case "PRD": // Production
                    SAPUserName = "CTPLABAP_SRTPRD";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my409033-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my407919-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public void Main()
        {
            // // 1. Check if any Retailer Order is waiting for auto closed
            // try
            // {
            //     // Get All Dealer
            //     var parameters = new DynamicParameters(new
            //     {
            //         var_Method_Name = "Get_RetailerOrder",
            //         var_Org_Id = OrgId
            //     });

            //     List<ReqRetailerOrder> RetailerOrderList = new List<ReqRetailerOrder>();
            //     RetailerOrderList = this.db.Query<ReqRetailerOrder>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            //     Console.WriteLine(RetailerOrderList.Count + " Retailer Order Found");

            //     for (int i = 0; i < RetailerOrderList.Count; i++)
            //     {
            //         // Post Dealer to SAP
            //         new SAP_Masters(SAPUserName, SAPPassword, SAPAPIURL).SaveRetailerOrder(RetailerOrderList[i]);
            //         Console.WriteLine("Retailer Order Entry " + i + " Posted");
            //     }

            // }
            // catch (Exception ex)
            // {
            //     Console.WriteLine("Error in finding new Retailer Order records");
            // }

            // // 2. Check if any Dealer Sales Area is waiting for posting
            // try
            // {
            //     // Get All Dealer
            //     var parameters = new DynamicParameters(new
            //     {
            //         var_Method_Name = "Get_DealerSalesArea",
            //         var_Org_Id = OrgId
            //     });

            //     List<ReqDealerSalesArea> PendingDealerSalesAreaList = new List<ReqDealerSalesArea>();
            //     PendingDealerSalesAreaList = this.db.Query<ReqDealerSalesArea>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            //     Console.WriteLine(PendingDealerSalesAreaList.Count + " Dealer Found");

            //     for (int i = 0; i < PendingDealerSalesAreaList.Count; i++)
            //     {
            //         // Post Dealer to SAP
            //         new SAP_Masters(SAPUserName, SAPPassword, SAPAPIURL).SaveDealerSalesArea(PendingDealerSalesAreaList[i]);
            //         Console.WriteLine("Dealer Entry " + i + " Posted");
            //     }

            // }
            // catch (Exception ex)
            // {
            //     Console.WriteLine("Error in finding new Dealer Sales Area records");
            // }

            // 3. Check if any Dealer Stock

            try
            {
                var result = db.Query("USP_SAdminDealerStock_Manage", commandType: CommandType.StoredProcedure, commandTimeout: 0).ToList();
                Console.WriteLine("Stored Procedure executed successfully");

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in finding new Dealer Stock records");
            }

            // // 4. Crate_Dump
            // try
            // {
            //     // Get All Dealer
            //     var parameters = new DynamicParameters(new
            //     {
            //         var_Method_Name = "Get_Dealer_Crate",
            //         var_Org_Id = OrgId
            //     });

            //     List<ReqDealerCrateDump> PendingDealerCrateDumpList = new List<ReqDealerCrateDump>();
            //     PendingDealerCrateDumpList = this.db.Query<ReqDealerCrateDump>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            //     Console.WriteLine(PendingDealerCrateDumpList.Count + " Dealer Found");

            //     for (int i = 0; i < PendingDealerCrateDumpList.Count; i++)
            //     {
            //         // Post Dealer to SAP
            //         new SAP_Masters(SAPUserName, SAPPassword, SAPAPIURL).SaveDealerCrateDump(PendingDealerCrateDumpList[i]);
            //         Console.WriteLine("Dealer Entry " + i + " Posted");
            //     }

            // }
            // catch (Exception ex)
            // {
            //     Console.WriteLine("Error in finding new Dealer Sales Area records");
            // }


        }
    }
}