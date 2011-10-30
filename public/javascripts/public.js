Shadowbox.init({
  skipSetup : true
});


$(document).ready(function(){

  Shadowbox.setup(".shadowbox_image", {gallery : "fofo"})

  if ($("#headline_image img").length != 0) {
    image_handler.initialize();
  }

  $("div#headline_image a").bind("click", function() {
    return false;
  });

  $("div#headline_image a img").bind("click", function(){
    $(".shadowbox_image:first").trigger("click");
  });
});


var image_handler = {
  initialize : function() {

    path_name     = window.location.pathname;
    locale_rexexp = /^\/(en|de)\\/;
    locale_match  = locale_rexexp.exec(path_name);

    if (locale_match) {
      locale = locale_match[0];
    }
    else {
      locale = "/de/";
    }

    path = path_name.replace(/\/(de|en)*\/*/, "");
    gallery_path = "";
  }
};