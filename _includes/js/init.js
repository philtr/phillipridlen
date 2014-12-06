var ready = function ready_() {
  $('[data-toggle="tooltip"]').tooltip();
}

$(document).on("ready page:load", ready);
