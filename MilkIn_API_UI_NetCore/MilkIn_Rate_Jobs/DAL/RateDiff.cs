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
using MilIn_DayEnd_Jobs.Models;
using MilIn_DayEnd_Jobs.DAL;

namespace MilIn_DayEnd_Jobs.DAL
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
            // 1. Check if any materials  is waiting for posting
            try
            {
               // Get All New materials
               var parameters = new DynamicParameters(new
               {
                   var_Method_Name = "Get_Materials",
                   var_Org_Id = OrgId
               });

               List<ResMaterials> PendingMaterialLsist = new List<ResMaterials>();
               PendingMaterialLsist = this.db.Query<ResMaterials>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

               Console.WriteLine(PendingMaterialLsist.Count + " materials Found");

               for (int i = 0; i < PendingMaterialLsist.Count; i++)
               {
                    // Post materials to SAP
                    new Materials(SAPUserName, SAPPassword, SAPAPIURL).SaveMaterials(PendingMaterialLsist[i]);
                    Console.WriteLine("Materials Entry " + i + " Posted");
                }

            }
            catch (Exception ex)
            {
               Console.WriteLine("Error in finding new Materials records");
            }

            try
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "Create",
                    var_Org_Id = OrgId,
                    var_User_Id = "",
                    var_User_Name = "",
                    var_MCC_Id = "",
                    var_Date = ""

                });

                var result = db.Query("USP_AdminMilkRate_Checker_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
                Console.WriteLine("Stored Procedure executed successfully");

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in finding Rate");
            }


        }
    }
}