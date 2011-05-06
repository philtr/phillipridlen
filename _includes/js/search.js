$(document).ready(function() {
  $('#search form').submit(function(){
    $('#query').val("site:blog.phillipridlen.com " + $('#query').val());
  });
});