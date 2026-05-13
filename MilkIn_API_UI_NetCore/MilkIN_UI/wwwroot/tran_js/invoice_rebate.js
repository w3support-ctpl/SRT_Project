$(document).ready(function () {
  $("#ddlSearchSAPPostedStatus").select2();
  GetMaster(
    "ddlSearchSAPPostedStatus",
    "Select Posted Status",
    "GetSAPPosted",
    0,
    ""
  );

  $("#dllSearchEntryMCCType").select2();
  $("#dllSearchEntryMCCWorkType").select2();
  $("#dllSearchEntryMCC").select2();
  GetMaster("dllSearchEntryMCCType", "All MCC Type", "GetMCCType", "", "");

  GetMaster(
    "dllSearchEntryMCCWorkType",
    "All MCC Work Type",
    "GetMCCWorkType",
    "",
    ""
  );

  const currentDate = new Date();
  const currentYear = currentDate.getFullYear();
  const currentMonth = (currentDate.getMonth() + 1).toString().padStart(2, "0"); // Adding 1 as months are zero-based

  $("#txtSearchDuration").val(`${currentYear}-${currentMonth}`);
});

function GetMCCName() {
  $("#dllSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  var MCCWorkType_Id = $("#dllSearchEntryMCCWorkType").val();
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    GetMaster("dllSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  } else {
    GetMasters(
      "dllSearchEntryMCC",
      "All MCC",
      "Get_MCC",
      "",
      MCCType_Id,
      MCCWorkType_Id
    );
  }
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetRebate";
  var Method_Name = "Get";
  var ApprovalStatus_Id = $("#ddlSearchSAPPostedStatus").val();
  var MCCType_Id = "%" + $("#dllSearchEntryMCCType").val() + "%";
  var MCCWorkType_Id = "%" + $("#dllSearchEntryMCCWorkType").val() + "%";
  var MCC_Id = "%" + $("#dllSearchEntryMCC").val() + "%";
  var url = "/Invoice/InvoiceRebate";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  var Search_Period_Set = Search_Period + "-01";
  var Status_Id = "";

  if (ApprovalStatus_Id == "") {
    Status_Id = "0";
  } else {
    Status_Id = ApprovalStatus_Id;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period_Set,
    approvalstatus_id: Status_Id,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWorkType_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_posted == 0) {
          Status = "Pending";
          // EditFlag = false;
        }
        if (value.is_posted == 1) {
          Status = "In Queue";
          // EditFlag = true;
        }
        if (value.is_posted == 2) {
          Status = "Posted";
          // EditFlag = true;
        }
        if (value.is_posted == 3) {
          Status = "Error";
          // EditFlag = true;
        }
        if (value.is_posted == 4) {
          Status = "";
          // EditFlag = true;
        }

        TableHTML += "<tr>";
        // TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.mcc_id +
          '">';

        if (value.is_posted == 0) {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.mcc_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;" id="chk' +
            value.mcc_id +
            '">';
        } else {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.mcc_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;"  id="chk' +
            value.mcc_id +
            '" checked disabled>';
        }

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';

        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.quantity_ltr + "</td>";
        TableHTML += "<td>" + value.rate + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.income_document + "</td>";

        if (value.is_posted == 0) {
          TableHTML += "<td>" + Status + "</td>";
        }
        if (value.is_posted == 1) {
          TableHTML +=
            "<td><span class='label label-warning mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 2) {
          TableHTML +=
            "<td><span class='label label-success mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 3) {
          TableHTML +=
            "<td><span class='label label-danger mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 4) {
          TableHTML += "<td></td>";
        }
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [7], "Rebate");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SelectAllCheckbox() {
  $("#selectAll").on("click", function () {
    var isChecked = $(this).prop("checked");
    $("#tableSearch #tableData .custom-control-input:not(:disabled)").prop(
      "checked",
      isChecked
    );
  });

  $(document).on(
    "click",
    "#tableSearch #tableData .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableSearch #tableData .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tableSearch #tableData .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAll").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}

function ShowPostEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, generate it!",
    },
    function (result) {
      if (result == true) {
        // $("#loader").show();
        var XMLData = "";

        XMLData += "<Rebate>";
        $("#tableSearch tbody tr").each(function () {
          var checkbox = $(this).find("input[type='checkbox']");
          // Check if checkbox is checked and not disabled
          if (checkbox.is(":checked") && !checkbox.is(":disabled")) {
            XMLData += "<RebateItem>";
            XMLData +=
              "<MCC_Id>" + $(this).find("td:eq(7)").text() + "</MCC_Id>";
            // XMLData += "<Date>" + $(this).find("td:eq(7)").text() + "</Date>";
            XMLData +=
              "<Quantity>" + $(this).find("td:eq(2)").text() + "</Quantity>";
            XMLData += "<Rate>" + $(this).find("td:eq(3)").text() + "</Rate>";
            XMLData +=
              "<Amount>" + $(this).find("td:eq(4)").text() + "</Amount>";

            XMLData += "</RebateItem>";
          }
        });

        XMLData += "</Rebate>";
        var Search_Period = $("#txtSearchDuration").val();

        if (Search_Period == "") {
          IsValid = 0;
          $("#txtSearchDuration").addClass("is-invalid state-invalid");
          return;
        }
        var Search_Period_Set = Search_Period + "-01";
        //Post it
        var APIEndPoint = "SaveRebate";
        var Method_Name = "Create";
        var url = "/Invoice/InvoiceRebate";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoicedata: XMLData,
          search_period: Search_Period_Set,
        };

        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
            //   $("#loader").hide();
              Show_Success_Toastr("Rebate posted successfully");

              GetSearchList();
            } else {
            //   $("#loader").hide();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            // $("#loader").hide();
            Show_Error_Toastr("Error : Rebate not posted");
            // $("#btn" + Entry_Id).show();
            // $("#loader" + Entry_Id).hide();
          },
        });
      }
    }
  );
}
