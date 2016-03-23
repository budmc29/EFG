(function($) {
  $.fn.selectPopover = function() {
    return this.each(function(_, element) {
      var select = $(element)
      var selectedOption;

      select.change(function() {
        selectedOption = $(this).find(":selected")

        if (selectedOption.data("toggle") == "popover") {
          select.popover({ 
            content: selectedOption.data("content"),
            placement: "bottom"
          }).popover("show")
        } else {
          select.popover("destroy")
        }
      })
    })
  }
})(jQuery)

$(document).ready(function() {
  $("[data-select-popover]").selectPopover()
})
