(function($) {
  function initMenuToggler() {
    $('#js-navigation-menu').removeClass('show');

    $('#js-mobile-menu').on('click', function(e) {
      $('#js-navigation-menu').toggleClass('show');
    });
  }

  $(document).ready(initMenuToggler);
}).call(window, Sprint);
