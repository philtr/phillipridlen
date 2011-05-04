$(document).ready(function() {
  $('a#send_email').click(function() {
    $('#contact').fadeToggle();
    location.href = location.href + '#contact';
    return false;
  });
});