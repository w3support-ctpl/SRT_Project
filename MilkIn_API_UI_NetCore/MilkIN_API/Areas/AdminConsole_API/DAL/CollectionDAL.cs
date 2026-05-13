using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;
using static MilkIN_API.Middleware.Notify;
using MilkIN_API.Areas.AdminConsole_API.FleetX;
using Newtonsoft.Json;
using MilkIN_API.Middleware;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class CollectionDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;
        public CollectionDAL(string Destination)
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


        /*----  ----    ----    ----    MilkCollection Get & Save   ----    ----    ----    ----*/

        public List<ResMilkCollection> GetMilkCollection(ReqMilkCollection milkCollectionSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionSearch.method_name,
                var_Org_Id = milkCollectionSearch.org_id,
                var_User_Id = milkCollectionSearch.user_id,
                var_Vehicle_Id = milkCollectionSearch.vehicle_id,
                var_MCC_Id = milkCollectionSearch.mcc_id,
                var_MCCCollectionShift_Id = milkCollectionSearch.mcccollectionshift_id,
                var_TripDocument_Id = milkCollectionSearch.tripdocument_id,
                var_Collected = milkCollectionSearch.is_collected,
                var_VehicleType = milkCollectionSearch.vehicletype,
                var_MilkCollectionDairy_Id = milkCollectionSearch.milkcollectiondairy_id,
                var_Date = milkCollectionSearch.search_period,
            });

            return this.db.Query<ResMilkCollection>("USP_AdminMilkCollection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMilkCollection(ReqMilkCollection milkCollectionSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionSave.method_name,
                var_Org_Id = milkCollectionSave.org_id,
                var_User_Id = milkCollectionSave.user_id,
                var_User_Name = milkCollectionSave.user_name,
                var_Is_Active = milkCollectionSave.is_active,
                var_Is_Deleted = milkCollectionSave.is_deleted,
                var_TripDocument_Id = milkCollectionSave.tripdocument_id,
                var_MCCCollectionShift_Id = milkCollectionSave.mcccollectionshift_id,
                var_MilkCollectionDairy_Id = milkCollectionSave.milkcollectiondairy_id,
                var_MCC_Id = milkCollectionSave.mcc_id,
                var_MilkData = milkCollectionSave.milkdata,
                var_Vehicle_Id = milkCollectionSave.vehicle_id,
                var_VehicleType_Id = milkCollectionSave.vehicletype_id,
                var_MCCCommission = "",
                var_Date = milkCollectionSave.search_period,

            });


            return this.db.Query<CommonOutput>("USP_AdminMilkCollection_Set", parameters, commandType: CommandType.StoredProcedure ,commandTimeout: 0).ToList();
        }


        public List<CommonOutput> SaveGoodsInwardPostingList(ReqMilkCollectionInSAP milkCollectionSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionSave.method_name,
                var_Org_Id = milkCollectionSave.org_id,
                var_Entry_Id = "",
                var_MilkCollectionDairy_Id = milkCollectionSave.milkcollectiondairy_id,
                var_Year = "",
                var_SAP_Document_Id = "",
                var_User_Id = milkCollectionSave.user_id,
                var_User_Name = milkCollectionSave.user_name,

            });


            return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }


        public List<CommonOutput> SaveMilkCollectionReverse(ReqMilkCollectionInSAP milkCollectionSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionSave.method_name,
                var_Org_Id = milkCollectionSave.org_id,
                var_Entry_Id = "",
                var_MilkCollectionDairy_Id = milkCollectionSave.milkcollectiondairy_id,
                var_Year = "",
                var_SAP_Document_Id = "",
                var_User_Id = milkCollectionSave.user_id,
                var_User_Name = milkCollectionSave.user_name,

            });


            return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }


        public List<ResSendSMS> SendSMS(ReqSendSMS reqSendSMS)
        {
            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = reqSendSMS.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();


            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Send_SMS",
                var_Org_Id = reqSendSMS.org_id,
                var_MilkCollectionDairy_Id = reqSendSMS.milkcollectiondairy_id,
            });


            List<ResSendSMS> res_Obj = this.db.Query<ResSendSMS>("USP_AdminSendSMS_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            foreach (var response in res_Obj)
            {
                string mobileNumber;
                if (response.vehicletype_id == "C020001")
                {
                    if (Connection_Name == "PRD")
                    {
                        mobileNumber = response.mobileno;
                    }
                    else
                    {
                        mobileNumber = "8308952088";
                    }
                    new Notify(Connection_Name, configuration).Send_SMS_Message(response.message, mobileNumber, "1107160973844571284");
                }
                if (response.vehicletype_id == "C020002")
                {
                    if (Connection_Name == "PRD")
                    {
                        mobileNumber = response.mobileno;
                    }
                    else
                    {
                        mobileNumber = "8308952088";
                    }
                    new Notify(Connection_Name, configuration).Send_SMS_Message(response.message, mobileNumber, "1107162028530135848");
                }

            }


            var parametersDataShift = new DynamicParameters(new
            {
                var_Method_Name = "DataShift",
                var_Org_Id = reqSendSMS.org_id,
                var_MilkCollectionDairy_Id = reqSendSMS.milkcollectiondairy_id,
            });


            //this.db.Query<ResSendSMS>("USP_AdminSendSMS_Get", parametersDataShift, commandType: CommandType.StoredProcedure).ToList();

            var dataShiftResponse = this.db.Query<ResSendSMS>("USP_AdminSendSMS_Get", parametersDataShift, commandType: CommandType.StoredProcedure).ToList();

            if (!dataShiftResponse.Any())
            {
                // Log or handle case when DataShift returns no results
                Console.WriteLine("DataShift operation returned no results.");
            }

            return res_Obj;
        }

        /*----  ----    ----    ----    MilkCollection Quantity Get & Save   ----    ----    ----    ----*/

        public List<ResMilkCollectionQuantity> GetMilkCollectionQuantity(ReqMilkCollectionQuantity milkCollectionQuantitySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionQuantitySearch.method_name,
                var_Org_Id = milkCollectionQuantitySearch.org_id,
                var_User_Id = milkCollectionQuantitySearch.user_id,
                var_Entry_Id = milkCollectionQuantitySearch.entry_id,
                var_TripDocument_Id = milkCollectionQuantitySearch.tripdocument_id,
                var_MCCCollectionShift_Id = milkCollectionQuantitySearch.mcccollectionshift_id,
                var_MilkCollectionDairy_Id = milkCollectionQuantitySearch.milkcollectiondairy_id,
                var_MCC_Id = milkCollectionQuantitySearch.mcc_id,
                var_Batch_Id = milkCollectionQuantitySearch.batch_id,
                var_Vehicle_Id = milkCollectionQuantitySearch.vehicle_id,
                var_Date = milkCollectionQuantitySearch.search_period,

            });

            return this.db.Query<ResMilkCollectionQuantity>(milkCollectionQuantitySearch.stored_procedure, parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMilkCollectionQuantity(ReqMilkCollectionQuantity milkCollectionQuantitySave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionQuantitySave.method_name,
                var_Org_Id = milkCollectionQuantitySave.org_id,
                var_Entry_Id = milkCollectionQuantitySave.entry_id,
                var_TripDocument_Id = milkCollectionQuantitySave.tripdocument_id,
                var_MCCCollectionShift_Id = milkCollectionQuantitySave.mcccollectionshift_id,
                var_MCC_Id = milkCollectionQuantitySave.mcc_id,
                var_MilkType_Id = milkCollectionQuantitySave.milktype_id,
                var_MilkStatus_Id = milkCollectionQuantitySave.milkstatus_id,
                var_Weight = milkCollectionQuantitySave.weight,
                var_Cans = milkCollectionQuantitySave.cans,
                var_MilkCollectionDairy_Id = milkCollectionQuantitySave.milkcollectiondairy_id,
                var_CellNo = milkCollectionQuantitySave.cellno,
                var_Vehicle_Id = milkCollectionQuantitySave.vehicle_id,
                var_Is_Active = milkCollectionQuantitySave.is_active,
                var_Is_Deleted = milkCollectionQuantitySave.is_deleted,
                var_User_Id = milkCollectionQuantitySave.user_id,
                var_User_Name = milkCollectionQuantitySave.user_name,
                var_Batch_Id = milkCollectionQuantitySave.batch_id,
                var_SupervisorData = milkCollectionQuantitySave.supervisordata,
                var_GrossWeight = milkCollectionQuantitySave.gross_weight,
                var_TareWeight = milkCollectionQuantitySave.tare_weight,
                var_Reasons = milkCollectionQuantitySave.reasons,
                var_Date = milkCollectionQuantitySave.search_period,
            });

            return this.db.Query<CommonOutput>(milkCollectionQuantitySave.stored_procedure, parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        /*----  ----    ----    ----    MilkCollection Quality Get & Save   ----    ----    ----    ----*/

        public List<ResMilkCollectionQuality> GetMilkCollectionQuality(ReqMilkCollectionQuality milkCollectionQualitySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionQualitySearch.method_name,
                var_Org_Id = milkCollectionQualitySearch.org_id,
                var_User_Id = milkCollectionQualitySearch.user_id,
                var_Entry_Id = milkCollectionQualitySearch.entry_id,
                var_TripDocument_Id = milkCollectionQualitySearch.tripdocument_id,
                var_MCCCollectionShift_Id = milkCollectionQualitySearch.mcccollectionshift_id,
                var_MCC_Id = milkCollectionQualitySearch.mcc_id,
                var_MilkCollectionDairy_Id = milkCollectionQualitySearch.milkcollectiondairy_id,
                var_Batch_Id = milkCollectionQualitySearch.batch_id,
                var_Vehicle_Id = milkCollectionQualitySearch.vehicle_id,
                var_Date = milkCollectionQualitySearch.search_period,
            });

            return this.db.Query<ResMilkCollectionQuality>(milkCollectionQualitySearch.stored_procedure, parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMilkCollectionQuality(ReqMilkCollectionQuality milkCollectionQualitySave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionQualitySave.method_name,
                var_Org_Id = milkCollectionQualitySave.org_id,
                var_Entry_Id = milkCollectionQualitySave.entry_id,
                var_TripDocument_Id = milkCollectionQualitySave.tripdocument_id,
                var_MCCCollectionShift_Id = milkCollectionQualitySave.mcccollectionshift_id,
                var_MCC_Id = milkCollectionQualitySave.mcc_id,
                var_Sample_No = milkCollectionQualitySave.sample_no,
                var_MilkStatus_Id = milkCollectionQualitySave.milkstatus_id,
                var_SNF = milkCollectionQualitySave.snf,
                var_Fat = milkCollectionQualitySave.fat,
                var_MilkCollectionDairy_Id = milkCollectionQualitySave.milkcollectiondairy_id,
                var_CellNo = milkCollectionQualitySave.cellno,
                var_Vehicle_Id = milkCollectionQualitySave.vehicle_id,
                var_Is_Active = milkCollectionQualitySave.is_active,
                var_Is_Deleted = milkCollectionQualitySave.is_deleted,
                var_User_Id = milkCollectionQualitySave.user_id,
                var_User_Name = milkCollectionQualitySave.user_name,
                var_Batch_Id = milkCollectionQualitySave.batch_id,
                var_Cans = milkCollectionQualitySave.cans,
                var_Date = milkCollectionQualitySave.search_period,

            });
            return this.db.Query<CommonOutput>(milkCollectionQualitySave.stored_procedure, parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }



        /*----  ----    ----    ----    MilkCollection Supervisor Get   ----    ----    ----    ----*/
        /*
        public List<ResMilkCollectionSupervisor> GetMilkCollectionSupervisor(ReqMilkCollectionSupervisor milkCollectionSupervisorSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionSupervisorSearch.method_name,
                var_Org_Id = milkCollectionSupervisorSearch.org_id,
                var_User_Id = milkCollectionSupervisorSearch.user_id,
                
            });

            return this.db.Query<ResMilkCollectionSupervisor>("USP_AdminMilkCollection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        */
        /*
        public List<CommonOutput> SaveMilkCollectionChemist(ReqMilkCollectionChemist milkCollectionChemistSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionChemistSave.method_name,
                var_Org_Id = milkCollectionChemistSave.org_id,
                var_SNF = milkCollectionChemistSave.snf,
                var_Fat = milkCollectionChemistSave.fat,
                var_CellNo = milkCollectionChemistSave.cellno
            });
            return this.db.Query<CommonOutput>("", parameters, commandType: CommandType.StoredProcedure).ToList();
        }*/


        /*----  ----    ----    ----    Milk Collection Analyst Get   ----    ----    ----    ----*/
        /*
        public List<ResMilkCollectionAnalyst> GetMilkCollectionAnalyst(ReqMilkCollectionAnalyst milkCollectionAnalystSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkCollectionAnalystSearch.method_name,
                var_Org_Id = milkCollectionAnalystSearch.org_id,
                var_User_Id = milkCollectionAnalystSearch.user_id
            });

            return this.db.Query<ResMilkCollectionAnalyst>("USP_AdminMilkCollection_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        */


        /*----  ----    ----    ----    Trip Document Get & Save   ----    ----    ----    ----*/
        public List<ResTripDocument> GetTripDocument(ReqTripDocument tripDocumentSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = tripDocumentSearch.method_name,
                var_Org_Id = tripDocumentSearch.org_id,
                var_User_Id = tripDocumentSearch.user_id,
                var_TripDocument_Id = tripDocumentSearch.tripdocument_id,
                var_Date = tripDocumentSearch.date,
                var_TripDocumentStatus_Id = tripDocumentSearch.tripdocumentstatus_id
            });

            return this.db.Query<ResTripDocument>("USP_AdminTripDocument_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveTripDocument(ReqTripDocument tripDocumentSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = tripDocumentSave.method_name,
                var_Org_Id = tripDocumentSave.org_id,
                var_User_Id = tripDocumentSave.user_id,
                var_User_Name = tripDocumentSave.user_name,
                var_Is_Active = tripDocumentSave.is_active,
                var_Is_Deleted = tripDocumentSave.is_deleted,
                var_FreightRateType_Id = tripDocumentSave.freightratetype_id,
                var_FinalDistance = tripDocumentSave.finaldistance,
                var_TripDocument_Id = tripDocumentSave.tripdocument_id,
                var_Rate = tripDocumentSave.rate,
                var_TripAmount = tripDocumentSave.tripamount,

                var_DieselBaseRate = tripDocumentSave.dieselbaserate,
                var_CurrentDieselRate = tripDocumentSave.currentdieselrate,
                var_Weight = tripDocumentSave.weight,
                var_Liters = tripDocumentSave.liters,
                var_FleetX_Id = tripDocumentSave.fleetx_id,
                var_DistanceAsPerFleetX = tripDocumentSave.disatance_fleetx,
                var_DistanceAsPerApp = tripDocumentSave.disatance_driver,

            });

            return this.db.Query<CommonOutput>("USP_AdminTripDocument_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        public List<CommonOutput> SaveTripDocumentKM(ReqTripDocument tripDocumentSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = tripDocumentSave.method_name,
                var_Org_Id = tripDocumentSave.org_id,
                var_User_Id = tripDocumentSave.user_id,
                var_User_Name = tripDocumentSave.user_name,
                var_Out_KM = tripDocumentSave.out_km,
                var_IN_KM = tripDocumentSave.in_km,
                var_TripDocument_Id = tripDocumentSave.tripdocument_id,

            });

            return this.db.Query<CommonOutput>("USP_AdminTripDocumentKM_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }


        //public List<CommonOutput> GetFleetXIdData(ReqTripDocument tripDocumentSave)
        //{
        //    var dynamic = new FleetX_Data().GetFleetXData(tripDocumentSave.fleetx_id);
        //    dynamic Data = JsonConvert.DeserializeObject<dynamic>(dynamic);

        //    string FleetXDistance = Data["route"]["distance"].ToString();

        //    CommonOutput commonOutput = new CommonOutput
        //    {
        //        result_id = 1, // Assuming result_id is an integer
        //        result_description = FleetXDistance,
        //        result_extra_key = ""
        //    };

        //    // Return the CommonOutput instance as a list with a single item
        //    return new List<CommonOutput> { commonOutput };
        //}

        public List<CommonOutput> GetFleetXIdData(ReqTripDocument tripDocumentSave)
        {
            try
            {
                var dynamicData = new FleetX_Data().GetFleetXData(tripDocumentSave.fleetx_id);
                dynamic Data = JsonConvert.DeserializeObject<dynamic>(dynamicData);

                string FleetXDistance = Data["route"]["distance"].ToString();

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = FleetXDistance,
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            catch (Exception ex)
            {
                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {ex.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return new List<CommonOutput> { commonOutput };
            }
        }


        public String GetMaterialSap(string value)
        {

            return value;

        }


        /*----  ----    ----    ----    Goods Inward Posting Get & Save   ----    ----    ----    ----*/
        public List<ResGoodsInwardPosting> GetGoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPostingSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = GoodsInwardPostingSearch.method_name,
                var_Org_Id = GoodsInwardPostingSearch.org_id,
                var_User_Id = GoodsInwardPostingSearch.user_id,
                var_Date = GoodsInwardPostingSearch.search_period,
                var_Entry_Id = GoodsInwardPostingSearch.entry_id,
                var_MilkCollectionDairy_Id = GoodsInwardPostingSearch.milkcollectiondairy_id,
                var_TripDocument_Id = GoodsInwardPostingSearch.tripdocument_id
            });

            return this.db.Query<ResGoodsInwardPosting>("USP_AdminMilkCollectionInSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveGoodsInwardPostingGRN(ReqGoodsInwardPosting goodsInwardPostingSave)
        {
              List<CommonOutput> res_Obj = new List<CommonOutput>();

            var parameters = new DynamicParameters(new
            {
                var_Method_Name = goodsInwardPostingSave.method_name,
                var_Org_Id = goodsInwardPostingSave.org_id,
                var_Entry_Id = goodsInwardPostingSave.entry_id,
                var_MilkCollectionDairy_Id = goodsInwardPostingSave.milkcollectiondairy_id,
                var_MCC_Id = goodsInwardPostingSave.mcc_id,
                var_Weight = goodsInwardPostingSave.quantity,
                var_SNF = goodsInwardPostingSave.snf,
                var_Fat = goodsInwardPostingSave.fat,
                var_Protein = goodsInwardPostingSave.protein,
                var_Ash = goodsInwardPostingSave.ash,
                var_Sodium = goodsInwardPostingSave.sodium,
                var_User_Id = goodsInwardPostingSave.user_id,
                var_User_Name = goodsInwardPostingSave.user_name,
            });


           res_Obj = this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAPGRN_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_Commission = new DynamicParameters(new
            {

                var_Method_Name = "Create_Commission_New",
                var_Org_Id = goodsInwardPostingSave.org_id,
                var_Entry_Id = goodsInwardPostingSave.entry_id,
                var_MilkCollectionDairy_Id = goodsInwardPostingSave.milkcollectiondairy_id,
                var_MCC_Id = goodsInwardPostingSave.mcc_id,
                var_Weight = goodsInwardPostingSave.quantity,
                var_SNF = goodsInwardPostingSave.snf,
                var_Fat = goodsInwardPostingSave.fat,
                var_Protein = goodsInwardPostingSave.protein,
                var_Ash = goodsInwardPostingSave.ash,
                var_Sodium = goodsInwardPostingSave.sodium,
                var_User_Id = goodsInwardPostingSave.user_id,
                var_User_Name = goodsInwardPostingSave.user_name,
            });

            this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAPGRN_Set", parameters_Commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

             

            // Return the CommonOutput instance as a list with a single item
            return res_Obj;
        }

        public List<CommonOutput> SaveGoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPostingSave)
        {


            ReqSAPMilkBatch parameter = new ReqSAPMilkBatch();

            var parameterGoodsMovementCode = new DynamicParameters(new
            {

                var_Method_Name = "Get_GoodsMovementCode",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = "",
                var_Entry_Id = "",
                var_TripDocument_Id = "",
            });

            var GoodsMovementCodeResult = this.db.Query<ReqSAPMilkBatchGoodsMovementCode>("USP_AdminMilkCollectionInSAP_Get", parameterGoodsMovementCode, commandType: CommandType.StoredProcedure).ToList();

            parameter.PostingDate = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss");
            /* parameter.PostingDate = "2023-11-15T00:00:00";      */
            parameter.MaterialDocumentHeaderText = "test fr";
            parameter.ReferenceDocument = GoodsInwardPostingSave.milkcollectiondairy_id;
            parameter.GoodsMovementCode = GoodsMovementCodeResult[0].GoodsMovementCode;

            var parameterItem = new DynamicParameters(new
            {

                var_Method_Name = "Get_Quantity_SAP",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                var_Entry_Id = GoodsInwardPostingSave.entry_id,
                var_TripDocument_Id = GoodsInwardPostingSave.tripdocument_id,
            });

            parameter.to_MaterialDocumentItem = this.db.Query<ReqSAPMilkBatchItem>("USP_AdminMilkCollectionInSAP_Get", parameterItem, commandType: CommandType.StoredProcedure).ToList();

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = GoodsInwardPostingSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();
            var dynamic = new CollectionSAP(Connection_Name).SaveMilkBatch(parameter, GoodsInwardPostingSave.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);


            if (jsonResponse.ContainsKey("d"))
            {
                // Extract MaterialDocumentYear and MaterialDocument
                string MaterialDocumentYear = jsonResponse["d"]["MaterialDocumentYear"].ToString();
                string MaterialDocument = jsonResponse["d"]["MaterialDocument"].ToString();


                var parameterItemCost = new DynamicParameters(new
                {

                    var_Method_Name = "Get_Quantity_SAPCost",
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_Date = "",
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Entry_Id = GoodsInwardPostingSave.entry_id,
                    var_TripDocument_Id = GoodsInwardPostingSave.tripdocument_id,
                });

                var parameterItemCostData = this.db.Query<ReqSAPMilkBatchItemCost>("USP_AdminMilkCollectionInSAP_Get", parameterItemCost, commandType: CommandType.StoredProcedure).ToList();


                //TOTQTY

                ReqSAPMilkBatchHeader parameterQty = new ReqSAPMilkBatchHeader();

                parameterQty.Material = parameterItemCostData[0].Material;
                parameterQty.BatchIdentifyingPlant = "";
                parameterQty.Batch = parameterItemCostData[0].Batch;
                parameterQty.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTQTY;
                parameterQty.CharcValueDependency = "1";
                parameterQty.CharcFromNumericValue = parameterItemCostData[0].TOTQTY;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterQty, GoodsInwardPostingSave.org_id);

                //FAT

                ReqSAPMilkBatchHeader parameterFat = new ReqSAPMilkBatchHeader();

                parameterFat.Material = parameterItemCostData[0].Material;
                parameterFat.BatchIdentifyingPlant = "";
                parameterFat.Batch = parameterItemCostData[0].Batch;
                parameterFat.CharcInternalID = parameterItemCostData[0].CharcInternalID_FAT;
                parameterFat.CharcValueDependency = "1";
                parameterFat.CharcFromNumericValue = parameterItemCostData[0].Fat;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterFat, GoodsInwardPostingSave.org_id);


                //SNF

                ReqSAPMilkBatchHeader parameterSNF = new ReqSAPMilkBatchHeader();

                parameterSNF.Material = parameterItemCostData[0].Material;
                parameterSNF.BatchIdentifyingPlant = "";
                parameterSNF.Batch = parameterItemCostData[0].Batch;
                parameterSNF.CharcInternalID = parameterItemCostData[0].CharcInternalID_SNF;
                parameterSNF.CharcValueDependency = "1";
                parameterSNF.CharcFromNumericValue = parameterItemCostData[0].SNF;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterSNF, GoodsInwardPostingSave.org_id);


                //TOTFAT


                ReqSAPMilkBatchHeader parameterTOTFAT = new ReqSAPMilkBatchHeader();

                parameterTOTFAT.Material = parameterItemCostData[0].Material;
                parameterTOTFAT.BatchIdentifyingPlant = "";
                parameterTOTFAT.Batch = parameterItemCostData[0].Batch;
                parameterTOTFAT.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTFAT;
                parameterTOTFAT.CharcValueDependency = "1";
                parameterTOTFAT.CharcFromNumericValue = parameterItemCostData[0].TOTFAT;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterTOTFAT, GoodsInwardPostingSave.org_id);

                //TOTSNF

                ReqSAPMilkBatchHeader parameterTOTSNF = new ReqSAPMilkBatchHeader();

                parameterTOTSNF.Material = parameterItemCostData[0].Material;
                parameterTOTSNF.BatchIdentifyingPlant = "";
                parameterTOTSNF.Batch = parameterItemCostData[0].Batch;
                parameterTOTSNF.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTSNF;
                parameterTOTSNF.CharcValueDependency = "1";
                parameterTOTSNF.CharcFromNumericValue = parameterItemCostData[0].TOTSNF;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterTOTSNF, GoodsInwardPostingSave.org_id);

                //FATCOST

                ReqSAPMilkBatchHeader parameterFatCost = new ReqSAPMilkBatchHeader();

                parameterFatCost.Material = parameterItemCostData[0].Material;
                parameterFatCost.BatchIdentifyingPlant = "";
                parameterFatCost.Batch = parameterItemCostData[0].Batch;
                parameterFatCost.CharcInternalID = parameterItemCostData[0].CharcInternalID_FATCOST;
                parameterFatCost.CharcValueDependency = "1";
                parameterFatCost.CharcFromNumericValue = parameterItemCostData[0].FatCost;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterFatCost, GoodsInwardPostingSave.org_id);

                //SNFCOST

                ReqSAPMilkBatchHeader parameterSNFCost = new ReqSAPMilkBatchHeader();

                parameterSNFCost.Material = parameterItemCostData[0].Material;
                parameterSNFCost.BatchIdentifyingPlant = "";
                parameterSNFCost.Batch = parameterItemCostData[0].Batch;
                parameterSNFCost.CharcInternalID = parameterItemCostData[0].CharcInternalID_SNFCOST;
                parameterSNFCost.CharcValueDependency = "1";
                parameterSNFCost.CharcFromNumericValue = parameterItemCostData[0].SNFCost;

                new CollectionSAP(Connection_Name).SaveMilkBatchHeader(parameterSNFCost, GoodsInwardPostingSave.org_id);


                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "2",
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Year = MaterialDocumentYear,
                    var_SAP_Document_Id = MaterialDocument,
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            }
            else if (jsonResponse.ContainsKey("error"))
            {

                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "3",
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Year = "",
                    var_SAP_Document_Id = "",
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

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
            return new List<CommonOutput>();
        }


        /*----  ----    ----    ----    Goods Inward Posting Get & Save   ----    ----    ----    ----*/
        public List<ResCollectionApproval> GetCollectionApproval(ReqCollectionApproval collectionApprovalSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = collectionApprovalSearch.method_name,
                var_Org_Id = collectionApprovalSearch.org_id,
                var_User_Id = collectionApprovalSearch.user_id,
                var_Date = collectionApprovalSearch.search_period,
                var_Entry_Id = collectionApprovalSearch.entry_id,
                var_MilkCollectionDairy_Id = collectionApprovalSearch.milkcollectiondairy_id,
                var_TripDocument_Id = collectionApprovalSearch.tripdocument_id
            });

            return this.db.Query<ResCollectionApproval>("USP_AdminMilkCollectionInSAP_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }
        public List<CommonOutput> SaveCollectionApproval(ReqCollectionApproval collectionApprovalSave)
        {

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = collectionApprovalSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();



            var parameter_MCC = new DynamicParameters(new
            {

                var_Method_Name = "Delete_MCC",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameter_MCC, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            if (collectionApprovalSave.vehicletype_id == "C020001" && collectionApprovalSave.method_name == "Locked")
            {


                var parameters_Truck = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Truck",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Truck, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            }
            if (collectionApprovalSave.vehicletype_id == "C020002" && collectionApprovalSave.method_name == "Locked")
            {
                var parameters_Tanker = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Tanker",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Tanker, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

                var parameters_Tanker_Sour = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Tanker_Sour",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Tanker_Sour, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

                var parameters_Tanker_Sour_Main = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Tanker_Sour_Main",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Tanker_Sour_Main, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


                var parameters_Tanker_Sour_MCC = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Tanker_Sour_MCC",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Tanker_Sour_MCC, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            }
            if (collectionApprovalSave.vehicletype_id == "BulkSupplier" && collectionApprovalSave.method_name == "Locked")
            {
                var parameters_Tanker = new DynamicParameters(new
                {

                    var_Method_Name = "Create_BulkSupplier",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Tanker, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            }


            var parameter_Commission = new DynamicParameters(new
            {

                var_Method_Name = "Delete_Commission",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameter_Commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_Commission = new DynamicParameters(new
            {

                var_Method_Name = "Create_Commission_New",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Commission, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            if (collectionApprovalSave.vehicletype_id == "C020002")
            {

                var parameters_Commission_Sour = new DynamicParameters(new
                {

                    var_Method_Name = "Create_Commission_Sour",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Commission_Sour, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            }

                var parameters = new DynamicParameters(new
            {

                var_Method_Name = collectionApprovalSave.method_name,
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_TripDocument_Id = collectionApprovalSave.tripdocument_id,
                var_MCCCollectionShift_Id = "",
                var_MCC_Id = "",
                var_Vehicle_Id = "",
                var_VehicleType_Id = collectionApprovalSave.vehicletype_id,
                var_MilkData = "",
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                //var_Entry_Id = collectionApprovalSave.entry_id,
                var_Is_Active = 0,
                var_Is_Deleted = 0,
                var_ApprovalStatus_Id = collectionApprovalSave.approvalstatus_id,
                var_ApprovalRemarks = collectionApprovalSave.approval_remarks,
                var_MCCCommission = collectionApprovalSave.mcc_commission,
                var_Date = "",
            });

            this.db.Query<CommonOutput>("USP_AdminMilkCollection_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_Rate = new DynamicParameters(new
            {

                var_Method_Name = "Create_Rate",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Rate, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_GainLoss = new DynamicParameters(new
            {

                var_Method_Name = "Create_GainLoss",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_GainLoss, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            

            var parameters_Ash = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Ash",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Ash, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_Ash_Sour = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Ash_Sour",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Ash_Sour, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();


            var parameters_Protein = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Protein",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Protein, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_Protein_Sour = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Protein_Sour",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Protein_Sour, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            var parameters_Clear_Sour = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Data_Sour",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Clear_Sour, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            if (collectionApprovalSave.vehicletype_id == "C020002")
            {
                var parameters_Deductions = new DynamicParameters(new
                {

                    var_Method_Name = "Deductions",
                    var_Org_Id = collectionApprovalSave.org_id,
                    var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                    var_User_Id = collectionApprovalSave.user_id,
                    var_User_Name = collectionApprovalSave.user_name,
                    var_MCCGRN = ""
                });

                this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Deductions, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            }



            var parameters_Clear = new DynamicParameters(new
            {

                var_Method_Name = "Clear_Data",
                var_Org_Id = collectionApprovalSave.org_id,
                var_MilkCollectionDairy_Id = collectionApprovalSave.milkcollectiondairy_id,
                var_User_Id = collectionApprovalSave.user_id,
                var_User_Name = collectionApprovalSave.user_name,
                var_MCCGRN = ""
            });

            this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters_Clear, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();



            CommonOutput commonOutput = new CommonOutput
            {
                result_id = 1, // Assuming result_id is an integer
                result_description = collectionApprovalSave.milkcollectiondairy_id,
                result_extra_key = ""
            };

            // Return the CommonOutput instance as a list with a single item
            return new List<CommonOutput> { commonOutput };



        }



        /*----  ----    ----    ----    Gain Loss Entry Get & Save   ----    ----    ----    ----*/
        public List<ResGainLossEntry> GetGainLossEntry(ReqGainLossEntry gainLossEntrySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = gainLossEntrySearch.method_name,
                var_Org_Id = gainLossEntrySearch.org_id,
                var_User_Id = gainLossEntrySearch.user_id,
                var_Date = gainLossEntrySearch.search_period,
                var_Entry_Id = gainLossEntrySearch.entry_id,
                var_MilkCollectionDairy_Id = gainLossEntrySearch.milkcollectiondairy_id,
                var_TripDocument_Id = gainLossEntrySearch.tripdocument_id
            });

            return this.db.Query<ResGainLossEntry>("USP_AdminGainLossEntry_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveGainLossEntry(ReqGainLossEntry gainLossEntrySave)
        {
            var parameters = new DynamicParameters(new
            {

                var_Method_Name = gainLossEntrySave.method_name,
                var_Org_Id = gainLossEntrySave.org_id,
                var_MilkCollectionDairy_Id = gainLossEntrySave.milkcollectiondairy_id,
                var_User_Id = gainLossEntrySave.user_id,
                var_User_Name = gainLossEntrySave.user_name,
                var_MCCGRN = gainLossEntrySave.mcc_commission
            });

            return this.db.Query<CommonOutput>("USP_AdminGainLossEntry_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

        }






        /*----  ----    ----    ----    Quality Entry Get & Save   ----    ----    ----    ----*/
        public List<ResQualityEntry> GetQualityEntry(ReqQualityEntry qualityEntrySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = qualityEntrySearch.method_name,
                var_Org_Id = qualityEntrySearch.org_id,
                var_User_Id = qualityEntrySearch.user_id,
                var_Date = qualityEntrySearch.search_period,
                var_Entry_Id = qualityEntrySearch.entry_id,
                var_MilkCollectionDairy_Id = qualityEntrySearch.milkcollectiondairy_id
            });

            return this.db.Query<ResQualityEntry>("USP_AdminQualityEntry_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveQualityEntry(ReqQualityEntry qualityEntrySave)
        {
            var parameters = new DynamicParameters(new
            {

                var_Method_Name = qualityEntrySave.method_name,
                var_Org_Id = qualityEntrySave.org_id,
                var_MilkCollectionDairy_Id = qualityEntrySave.milkcollectiondairy_id,
                var_Entry_Id = qualityEntrySave.entry_id,
                var_SNF = qualityEntrySave.snf,
                var_Fat = qualityEntrySave.fat,
                var_Protein = qualityEntrySave.protein,
                var_Ash = qualityEntrySave.ash,
                var_Sodium = qualityEntrySave.sodium,
                var_Adulteration = qualityEntrySave.adulteration,
                var_User_Id = qualityEntrySave.milkstatus_id,
                var_User_Name = qualityEntrySave.user_name,
                var_Is_Active = 1,
                var_Is_Deleted = 0
            });

            return this.db.Query<CommonOutput>("USP_AdminQualityEntry_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

        }


        /*----  ----    ----    ----    Machine Data Get    ----    ----    ----    ----*/
        public List<ResMachineData> GetMachineData(ReqMachineData machineDataSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = machineDataSearch.method_name,
                var_Org_Id = machineDataSearch.org_id,
                var_User_Id = machineDataSearch.user_id
            });

            return this.db.Query<ResMachineData>("USP_AdminMachine_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



    }
}

