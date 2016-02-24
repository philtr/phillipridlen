(function($) {
  var sendContactForm = function sendContactForm(form) {
    var request = new XMLHttpRequest();
    var formData = new FormData(form);

    request.open('POST', 'https://formspree.io/p@rdln.net', true);
    request.setRequestHeader('Accept', 'application/json');
    request.send(formData);

    request.onreadystatechange = function () {
      if (request.readyState === 4) {
        Turbolinks.visit('/contact/thanks/');
      }
    };
  };


  var initRemoteContactForm = function initRemoteContactForm () {
    $('form#contact').on('submit', function(e) {
      e.preventDefault();
      sendContactForm(this);
    });
  }

  $(document).on('turbolinks:load', initRemoteContactForm);
}).call(window, Sprint);
