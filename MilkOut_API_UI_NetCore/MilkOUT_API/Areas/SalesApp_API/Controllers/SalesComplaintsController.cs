using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using MilkOUT_API.Areas.SalesApp_API.Models;
using MilkOUT_API.Areas.SalesApp_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Configuration;
using System.Data;
using System.Net.Http.Headers;
using System.Xml.Linq;

namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
    [Route("v1/api/sales/complaints/")]
    [ApiController]
    public class SalesComplaintsController : Controller
    {
        private readonly ILogger<SalesComplaintsController> _logger;

        private readonly IConfiguration _configuration;
        public SalesComplaintsController(ILogger<SalesComplaintsController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        [HttpPost("GetSalesComplaints", Name = "GetSalesComplaints")]
        public IActionResult GetSalesComplaints([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserComplaint_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }

        [HttpPost("SetSalesComplaints", Name = "SetSalesComplaints")]
        public IActionResult SetSalesComplaints([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserComplaint_Set");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }





        [HttpPost("SetSalesComplaintss", Name = "SetSalesComplaintss")]
        public IActionResult SetSalesComplaintss([FromForm] ReqSalesComplaints salesComplaintsSave)
        {
            try
            {
                if (salesComplaintsSave.method_name == null)
                {
                    return BadRequest();
                }


                // Image upload logic
                var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
                var files = HttpContext.Request.Form.Files;
                XDocument xmlDocument = new XDocument(new XElement("Images"));

                if (files.Count > 0)
                {
                    var Document_Path = Path.Combine(uploadfilebasepath, "SalesUser");
                    if (!Directory.Exists(Document_Path))
                    {
                        Directory.CreateDirectory(Document_Path);
                    }

                    foreach (var file in files)
                    {
                        var filename = ContentDispositionHeaderValue
                          .Parse(file.ContentDisposition)
                          .FileName
                          .Trim('"');
                        Guid loGuid = Guid.NewGuid();
                        filename = loGuid + "_" + filename;
                        var FilePath = Path.Combine(Document_Path, filename);
                        using (var fs = System.IO.File.Create(FilePath))
                        {
                            file.CopyTo(fs);
                            fs.Flush();
                        }

                        XElement imageData = new XElement("Image", new XElement("Image_Url", "/SalesUser/" + filename));
                        xmlDocument.Root.Add(imageData);
                    }
                }

                salesComplaintsSave.imagesList = xmlDocument.ToString();

                var parameters = new
                {
                    Method_Name = salesComplaintsSave.method_name,
                    Org_Id = salesComplaintsSave.org_id,
                    Complaint_Id = salesComplaintsSave.complaint_id,
                    ComplaintType_Id = salesComplaintsSave.complainttype_id,
                    Complaint_Remark = salesComplaintsSave.complaint_remark,
                    Complaint_For = salesComplaintsSave.complaint_for,
                    Complaint_For_User_Id = salesComplaintsSave.complaint_for_user_id,
                    Complaint_By = salesComplaintsSave.complaint_by,
                    Complaint_Date = salesComplaintsSave.complaint_date,
                    ComplaintStatus_Id = salesComplaintsSave.complaintstatus_id,
                    Closing_Date = salesComplaintsSave.closing_date,
                    Profile_Id = salesComplaintsSave.profile_id,
                    Latitude = salesComplaintsSave.latitude,
                    Longitude = salesComplaintsSave.longitude,
                    Images = salesComplaintsSave.imagesList,
                    Product_Id = salesComplaintsSave.product_id,
                    NotificationCodeGroup_Id = salesComplaintsSave.notificationcodegroup_id,
                    NotificationCode_Id = salesComplaintsSave.notificationcode_id,
                    NotificationPriority_Id = salesComplaintsSave.notificationpriority_id,
                    QualityNotification = salesComplaintsSave.qualitynotification
                };

                string ReqParams = JsonConvert.SerializeObject(parameters);
                dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());

                 string destination_name = "";


                var parameters_1 = new 
                {
                    Method_Name = "Get",
                    Org_Id = salesComplaintsSave.org_id,

                };

                string ReqParams_1 = JsonConvert.SerializeObject(parameters_1);
                dynamic inputParamd_1 = JsonConvert.DeserializeObject(ReqParams_1.ToString());
                

                string res_DestinationName_1 = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParamd_1, "USP_AdminOrg_Get");

                var accountDataD_1 = JsonConvert.DeserializeObject<List<dynamic>>(res_DestinationName_1);

                destination_name = (string)accountDataD_1[0].ConnectionName;



                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserComplaint_Set");

                dynamic result = JsonConvert.DeserializeObject(res_Str);
               
                if (salesComplaintsSave.method_name == "Create" && result[0].Result_Id == "1")
                {

                    
                    NotificationHeader parameterNotificationHeaders = new NotificationHeader();

                    var parameterNotificationHeader = new
                    {
                        Method_Name = "NotificationHeader",
                        Org_Id = salesComplaintsSave.org_id,
                        Complaint_Id = result[0].Result_Extra_Key,
                        SalesUser_Id = "",
                        Profile_Id = "",
                        Search_Period ="",
                        Dealer_Id ="",
                    };



                    
                    string Header = JsonConvert.SerializeObject(parameterNotificationHeader);

                    dynamic InHeader = JsonConvert.DeserializeObject(Header.ToString());

                    
                    //string destination_name = "";
                    string parameterData = new CommonDAL(destination_name, _configuration).RunDBQuery(InHeader, "USP_SalesUserComplaint_Get");

                
                    List<NotificationHeader> resultList = JsonConvert.DeserializeObject<List<NotificationHeader>>(parameterData.ToString());

                    if (resultList != null && resultList.Count > 0)
                    {
                        // Bind the data from the first object in the list
                    parameterNotificationHeaders = resultList[0];

                    parameterNotificationHeaders.odataetag = resultList[0].odataetag;
                    parameterNotificationHeaders.QualityNotification = resultList[0].QualityNotification;
                    parameterNotificationHeaders.NotificationOrigin = resultList[0].NotificationOrigin;
                    parameterNotificationHeaders.NotificationType = resultList[0].NotificationType;
                    parameterNotificationHeaders.MasterLanguage = resultList[0].MasterLanguage;
                    parameterNotificationHeaders.NotificationText = resultList[0].NotificationText;
                    parameterNotificationHeaders.NotificationPriorityType = resultList[0].NotificationPriorityType;
                    parameterNotificationHeaders.NotificationPriority = resultList[0].NotificationPriority;
                    parameterNotificationHeaders.NotificationStatusObject = resultList[0].NotificationStatusObject;
                    parameterNotificationHeaders.NotifProcessingPhase = resultList[0].NotifProcessingPhase;
                    parameterNotificationHeaders.NotificationCatalog = resultList[0].NotificationCatalog;
                    parameterNotificationHeaders.NotificationCodeGroup = resultList[0].NotificationCodeGroup;
                    parameterNotificationHeaders.NotificationCodeID = resultList[0].NotificationCodeID;
                    parameterNotificationHeaders.NotificationReportingDate = resultList[0].NotificationReportingDate;
                    parameterNotificationHeaders.NotificationCompletionDate = resultList[0].NotificationCompletionDate;
                    parameterNotificationHeaders.NotificationRequiredStartDate = resultList[0].NotificationRequiredStartDate;
                    parameterNotificationHeaders.NotificationRequiredStartTime = resultList[0].NotificationRequiredStartTime;
                    parameterNotificationHeaders.NotificationRequiredEndDate = resultList[0].NotificationRequiredEndDate;
                    parameterNotificationHeaders.NotificationRequiredEndTime = resultList[0].NotificationRequiredEndTime;
                    parameterNotificationHeaders.NotificationTimeZone = resultList[0].NotificationTimeZone;
                    parameterNotificationHeaders.Supplier = resultList[0].Supplier;
                    parameterNotificationHeaders.Customer = resultList[0].Customer;
                    parameterNotificationHeaders.Material = resultList[0].Material;
                    parameterNotificationHeaders.MaterialGroup = resultList[0].MaterialGroup;
                    parameterNotificationHeaders.Plant = resultList[0].Plant;
                    parameterNotificationHeaders.PurchasingDocument = resultList[0].PurchasingDocument;
                    parameterNotificationHeaders.PurchasingDocumentItem = resultList[0].PurchasingDocumentItem;
                    parameterNotificationHeaders.PurchasingOrganization = resultList[0].PurchasingOrganization;
                    parameterNotificationHeaders.PurchasingGroup = resultList[0].PurchasingGroup;
                    parameterNotificationHeaders.ActiveDivision = resultList[0].ActiveDivision;
                    parameterNotificationHeaders.SalesOrganization = resultList[0].SalesOrganization;
                    parameterNotificationHeaders.DistributionChannel = resultList[0].DistributionChannel;
                    parameterNotificationHeaders.WBSElementInternalID = resultList[0].WBSElementInternalID;
                    parameterNotificationHeaders.WorkCenterTypeCode = resultList[0].WorkCenterTypeCode;
                    parameterNotificationHeaders.MainWorkCenterInternalID = resultList[0].MainWorkCenterInternalID;
                    parameterNotificationHeaders.MainWorkCenterPlant = resultList[0].MainWorkCenterPlant;
                    parameterNotificationHeaders.InspectionLot = resultList[0].InspectionLot;
                    parameterNotificationHeaders.Batch = resultList[0].Batch;
                    parameterNotificationHeaders.MaterialDocumentYear = resultList[0].MaterialDocumentYear;
                    parameterNotificationHeaders.MaterialDocument = resultList[0].MaterialDocument;
                    parameterNotificationHeaders.MaterialDocumentItem = resultList[0].MaterialDocumentItem;
                    parameterNotificationHeaders.IsBusinessPurposeCompleted = resultList[0].IsBusinessPurposeCompleted;
                    parameterNotificationHeaders.IsDeleted = resultList[0].IsDeleted;
                    parameterNotificationHeaders.CreatedByUser = resultList[0].CreatedByUser;
                    parameterNotificationHeaders.CreationDate = resultList[0].CreationDate;
                    parameterNotificationHeaders.LastChangedByUser = resultList[0].LastChangedByUser;
                    parameterNotificationHeaders.LastChangedDate = resultList[0].LastChangedDate;
                    parameterNotificationHeaders.ChangedDateTime = resultList[0].ChangedDateTime;
                    }
                    else
                    {
                        Console.WriteLine("No data returned.");
                    }

                    //Console.WriteLine(result_1);
                    var NotificationItem = new
                    {
                        Method_Name = "NotificationItem",
                        Org_Id = salesComplaintsSave.org_id,
                        Complaint_Id = result[0].Result_Extra_Key,
                        SalesUser_Id = "",
                        Profile_Id = "",
                        Search_Period = "",
                        Dealer_Id ="",
                    };

                    

                    string Item = JsonConvert.SerializeObject(NotificationItem);

                    dynamic InItem = JsonConvert.DeserializeObject(Item.ToString());

                    string parameterDataItem = new CommonDAL(destination_name, _configuration).RunDBQuery(InItem, "USP_SalesUserComplaint_Get");

                    
                    List<_QltyNotificationPartner> resultListItem = JsonConvert.DeserializeObject<List<_QltyNotificationPartner>>(parameterDataItem.ToString());
                    
                    if (resultListItem != null && resultListItem.Count > 0)
                    {
                    parameterNotificationHeaders._QltyNotificationPartner = resultListItem;
                    parameterNotificationHeaders._QltyNotificationPartner[0].PartnerFunction = resultListItem[0].PartnerFunction;
                    parameterNotificationHeaders._QltyNotificationPartner[0].NotificationPartner = resultListItem[0].NotificationPartner;
                    }
                    else
                    {
                        Console.WriteLine("No data returned.");
                    }
                    //Console.WriteLine(JsonConvert.SerializeObject(parameterNotificationHeaders));

                   
                    string resString = new SalesOrderDAL(destination_name).SaveNotificationSAP(parameterNotificationHeaders, salesComplaintsSave.org_id);
                    JObject jsonResponse = JObject.Parse(resString);

                    

                    if (jsonResponse["code"].ToString() == "1")
                    {
                        var parametersSave = new
                        {
                            Method_Name = "SaveNotification",
                            Org_Id = salesComplaintsSave.org_id,
                            Complaint_Id = result[0].Result_Extra_Key,
                            ComplaintType_Id = salesComplaintsSave.complainttype_id,
                            Complaint_Remark = salesComplaintsSave.complaint_remark,
                            Complaint_For = salesComplaintsSave.complaint_for,
                            Complaint_For_User_Id = salesComplaintsSave.complaint_for_user_id,
                            Complaint_By = salesComplaintsSave.complaint_by,
                            Complaint_Date = salesComplaintsSave.complaint_date,
                            ComplaintStatus_Id = salesComplaintsSave.complaintstatus_id,
                            Closing_Date = salesComplaintsSave.closing_date,
                            Profile_Id = salesComplaintsSave.profile_id,
                            Latitude = salesComplaintsSave.latitude,
                            Longitude = salesComplaintsSave.longitude,
                            Images = salesComplaintsSave.imagesList,
                            Product_Id = salesComplaintsSave.product_id,
                            NotificationCodeGroup_Id = salesComplaintsSave.notificationcodegroup_id,
                            NotificationCode_Id = salesComplaintsSave.notificationcode_id,
                            NotificationPriority_Id = salesComplaintsSave.notificationpriority_id,
                            QualityNotification = jsonResponse["qualitynotification"].ToString()
                        };

                        string ReqParamsSave = JsonConvert.SerializeObject(parametersSave);
                        dynamic inputParaSave = JsonConvert.DeserializeObject(ReqParamsSave.ToString());

                       
                        new CommonDAL(destination_name, _configuration).RunDBQuery(inputParaSave, "USP_SalesUserComplaint_Set");

                    }

                }

                return Ok(res_Str);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;
                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetSalesComplaintss", Name = "GetSalesComplaintss")]

        public IActionResult GetSalesComplaintss(ReqQualityNotification qualityNotification)
        {
            try
            {
                if (qualityNotification.method_name == null)
                {
                    return BadRequest();
                }
                string destination_name = qualityNotification.destination_name;


                var parameter = new 
                {
                    Method_Name = qualityNotification.method_name,
                    Org_Id = qualityNotification.org_id,
                    ParentField_Id  = qualityNotification.parentfield_id,

                };

                string ReqParam = JsonConvert.SerializeObject(parameter);
                dynamic inputParam = JsonConvert.DeserializeObject(ReqParam.ToString());
                

                string res_QualityNotification = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesCommon_Master");

                var accountData = JsonConvert.DeserializeObject<List<dynamic>>(res_QualityNotification);

                string qualityNotification_id = accountData[0].QualityNotification;


                var parameters = new 
                {
                    Method_Name = "Get",
                    Org_Id = qualityNotification.org_id,

                };

                string ReqParams = JsonConvert.SerializeObject(parameters);
                dynamic inputParamd = JsonConvert.DeserializeObject(ReqParams.ToString());
                

                string res_DestinationName = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParamd, "USP_AdminOrg_Get");

                var accountDataD = JsonConvert.DeserializeObject<List<dynamic>>(res_DestinationName);

                string connectionName = (string)accountDataD[0].ConnectionName;

                string res_output = new SalesOrderDAL(connectionName).GetNotificationSAP(qualityNotification_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        public class ReqSalesComplaints
        {

            public string? method_name { get; set; }
            public string? destination_name { get; set; }
            public string? org_id { get; set; }


            public string? complaint_id { get; set; }
            public string? complainttype_id { get; set; }
            public string? complaint_remark { get; set; }
            public string? complaint_for { get; set; }
            public string? complaint_for_user_id { get; set; }
            public string? complaint_by { get; set; }
            public string? complaint_date { get; set; }
            public string? complaintstatus_id { get; set; }
            public string? closing_date { get; set; }
            public string? profile_id { get; set; }
            public string? latitude { get; set; }
            public string? longitude { get; set; }

            public string? product_id { get; set; }
            public List<IFormFile>? images { get; set; }

            public string? imagesList { get; set; }

            public string? notificationcodegroup_id { get; set; }
            public string? notificationcode_id { get; set; }
            public string? notificationpriority_id { get; set; }
            public string? qualitynotification { get; set; }

        }

        public class CommonOutput
        {
            public int result_id { get; set; }
            public string? result_description { get; set; }
            public string? result_extra_key { get; set; }


        }

        public class ReqFileInput
        {
            public IFormFile file { get; set; }
            public string AppName { get; set; }
        }





    }
}
