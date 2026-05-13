$(document).ready(function () {
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

function GetSearchList() {
  ClearDataTable("tableSearch");
  var Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetDieselUpload";
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  var Method_Name = "Get";
  var url = "/Transporter/DieselUpload";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
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
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.upload_on + "</td>";
        TableHTML += "<td>" + value.file_name + "</td>";
        TableHTML += "<td>" + value.success_count + "</td>";
        TableHTML += "<td>" + value.error_count + "</td>";
        // TableHTML += "<td>" + value.duplicate_count + "</td>";
        TableHTML += "<td>" + value.total_count + "</td>";
        TableHTML += "<td>" + value.user_name + "</td>";
        // TableHTML += "<td></td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.dieselupload_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";

        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [7], "Diesel Upload");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function ShowAddEntry() {
  ShowContentDiv("Transporter", "DieselUploadAdd", "", function () {
    $("#divUploadFile").show();
    $("#excelDownload").show();
  });

  return;
}
function ShowEditEntry(dieselupload_id) {
  ShowContentDiv("Transporter", "DieselUploadEdit", "", function () {
    $("#lblEntryId").html(dieselupload_id);
    $("#divUploadFile").hide();
    $("#excelDownload").hide();
    $("#DeleteEntry").hide();
    GetDieselUploadDelete(dieselupload_id);
    GetDieselUploadList(dieselupload_id);
  });

  return;
}

function ExcelDownload() {
  var data = [
    ["Transporter Code", "Vehicle No", "Date", "Qty"],
    ["xxxx", "xxxxx", "yyyy-mm-dd", "xxxx"],
  ];

  // Convert data to CSV format
  var csvContent =
    "data:text/csv;charset=utf-8," +
    data.map((row) => row.join(",")).join("\n");

  // Create a virtual link and trigger download
  var encodedUri = encodeURI(csvContent);
  var link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", "DieselUploadTemplate.csv");
  document.body.appendChild(link); // Required for Firefox
  link.click();
}

function SaveExcelUploadEntry() {
  $("#divUploadFile").hide();
  $("#excelDownload").hide();
  ClearDataTable("tableDieselUploadList");
  Show_Loader();
  var file = $("#txtEntryExcelUpload");

  var reqdata = new FormData();
  reqdata.append("FIle", file[0].files[0]);
  reqdata.append("ModuleName", "CategoryMaster");

  var url = "/Transporter/CovertExcelToTable";
  $.ajax({
    url: url,
    type: "POST",
    processData: false,
    contentType: false,
    data: reqdata,
    async: false,
    success: function (response) {
      if (response.status == 200) {
        var res_Json = JSON.parse(response.data);
        // // console.log(res_Json);

        var dieselUploadCollectionData = "<DieselUpload>";
        for (var i = 0; i < res_Json.length; i++) {
          var dieselUploadData = res_Json[i];

          // if (
          //   dieselUploadData["Transporter Code"] &&
          //   dieselUploadData["Vehicle No"] &&
          //   dieselUploadData["Date"] &&
          //   dieselUploadData["Qty"]
          // ) {

          dieselUploadCollectionData += "<DieselUploadItem>";
          dieselUploadCollectionData +=
            "<Transporter_Id>" +
            dieselUploadData["Transporter Code"] +
            "</Transporter_Id>";

          dieselUploadCollectionData +=
            "<Vehicle_Id>" + dieselUploadData["Vehicle No"] + "</Vehicle_Id>";
          dieselUploadCollectionData +=
            "<Entry_Date>" + dieselUploadData["Date"] + "</Entry_Date>";
          dieselUploadCollectionData +=
            "<Quantity_Ltr>" + dieselUploadData["Qty"] + "</Quantity_Ltr>";
          dieselUploadCollectionData += "</DieselUploadItem>";

          // }
        }

        dieselUploadCollectionData += "</DieselUpload>";

        var Method_Name = "ExcelUpload";
        var APIEndPoint = "SaveDieselUpload";
        var url_One = "/Transporter/DieselUpload";

        var file_name = file[0].files[0].name;

        var reqdata_one = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          dieselupload_data: dieselUploadCollectionData,
          file_name: file_name,
        };

        $.ajax({
          type: "POST",
          url: url_One,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata_one,
          success: function (res) {
            var result = JSON.parse(res);
            Hide_Loader();

            var TableHTML = "";
            $.each(result, function (data, value) {
              TableHTML += "<tr>";
              TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
              TableHTML += "<td>" + value.transporter_id + "</td>";
              TableHTML += "<td>" + value.vehicle_id + "</td>";
              TableHTML += "<td>" + value.entry_date + "</td>";
              TableHTML += "<td>" + value.quantity_ltr + "</td>";
              TableHTML += "<td>" + value.status + "</td>";
              TableHTML += "<td hidden></td>";
              TableHTML += "</tr>";
            });

            $("#tableDieselUploadData").html(TableHTML);

            SetDataTable("tableDieselUploadList", [6], "Diesel Upload");
          },
          error: function () {
            $("#divUploadFile").show();
            $("#excelDownload").show();
            Hide_Loader();
            Show_Error_Toastr("Error : Diesel Upload details not saved");
          },
        });
      } else {
        $("#divUploadFile").show();
        $("#excelDownload").show();
        Hide_Loader();
        Show_Error_Toastr(response.data);
      }

      // Hide_Loader();
    },
    error: function (msg) {
      Hide_Loader();
      Show_Error_Toastr(msg);
      // Hide_Loader();
    },
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function GetDieselUploadList(dieselupload_id) {
  ClearDataTable("tableDieselUploadList");
  var APIEndPoint = "GetDieselUpload";

  var Method_Name = "Get_One";
  var url = "/Transporter/DieselUpload";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    dieselupload_id: dieselupload_id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.transporter_code + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.entry_on + "</td>";
        TableHTML += "<td>" + value.quantity_ltr + "</td>";
        TableHTML += "<td>" + value.status + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });

      $("#tableDieselUploadData").html(TableHTML);

      SetDataTable("tableDieselUploadList", [6], "Diesel Upload");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetDieselUploadDelete(dieselupload_id) {
  // ClearDataTable("tableDieselUploadList");
  var APIEndPoint = "GetDieselUpload";

  var Method_Name = "Get_Locked";
  var url = "/Transporter/DieselUpload";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    dieselupload_id: dieselupload_id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res[0].is_locked == "1") {
        $("#DeleteEntry").hide();
      } else {
        $("#DeleteEntry").show();
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function DeleteEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        var dieselupload_id = $("#lblEntryId").html();
        var APIEndPoint = "SaveDieselUpload";
        var Method_Name = "Delete";
        var url = "/Transporter/DieselUpload";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          dieselupload_id: dieselupload_id,
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
              Show_Success_Toastr("Diesel Upload Data Delete successfully");

              CloseEntry();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Diesel Upload Data Delete not Reverse");
          },
        });
      }
    }
  );
}
