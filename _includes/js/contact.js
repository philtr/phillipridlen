$(document).ready(function() {
  $('a#send_email').click(function() {
    $('#contact').hide().fadeIn(500);
     document.getElementById('contact').scrollIntoView(true);
    return false;
  });
  $('#contact #cancel_email').click(function() {
    $('#contact').fadeOut();
    return false;
  })
});