$(document).ready(function () {
  $("#txtLoginName").focus();

  $("#show_hide_password span button").on("click", function (event) {
    event.preventDefault();
    if ($("#show_hide_password input").attr("type") == "text") {
      $("#show_hide_password input").attr("type", "password");
      $("#show_hide_password i").addClass("fa-eye-slash");
      $("#show_hide_password i").removeClass("fa-eye");
    } else if ($("#show_hide_password input").attr("type") == "password") {
      $("#show_hide_password input").attr("type", "text");
      $("#show_hide_password i").removeClass("fa-eye-slash");
      $("#show_hide_password i").addClass("fa-eye");
    }
  });

  if (localStorage.getItem("rememberMe") === "true") {
    $("#rememberMe").prop("checked", true);
    $("#txtLoginName").val(localStorage.getItem("employeeID") || "");
    $("#txtLoginPassword").val(localStorage.getItem("employeePassword") || "");
  }

  // Attach a change event listener to the "Remember me" checkbox
  $("#rememberMe").change(function () {
    if ($(this).prop("checked")) {
      // Save data to localStorage
      localStorage.setItem("rememberMe", "true");
      localStorage.setItem("employeeID", $("#txtLoginName").val());
      localStorage.setItem("employeePassword", $("#txtLoginPassword").val());
    } else {
      // Clear data from localStorage
      localStorage.removeItem("rememberMe");
      localStorage.removeItem("employeeID");
      localStorage.removeItem("employeePassword");
    }
  });
});

$("#txtLoginPassword").keypress(function (e) {
  Login_Name = $("#txtLoginName").val();
  Login_Password = $("#txtLoginPassword").val();

  if (
    Login_Name != "" &&
    Login_Password != "" &&
    Login_Name != undefined &&
    Login_Password != undefined &&
    Login_Name != null &&
    Login_Password != null
  ) {
    if (e.which === 13) {
      // Enter key is pressed
      ValidateLogin();
    }
  }
});

function ValidateLogin() {
  // Validate Login
  Login_Name = $("#txtLoginName").val();
  Login_Password = $("#txtLoginPassword").val();

  $("#btnLogIn").prop("disabled", true);

  if (Login_Name != "" && Login_Password != "") {
    $("#lblLogin").html("Validating ...");
    $("#loaderLogin").show();

    var url = "/Login/Login";
    var reqdata = {
      login_name: Login_Name,
      login_password: Login_Password,
      country_code: "+91",
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        // If successful login then take user to Home Page
        window.location = "/Home/Index";
      },
      error: function () {
        $("#loaderLogin").hide();
        $("#lblLogin").html("Login");
        $("#btnLogIn").prop("disabled", false);
        Show_Error_Toastr("Invalid login credentials.");
      },
    });
  } else {
    // Show Error that UserName and LoginPassword can't be empty
    $("#loaderLogin").hide();
    $("#lblLogin").html("Login");
    $("#btnLogIn").prop("disabled", false);

    Show_Error_Toastr("User name or LoginPassword is blank.");
  }
}

function ShowForgotPasswordDiv() {
  $.ajax({
    url: "/Login/ForgotPassword",
    data: { Pkey: "" },
    success: function (result) {
      if (result) {
        $("#divForgotPassword").html(result);
        $("#divLoginSection").hide();
        $("#divOTPEntry").hide();
        $("#divSubmitOTP").hide();
        $("#divForgotPassword").show();
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

function ShowLoginDiv() {
  $("#divLoginSection").show();
  $("#divForgotPassword").hide();
}

function SendOTP() {
  $("#divOTPEntry").show();
  $("#divSendOTP").hide();
  $("#divSubmitOTP").show();
}
