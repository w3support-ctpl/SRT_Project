$(document).ready(function () {
  $("#logoClick").on("click", function (event) {
    event.preventDefault(); // Prevents the default anchor click behavior
    window.location.href = "/Home/Index"; // Redirects to the specified page
  });

  function fetchCPUUsage() {
    fetch("/System/CpuUsage")
      .then((response) => response.json())
      .then((data) => {
        // document.getElementById(
        //   "cpuUsageDisplay"
        // ).textContent = `CPU Usage: ${data.cpuUsage.toFixed(2)}%`;

        $("#cpuUsageDisplay").text(`CPU Usage: ${data.cpuUsage.toFixed(2)}%`);
      })
      .catch((error) => {
        console.error("Fetch error:", error);
        // document.getElementById("cpuUsageDisplay").textContent =
        //   "Error fetching CPU usage";

        $("#cpuUsageDisplay").text("Error fetching CPU usage");
      });
  }

  setInterval(fetchCPUUsage, 1000); // Refresh every 2 seconds
  fetchCPUUsage();
});

var api;
var idtable;
var datatablecol;
function Show_Success_Toastr(message) {
  return $.growl.notice({
    message: message,
  });
}

function Show_Error_Toastr(message) {
  return $.growl.warning({
    message: message,
  });
}

function Show_Info_Toastr(message) {
  $.growl({
    title: "Info",
    message: message,
  });
}

function DisableFutureDates(ControlName) {
  var date = new Date(Date.now());
  var newdate = date.toISOString().slice(0, 10);

  $("#" + ControlName).attr("max", newdate);
  //$("#" + ControlName).val(newdate);

  return;
}

function DisablePastDates(ControlName) {
  var date = new Date(Date.now());
  var newdate = date.toISOString().slice(0, 10);

  $("#" + ControlName).attr("min", newdate);
  //$("#" + ControlName).val(newdate);

  return;
}

function Is_Valid_Driving_License($licenseno) {
  if ($licenseno.length > 0) {
    var licenseReg =
      // /^(([A-Z]{2}[0-9]{2})( )|([A-Z]{2}-[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$/;
      /^[A-Z]{2}\d{2}[- ]?\d{11,}$/;
    return licenseReg.test($licenseno);
  } else {
    return false;
  }
}

function Is_Valid_Email($email) {
  if ($email.length > 0) {
    var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
    return emailReg.test($email);
  } else {
    return false;
  }
}

function Is_Valid_PanNO($pan) {
  if ($pan.length > 0) {
    var panReg = /^([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}?$/;
    return panReg.test($pan);
  } else {
    return false;
  }
}

function Is_Valid_AadharNo($aadhar) {
  if ($aadhar.length > 0) {
    var aadharReg = /^[2-9]{1}[0-9]{11}$/;
    return aadharReg.test($aadhar);
  } else {
    return false;
  }
}

function Is_Valid_MobileNo($mobile) {
  if ($mobile.length > 0) {
    var mobileReg = /^\d{10}$/;
    // var mobileReg = /^[6-9]\d{9}$/;
    return mobileReg.test($mobile);
  } else {
    return false;
  }
}

function Is_Valid_PinCode($pincode) {
  if ($pincode.length > 0) {
    var pincodeReg = /^[\d]{6}$/;
    return pincodeReg.test($pincode);
  } else {
    return false;
  }
}

function Is_Valid_FSSAINO($fssai) {
  if ($fssai.length > 0) {
    var fssaiReg = /^[0-9]{14}$/;
    return fssaiReg.test($fssai);
  } else {
    return false;
  }
}

function Is_Valid_IFSCNO($ifsc) {
  if ($ifsc.length > 0) {
    var ifscReg = /^[A-Z]{4}0[A-Z0-9]{6}$/;
    return ifscReg.test($ifsc);
  } else {
    return false;
  }
}

function Is_Valid_Number($no) {
  if ($no.length > 0) {
    var noReg = /^\d+$/;
    return noReg.test($no);
  } else {
    return false;
  }
}

function Is_Valid_Float($float) {
  if ($float.length > 0) {
    var floatReg = /^(?=.*[1-9])\d*(?:\.\d+)?$/;
    // /^(0*(\.[1-9])?|0*\.\d+|1(\.0+)?)$/;
    // /^(0*[1-9]\d*(\.\d+)?|\.\d+)$/;

    // /^(\d+(\.\d*)?|\.\d+)$/;
    return floatReg.test($float);
  } else {
    return false;
  }
}

function Is_Valid_Float_Zero($float) {
  if ($float.length > 0) {
    var floatReg = /^(?:0(?:\.\d+)?|[1-9]\d*(?:\.\d+)?)$/;
    // /^(0*(\.[1-9])?|0*\.\d+|1(\.0+)?)$/;
    // /^(0*[1-9]\d*(\.\d+)?|\.\d+)$/;

    // /^(\d+(\.\d*)?|\.\d+)$/;
    return floatReg.test($float);
  } else {
    return false;
  }
}

function Is_Valid_Name($name) {
  if ($name.length > 0) {
    var nameReg = /^[a-zA-Z]+[\sa-zA-Z]*$/;
    return nameReg.test($name);
  } else {
    return false;
  }
}
function Is_Valid_Name_With_Number($name) {
  if ($name.length > 0) {
    var nameReg = /^[a-zA-Z]+[.\s_\-\/a-zA-Z0-9]*$/;
    //  /^[a-zA-Z]+[\sa-zA-Z0-9]*$/;
    return nameReg.test($name);
  } else {
    return false;
  }
}

function Is_AlphaNumeric($mystring) {
  if ($mystring.length > 0) {
    var mystringReg = /^[A-Za-z0-9]+$/;
    return mystringReg.test($mystring);
  } else {
    return false;
  }
}

function Is_AlphaNumericWithSpaces($mystring) {
  if ($mystring.length > 0) {
    var mystringReg = /^[A-Za-z0-9 ]+$/;
    return mystringReg.test($mystring);
  } else {
    return false;
  }
}

function Is_Valid_NumberCheck($number) {
  if ($number.length > 0) {
    var numberReg = /^[0-9]+(\.[0-9]+)?$/;
    return numberReg.test($number);
  } else {
    return false;
  }
}

function Is_Positive_Integer($no) {
  var noReg = /^[\d]+$/;
  return noReg.test($no);
}

function Is_Positive_Number_Greater_Than_Zero($no) {
  return parseFloat($no) > 0 || parseInt($no) > 0;
}

function SetDataTable(ControlName, HideSortColArray, ExportFileName) {
  var curTime = moment().format("DD_MMM_YYYY_HH_MM_ss");

  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInReport";
  }
  ExportFileName = ExportFileName + " " + curTime;
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }
  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    dom:
      "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'f><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'B>>" +
      "<'row'<'col-sm-12'tr>>" +
      "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
    buttons: [
      {
        extend: "csvHtml5",
        text: "Export",
        titleAttr: "Generate CSV",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
      },
    ],
    columnDefs: [
      {
        targets: HideSortColArray, // Should be an array like [2] or [2,3]
        orderable: false,
      },
    ],
    language: {
      searchPlaceholder: "Search in table",
      sSearch: "",
      lengthMenu: "_MENU_ records/page",
      loadingRecords: " & nbsp; ",
      infoEmpty: "No records to display",
      emptyTable: " ",
    },
  });
}

function SetPagingDataTable(ControlName, HideSortColArray, ExportFileName) {
  var curTime = moment().format("DD_MMM_YYYY_HH_MM_ss");

  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInReport";
  }
  ExportFileName = ExportFileName + " " + curTime;
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }
  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    scrollCollapse: true,
    paging: false,
    // scrollY: "70vh",
    // scrollX: true,
    dom:
      "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'f><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'B>>" +
      "<'row'<'col-sm-12'tr>>" +
      "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
    buttons: [
      {
        extend: "csvHtml5",
        text: "Export",
        titleAttr: "Generate CSV",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
      },
    ],
    columnDefs: [
      {
        targets: HideSortColArray, // Should be an array like [2] or [2,3]
        orderable: false,
      },
    ],
    language: {
      searchPlaceholder: "Search in table",
      sSearch: "",
      lengthMenu: "_MENU_ records/page",
      loadingRecords: " & nbsp; ",
      infoEmpty: "No records to display",
      emptyTable: " ",
    },
  });
}

function SetDataTable_MCC(ControlName, HideSortColArray, ExportFileName) {
  var curTime = moment().format("DD_MMM_YYYY_HH_MM_ss");

  idtable = "#" + ControlName;

  datatablecol = $(idtable + " thead tr").clone(true);
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInReport";
  }
  ExportFileName = ExportFileName + " " + curTime;
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }

  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    // responsive: true,
    searching: true,
    paging: false,
    dom:
      "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'f><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'B>>" +
      "<'row'<'col-sm-12'tr>>" +
      "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
    buttons: [
      {
        extend: "",
        text: "",
        titleAttr: "Generate CSV",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
      },
    ],
    columnDefs: [
      {
        targets: HideSortColArray, // Should be an array like [2] or [2,3]
        orderable: false,
      },
    ],
    language: {
      searchPlaceholder: "Search in table",
      sSearch: "",
      lengthMenu: "_MENU_ records/page",
      loadingRecords: " & nbsp; ",
      infoEmpty: "No records to display",
      emptyTable: " ",
    },
    initComplete: function () {
      api = this.api();
      datatablecol = $(idtable + " thead tr").clone(true);
      addfiltertotable(0);
      $(idtable + "_filter").hide();
    },
  });
}

function SetDataTable_Report(ControlName, HideSortColArray, ExportFileName) {
  var curTime = moment().format("DD_MMM_YYYY_HH_MM_ss");

  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInReport";
  }
  ExportFileName = ExportFileName + " " + curTime;
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }
  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    scrollCollapse: true,
    paging: false,
    dom:
      "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'f><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'B>>" +
      "<'row'<'col-sm-12'tr>>" +
      "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
    buttons: [
      {
        extend: "csvHtml5",
        text: "Export",
        titleAttr: "Generate CSV",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
      },
    ],
    columnDefs: [
      {
        targets: HideSortColArray, // Should be an array like [2] or [2,3]
        orderable: false,
      },
    ],
    language: {
      searchPlaceholder: "Search in table",
      sSearch: "",
      lengthMenu: "_MENU_ records/page",
      loadingRecords: " & nbsp; ",
      infoEmpty: "No records to display",
      emptyTable: " ",
    },
  });
}

function SetDataTable_Master(
  ControlName,
  HideSortColArray,
  ExportFileName,
  HideColumnArray,
  ExportColumnsArray
) {
  var curTime = moment().format("DD_MMM_YYYY_HH_MM_ss");
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInData";
  }
  ExportFileName = ExportFileName + " " + curTime;
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    dom:
      "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'f><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'B>>" +
      "<'row'<'col-sm-12'tr>>" +
      "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
    buttons: [
      {
        extend: "colvis",
        text: "Column Visibility",
        titleAttr: "Col visibility",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
      },
      {
        extend: "csvHtml5",
        text: "Export",
        titleAttr: "Generate CSV",
        className: "btn-outline-default",
        filename: function () {
          return ExportFileName;
        },
        exportOptions: {
          columns: ExportColumnsArray,
        },
      },
    ],
    columnDefs: [
      {
        targets: HideSortColArray, // Should be an array like [2] or [2,3]
        orderable: false,
      },
    ],
    language: {
      searchPlaceholder: "Search in table",
      sSearch: "",
      lengthMenu: "_MENU_ records/page",
      loadingRecords: " & nbsp; ",
      infoEmpty: "No records to display",
      emptyTable: " ",
    },
  });

  if (HideColumnArray != "" && HideColumnArray != undefined) {
    // Hide Few columns from default view
    var table = $("#" + ControlName).DataTable();
    table.columns(HideColumnArray).visible(false);
  }
}

function addfiltertotable(outcelindex) {
  $('input[class="dt-search"]').val("").trigger("keyup");
  if ($(".filters").length == 0) {
    $(datatablecol[0])
      .insertAfter(idtable + " thead tr:first")
      .addClass("filters");
    var i = 1;
    api
      .columns()
      .eq(0)
      .each(function (colIdx) {
        // Set the header cell to contain the input element
        var cell = $(".filters th").eq($(api.column(colIdx).header()).index());
        var celltile = $(idtable + " th").eq(
          $(api.column(colIdx).header()).index()
        );
        var title = $(celltile).text().trim();

        if (colIdx == outcelindex) {
          $(cell).html("");
          $(cell).removeClass("sorting_asc");
          return true;
        }

        $(cell).html(
          '<input type="text" class="dt-search form-control" placeholder="' +
            title +
            '" />'
        );

        // On every keypress in this input
        $("input", $(".filters th").eq($(api.column(colIdx).header()).index()))
          .off("keyup change")
          .on("keyup change", function (e) {
            e.stopPropagation();
            // Get the search value
            $(this).attr("title", $(this).val());
            var regexr = "({search})"; //$(this).parents('th').find('select').val();
            var cursorPosition = this.selectionStart;
            // Search the column for that value
            api
              .column(colIdx)
              .search(
                this.value != ""
                  ? regexr.replace("{search}", "(((" + this.value + ")))")
                  : "",
                this.value != "",
                this.value == ""
              )
              .draw();

            $(this)
              .focus()[0]
              .setSelectionRange(cursorPosition, cursorPosition);
          });

        i++;
      });

    $(".filters th").removeClass("sorting");
  } else {
    api
      .columns()
      .eq(0)
      .each(function (colIdx) {
        api
          .column(colIdx)
          .search("", this.value != "", this.value == "")
          .draw();
      });
    $(".filters").remove();
  }
}

function ClearDataTable(ControlName) {
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .clear()
      .destroy();
  }
  $("#" + ControlName + " tbody").empty();
}

function ShowContentDiv(ControllerName, Action, Pkey, callback) {
  $.ajax({
    url: "/" + ControllerName + "/" + Action + "",
    data: { Pkey: Pkey },
    success: function (result) {
      if (result.trim() != "") {
        // This is done for Delete Partial Page.
        $("#divContent").html(result);
        $("#divSearch").hide();
        $("#divContent").show();
      }
      callback(true);
    },
    error: function (result) {
      if (result.status == "401") {
        Show_Error_Toastr("You are not authorized to this transaction");
      }
    },
  });
}

function HideContentDiv() {
  $("#divSearch").show();
  $("#divContent").hide();
}

function ShowEntryError(message) {
  $("#divEntrySuccess").hide();
  $("#divEntryError").html(message);

  $("#divEntryError")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $("#divEntryError").slideUp(500);
    });
}

function ShowEntrySuccess(message) {
  $("#divEntryError").hide();
  $("#divEntrySuccess").html(message);

  $("#divEntrySuccess")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $("#divEntrySuccess").slideUp(500);
    });
}

function ShowItemError(message) {
  $("#divItemSuccess").hide();
  $("#divItemError").html(message);

  $(".divItemSuccess").hide();
  $(".divItemError").html(message);

  $("#divItemError")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $("#divItemError").slideUp(500);
    });

  $(".divItemError")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $(".divItemError").slideUp(500);
    });
}

function ShowItemSuccess(message) {
  $("#divItemError").hide();
  $("#divItemSuccess").html(message);

  $(".divItemError").hide();
  $(".divItemSuccess").html(message);

  $("#divItemSuccess")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $("#divItemSuccess").slideUp(500);
    });

  $(".divItemSuccess")
    .fadeTo(2000, 500)
    .slideUp(500, function () {
      $(".divItemSuccess").slideUp(500);
    });
}

function GetMaster(
  ControlName,
  ControlCaption,
  MethodName,
  DefaultValue,
  ParentFieldId
) {
  var JQ_ControlName = "#" + ControlName;
  if (ControlCaption != "") {
    $(JQ_ControlName)
      .empty()
      .append($("<option></option>").val("").html(ControlCaption));
  } else {
    $(JQ_ControlName).empty();
  }

  DefaultValue = DefaultValue + "";
  var APIEndPoint = "GetMasterData";
  var url = "/Home/MasterData";
  var reqdata = {
    Method_Name: MethodName,
    ParentField_Id: ParentFieldId,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      $.each(result, function (data, value) {
        $(JQ_ControlName).append(
          $("<option></option>").val(value.item_id).html(value.item_value)
        );
      });

      if (DefaultValue != "" && DefaultValue.charAt(0) == "[") {
        $(JQ_ControlName).val(JSON.parse(DefaultValue)).change(); // Multiselect
      } else if (DefaultValue != "" && DefaultValue.charAt(0) != "[") {
        $(JQ_ControlName).val(DefaultValue); // Single select
      }
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
    },
  });
}

function GetMasters(
  ControlName,
  ControlCaption,
  MethodName,
  DefaultValue,
  MCCType_Id,
  MCCWorkType_Id
) {
  var JQ_ControlName = "#" + ControlName;
  if (ControlCaption != "") {
    $(JQ_ControlName)
      .empty()
      .append($("<option></option>").val("").html(ControlCaption));
  } else {
    $(JQ_ControlName).empty();
  }

  DefaultValue = DefaultValue + "";
  var APIEndPoint = "GetMastersData";
  var url = "/Home/MasterData";
  var reqdata = {
    Method_Name: MethodName,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWorkType_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      $.each(result, function (data, value) {
        $(JQ_ControlName).append(
          $("<option></option>").val(value.item_id).html(value.item_value)
        );
      });

      if (DefaultValue != "" && DefaultValue.charAt(0) == "[") {
        $(JQ_ControlName).val(JSON.parse(DefaultValue)).change(); // Multiselect
      } else if (DefaultValue != "" && DefaultValue.charAt(0) != "[") {
        $(JQ_ControlName).val(DefaultValue); // Single select
      }
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
    },
  });
}

function GetMasterCallback(
  ControlName,
  ControlCaption,
  MethodName,
  DefaultValue,
  ParentFieldId,
  callback
) {
  var JQ_ControlName = "#" + ControlName;
  if (ControlCaption != "") {
    $(JQ_ControlName)
      .empty()
      .append($("<option></option>").val("").html(ControlCaption));
  } else {
    $(JQ_ControlName).empty();
  }

  DefaultValue = DefaultValue + "";
  var APIEndPoint = "GetMasterData";
  var url = "/Home/MasterData";
  var reqdata = {
    Method_Name: MethodName,
    ParentField_Id: ParentFieldId,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      $.each(result, function (data, value) {
        $(JQ_ControlName).append(
          $("<option></option>").val(value.item_id).html(value.item_value)
        );
      });

      if (DefaultValue != "" && DefaultValue.charAt(0) == "[") {
        $(JQ_ControlName).val(JSON.parse(DefaultValue)).change(); // Multiselect
      } else if (DefaultValue != "" && DefaultValue.charAt(0) != "[") {
        $(JQ_ControlName).val(DefaultValue); // Single select
      }

      return callback(true);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
      return callback(false);
    },
  });
}

function GetIFSCCode(Bank_Id, Branch_Id, Label_Id) {
  if (Branch_Id == "") {
    $("#" + Label_Id).text("");
    return;
  }
  var APIEndPoint = "GetBankBranch";
  var MethodName = "Get_One";
  var url = "/Masters/BankBranch";
  var reqdata = {
    Method_Name: MethodName,
    branch_id: Branch_Id,
    api_end_point: APIEndPoint,
    bank_id: Bank_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var ifsccode = res[0].ifsc_code;
      $("#" + Label_Id).text(ifsccode);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
    },
  });
}

// Hide Error Message under element whenever any text is pasted in the selected element
function ClearInputFieldError() {
  $("input[type=text], input[type=tel], input[type=number]").on(
    "paste",
    function (e) {
      //$("#" + e.target.id).removeClass("is-invalid state-invalid");
      ClearInvalidState(e.target);
    }
  );
}

function ClearInvalidState(e) {
  $("#" + e.id).removeClass("is-invalid state-invalid");
}

function ShowMyProfileEntry() {
  $("#modelEntryMyProfile")
    .modal({
      backdrop: "static",
    })
    .modal("show");
}

function CloseMyProfileEntry() {
  $("#modelEntryMyProfile").modal("hide");
}

function Show_Loader() {
  $("#global-loader").show();
}
function Hide_Loader() {
  $("#global-loader").fadeOut("slow");
}

function ShowChangePasswordModal() {
  $("#modelChangePassword")
    .modal({
      backdrop: "static",
    })
    .modal("show");
}

function UpdatePassword() {
  var validationresult = Validate_User_Before_Resest();
  var ValidateMismatchPass = Validate_Mismatch_Password();

  if (validationresult == true && ValidateMismatchPass == true) {
    var Current_Password = document.getElementById(
      "txtPassChangeCurPassword"
    ).value;
    var New_Password = document.getElementById(
      "txtPassChangeNewPassword"
    ).value;
    $("#btnSavePassword").prop("disabled", true);
    Show_Loader();
    var APIEndPoint = "SavePassword";
    var url = "/Users/ChangePassword";
    var Method_Name = "UpdatePassword";
    var reqdata = {
      Current_Password: Current_Password,
      New_Password: New_Password,
      method_name: Method_Name,
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
          // Show Success Message
          Hide_Loader();
          Show_Success_Toastr("Password saved successfully");
          window.location = "/Login/Logout";
        } else {
          Hide_Loader();
          Show_Error_Toastr("Error : " + result[0].result_description);
          $("#btnSavePassword").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : Password details not saved");
        $("#btnSavePassword").prop("disabled", false);
      },
    });
  }
}

// Validate User before Password Reset
function Validate_User_Before_Resest() {
  // Validate Password
  if ($("#txtPassChangeCurPassword").val() == "") {
    $("#txtPassChangeCurPassword").addClass("is-invalid");
    Show_Error_Toastr("Please Enter Current Password");
    return false;
  }

  if ($("#txtPassChangeNewPassword").val() == "") {
    $("#txtPassChangeNewPassword").addClass("is-invalid");
    Show_Error_Toastr("Please Enter New Password");
    return false;
  } else if ($("#txtPassChangeNewRePassword").val() == "") {
    $("#txtPassChangeNewRePassword").addClass("is-invalid");
    Show_Error_Toastr("Please Enter Confirm Password");
    return false;
  } else if (
    $("#txtPassChangeNewPassword").val() == "" &&
    $("#txtPassChangeNewRePassword").val() == ""
  ) {
    $("#txtPassChangeNewPassword").addClass("is-invalid");
    $("#txtPassChangeNewRePassword").addClass("is-invalid");
  } else {
    $("#txtPassChangeNewPassword").addClass("is-valid");
    $("#txtPassChangeNewRePassword").addClass("is-valid");
    return true;
  }
}

function Validate_Mismatch_Password() {
  if (
    $("#txtPassChangeNewPassword").val() !=
    $("#txtPassChangeNewRePassword").val()
  ) {
    $("#txtPassChangeNewPassword").addClass("is-invalid");
    $("#txtPassChangeNewRePassword").addClass("is-invalid");
    Show_Error_Toastr("Password Mismatch!!");
    return false;
  } else {
    $("#txtPassChangeNewPassword").addClass("is-valid");
    $("#txtPassChangeNewRePassword").removeClass("is-invalid");
    return true;
  }
}

//Password Validation
function PasswordValidator_1(txtPassword) {
  var val = txtPassword;
  var regularExpression =
    /^.*(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%&]).*$/;
  if (regularExpression.test(val)) {
    $("#txtPassChangeNewPassword").removeClass("is-invalid");
    $("#divPasswordInvalid").hide();
  } else {
    $("#divPasswordInvalid").show();
    $("#txtPassChangeNewPassword").addClass("is-invalid");
  }
}

// By default, Bootstrap doesn't auto close popover after appearing in the page
// resulting other popover overlap each other. Doing this will auto dismiss a popover
// when clicking anywhere outside of it
$(document).on("click", function (e) {
  $('[data-toggle="popover"],[data-original-title]').each(function () {
    //the 'is' for buttons that trigger popups
    //the 'has' for icons within a button that triggers a popup
    if (
      !$(this).is(e.target) &&
      $(this).has(e.target).length === 0 &&
      $(".popover").has(e.target).length === 0
    ) {
      (
        ($(this).popover("hide").data("bs.popover") || {}).inState || {}
      ).click = false; // fix for BS 3.3.6
    }
  });
});
