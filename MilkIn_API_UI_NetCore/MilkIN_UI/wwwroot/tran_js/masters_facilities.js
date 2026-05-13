$(document).ready(function () {
  $("#ddlSearchFacilityType").select2();

  // GetMaster("ddlSearchBranch", "All Branches", "GetBranch", "", "");

  SetDataTable("tableSearch", [6], "Facility");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
}

// Get data from database and show in table

function ShowAddEntry() {
  ShowContentDiv("Masters", "FacilitiesAdd", "", function () {
    // Initialization Code
    $("#ddlEntryFacilityType").select2();
    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function ShowEditEntry(Facility_Id) {
  ShowContentDiv("Masters", "FacilitiesEdit", "", function () {
    // Initialization Code
    $("#ddlEntryFacilityType").select2();
    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function CloseEntry() {
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var FacilityCode = $("#txtEntryFacilityCode").val();

  if (FacilityCode == "") {
    ShowEntryError("Enter Facility Code");
    return;
  }

  // Start Saving
  ShowEntrySuccess("Facility details saved successfully");
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

function DeleteEntry(Facility_Entry) {
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
      }
    }
  );
}
function SaveDeleteEntry() {
  // Write code to delete
  var Facility_Id = $("#lblEntryId").html();
  // In success do following things
  Show_Success_Toastr("Facility entry blocked successfully");
  CloseEntry();
  GetSearchList();
}
