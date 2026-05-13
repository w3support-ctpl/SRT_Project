$(document).ready(function () {
  // GetMaster("ddlSearchBranch", "All Branches", "GetBranch", "", "");
  //SetDataTable("tableSearch", [4], "State");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  $("#btn_Search").prop("disabled", true);
  var State_Name = $("#txtSearchStateName").val();
  var APIEndPoint = "GetState";
  var Method_Name = "Get";
  var url = "/Location/State";

  var reqdata = {
    state_name: "%" + State_Name + "%",
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
        if (res.length == 0) {
            Show_Error_Toastr("Data not found.");
            return;
        }
      var TableHTML = "";
      var Row_No = 0;

      $.each(res, function (data, value) {
        var Active_Status;
        Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.state_code + "</td>";
        TableHTML += "<td>" + value.state_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";

        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [4], "State");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  ShowContentDiv("Location", "StateAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function ShowEditEntry(State_Id) {
  ShowContentDiv("Location", "StateEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(State_Id);
    $("#lblAction").html("Edit");

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code

  var StateCode = $("#txtEntryStateCode").val();

  if (StateCode == "") {
    ShowEntryError("Enter State Code");
    return;
  }

  // Start Saving
  ShowEntrySuccess("State details saved successfully");
}

function ShowDeleteEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, delete it!",
    },
    function (result) {
      if (result == true) {
        SaveDeleteEntry();
      }
    }
  );
}

function SaveDeleteEntry() {
  // Write code to delete
  var State_Id = $("#lblEntryId").html();
  // In success do following things
  Show_Success_Toastr("State entry blocked successfully");
  CloseEntry();
}
