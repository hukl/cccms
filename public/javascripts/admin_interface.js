$(document).ready(function () {
  $("#metadata").attr("style", "display: none;");
  
  $("#button").click(function () {
    $("#metadata").slideToggle("slow");
    
    if ($("#button").attr("class") == "unselected") {
      $("#button").attr("class", "selected");
    }
    else {
      $("#button").attr("class", "unselected");
    }
  });
  
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })
  
  jQuery.fn.submitWithAjax = function() {
    $("#flash").append("<img src='/images/ajax-loader.gif' alt='' />");
    $.post(this.attr("action"), $(this).serialize(), null, "script");
  };
  
  
  
});