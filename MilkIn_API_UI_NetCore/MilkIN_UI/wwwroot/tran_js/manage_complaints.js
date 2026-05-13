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
  CurrentUserName = $("#lblusername").text();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetComplaints";
  var ComplaintPeriod = $("#txtSearchComplaintPeriod").val();
  var ComplaintType_Id = $("#ddlSearchComplaintType").val();
  var ComplaintStatus_Id = $("#ddlSearchComplaintType").val();

  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Manage/Complaints";
  var reqdata = {
    method_name: Method_Name,
    complaintstatus_id: ComplaintStatus_Id,
    complainttype_id: ComplaintType_Id,
    complaint_period: ComplaintPeriod,
    api_end_point: APIEndPoint,
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
      var EditFlag;
      var Today = new Date(Date.now());
      $.each(res, function (data, value) {
        EditFlag = value.is_closed;
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
        TableHTML += "<td>" + value.complaint_for_user_name + "</td>";
        TableHTML += "<td>" + OpenDays + "</td>";
        TableHTML += "<td>" + value.closing_date + "</td>";
        TableHTML += "<td>" + value.complaintstatus_name + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 0) {
          var complaintremarks = value.complaint_remark
            .trim()
            .replace(/(\r\n|\n|\r)/gm, "");
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.complaint_id +
            "', '" +
            value.formatted_complaint_date +
            "', '" +
            value.complaint_for_user_name +
            "', '" +
            value.complaint_for_user_id +
            "', '" +
            value.complaint_for +
            "', '" +
            complaintremarks +
            "', '" +
            value.complainttype_name +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          var complaintremarks = value.complaint_remark
            .trim()
            .replace(/(\r\n|\n|\r)/, "");

          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.complaint_id +
            "', '" +
            value.formatted_complaint_date +
            "', '" +
            value.complaint_for_user_name +
            "', '" +
            value.complaint_for_user_id +
            "', '" +
            value.complaint_for +
            "', '" +
            complaintremarks +
            "', '" +
            value.complainttype_name +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Complaints");
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

function ShowEditEntry(
  Action,
  Complaint_Id,
  _ComplaintDate,
  _UserName,
  _UserId,
  _ComplaintFor,
  _ComplaintRemarks,
  _ComplaintType
) {
  Complaint_Date = _ComplaintDate;
  User_Name = _UserName;
  User_Id = _UserId;
  Complaint_For = _ComplaintFor;
  ComplaintRemarks = _ComplaintRemarks;
  ComplaintType = _ComplaintType;
  ShowContentDiv("Manage", "ComplaintsEdit", "", function () {
    $("#txtEntryComplaintDate").val(Complaint_Date);
    $("#txtEntryComplaintDate").prop("disabled", true);
    $("#txtEntryUserName").val(User_Name);
    $("#txtEntryUserName").prop("disabled", true);
    $("#txtEntryComplaintType").val(ComplaintType);
    $("#txtEntryComplaintType").prop("disabled", true);
    $("#txtEntryComplaintRemarks").val(ComplaintRemarks);
    $("#txtEntryComplaintRemarks").prop("disabled", true);
    $("#lblEntryId").html(Complaint_Id);
    $("#lblAction").html(Action);
    // if (Action == "Edit") {
    //     $("#btn_Add").show();
    // }
    // else {
    //     $("#btn_Add").hide();
    // }

    // get item table
    ClearDataTable("tableEntry");
    var APIEndPoint = "GetComplaints";
    var Method_Name = "Get_One";
    var url = "/Manage/Complaints";
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
        // Fill data in table
        var TableHTML = "";
        var EditFlag;

        $.each(res, function (data, value) {
          var DisplayFlag = "No";
          if (value.is_display == 1) {
            DisplayFlag = "Yes";
          }

          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.action_date + "</td>";
          TableHTML += "<td>" + value.action_by_name + "</td>";
          TableHTML += "<td>" + value.remarks + "</td>";
          TableHTML += "<td>" + value.new_status_name + "</td>";
          TableHTML += "<td>" + DisplayFlag + "</td>";
          TableHTML += "</tr>";
        });

        $("#tableEntryData").html(TableHTML);

        SetDataTable("tableEntry", [5], "Complaint Actions");
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
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var Remarks = $("#txtEntryRemarks").val().trim();
  var Display_Flag = 0;
  if ($("#chkDisplayFlag").prop("checked") == true) {
    Display_Flag = 1;
  }
  var NewStatus_Id = $("#ddlEntryNewStatus").val();

  var IsValid = 1;

  if (Remarks == "" || Is_AlphaNumericWithSpaces(Remarks) == false) {
    IsValid = 0;
    $("#txtEntryRemarks").addClass("is-invalid state-invalid");
  }
  if (NewStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryNewStatus").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btnSave").prop("disabled", true);
  var APIEndPoint = "SaveComplaints";
  var Method_Name = "Create";
  var url = "/Manage/Complaints";
  var Complaint_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    complaint_id: Complaint_Id,
    remarks: Remarks,
    display_flag: Display_Flag,
    newstatus_id: NewStatus_Id,
    complaint_for_user_id: User_Id,
    complaint_for: Complaint_For,
  };
  //Save Complaint Action
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        Show_Success_Toastr("Complaint Action saved successfully");
        ShowEditEntry(
          "Edit",
          Complaint_Id,
          Complaint_Date,
          User_Name,
          User_Id,
          Complaint_For,
          ComplaintRemarks,
          ComplaintType
        );
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Complaint Action not saved");
    },
  });
  $("#modelEntryComplaint").modal("hide");
  $("#btnSave").prop("disabled", false);
}

function OpenModal(action) {
  $("#modelEntryComplaint").modal("show");

  var Today = new Date(Date.now()).toISOString().slice(0, 10);
  $("#txtEntryActionDate").val(Today);
  $("#txtEntryActionDate").prop("disabled", true);

  $("#txtEntryActionBy").val(CurrentUserName);
  $("#txtEntryActionBy").prop("disabled", true);

  $("#ddlEntryNewStatus").select2();

  GetMaster(
    "ddlEntryNewStatus",
    "Select New Complaint Status",
    "GetComplaintStatusOpenResolved",
    "",
    ""
  );

  if (action == "Add") {
    $("#AddEditComplaint").text("Add Entry");
  }
}

$("#modelEntryComplaint").on("hidden.bs.modal", function (e) {
  $("#lblActionComplaint").html("");
  $("#AddEditComplaint").text("");
});