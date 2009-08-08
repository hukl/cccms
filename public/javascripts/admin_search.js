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
    $("#search_term").bind("keyup", function() {
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
      var foo = $(("<a href='#'>"+ results[result].title + "</a>"));
      $(foo).bind("click", function(){
        menu_items.open_title_popup();
        //menu_items.add_item_to_menu(results[result]);
        return false;
      });
      
      $("#search_results").append(foo);
      
    }
  },
  
  open_title_popup : function() {
    popup = $("<div><form action='#'><input id='item_title' type='text' /><input id='foobar' type='submit' /></form></div>");
    $("form", popup).submit(function(){
      alert("hi");
      return false;
    });
    $("body").append(popup);
  },
  
  add_item_to_menu : function(node) {
    $.ajax({
      type: "post",
      url: "/menu_items/create",
      data: {
        "menu_item[node_id]"      : node.node_id,
        "menu_item[path]"         : "/" + node.unique_name,
        "menu_item[title]"        : node.title
      },
      success : function() {
        alert("s");
      }
    });
  }
  
};