$(document).ready(function () {
  $("#metadata").attr("style", "display: none;")
  
  $("#button").click(function () {
    $("#metadata").slideToggle("slow");
    
    if ($("#button").attr("class") == "unselected") {
      $("#button").attr("class", "selected");
    }
    else {
      $("#button").attr("class", "unselected");
    }
  });
});