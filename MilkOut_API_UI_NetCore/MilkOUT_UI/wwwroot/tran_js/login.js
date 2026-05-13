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
});

if (localStorage.getItem("rememberMe") === "true") {
  $("#remember_Me").prop("checked", true);
  $("#txtLoginName").val(localStorage.getItem("employee_ID") || "");
  $("#txtLoginPassword").val(localStorage.getItem("employee_Password") || "");
}

// Attach a change event listener to the "Remember me" checkbox
$("#rememberMe").change(function () {
  if ($(this).prop("checked")) {
    // Save data to localStorage
    localStorage.setItem("rememberMe", "true");
    localStorage.setItem("employee_ID", $("#txtLoginName").val());
    localStorage.setItem("employee_Password", $("#txtLoginPassword").val());
  } else {
    // Clear data from localStorage
    localStorage.removeItem("rememberMe");
    localStorage.removeItem("employee_ID");
    localStorage.removeItem("employee_Password");
  }
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
      method_name: "AdminUser",
      country_code: "+91",
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        // if Password Reset flag set to 1, show Change Password Page
        if (result == 1) {
          $.ajax({
            url: "/Login/ChangePassword",
            data: { Pkey: "" },
            success: function (result) {
              if (result) {
                $("#divChangePassword").html(result);
                $("#divLoginSection").hide();
              }
              callback(true);
            },
            error: function (result) {
              if (result.status == "401") {
                Show_Error_Toastr("You are not authorized to this transaction");
              }
            },
          });
        } else {
          // If successful login then take user to Home Page
          window.location = "/Home/Index";
        }
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

    Show_Error_Toastr("User name or Login Password is blank.");
  }
}

function ChangePassword() {
  var NewPassword = $("#txtLoginNewPassword").val();
  var ConfirmNewPassword = $("#txtLoginConfirmNewPassword").val();
  if (NewPassword != ConfirmNewPassword) {
    $("#txtLoginConfirmNewPassword").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Both Passwords should match.");
    return;
  }
  var url = "/Login/Change_Password";
  var Method_Name = "ChangePassword";
  var reqdata = {
    login_password: NewPassword,
    method_name: Method_Name,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      // var res = JSON.parse(result);
      if (result == 0) {
        // Show Dashboard
        // window.location = "Home/Index";
        window.location = "Login/Logout";
      } else {
        Show_Error_Toastr("Changing Password Failed");
        window.location = "Login/Index";
      }
    },
    error: function () {
      Show_Error_Toastr("Something went wrong.");
    },
  });
}

function ShowLoginDiv() {
  $("#divLoginSection").show();
  $("#divChangePassword").hide();
}
