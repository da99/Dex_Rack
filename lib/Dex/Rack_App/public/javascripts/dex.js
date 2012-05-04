$(document).ready(function() {
  
  $("#show_backtrace").click(function() {
    $("#show_backtrace").css("visibility", "hidden");
    $("#hide_backtrace").css("visibility", "visible");
    $("#backtrace").show();
  });
  
  $("#hide_backtrace").click(function() {
    $("#show_backtrace").css("visibility", "visible");
    $("#hide_backtrace").css("visibility", "hidden");
    $("#backtrace").hide();
  });

});

