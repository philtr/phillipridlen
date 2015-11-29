function initMenuToggler() {
  var menuToggle = $('#js-mobile-menu');
 $('#js-navigation-menu').removeClass("show");

  menuToggle.on('click', function(e) {
    e.preventDefault();
    $('#js-navigation-menu').toggleClass("show");
  });
}

function initNavHighlighter() {
  $("li.nav-link").on('click', function(e) {
    $(this).siblings().removeClass("active-nav-item");
    $(this).addClass("active-nav-item");
  });
}
