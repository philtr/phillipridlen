$(document).ready(function() {
  $('a#send_email').click(function() {
    $('#contact').fadeIn(100);
    document.getElementById('contact').scrollIntoView(true);
    return false;
  });
  $('#contact #cancel_email').click(function() {
    $('#contact').slideUp(100);
    return false;
  })
});