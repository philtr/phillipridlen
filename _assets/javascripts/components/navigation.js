(function($) {
  function initMenuToggler() {
    $('#js-navigation-menu').removeClass('show');

    $('#js-mobile-menu').on('click', function(e) {
      $('#js-navigation-menu').toggleClass('show');
    });
  }

  function initNavHighlighter() {
    $('li.nav-link, a.logo').on('click', function(e) {
      $('li.nav-link, a.logo').removeClass('active-nav-item');
      $(this).addClass('active-nav-item');
      $('#js-navigation-menu').removeClass('show');
    });
  }

  $(document).ready(initMenuToggler);
  $(document).ready(initNavHighlighter);
}).call(window, Sprint);
