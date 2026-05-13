$(document).ready(function () {});

function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var APIEndPoint = "GetMaterial";
  var SearchText = "%" + $("#txtSearchText").val() + "%";
  //var Material_Id = "";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/Material";
  var reqdata = {
    method_name: Method_Name,
    search_text: SearchText,
    //"material_id": Material_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      
      var res = JSON.parse(result);
      // console.log(res);
      // Fill data in table
      var TableHTML = "";
      //var Row_No = 0;
      $.each(res, function (data, value) {
        //Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.material_code + "</td>";
        TableHTML += "<td>" + value.material_name + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Mapping" onclick="ShowMaterialMappingModal(\'' +
          value.material_id +
          "','" +
          value.materialtype_id +
          "');\">";
        TableHTML += '<i class="fa fa-cogs"></i>';
        TableHTML += "</a>";
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [3], "Material");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  $("#btn_Search").prop("disabled", false);
  return;
}

function ShowMaterialMappingModal(Material_Id, MaterialType_Id) {
  $("#ddlEntryMaterialType").select2();
  GetMaster(
    "ddlEntryMaterialType",
    "Select Material Type",
    "GetMaterialType",
    MaterialType_Id,
    ""
  );
  $("#modelMaterialMapping")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblEntryMaterialId").html(Material_Id);
}

function SaveMaterialMapping() {
  var MaterialType_Id = $("#ddlEntryMaterialType").val();
  var IsValid = 1;
  if (MaterialType_Id != "") {
    if (MaterialType_Id == null || MaterialType_Id == undefined) {
      IsValid = 0;
      $("#ddlEntryMaterialType").addClass("is-invalid state-invalid");
    }
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    Show_Loader();
    var APIEndPoint = "SaveMaterial";
    var Method_Name = "Update";
    var Material_Id = $("#lblEntryMaterialId").html();
    var url = "/Masters/Material";
    var reqdata = {
      method_name: Method_Name,
      material_id: Material_Id,
      materialtype_id: MaterialType_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          Show_Success_Toastr("Material details saved successfully");
          ResetInputFields();
        } else {
          Hide_Loader();
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : Material details not saved");
      },
    });
    $("#modelMaterialMapping").modal("hide");
    $("#btn_Save").prop("disabled", false);
    GetSearchList();
  }
}

function ResetInputFields() {
  $(".modal input").val("");
}

function ShowDownloadEntry() {
  // Get data from database and show in table
  var APIEndPoint = "SaveMaterialMasterSAP";
  var Method_Name = "Create";
  var url = "/Masters/Material";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    product_id: "",
    product_photo: "",
  };
  Show_Loader();
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var result = JSON.parse(result);
      if (result[0].result_id == 1) {
        Hide_Loader();
        Show_Success_Toastr("Material Get successfully");
        GetSearchList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

/*function ShowAddEntry() {

    ShowContentDiv('Masters', 'MaterialAdd', '', function () {
        // Initialization Code

        $("#lblEntryId").html("");
        $("#lblAction").html("Add");

        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    });
}

function ShowEditEntry(Material_Id) {
    ShowContentDiv('Masters', 'MaterialEdit', '', function () {
        // Initialization Code

        $("#lblEntryId").html(Material_Id);
        $("#lblAction").html("Edit");

        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    });
}

function CloseEntry() {
    HideContentDiv();
}

function SaveEntry() {
    // Validation code
    var MaterialCode = $("#txtEntryMaterialCode").val();

    if (MaterialCode == "") {
        ShowEntryError("Enter Material Code");
        return;
    }

    // Start Saving
    ShowEntrySuccess("Material details saved successfully");

}

function ShowDeleteEntry() {

    swal(
        {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: 'question',
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, delete it!"
        }, function (result) {
            if (result == true) {
                SaveDeleteEntry();
            }
        });

}

function SaveDeleteEntry() {
    // Write code to delete
    var Taluka_Id = $("#lblEntryId").html();
    // In success do following things
    Show_Success_Toastr("Material entry blocked successfully");
    CloseEntry();
    GetSearchList();
}
*/
