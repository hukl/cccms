admin_search = {
  
  display_toggle : function() {
    if ($('#search_widget').css("display") != "none") {
      $('#search_widget').fadeOut();
    }
    else {
      $('#search_widget').fadeIn();
      $('#search_term').attr("value", "");
      $('#search_term').focus();
    }
    
    $("#search_term").bind("keyup", function() {
      if ($(this).attr("value")) {
        $.ajax({
          type: "GET",
          url: "/admin/search",
          data: "search_term=" + $(this).attr("value"),
          dataType: "json",
          success : function(results) {
            admin_search.show_results(results);
          }
        });
      }
      else {
        $('#search_results').slideUp();
        $('#search_results').empty(); 
      }
    });
  },
    
  show_results : function(results) {
     $('#search_results').empty();
     for (result in results) {
       $('#search_results').append("<p><a href='"+ results[result].edit_path + "'>" + results[result].title + "</a></p>");
     }
     $('#search_results').slideDown();
  }
}