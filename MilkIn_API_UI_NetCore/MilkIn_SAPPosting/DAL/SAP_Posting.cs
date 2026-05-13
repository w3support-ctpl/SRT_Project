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
using MilkIn_SAPPosting.Models;
using MySql.Data.MySqlClient;

namespace MilkIn_SAPPosting.DAL
{
  internal class SAP_Posting
  {
    private string SAPUserName;
    private string SAPPassword;
    private string SAPAPIURL;
    private string ConnectionName;
    private string Environment;
    private string OrgId;
    private IDbConnection db;

    public SAP_Posting()
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
      // 1. Check if any GRN is waiting for posting
      try
      {
        // Get All New GRN
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_GRN",
          var_Org_Id = OrgId
        });

        List<ReqGoodsInwardPosting> PendingGRNList = new List<ReqGoodsInwardPosting>();
        PendingGRNList = this.db.Query<ReqGoodsInwardPosting>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingGRNList.Count + " GRN Found");

        for (int i = 0; i < PendingGRNList.Count; i++)
        {
          // Post GRN to SAP
          new SAP_GRNPosting(SAPUserName, SAPPassword, SAPAPIURL).SaveGoodsInwardPosting(PendingGRNList[i]);
          Console.WriteLine("GRN Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_GRN", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new GRN records");
      }

      // 2. Check if any Farmer Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Income",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceFarmer> PendingInvoiceList = new List<ReqInvoiceFarmer>();
        PendingInvoiceList = this.db.Query<ReqInvoiceFarmer>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Farmer Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceFarmerInSapIncomeJson(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Income", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 3. Check if any Farmer Deduction is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Deduction",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceFarmer> PendingInvoiceList = new List<ReqInvoiceFarmer>();
        PendingInvoiceList = this.db.Query<ReqInvoiceFarmer>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Farmer Deductions Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceFarmerInSapDeduction(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Deduction Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Deduction", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Deduction records");
      }

      // 4. Check if any MCC Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_MCC_Income",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceMCC> PendingInvoiceList = new List<ReqInvoiceMCC>();
        PendingInvoiceList = this.db.Query<ReqInvoiceMCC>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " MCC Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceMCCInSapIncomeJson(PendingInvoiceList[i]);
          Console.WriteLine("MCC Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_MCC_Income", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 5. Check if any Gain Loss is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Voucher_GainLoss",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceMCC> PendingInvoiceList = new List<ReqInvoiceMCC>();
        PendingInvoiceList = this.db.Query<ReqInvoiceMCC>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " MCC Deduction Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceMCCInSapDeduction(PendingInvoiceList[i]);
          Console.WriteLine("MCC Deduction Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Voucher_GainLoss", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 6. Check if any MCC Deduction is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_MCC_Deduction",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceMCC> PendingInvoiceList = new List<ReqInvoiceMCC>();
        PendingInvoiceList = this.db.Query<ReqInvoiceMCC>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " MCC Deduction Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceMCCInSapDeduction(PendingInvoiceList[i]);
          Console.WriteLine("MCC Deduction Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_MCC_Deduction", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 7. Check if any MCC Rebate is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Rebate",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceMCC> PendingInvoiceList = new List<ReqInvoiceMCC>();
        PendingInvoiceList = this.db.Query<ReqInvoiceMCC>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " MCC Rebate Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceMCCInSapRebate(PendingInvoiceList[i]);
          Console.WriteLine("MCC Rebate Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Rebate", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 8. Check if any Transporter Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Transpoter",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceTransporter> PendingInvoiceList = new List<ReqInvoiceTransporter>();
        PendingInvoiceList = this.db.Query<ReqInvoiceTransporter>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Transporter Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceTransporterInSap(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Transpoter", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 9. Check if any Crate GRN is waiting for posting
      try
      {
        // Get All New GRN
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_CrateGRN",
          var_Org_Id = OrgId
        });

        List<ReqCrateGRNPosting> PendingCrateGRNList = new List<ReqCrateGRNPosting>();
        PendingCrateGRNList = this.db.Query<ReqCrateGRNPosting>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingCrateGRNList.Count + " GRN Found");

        for (int i = 0; i < PendingCrateGRNList.Count; i++)
        {
          // Post GRN to SAP
          new SAP_GRNPosting(SAPUserName, SAPPassword, SAPAPIURL).SaveCrateGRNPosting(PendingCrateGRNList[i]);
          Console.WriteLine("Crate GRN Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_CrateGRN", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Crate GRN records");
      }

      // 10. Check if any Business Parter data is to be updated in SAP
      try
      {
        // Get All Business Partner Data where Is_Posted = 1
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_BPUpdate",
          var_Org_Id = OrgId
        });

        List<ReqBusinessParterList> BusinessPartnerList = new List<ReqBusinessParterList>();
        BusinessPartnerList = this.db.Query<ReqBusinessParterList>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(BusinessPartnerList.Count + " BP Code Found");

        for (int i = 0; i < BusinessPartnerList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_BPPosting(SAPUserName, SAPPassword, SAPAPIURL).SaveBusinessPartnerHeader(BusinessPartnerList[i]);
          Console.WriteLine("Business Partner data " + i + " updated");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_BPUpdate", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding updated BP records");
      }

      // 11. Check if any Rate Change Farmer Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Rate_Change_Farmer_Income",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceFarmer> PendingInvoiceList = new List<ReqInvoiceFarmer>();
        PendingInvoiceList = this.db.Query<ReqInvoiceFarmer>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Farmer Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceRateChangeFarmerInSapIncomeJson(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Rate_Change_Farmer_Income", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }


      // 12. Check if any Farmer Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Income_SAPPosting",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceFarmer> PendingInvoiceList = new List<ReqInvoiceFarmer>();
        PendingInvoiceList = this.db.Query<ReqInvoiceFarmer>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Farmer Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceSAPPostingInSapIncomeJson(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Income_SAPPosting", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 13. Check if any Farmer Invoice is waiting for posting
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Income_SAPPostingDebit",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceFarmer> PendingInvoiceList = new List<ReqInvoiceFarmer>();
        PendingInvoiceList = this.db.Query<ReqInvoiceFarmer>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingInvoiceList.Count + " Farmer Invoice Found");

        for (int i = 0; i < PendingInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).SaveInvoiceSAPPostingDebitInSapIncomeJson(PendingInvoiceList[i]);
          Console.WriteLine("Farmer Invoice Entry " + i + " Posted");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Income_SAPPostingDebit", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 14. Check if TDS data needs to be downloaded from SAP
      try
      {
        // Get All New Invoice
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_TDS",
          var_Org_Id = OrgId
        });

        List<ReqInvoiceTDS> PendingTDSList = new List<ReqInvoiceTDS>();
        PendingTDSList = this.db.Query<ReqInvoiceTDS>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingTDSList.Count + " TDS Download Found");

        for (int i = 0; i < PendingTDSList.Count; i++)
        {
          // Download TDS from SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).GetTDSDetailsFromSap(PendingTDSList[i]);
          Console.WriteLine("TDS Entry " + i + " Downloaded");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_TDS", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new TDS records");
      }

      // 15. Check if Trading Material Sales Order is pending for Posting
      try
      {
        // Get All New Pending
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_TradingMaterialIssue",
          var_Org_Id = OrgId
        });

        List<ReqTradingMaterial> PendingTradingList = new List<ReqTradingMaterial>();
        PendingTradingList = this.db.Query<ReqTradingMaterial>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PendingTradingList.Count + " Trading Material Entries Found");

        for (int i = 0; i < PendingTradingList.Count; i++)
        {
          // Download TDS from SAP
          new SAP_InvoicePosting(SAPUserName, SAPPassword, SAPAPIURL).GetTradingMaterialDetailsFromSap(PendingTradingList[i]);
          Console.WriteLine("TDS Entry " + i + " Downloaded");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_TradingMaterialIssue", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Trading Material Issue records");
      }

      // 16. Check if any Farmer Invoice is to be printed in PDF
      try
      {
        // Get All Farmer Invoice where Is_InvoicePDFGenerated = 1
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Invoice_List",
          var_Org_Id = OrgId,
          var_Param1 = "",
          var_Param2 = ""
        });

        List<ReqPrintInvoiceFarmerList> PrintInvoiceList = new List<ReqPrintInvoiceFarmerList>();
        PrintInvoiceList = this.db.Query<ReqPrintInvoiceFarmerList>("USP_AdminInvoicePrint_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PrintInvoiceList.Count + " Farmer Invoice for Print Found");

        for (int i = 0; i < PrintInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new PDF_InvoicePrinting().PrintFarmerInvoice(PrintInvoiceList[i]);
          Console.WriteLine("Farmer Invoice no " + i + " Generated");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Invoice_List", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 17. Check if any MCC Invoice is to be printed in PDF
      try
      {
        // Get All MCC Invoice where Is_InvoicePDFGenerated = 1
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_MCC_Invoice_List",
          var_Org_Id = OrgId,
          var_Param1 = "",
          var_Param2 = ""
        });

        List<ReqPrintInvoiceMCCList> PrintInvoiceList = new List<ReqPrintInvoiceMCCList>();
        PrintInvoiceList = this.db.Query<ReqPrintInvoiceMCCList>("USP_AdminInvoicePrint_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PrintInvoiceList.Count + " MCC Invoice for Print Found");

        for (int i = 0; i < PrintInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new PDF_InvoicePrinting().PrintMCCInvoice(PrintInvoiceList[i]);
          Console.WriteLine("MCC Invoice no " + i + " Generated");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_MCC_Invoice_List", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }

      // 18. Check if any Offline Farmer Invoice is to be printed in PDF
      try
      {
        // Get All Offline Farmer Invoice where Is_InvoicePDFGenerated = 1
        var parameters = new DynamicParameters(new
        {
          var_Method_Name = "Get_Farmer_Invoice_List",
          var_Org_Id = OrgId,
          var_Param1 = "",
          var_Param2 = ""
        });

        List<ReqPrintInvoiceFarmerList> PrintInvoiceList = new List<ReqPrintInvoiceFarmerList>();
        PrintInvoiceList = this.db.Query<ReqPrintInvoiceFarmerList>("USP_AdminOfflineInvoicePrint_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

        Console.WriteLine(PrintInvoiceList.Count + " Farmer Invoice for Print Found");

        for (int i = 0; i < PrintInvoiceList.Count; i++)
        {
          // Post Invoice to SAP
          new PDF_InvoicePrinting().PrintOfflineFarmerInvoice(PrintInvoiceList[i]);
          Console.WriteLine("Farmer Invoice no " + i + " Generated");
        }

      }
      catch (Exception ex)
      {
        new SAP_Posting().JobApiLog("Create", OrgId, "Get_Farmer_Invoice_List", "", "", "500", ex.Message);
        Console.WriteLine("Error in finding new Invoice records");
      }


    }


    public int SAPApiLog(string method_name, string org_id, string transaction_name, object request_url, object request_body, string response_code, object response_body)
    {

      try
      {

        var parameters = new
        {
          var_Method_Name = method_name,
          var_Org_Id = org_id,
          var_Transaction_Name = transaction_name,
          var_Request_URL = request_url,
          var_Request_Body = request_body,
          var_Response_Code = response_code,
          var_Response_Body = response_body,
        };

        string ReqParams = JsonConvert.SerializeObject(parameters);

        dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());


        string destination_name = "";
        //return new CommonDAL(destination_name, configuration).RunDBQuery(inputParam, "USP_AdminJobApiLog_Set");

        dynamic resObj = this.db.Query<dynamic>("USP_AdminSAPApiLog_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



        return 1;

      }
      catch (Exception e)
      {
        var ErrMsg = e.Message;


        return 1;
      }

    }


    public int JobApiLog(string method_name, string org_id, string transaction_name, object request_url, object request_body, string response_code, object response_body)
    {

      try
      {

        var parameters = new
        {
          var_Method_Name = method_name,
          var_Org_Id = org_id,
          var_Transaction_Name = transaction_name,
          var_Request_URL = request_url,
          var_Request_Body = request_body,
          var_Response_Code = response_code,
          var_Response_Body = response_body,
        };

        string ReqParams = JsonConvert.SerializeObject(parameters);

        dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());


        string destination_name = "";
        //return new CommonDAL(destination_name, configuration).RunDBQuery(inputParam, "USP_AdminJobApiLog_Set");

        dynamic resObj = this.db.Query<dynamic>("USP_AdminJobLog_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



        return 1;

      }
      catch (Exception e)
      {
        var ErrMsg = e.Message;


        return 1;
      }

    }
  }
}
