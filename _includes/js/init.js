var ready = function ready_() {
  $("form#contact").on("submit", function submitFormToBrace(e) {
    e.preventDefault();

    $.ajax({
      url: "https://formkeep.com/f/321d46f244f3",
      method: "POST",
      data: $(this).serialize(),
      dataType: "json",
      success: function() {
        alert("Thanks for contacting me. I'll be in touch with you shortly!");
        $(this).reset()
      },
    });
  });
}

$(document).on("ready page:load", ready);

Turbolinks.enableTransitionCache();
Turbolinks.enableProgressBar();
