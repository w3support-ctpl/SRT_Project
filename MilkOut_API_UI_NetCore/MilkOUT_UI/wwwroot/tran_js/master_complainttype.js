$(document).ready(function () {
  GetSearchList();
});

function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var Method_Name = "Get";
  var APIEndPoint = "GetComplaintType";
  var url = "/Masters/ComplaintType";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // send message if there's no result
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // extract values and create an html string to assign to html table
      var TableHTML = "";
      var EditFlag = true;

      $.each(res, function (data, value) {
        var Active_Status;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.complainttype_name + "</td>";

        TableHTML += "</tr>";
      });
      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [1], "Complaint Type List");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  // enable search button to let user make function calls

  return;
}

function ShowAddEntry() {
  $("#modelComplaintType")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#txtSearchComplaintTypeName").val("");
  $("#btn_Save_Item").prop("disabled", false);
}

function SaveEntryItem() {
  // Validation code
  var ComplaintTypeName = $("#txtSearchComplaintTypeName").val();

  var IsValid = 1;

  if (ComplaintTypeName == "") {
    IsValid = 0;
    $("#txtSearchComplaintTypeName").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    $("#btn_Save_Item").prop("disabled", true);

    var APIEndPoint = "SaveComplaintType";
    var Method_Name = "Create";
    var ComplaintType_Id = "";

    var url = "/Masters/ComplaintType";

    var reqdata = {
      complainttype_name: ComplaintTypeName,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      complainttype_id: ComplaintType_Id,
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
          // Show Success Message
          Show_Success_Toastr("Complaint Type " + result[0].result_description);
          $("#modelComplaintType").modal("hide");
          GetSearchList();
        } else {
          Show_Error_Toastr("Error : " + result[0].result_description);
          $("#modelComplaintType").modal("hide");
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Complaint Type details not saved");
        $("#modelComplaintType").modal("hide");
      },
    });
  }

  return;
}
