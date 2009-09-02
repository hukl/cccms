$(document).ready(function () {
  admin_search.initialize();
  menu_items.initialize_search();
  meta_data.initialize();
  menu_item_sorter.initialize();
  
  
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })
  
  $(document).ajaxSend(function(event, request, settings) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });
  
});


meta_data = {
  initialize : function() {
    $("#metadata").hide();

    $("#button").click(function () {
      $("#metadata").slideToggle(1200);

      if ($("#button").attr("class") == "unselected") {
        $("#button").attr("class", "selected");
        image_interface.initialize(); 
      }
      else {
        $("#button").attr("class", "unselected");
      }
      
      return false;
    });
  }
};

cccms = {
  setup_autosave : function() {
    
    var elements = {
      title     : $('#page_title'),
      abstract  : $('#page_abstract'),
      body      : $('#page_body_ifr').contents().find('#tinymce'),
    }
  
    var page = {         
      cached_title    : elements.title.val(),
      cached_abstract : elements.abstract.val(),
      cached_body     : elements.body.html(),
  
      title_has_changed : function() {
         return (elements.title.val() != this.cached_title)
       },
  
       abstract_has_changed : function() {
         return (elements.abstract.val() != this.cached_abstract)
       },
  
       body_has_changed : function() {
         return elements.body.html() != this.cached_body
       }
    }
  
    jQuery.fn.submitWithAjax = function(options) {
      if (page.title_has_changed() || page.abstract_has_changed() || page.body_has_changed()) {
  
        page.cached_title      = elements.title.val();
        page.cached_abstract   = elements.abstract.val();
        page.cached_body       = elements.body.html();
  
        $("#flash").append("<img src='/images/ajax-loader.gif' alt='' />");
        $.post(this.attr("action"), $(this).serialize(), null, "script");
        
      }
    };
  
    setInterval('$("#page_editor > form").submitWithAjax()', 15000);
  }
}

menu_item_sorter = {
  
  initialize : function() {
    $("#menu_item_list").sortable({
      axis: 'y',
      items: 'tr',
      handle: 'td',
      placeholder: 'ui-state-highlight',
      start: function(e, ui) {
        menu_item_sorter.placeholder_helper(e,ui);
      },
      stop : function(){
        $.ajax({
          type: "POST",
          url: "/menu_items/0/sort",
          data: $(this).sortable("serialize"),
          dataType: "json",
          success : function(results) {
            alert(results);
          }
        });
      }
    });
  },
  
  placeholder_helper : function(e,ui) {
    $(".ui-state-highlight").html("<td colspan='100%'></td>");
  }
}

image_interface = {
  initialize : function() {
    $("ul#image_box").sortable({
      revert  : true,
      stop    : function(event, ui) {
        $.ajax({
          type : "POST",
          url  : "/pages/" + $("ul#image_box").attr("rel") + "/sort_images",
          dataType : "json",
          data : $("ul#image_box").sortable("serialize", {attribute : "rel"}) + 
                 "&_method=put",
          success : function() {}
        });
      }
    });
    
    $("ul#image_box").droppable({
      out : function(event, ui) {
        $(ui.draggable).bind("mouseup", function() {
          $(this).remove()
        });
      }
    });
    
    $("div#asset_toolbox ul li").draggable({
      connectToSortable : 'ul#image_box',
      helper : 'clone',
      revert : 'invalid',
      stop   : function() {
        
      }
    });
    
    $("ul, li").disableSelection();
  }
}
      

