$(document).ready(function () {
  $("#logoClick").on("click", function (event) {
    event.preventDefault(); // Prevents the default anchor click behavior
    window.location.href = "/Home/Index"; // Redirects to the specified page
  });
});

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
    var panReg = /^([A-Z]){5}([0-9]){4}([A-Z]){1}?$/;
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
    var mobileReg = /^[6-9]\d{9}$/;
    return mobileReg.test($mobile);
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

function Is_Valid_FSSAINO($fssai) {
  if ($fssai.length > 0) {
    var fssaiReg = /^[0-9]{14}$/;
    return fssaiReg.test($fssai);
  } else {
    return false;
  }
}

function Is_Valid_PhoneNo($phone) {
  if ($phone.length > 0) {
    var mobileReg = /^[6-9]\d{9}$/;
    return mobileReg.test($phone);
  } else {
    return false;
  }
}

function Is_Valid_PINNO($pinCode) {
  if ($pinCode.length > 0) {
    var pinCodeReg = /^(\d{6})$/;
    return pinCodeReg.test($pinCode);
  } else {
    return false;
  }
}

function Is_Valid_MobileNo($mobile) {
  if ($mobile.length > 0) {
    var mobileReg = /^\d{10}$/;
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
function Is_Valid_Number($no) {
  if ($no.length > 0) {
    var noReg = /^\d+$/;
    return noReg.test($no);
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

function Is_Positive_Integer($no) {
  var noReg = /^[\d]+$/;
  return noReg.test($no);
}

function Is_Positive_Number_Greater_Than_Zero($no) {
  return parseFloat($no) > 0 || parseInt($no) > 0;
}

function Is_Valid_GST($gst) {
  if ($gst.length > 0) {
    var gstReg = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
    return gstReg.test($gst);
  } else {
    return false;
  }
}

// Hide Error Message under element whenever any text is pasted in the selected element
function ClearInputFieldError() {
  $("input[type=text], input[type=tel], input[type=number]").on(
    "paste",
    function (e) {
      ClearInvalidState(e.target);
    }
  );
}
function ClearInvalidState(e) {
  $("#" + e.id).removeClass("is-invalid state-invalid");
}

function GetIFSCCode(Branch_Id, Label_Id) {
  if (Branch_Id == "" || Branch_Id == null || Branch_Id == undefined) {
    $("#" + Label_Id).text("");
    return;
  }
  var MethodName = "GetIFSCCode";
  var url = "/Home/GetMasterData";
  var reqdata = {
    Method_Name: MethodName,
    ParentField_Id: Branch_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      //var res = JSON.parse(result);
      var ifsccode = res[0].item_value;
      $("#" + Label_Id).text(ifsccode);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
    },
  });
}

function SetDataTable(ControlName, HideSortColArray, ExportFileName) {
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "InventoryReport";
  }
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }
  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    order: [[1, "desc"]],
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

function SetDataTableorder(ControlName, HideSortColArray, ExportFileName) {
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "InventoryReport";
  }
  if ($.fn.DataTable.isDataTable("#" + ControlName)) {
    $("#" + ControlName)
      .DataTable()
      .destroy();
  }
  // $('#example2').DataTable();
  $("#" + ControlName).dataTable({
    responsive: true,
    searching: true,
    order: [[0, "asc"]],
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

    // Ensure DefaultValue is a string for processing
    DefaultValue = DefaultValue ? DefaultValue + "" : "";

    var url = "/Home/GetMasterData";
    var reqdata = {
        Method_Name: MethodName,
        ParentField_Id: ParentFieldId,
    };

    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            $.each(result, function (data, value) {
                $(JQ_ControlName).append(
                    $("<option></option>").val(value.item_id).html(value.item_value)
                );
            });

            if (DefaultValue !== "") {
                // Case 1: Value is a JSON array string (starts with [)
                if (DefaultValue.charAt(0) == "[") {
                   
                    $(JQ_ControlName).val(JSON.parse(DefaultValue)).change();
                }
                // Case 2: Value is a comma-separated string
                else if (DefaultValue.indexOf(',') > -1) {
                   
                    var valArray = DefaultValue.split(',');
                    $(JQ_ControlName).val(valArray).change();
                }
                // Case 3: Single select
                else {
                    
                    $(JQ_ControlName).val(DefaultValue).change();
                }
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
  Param1,
  Param2
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

  var url = "/Home/GetMastersData";
  var reqdata = {
    Method_Name: MethodName,
    Param1: Param1,
    Param2: Param2,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
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

function Show_Loader() {
  $("#global-loader").show();
}
function Hide_Loader() {
  $("#global-loader").fadeOut("slow");
}

function SetDataTable_Filter(ControlName, HideSortColArray, ExportFileName) {
  idtable = "#" + ControlName;

  datatablecol = $(idtable + " thead tr").clone(true);
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "InventoryReport";
  }
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

function SetDataTable_Report(ControlName, HideSortColArray, ExportFileName) {
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "MilkInReport";
  }
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

function SetPagingDataTable(ControlName, HideSortColArray, ExportFileName) {
  if (ExportFileName == "" || ExportFileName == null) {
    ExportFileName = "InventoryReport";
  }
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
  var APIEndPoint = MethodName;
  var url = "/Home/GetMasterData";
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
    success: function (result) {
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
