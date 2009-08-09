admin_search = {
  
  initialize : function() {
    $("#search_widget").hide();

    $(document).bind("keydown", 'Alt+f', function(){
      admin_search.display_toggle();
      return false;
    });
  },
  
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
};

menu_items = {
  
  initialize_search : function() {
    $("#menu_search_term").bind("keyup", function() {
      if ($(this).attr("value")) {
        $.ajax({
          type: "GET",
          url: "/admin/menu_search",
          data: "search_term=" + $(this).attr("value"),
          dataType: "json",
          success : function(results) {
            menu_items.show_results(results);
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
    $("#search_results").empty();
    for (result in results) {
      var link = $(("<a href='#'>"+ results[result].title + "</a>"));
      $(link).bind("click", function(){
        menu_items.add_item_to_form(results[result]);
        return false;
      });
      
      
      // Sometimes I don't get jquery; wrap() didn't work *sigh*
      // Guess I'll need a book someday or another framework
      var wrapper = $("<div></div>");
      $(wrapper).append(link)
      
      $("#search_results").append(wrapper);
      
    }
  },
  
  add_item_to_form : function(node) {
    $("#menu_item_node_id").val(node.node_id);
    $("#menu_item_path").val("/" + node.unique_name);
    $("#menu_item_title").val(node.title);
  } 
};