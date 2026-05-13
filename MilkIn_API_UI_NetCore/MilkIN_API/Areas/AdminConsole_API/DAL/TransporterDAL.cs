using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class TransporterDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public TransporterDAL(string Destination)
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

        /*----  ----    ----    ----    Route Get & Save   ----    ----    ----    ----*/

        public List<ResRoute> GetRoute(ReqRoute routeSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = routeSearch.method_name,
                var_Org_Id = routeSearch.org_id,
                var_Destination_name = routeSearch.destination_name,
                var_Route_Code = routeSearch.route_code,
                var_Route_Name = routeSearch.route_name,
                var_Status = routeSearch.route_status_id,
                var_Route_Id = routeSearch.route_id,
                var_User_Id = routeSearch.user_id,
                var_Is_Lived = routeSearch.is_lived

            });

            var result = this.db.Query<ResRoute>("USP_AdminRoute_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveRoute(ReqRoute routeSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = routeSave.method_name,
                var_Org_Id = routeSave.org_id,
                var_User_Id = routeSave.user_id,
                var_Destination_name = routeSave.destination_name,
                var_User_Name = routeSave.user_name,
                var_Route_Id = routeSave.route_id,
                var_Route_Code = routeSave.route_code,
                var_Route_Name = routeSave.route_name,
                var_CollectionShift_Id = routeSave.collectionshift_id,
                var_VehicleType_Id = routeSave.vehicletype_id,
                var_Freight_Fix_Cost = routeSave.freight_fix_cost,
                var_Frequency = routeSave.frequency_id,
                var_Duration = routeSave.duration,
                var_Fuel_Required = routeSave.fuel_required,
                var_Is_Active = routeSave.is_active,
                var_Is_Deleted = routeSave.is_deleted,
                var_Is_Lived = routeSave.is_lived,
                var_Start_Time = routeSave.start_time,
                var_End_Time = routeSave.end_time,
                var_Start_Date = routeSave.start_date,
                var_End_Date = routeSave.end_date,
                var_Total_Distance = routeSave.total_distance
            });

            return this.db.Query<CommonOutput>("USP_AdminRoute_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Route Item Get & Save   ----    ----    ----    ----*/

        public List<ResRouteItem> GetRouteItem(ReqRouteItem routeItemSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = routeItemSearch.method_name,
                var_Org_Id = routeItemSearch.org_id,
                var_User_Id = routeItemSearch.user_id,
                var_Destination_name = routeItemSearch.destination_name,
                var_User_Name = routeItemSearch.user_name,
                var_Route_Id = routeItemSearch.route_id,
                var_Stage_No = routeItemSearch.stage_no
            });

            return this.db.Query<ResRouteItem>("USP_AdminRouteItem_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveRouteItem(ReqRouteItem routeItemSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = routeItemSave.method_name,
                var_Org_Id = routeItemSave.org_id,
                var_User_Id = routeItemSave.user_id,
                var_Destination_name = routeItemSave.destination_name,
                var_User_Name = routeItemSave.user_name,
                var_Route_Id = routeItemSave.route_id,
                var_Stage_No = routeItemSave.stage_no,
                var_MCC_Id = routeItemSave.mcc_id,
                var_Distance = routeItemSave.distance,
                var_Arrival_Time = routeItemSave.arrival_time,
                var_Departure_Time = routeItemSave.departure_time
            });
            var result = this.db.Query<CommonOutput>("USP_AdminRouteItem_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        /*----  ----    ----    ----    Vehicle Sheet (Truck Sheet & Tanker Sheet) Get & Save   ----    ----    ----    ----*/

        public List<ResVehicleSheet> GetVehicleSheet(ReqVehicleSheet vehicleSheetSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = vehicleSheetSearch.method_name,
                var_Org_Id = vehicleSheetSearch.org_id,
                var_Route_Id = vehicleSheetSearch.route_id,
                var_User_Id = vehicleSheetSearch.user_id,
                var_Entry_Id = vehicleSheetSearch.entry_id,
                var_VehicleType = vehicleSheetSearch.vehicletype

            });

            return this.db.Query<ResVehicleSheet>("USP_AdminTruckSheet_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveVehicleSheet(ReqVehicleSheet vehicleSheetSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = vehicleSheetSave.method_name,
                var_Org_Id = vehicleSheetSave.org_id,
                var_User_Id = vehicleSheetSave.user_id,
                var_Destination_name = vehicleSheetSave.destination_name,
                var_User_Name = vehicleSheetSave.user_name,
                var_Route_Id = vehicleSheetSave.route_id,
                var_VehicleType_Id = vehicleSheetSave.vehicletype_id,
                var_Vehicle_Id = vehicleSheetSave.vehicle_no_id,
                var_Driver_Id = vehicleSheetSave.driver_id,
                var_Chemist_Id = vehicleSheetSave.chemist_id,
                var_From_Date = vehicleSheetSave.from_date,
                var_To_Date = vehicleSheetSave.to_date,
                var_Is_Active = vehicleSheetSave.is_active,
                var_Is_Deleted = vehicleSheetSave.is_deleted,
                var_Entry_Id = vehicleSheetSave.entry_id,
                var_VehicleType = vehicleSheetSave.vehicletype
            });

            return this.db.Query<CommonOutput>("USP_AdminTruckSheet_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Cancel Trip Get & Save   ----    ----    ----    ----*/

        public List<ResManageTrip> GetManageTrip(ReqManageTrip manageTripSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = manageTripSearch.method_name,
                var_Org_Id = manageTripSearch.org_id,
                var_Destination_name = manageTripSearch.destination_name,
                var_User_Id = manageTripSearch.user_id,
                var_Route_Trip_Id = manageTripSearch.entry_id,
                var_Date = manageTripSearch.search_period,
                var_MCC_Id = manageTripSearch.mcc_id,
                var_MCCCollectionShift_Id = manageTripSearch.mcc_collectionshift_id,
                var_TripDocument_Id = manageTripSearch.tripdocument_id,
                var_Profile_Id = manageTripSearch.profile_id,
                var_Reason = manageTripSearch.reason,
            });

            var result = this.db.Query<ResManageTrip>("USP_AdminManageTrip_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<ResManageTrip> GetSetManageTrip(ReqManageTrip manageTripSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = manageTripSave.method_name,
                var_Org_Id = manageTripSave.org_id,
                var_User_Id = manageTripSave.user_id,
                var_Destination_name = manageTripSave.destination_name,
                var_User_Name = manageTripSave.user_name,
                Var_Route_Trip_Id = manageTripSave.entry_id,
                Var_Vehicle_Id = manageTripSave.vehicle_id,
                Var_Profile_Id = manageTripSave.profile_id,
                Var_MCC_Id = manageTripSave.mcc_id,
                Var_Trip_Id = manageTripSave.tripdocument_id,
                Var_Reason = manageTripSave.reason,
            });

            var result = this.db.Query<ResManageTrip>("USP_AdminManageTrips", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
            return result;
        }

        public List<CommonOutput> SaveManageTrip(ReqManageTrip manageTripSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = manageTripSave.method_name,
                var_Org_Id = manageTripSave.org_id,
                var_User_Id = manageTripSave.user_id,
                var_Destination_name = manageTripSave.destination_name,
                var_User_Name = manageTripSave.user_name,
                var_Route_Trip_Id = manageTripSave.entry_id,
                var_Vehicle_Id = manageTripSave.vehicle_id,
                var_Profile_Id = manageTripSave.profile_id,
                var_MCC_Id = manageTripSave.mcc_id,
                var_TripDocument_Id = manageTripSave.tripdocument_id,
                var_MCCCollectionShift_Id = manageTripSave.mcc_collectionshift_id,
                var_Reason = manageTripSave.reason,

                var_CollectionShift_Id = manageTripSave.collectionshift_id,
                var_Farmer_Id = manageTripSave.farmer_id,
                var_Weight = manageTripSave.weight,
                var_SNF = manageTripSave.snf,
                var_Fat = manageTripSave.fat,
                var_MilkType_Id = manageTripSave.milktype_id,
                var_MilkStatus_Id = manageTripSave.milkstatus_id,
                var_Image = "",
                var_CollectionData = manageTripSave.collection_data,
                var_CellNo = manageTripSave.cell_no,
                var_Date = manageTripSave.search_period,
            });

            return this.db.Query<CommonOutput>("USP_AdminManageTrip_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

        /*----  ----    ----    ----    Survey Get & Save   ----    ----    ----    ----*/

        public List<ResSurvey> GetSurvey(ReqSurvey surveySearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = surveySearch.method_name,
                var_Org_Id = surveySearch.org_id,
                var_User_Id = surveySearch.user_id,
                var_Date = surveySearch.applicable_date,
                var_Survey_Id = surveySearch.survey_id

            });

            var result = this.db.Query<ResSurvey>("USP_AdminSurvey_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }
        
        public List<CommonOutput> SaveSurvey(ReqSurvey surveySave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = surveySave.method_name,
                var_Org_Id = surveySave.org_id,
                var_User_Id = surveySave.user_id,
                var_User_Name = surveySave.user_name,
                var_Applicable_Date = surveySave.applicable_date,
                var_Chemist_Id = surveySave.chemist_id,
                var_MCC_Id = surveySave.mcc_id,
                var_Is_Active = surveySave.is_active,
                var_Is_Deleted = surveySave.is_deleted,
                var_Survey_Id = surveySave.survey_id,
                var_Assign = surveySave.assign
            });

            return this.db.Query<CommonOutput>("USP_AdminSurvey_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        /*----  ----    ----    ----    Diesel Upload Get & Save   ----    ----    ----    ----*/

        public List<ResDieselUpload> GetDieselUpload(ReqDieselUpload dieselUploadSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dieselUploadSearch.method_name,
                var_Org_Id = dieselUploadSearch.org_id,
                var_User_Id = dieselUploadSearch.user_id,
                var_DieselUpload_Id = dieselUploadSearch.dieselupload_id,
                var_Date = dieselUploadSearch.search_period

            });

            var result = this.db.Query<ResDieselUpload>("USP_AdminDieselUpload_Get", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
            return result;
        }

        public List<ResDieselUpload> SaveDieselUpload(ReqDieselUpload dieselUploadSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dieselUploadSave.method_name,
                var_Org_Id = dieselUploadSave.org_id,
                var_DieselUpload_Id = dieselUploadSave.dieselupload_id,
                var_File_Name = dieselUploadSave.file_name,
                var_DieselUpload_Data = dieselUploadSave.dieselupload_data,
                var_User_Id = dieselUploadSave.user_id,
                var_User_Name = dieselUploadSave.user_name,
            });

            return this.db.Query<ResDieselUpload>("USP_AdminDieselUpload_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
        }

    }
}
