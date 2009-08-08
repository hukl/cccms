$(document).ready(function () {
  admin_search.initialize();
  menu_items.initialize_search();
  meta_data.initialize();
  
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