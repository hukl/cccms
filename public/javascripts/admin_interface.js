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
  
});


cccms = {
  setup_autosave : function() {
    
    var elements = {
      "title"    : $('#page_title'),
      "abstract" : $('#page_abstract'),
      "body"     : $('#page_body_ifr').contents().find('#tinymce'),
    }
  
  
    var page = {         
      "cached_title_length"    : elements.title.val().length,
      "cached_abstract_length" : elements.abstract.val().length,
      "cached_body_length"     : elements.body.html().length,
  
      "title_has_changed" : function() {
         return (elements.title.val().length != this.cached_title_length)
       },
  
       "abstract_has_changed" : function() {
         return (elements.abstract.val().length != this.cached_abstract_length)
       },
  
       "body_has_changed" : function() {
         return elements.body.html().length != this.cached_body_length
       }
    }
  
  
    jQuery.fn.submitWithAjax = function(options) {
      if (page.title_has_changed() || page.abstract_has_changed() || page.body_has_changed()) {
  
        page.cached_title_length      =  elements.title.val().length;
        page.cached_abstract_length   = elements.abstract.val().length;
        page.cached_body_length       = elements.body.html().length;
  
        $("#flash").append("<img src='/images/ajax-loader.gif' alt='' />");
        $.post(this.attr("action"), $(this).serialize(), null, "script");
        
      }
    };
  
    setInterval('$("#page_editor > form").submitWithAjax()', 15000);
  }
}