(function($) {
  $.fn.repaymentProfile = function() {
    return this.each(function(_, element) {
      var parentElement = $(element)
      var totalAmount = parentElement.
        find("[data-repayment-profile-total-amount]")

      var repaymentProfile = parentElement.find("[data-repayment-profile]")

      var fixedRepaymentAmount = parentElement.find("[data-repayment-amount]")
      var fixedRepaymentAmountInput = fixedRepaymentAmount.find("input")

      var repaymentDuration = parentElement.find("[data-repayment-duration]")
      var repaymentDurationYears = repaymentDuration.
        find("[data-repayment-duration-years]")
      var repaymentDurationMonths = repaymentDuration.
        find("[data-repayment-duration-months]")

      toggleFieldVisibility()

      repaymentProfile.on("change", "input", toggleFieldVisibility)
      totalAmount.on("keyup", calculateDuration)
      fixedRepaymentAmountInput.on("keyup", calculateDuration)

      function toggleFieldVisibility() {
        var selectedRepaymentProfile = repaymentProfile.find(":checked").val()

        if (selectedRepaymentProfile == "fixed_term") {
          fixedRepaymentAmount.slideUp()
          repaymentDuration.slideDown()
          repaymentDurationYears.prop("disabled", false)
          repaymentDurationMonths.prop("disabled", false)
          fixedRepaymentAmountInput.prop("disabled", true)
        } else if (selectedRepaymentProfile == "fixed_amount") {
          fixedRepaymentAmountInput.prop("disabled", false)
          repaymentDuration.slideDown()
          fixedRepaymentAmount.slideDown()
          repaymentDurationYears.val("").prop("disabled", true)
          repaymentDurationMonths.val("").prop("disabled", true)
          calculateDuration()
        } else {
          fixedRepaymentAmount.hide()
          repaymentDuration.hide()
        }
      }

      function calculateDuration() {
        if (!totalAmount.val()) return
        if (!fixedRepaymentAmountInput.val()) return

        var totalMonths = Math.ceil(
          totalAmount.val() / fixedRepaymentAmountInput.val()
        )

        years = Math.floor(totalMonths / 12)
        months = totalMonths % 12

        repaymentDurationYears.val(years)
        repaymentDurationMonths.val(months)
      }
    })
  }
})(jQuery)

$(document).ready(function() {
  $('.repayment-profile').repaymentProfile()
})
