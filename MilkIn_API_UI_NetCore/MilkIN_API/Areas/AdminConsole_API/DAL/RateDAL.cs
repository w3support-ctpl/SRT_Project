using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using System.Xml;
using System;


namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class RateDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public RateDAL(string Destination)
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

        /*----  ----    ----    ----    Slab Get & Save   ----    ----    ----    ----*/

        public List<ResSlab> GetSlab(ReqSlab slabSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = slabSearch.method_name,
                var_Org_Id = slabSearch.org_id,
                var_Slab_Id = slabSearch.slab_id,
                var_Slab_Name = slabSearch.slab_name,
                var_User_id = slabSearch.user_id,
                var_Slab_Type = slabSearch.slab_type
            });

            return this.db.Query<ResSlab>("USP_AdminSlab_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveSlab(ReqSlab slabSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = slabSave.method_name,
                var_Org_Id = slabSave.org_id,
                var_Slab_Id = slabSave.slab_id,
                var_Slab_Name = slabSave.slab_name,
                var_Slab_Min = slabSave.slab_min,
                var_Slab_Max = slabSave.slab_max,
                var_User_Id = slabSave.user_id,
                var_User_Name = slabSave.user_name,
                var_Is_Active = slabSave.is_active,
                var_Is_Deleted = slabSave.is_deleted,
                var_destination_name = slabSave.destination_name,
                var_Slab_Type = slabSave.slab_type
            });

            return this.db.Query<CommonOutput>("USP_AdminSlab_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Diesel Get & Save   ----    ----    ----    ----*/

        public List<ResDiesel> GetDiesel(ReqDiesel dieselSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dieselSearch.method_name,
                var_Org_Id = dieselSearch.org_id,
                var_Date = dieselSearch.date,
                var_DieselRate_Id = dieselSearch.dieselrate_id,
                var_User_id = dieselSearch.user_id
            });

            return this.db.Query<ResDiesel>("USP_AdminDieselRate_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveDiesel(ReqDiesel dieselSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = dieselSave.method_name,
                var_Org_Id = dieselSave.org_id,
                var_DieselRate = dieselSave.dieselrate,
                var_DieselRate_Id = dieselSave.dieselrate_id,
                var_DieselRate_Date = dieselSave.dieselrate_date,
                var_Is_Active = dieselSave.is_active,
                var_Is_Deleted = dieselSave.is_deleted,
                var_User_id = dieselSave.user_id,
                var_User_name = dieselSave.user_name,
                var_destination_name = dieselSave.destination_name,
            });

            return this.db.Query<CommonOutput>("USP_AdminDieselRate_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Milk Rate Get & Save   ----    ----    ----    ----*/

        public List<ResMilkRate> GetMilkRate(ReqMilkRate milkRateSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateSearch.method_name,
                var_Org_Id = milkRateSearch.org_id,
                var_User_Id = milkRateSearch.user_id,
                var_Destination_name = milkRateSearch.destination_name,
                var_MilkType_Id = milkRateSearch.milktype_id,
                var_MilkStatus_Id = milkRateSearch.milkstatus_id,
                var_Chart_Id = milkRateSearch.chart_id,
                var_Chart_Name = milkRateSearch.chart_name,
                var_Date = milkRateSearch.rate_date,
                var_MCC_Id = milkRateSearch.mcc_id,
                var_CollectionShift_Id = milkRateSearch.collectionshift_id,
                var_Profile_Id = ""

            });
            return this.db.Query<ResMilkRate>("USP_AdminMilkRate_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveMilkRate(ReqMilkRate milkRateSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateSave.method_name,
                var_Org_Id = milkRateSave.org_id,
                var_User_Id = milkRateSave.user_id,
                var_Destination_name = milkRateSave.destination_name,
                var_User_Name = milkRateSave.user_name,
                var_Chart_Id = milkRateSave.chart_id,
                var_Chart_Name = milkRateSave.chart_name,
                var_MilkType_Id = milkRateSave.milktype_id,
                var_MilkStatus_Id = milkRateSave.milkstatus_id,
                var_UOM_Id = milkRateSave.uom_id,
                var_CollectionShift_Id = milkRateSave.collectionshift_id,
                var_Is_Lived = milkRateSave.is_lived,
                var_Is_Active = milkRateSave.is_active,
                var_Is_Deleted = milkRateSave.is_deleted
            });
            return this.db.Query<CommonOutput>("USP_AdminMilkRate_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Milk Rate Item Get & Save   ----    ----    ----    ----*/

        public List<ResMilkRateItem> GetMilkRateItem(ReqMilkRateItem milkRateItemSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateItemSearch.method_name,
                var_Org_Id = milkRateItemSearch.org_id,
                var_User_Id = milkRateItemSearch.user_id,
                var_Entry_Id = milkRateItemSearch.entry_id,
                var_Chart_Id = milkRateItemSearch.chart_id,
                var_MilkRateEntryType_Id = milkRateItemSearch.milkrateentrytype_id
            });
            return this.db.Query<ResMilkRateItem>("USP_AdminMilkRateItem_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveMilkRateItem(ReqMilkRateItem milkRateItemSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateItemSave.method_name,
                var_Org_Id = milkRateItemSave.org_id,
                var_User_Id = milkRateItemSave.user_id,
                var_User_Name = milkRateItemSave.user_name,
                var_Is_Active = milkRateItemSave.is_active,
                var_Is_Deleted = milkRateItemSave.is_deleted,
                var_Chart_Id = milkRateItemSave.chart_id,
                var_Entry_Id = milkRateItemSave.entry_id,
                var_MilkRateEntryType_Id = milkRateItemSave.milkrateentrytype_id,
                var_Slab_Id = milkRateItemSave.slab_id,
                var_BaseFat = milkRateItemSave.basefat,
                var_BaseSNF = milkRateItemSave.basesnf,
                var_Version_No = milkRateItemSave.version_no,
                var_Amount = milkRateItemSave.amount,
                var_Applicable_Date = milkRateItemSave.applicable_date

            });
            return this.db.Query<CommonOutput>("USP_AdminMilkRateItem_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Milk Rate MCC Get & Save   ----    ----    ----    ----*/

        public List<ResMilkRateMCC> GetMilkRateMCC(ReqMilkRateMCC milkRateMCCSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateMCCSearch.method_name,
                var_Org_Id = milkRateMCCSearch.org_id,
                var_User_Id = milkRateMCCSearch.user_id,
                var_Chart_Id = milkRateMCCSearch.chart_id,
                var_Version_No = milkRateMCCSearch.version_no,
                var_MilkType_Id = milkRateMCCSearch.milktype_id,
                var_CollectionShift_Id = milkRateMCCSearch.collectionshift_id,
                var_Search_Text = milkRateMCCSearch.search_text

            });

            return this.db.Query<ResMilkRateMCC>("USP_AdminMilkRateMCC_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMilkRateMCC(ReqMilkRateMCC milkRateMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = milkRateMCCSave.method_name,
                var_Org_Id = milkRateMCCSave.org_id,
                var_User_Id = milkRateMCCSave.user_id,
                var_User_Name = milkRateMCCSave.user_name,
                var_MCC_Id = milkRateMCCSave.mcc_id,
                var_Version_No = milkRateMCCSave.version_no,
                var_Chart_Id = milkRateMCCSave.chart_id,
                var_Applicable_Date = milkRateMCCSave.applicable_date

            });
            return this.db.Query<CommonOutput>("USP_AdminMilkRateMCC_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    MCC Commission Get & Save   ----    ----    ----    ----*/

        public List<ResMCCCommission> GetMCCCommission(ReqMCCCommission mccCommissionSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionSearch.method_name,
                var_Org_Id = mccCommissionSearch.org_id,
                var_User_Id = mccCommissionSearch.user_id,
                var_MilkType_Id = mccCommissionSearch.milktype_id,
                var_MPPI_Id = mccCommissionSearch.mppi_id,
                var_MPPI_Name = mccCommissionSearch.mppi_name,
                var_MPPI_Type = mccCommissionSearch.mppitype_id
            });
            return this.db.Query<ResMCCCommission>("USP_AdminMCCCommission_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMCCCommission(ReqMCCCommission mccCommissionSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionSave.method_name,
                var_Org_Id = mccCommissionSave.org_id,
                var_User_Id = mccCommissionSave.user_id,
                var_User_Name = mccCommissionSave.user_name,
                var_MPPI_Id = mccCommissionSave.mppi_id,
                var_MPPI_Name = mccCommissionSave.mppi_name,
                var_MilkType_Id = mccCommissionSave.milktype_id,
                var_MilkStatus_Id = mccCommissionSave.milkstatus_id,
                var_UOM_Id = mccCommissionSave.uom_id,
                var_MCCType_Id = mccCommissionSave.mcctype_id,
                var_MCCWorkType_Id = mccCommissionSave.mccworktype_id,
                var_Is_Active = mccCommissionSave.is_active,
                var_Is_Deleted = mccCommissionSave.is_deleted,
                var_Is_Lived = mccCommissionSave.is_lived,
                var_CollectionShift_Id = mccCommissionSave.collectionshift_id,
                var_MPPI_Type = mccCommissionSave.mppitype_id
            });
            return this.db.Query<CommonOutput>("USP_AdminMCCCommission_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    MCC Commission Item Get & Save   ----    ----    ----    ----*/

        public List<ResMCCCommissionItem> GetMCCCommissionItem(ReqMCCCommissionItem mccCommissionItemSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionItemSearch.method_name,
                var_Org_Id = mccCommissionItemSearch.org_id,
                var_User_Id = mccCommissionItemSearch.user_id,
                var_MPPI_Id = mccCommissionItemSearch.mppi_id,
                var_Entry_Id = mccCommissionItemSearch.entry_id,

            });

            return this.db.Query<ResMCCCommissionItem>("USP_AdminMCCCommissionItem_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMCCCommissionItem(ReqMCCCommissionItem mccCommissionItemSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionItemSave.method_name,
                var_Org_Id = mccCommissionItemSave.org_id,
                var_User_Id = mccCommissionItemSave.user_id,
                var_User_Name = mccCommissionItemSave.user_name,
                var_MPPI_Id = mccCommissionItemSave.mppi_id,
                var_Entry_Id = mccCommissionItemSave.entry_id,
                var_MinimumQuantity = mccCommissionItemSave.minimumquantity,
                var_MaximumQuantity = mccCommissionItemSave.maximumquantity,
                var_BaseRate = mccCommissionItemSave.baserate,
                var_BaseFat = mccCommissionItemSave.basefat,
                var_BaseSNF = mccCommissionItemSave.basesnf,
                var_MinimumFat = mccCommissionItemSave.minimumfat,
                var_MinimumSNF = mccCommissionItemSave.minimumsnf,
                var_MaximumFat = mccCommissionItemSave.maximumfat,
                var_MaximumSNF = mccCommissionItemSave.maximumsnf,
                var_ServiceCharge = mccCommissionItemSave.servicecharge,
                var_Applicable_Date = mccCommissionItemSave.applicable_date,
                var_Version_No = mccCommissionItemSave.version_no,
                var_Is_Active = mccCommissionItemSave.is_active,
                var_Is_Deleted = mccCommissionItemSave.is_deleted,
                Var_FAT_Deduction = mccCommissionItemSave.fat_deduction,
                Var_SNF_Deduction = mccCommissionItemSave.snf_deduction,
                Var_FAT_Incentives = mccCommissionItemSave.fat_incentive,
                Var_SNF_Incentives = mccCommissionItemSave.snf_incentive,

                var_MinimumProtein = mccCommissionItemSave.minimumprotein,
                var_MaximumProtein = mccCommissionItemSave.maximumprotein,
                var_MinimumAsh = mccCommissionItemSave.minimumash,
                var_MaximumAsh = mccCommissionItemSave.maximumash,
            });
            return this.db.Query<CommonOutput>("USP_AdminMCCCommissionItem_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    MCC Commission MCC Get & Save   ----    ----    ----    ----*/

        public List<ResMCCCommissionMCC> GetMCCCommissionMCC(ReqMCCCommissionMCC mccCommissionMCCSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionMCCSearch.method_name,
                var_Org_Id = mccCommissionMCCSearch.org_id,
                var_User_Id = mccCommissionMCCSearch.user_id,
                var_MPPI_Id = mccCommissionMCCSearch.mppi_id,
                var_Version_No = mccCommissionMCCSearch.version_no,
                var_MCCType_Id = mccCommissionMCCSearch.mcctype_id,
                var_MCCWorkType_Id = mccCommissionMCCSearch.mccworktype_id,
                var_Search_MCC = mccCommissionMCCSearch.search_text,
                var_Applicable_Date = mccCommissionMCCSearch.applicable_date

            });

            return this.db.Query<ResMCCCommissionMCC>("USP_AdminMCCCommissionMCC_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
        public List<CommonOutput> SaveMCCCommissionMCC(ReqMCCCommissionMCC mccCommissionMCCSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = mccCommissionMCCSave.method_name,
                var_Org_Id = mccCommissionMCCSave.org_id,
                //var_User_Id = mccCommissionMCCSave.user_id,
                //var_User_Name = mccCommissionMCCSave.user_name,
                var_MCC_Id = mccCommissionMCCSave.mcc_id,
                var_Version_No = mccCommissionMCCSave.version_no,
                var_MPPI_Id = mccCommissionMCCSave.mppi_id,
                var_Applicable_Date = mccCommissionMCCSave.applicable_date

            });
            return this.db.Query<CommonOutput>("USP_AdminMCCCommissionMCC_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Freight Get & Save   ----    ----    ----    ----*/

        public List<ResFreight> GetFreight(ReqFreight freightSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = freightSearch.method_name,
                var_Org_Id = freightSearch.org_id,
                var_Vehicle_Id = freightSearch.vehicle_id,
                var_Freight_Id = freightSearch.freight_id,
                var_User_id = freightSearch.user_id
            });

            return this.db.Query<ResFreight>("USP_AdminFreight_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveFreight(ReqFreight freightSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = freightSave.method_name,
                var_Org_Id = freightSave.org_id,
                var_Freight_Id = freightSave.freight_id,
                var_Vehicle_Id = freightSave.vehicle_id,
                var_FreightRateType_Id = freightSave.freightratetype_id,
                var_Is_Active = freightSave.is_active,
                var_Is_Deleted = freightSave.is_deleted,
                var_User_id = freightSave.user_id,
                var_User_name = freightSave.user_name,
                var_BaseRate = freightSave.baserate,
                var_Amount = freightSave.amount,
                var_Applicable_Date = freightSave.applicable_date,
                var_Version_No = freightSave.version_no
            });

            return this.db.Query<CommonOutput>("USP_AdminFreight_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Fat SNF Ratio Get & Save   ----    ----    ----    ----*/

        public List<ResFatSNFRatio> GetFatSNFRatio(ReqFatSNFRatio fatSNFRatioSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = fatSNFRatioSearch.method_name,
                var_Org_Id = fatSNFRatioSearch.org_id,
                var_Date = fatSNFRatioSearch.ratio_date,
                var_Ratio_Id = fatSNFRatioSearch.ratio_id,
                var_User_id = fatSNFRatioSearch.user_id
            });

            return this.db.Query<ResFatSNFRatio>("USP_AdminFatSNFRatio_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveFatSNFRatio(ReqFatSNFRatio fatSNFRatioSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = fatSNFRatioSave.method_name,
                var_Org_Id = fatSNFRatioSave.org_id,
                var_Ratio_Id = fatSNFRatioSave.ratio_id,
                var_Ratio_Date = fatSNFRatioSave.ratio_date,
                var_Is_Active = fatSNFRatioSave.is_active,
                var_Is_Deleted = fatSNFRatioSave.is_deleted,
                var_User_id = fatSNFRatioSave.user_id,
                var_User_name = fatSNFRatioSave.user_name,
                var_SNF = fatSNFRatioSave.snf,
                var_Fat = fatSNFRatioSave.fat,
                var_OverheadAmount = fatSNFRatioSave.overhead,
            });

            return this.db.Query<CommonOutput>("USP_AdminFatSNFRatio_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



    }
}
