$(document).ready(function() {
  $("#btn-login").click(function() {
    $.post("/login",
           {
             username: $("#username").val(),
             password: $("#password").val()
           },
           function(res) {
             console.log(res);
           })
  });
});
