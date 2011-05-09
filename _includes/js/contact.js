$(document).ready(function() {
  $('a#send_email').click(function() {
    $('#contact').fadeIn(100);
    document.getElementById('contact').scrollIntoView(true);
    return false;
  });
  $('#contact #cancel_email').click(function() {
    $('#contact').slideUp(100);
    return false;
  });
  if(location.href.split('?')[1] == "thanks") {
    $('#notice .content').text("Thanks for your input! I will read but may not necessarily respond to every email.");
    $('#notice').fadeIn();
    $('#notice .close a').click(function(){
      $('#notice').fadeOut();
      return false;
    });
  }
});