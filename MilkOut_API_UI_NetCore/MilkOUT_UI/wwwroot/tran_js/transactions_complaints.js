$(document).ready(function () {
  $("#ddlSearchComplaintType").select2();
  $("#ddlSearchComplaintStatus").select2();
  GetMaster(
    "ddlSearchComplaintType",
    "Select Complaint Type",
    "GetComplaintType",
    "",
    ""
  );
  GetMaster(
    "ddlSearchComplaintStatus",
    "Select Complaint Status",
    "GetComplaintStatus",
    "",
    ""
  );

  $('input[name="datefilter"]').daterangepicker({
    locale: {
      cancelLabel: "Clear",
    },
    startDate: moment().subtract(30, "days"), // Set the startDate to 30 days ago
    endDate: moment(), // Set the endDate to the current date
    ranges: {
      Today: [moment(), moment()],
      Yesterday: [moment().subtract(1, "days"), moment().subtract(1, "days")],
      "Last 7 Days": [moment().subtract(6, "days"), moment()],
      "Last 30 Days": [moment().subtract(29, "days"), moment()],
      "This Month": [moment().startOf("month"), moment().endOf("month")],
      "Last Month": [
        moment().subtract(1, "month").startOf("month"),
        moment().subtract(1, "month").endOf("month"),
      ],
    },
  });

  $('input[name="datefilter"]').on(
    "apply.daterangepicker",
    function (ev, picker) {
      $(this).val(
        picker.startDate.format("MM/DD/YYYY") +
          " - " +
          picker.endDate.format("MM/DD/YYYY")
      );
    }
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    }
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var ComplaintType_Id = $("#ddlSearchComplaintType").val();
  var ComplaintStatus_Id = $("#ddlSearchComplaintStatus").val();
  var ComplaintPeriod = $("#txtSearchComplaintPeriod").val().trim();
  var IsValid = 1;
  if (ComplaintPeriod == "") {
    IsValid = 0;
    $("#txtSearchComplaintPeriod").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't search for data.");
    return;
  }
  var Method_Name = "Get";
  var APIEndPoint = "GetComplaints";
  var url = "/Transactions/Complaints";
  var reqdata = {
    method_name: Method_Name,
    complainttype_id: ComplaintType_Id,
    complaintstatus_id: ComplaintStatus_Id,
    complaint_period: ComplaintPeriod,
    api_end_point: APIEndPoint,
  };
  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        $("#btn_Search").prop("disabled", false);
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var EditFlag = 1;
      var Today = new Date(Date.now());
      $.each(res, function (data, value) {
        // EditFlag = value.is_closed;
        var EntryDate;
        var OpenDays;
        // calculating the total number of days the complaint has stayed open

        if (value.is_closed == 1) {
          EntryDate = new Date(value.complaint_date);
          ClosingDate = new Date(value.closing_date);
          OpenDays = Math.round(
            (ClosingDate.getTime() - EntryDate.getTime()) /
              (1000 * 60 * 60 * 24)
          );
          if (
            value.closing_date == null ||
            value.closing_date == undefined ||
            value.closing_date == ""
          ) {
            EntryDate = new Date(value.complaint_date);
            OpenDays = Math.round(
              (Today.getTime() - EntryDate.getTime()) / (1000 * 60 * 60 * 24)
            );
          }
        } else {
          EntryDate = new Date(value.complaint_date);
          OpenDays = Math.round(
            (Today.getTime() - EntryDate.getTime()) / (1000 * 60 * 60 * 24)
          );
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.formatted_complaint_date + "</td>";
        TableHTML += "<td>" + value.complainttype_name + "</td>";
        TableHTML += "<td>" + value.complaint_for + "</td>";
        TableHTML += "<td>" + value.complaint_for_user_name + "</td>";
        TableHTML += "<td>" + OpenDays + "</td>";
        TableHTML += "<td>" + value.qualitynotification + "</td>";
        TableHTML += "<td>" + value.complaintstatus_name + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Open" onclick="ShowEditEntry(\'' +
          value.complaint_id +
          "')\">";
        TableHTML += '<i class="fa fa-eye"></i>';
        TableHTML += "</a>";

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [7], "Complaints");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowEditEntry(Complaint_Id) {
  ShowContentDiv("Transactions", "ComplaintsEdit", "", function () {
    $("#lblEntryId").html(Complaint_Id);
    // set text field values
    var Method_Name = "Get_One";
    var APIEndPoint = "GetComplaints";
    var url = "/Transactions/Complaints";
    var reqdata = {
      method_name: Method_Name,
      complaint_id: Complaint_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        var EntryDate;
        var OpenDays;
        var Today = new Date(Date.now());
        // calculating the total number of days the complaint has stayed open
        if (res[0].is_closed == 1) {
          EntryDate = new Date(res[0].complaint_date);
          ClosingDate = new Date(res[0].closing_date);
          OpenDays = Math.round(
            (ClosingDate.getTime() - EntryDate.getTime()) /
              (1000 * 60 * 60 * 24)
          );
          if (
            res[0].closing_date == null ||
            res[0].closing_date == undefined ||
            res[0].closing_date == ""
          ) {
            EntryDate = new Date(res[0].complaint_date);
            OpenDays = Math.round(
              (Today.getTime() - EntryDate.getTime()) / (1000 * 60 * 60 * 24)
            );
          }
        } else {
          EntryDate = new Date(res[0].complaint_date);
          OpenDays = Math.round(
            (Today.getTime() - EntryDate.getTime()) / (1000 * 60 * 60 * 24)
          );
        }
        $("#txtEntryComplaintsDate").text(res[0].formatted_complaint_date);
        $("#txtEntryUserType").text(res[0].complaint_for);
        $("#txtEntryUserName").text(res[0].complaint_for_user_name);
        $("#ddlEntryComplaintType").text(res[0].complainttype_name);
        $("#ddlEntryComplaintStatus").text(res[0].complaintstatus_name);
        $("#txtEntryOpenDays").text(OpenDays);

        $("#txtEntryLatitude").text(res[0].latitude);
        $("#txtEntryLongitude").text(res[0].longitude);
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });

    // set complaint progress table
    var Method_Name = "Get_Item";
    var APIEndPoint = "GetComplaints";
    var url = "/Transactions/Complaints";
    var reqdata = {
      method_name: Method_Name,
      complaint_id: Complaint_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        // fill the extracted data into the table
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.action_date + "</td>";
          TableHTML += "<td>" + value.action_by_name + "</td>";
          TableHTML += "<td>" + value.remarks + "</td>";
          TableHTML += "<td>" + value.complaintstatus_name + "</td>";
          TableHTML += "</tr>";
        });

        $("#tableComplaintListBody").html(TableHTML);
        SetDataTable("tableComplaintList", [4], "Complaint Progress");
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function generateGoogleMapsURL() {
  var lat = $("#txtEntryLatitude").text();
  var long = $("#txtEntryLongitude").text();
  var url = `https://www.google.com/maps/place/${lat},${long}/@${lat},${long},17z/data=!3m1!4b1`;
  window.open(url, "_blank");
}

function openImages() {
  $("#modelEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var Complaint_Id = $("#lblEntryId").html();
  // set text field values
  var Method_Name = "Get_Images";
  var APIEndPoint = "GetComplaints";
  var url = "/Transactions/Complaints";
  var reqdata = {
    method_name: Method_Name,
    complaint_id: Complaint_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
      } else {
        console.log(res);
        // Clear the existing images
        $("#cImages").empty();
        // Loop through the result and append images
        res.forEach(function (image) {
          var imageHtml = `
            <div class="col-12">
              <div class="bg-light p-6 text-center">
                <img class="" alt="Product" src="${image.link}">
              </div>
            </div>`;
          $("#cImages").append(imageHtml);
        });
      }
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function ShowDetailsModal() {
  $("#modelEntryRemarks")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#txtEntryRemarks").val("");
}

function SaveEntryRemarksDetails() {
  var Remarks = $("#txtEntryRemarks").val();

  var IsValid = 1;

  if (Remarks == "" || Remarks == null || Remarks == undefined) {
    IsValid = 0;
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    //Start Saving
    $("#btn_SaveRemarks").prop("disabled", true);
    var Method_Name = "Updatecomplaint";
    var Complaint_Id = $("#lblEntryId").html();

    var url = "/Transactions/Complaints";
    var APIEndPoint = "SaveComplaintsRemarks";

    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      complaint_remark: Remarks,
      complaint_id: Complaint_Id,
    };

    //Save
    return $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,

      success: function (result) {
        var res = JSON.parse(result)[0];
        if (res.result_id == 1) {
          ShowEntrySuccess("Complaints Remarks details saved successfully");
        } else {
          ShowEntryError("Error : " + res.result_description);
          $("#btn_SaveRemarks").prop("disabled", false);
        }
        $("#modelEntryRemarks").modal("hide");
        ShowEditEntry(Complaint_Id);
        $("#btn_SaveRemarks").prop("disabled", false);
      },
      error: function () {
        Show_Error_Toastr("Error : Complaints Remarks details not saved");
        $("#btn_SaveRemarks").prop("disabled", false);
      },
    });
  }
  return;
}
