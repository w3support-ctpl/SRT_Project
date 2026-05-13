using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;



using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
	[Route("v1/api/admin/invoice/")]
	[ApiController]
	public class InvoiceController : Controller
	{
		private readonly ILogger<LoginController> _logger;

		public InvoiceController(ILogger<LoginController> logger)
		{
			_logger = logger;
		}


		[HttpPost("GetInvoice", Name = "GetInvoice")]
		public IActionResult GetInvoice(ReqInvoice invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResGetDealer> res_Obj = new List<ResGetDealer>();
				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();



				string destination_name = invoice.destination_name + "";


				ReqGetDealer req_Obj = new ReqGetDealer();
				req_Obj.org_id = invoice.org_id;
				req_Obj.dealer_id = invoice.dealer_id;

				res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).GetAllInvoice(invoice.start_date, invoice.end_date, res_Obj[0].dealer_code);


				return Ok(res_output);

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}




		[HttpPost("GetOneInvoice", Name = "GetOneInvoice")]
		public IActionResult GetOneInvoice(ReqInvoice invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
				string destination_name = invoice.destination_name + "";

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

				string invoice_no = invoice.invoice_no;





				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).GetOneInvoice(invoice_no);

				return Ok(res_output);

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}



		[HttpPost("GetInvoicePDF", Name = "GetInvoicePDF")]
		public IActionResult GetInvoicePDF(ReqInvoice invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
				string destination_name = invoice.destination_name + "";

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

				string invoice_no = invoice.invoice_no;





				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).GetInvoicePDF(invoice_no);



				// Load the XML string
				XDocument xmlDoc = XDocument.Parse(res_output);

				// Convert the XML to JSON
				string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

				// Deserialize the JSON to a JObject
				JObject json = JObject.Parse(jsonResponse);

				// Assuming you already have the JSON object named 'json'


				return Ok(json["d:GetPDF"]["d:BillingDocumentBinary"]?.ToString());

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}


		[HttpPost("GetOneInvoicePricing", Name = "GetOneInvoicePricing")]
		public IActionResult GetOneInvoicePricing(ReqInvoice invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
				string destination_name = invoice.destination_name + "";

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

				string invoice_no = invoice.invoice_no;





				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).GetOneInvoicePricing(invoice_no);


				return Ok(res_output);

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}



		[HttpPost("CustomerReturn", Name = "CustomerReturn")]
		public IActionResult CustomerReturn(ReqNewHeader invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
				string destination_name = invoice.destination_name + "";

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


				Roots parameter = new Roots();

				parameter.CustomerReturn = "";
				parameter.CustomerReturnType = invoice.CustomerReturnType;
				parameter.SalesOrganization = invoice.SalesOrganization;
				parameter.DistributionChannel = "";
				parameter.OrganizationDivision = "";
				parameter.SalesGroup = invoice.SalesGroup;
				parameter.SalesOffice = invoice.SalesOffice;
				parameter.SalesDistrict = "";
				parameter.SoldToParty = invoice.SoldToParty;
				parameter.CreationDate = invoice.CreationDate;
				parameter.CreatedByUser = invoice.CreatedByUser;
				parameter.LastChangeDate = invoice.LastChangeDate;
				parameter.SenderBusinessSystemName = "";
				parameter.LastChangeDateTime = invoice.LastChangeDateTime;
				parameter.PurchaseOrderByCustomer = "";
				parameter.CustomerPurchaseOrderType = "";
				parameter.CustomerPurchaseOrderDate = invoice.CustomerPurchaseOrderDate;
				parameter.CustomerReturnDate = invoice.CustomerReturnDate;
				parameter.TotalNetAmount = invoice.TotalNetAmount;
				parameter.TransactionCurrency = invoice.TransactionCurrency;
				parameter.SDDocumentReason = invoice.SDDocumentReason;
				parameter.PricingDate = invoice.PricingDate;
				parameter.RequestedDeliveryDate = invoice.RequestedDeliveryDate;
				parameter.ShippingType = "";
				parameter.HeaderBillingBlockReason = "";
				parameter.DeliveryBlockReason = "";
				parameter.IncotermsClassification = invoice.IncotermsClassification;
				parameter.IncotermsTransferLocation = invoice.IncotermsTransferLocation;
				parameter.IncotermsLocation1 = invoice.IncotermsLocation1;
				parameter.IncotermsLocation2 = "";
				parameter.IncotermsVersion = "";
				parameter.CustomerPaymentTerms = invoice.CustomerPaymentTerms;
				parameter.PaymentMethod = "";
				parameter.RetsMgmtProcess = "";
				parameter.ReferenceSDDocument = invoice.ReferenceSDDocument;
				parameter.ReferenceSDDocumentCategory = invoice.ReferenceSDDocumentCategory;
				parameter.AccountingDocExternalReference = invoice.AccountingDocExternalReference;
				parameter.AssignmentReference = "";
				parameter.CustomerReturnApprovalReason = "";
				parameter.SalesDocApprovalStatus = "";
				parameter.RetsMgmtLogProcgStatus = "";
				parameter.RetsMgmtCompnProcgStatus = "";
				parameter.RetsMgmtProcessingStatus = "";
				parameter.OverallSDProcessStatus = invoice.OverallSDProcessStatus;
				parameter.TotalCreditCheckStatus = invoice.TotalCreditCheckStatus;
				parameter.OverallSDDocumentRejectionSts = "";
				parameter.to_Item = invoice.to_Item;

				Console.WriteLine(parameter);

				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).SaveCustomerReturn(parameter);

				return Ok(res_output);

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}







		[HttpPost("CreditMemoReturn", Name = "CreditMemoReturn")]
		public IActionResult CreditMemoReturn([FromBody] object reqObject)
		{
			try
			{
				if (reqObject == null)
				{
					return BadRequest();
				}


				dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
				string destination_name = inputParam.Destination_Name;

				List<ResGetDealer> res_Obj = new List<ResGetDealer>();
				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = inputParam.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


				dynamic parameter = new DynamicParameters();


				//parameter.Add("CreditMemoRequestType", inputParam.CreditMemoRequestType);
				//parameter.Add("SalesOrganization", inputParam.SalesOrganization);
				//parameter.Add("DistributionChannel", inputParam.DistributionChannel);

				//parameter.Add("OrganizationDivision", inputParam.OrganizationDivision);

				//parameter.Add("ReferenceSDDocument", inputParam.ReferenceSDDocument);

				//parameter.Add("SoldToParty", inputParam.SoldToParty);
				//parameter.Add("PurchaseOrderByCustomer", inputParam.PurchaseOrderByCustomer);

				//parameter.Add("CustomerPaymentTerms", inputParam.CustomerPaymentTerms);

				//parameter.Add("to_Partner", inputParam.to_Partner);

				//parameter.Add("to_Item", inputParam.to_Item);



				dynamic jsonObject = new
				{
					CreditMemoRequestType = inputParam.CreditMemoRequestType,
					SalesOrganization = inputParam.SalesOrganization,
					DistributionChannel = inputParam.DistributionChannel,
					OrganizationDivision = inputParam.OrganizationDivision,
					ReferenceSDDocument = inputParam.ReferenceSDDocument,
					SoldToParty = inputParam.SoldToParty,
					PurchaseOrderByCustomer = inputParam.PurchaseOrderByCustomer,
					CustomerPaymentTerms = inputParam.CustomerPaymentTerms,
					to_Partner = inputParam.to_Partner,
					to_Item = inputParam.to_Item,
				};



				//parameter.SalesOrganization = inputParam.SalesOrganization;
				//parameter.DistributionChannel = inputParam.DistributionChannel;
				//parameter.OrganizationDivision = inputParam.OrganizationDivision;
				//parameter.ReferenceSDDocument = inputParam.ReferenceSDDocument;
				//parameter.SoldToParty = inputParam.SoldToParty;
				//parameter.PurchaseOrderByCustomer = inputParam.PurchaseOrderByCustomer;
				//parameter.CustomerPaymentTerms = inputParam.CustomerPaymentTerms;
				//parameter.to_Partner = inputParam.to_Partner;
				//parameter.to_Item = inputParam.to_Item;



				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).SaveCreditMemoReturn(jsonObject);


				return Ok(res_output);



			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}

		[HttpPost("GetQRCodeAmount", Name = "GetQRCodeAmount")]
		public IActionResult GetQRCodeAmount(ReqInvoice invoice)
		{
			try
			{
				if (invoice.method_name == null)
				{
					return BadRequest();
				}

				List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
				string destination_name = invoice.destination_name + "";

				ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
				req_DestinationName.org_id = invoice.org_id;


				res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

				string invoice_no = invoice.invoice_no;





				string res_output = new InvoiceSAP(res_DestinationName[0].ConnectionName).GetQRCodeAmount(invoice_no);

				return Ok(res_output);

			}
			catch (Exception e)
			{
				var ErrMsg = e.Message;

				return StatusCode(500, ErrMsg);
			}
		}








	}
}
