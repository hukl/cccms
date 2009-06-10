admin_search = {
  
  initialize : function() {
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
        $('#results').empty(); 
      }
    });
  },
  
  show_results : function(results) {
    $('#results').empty();
    for (result in results) {
      $('#results').append("<p>" + results[result].title + "</p>");
    }
  }
}