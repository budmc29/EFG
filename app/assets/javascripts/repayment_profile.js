(function($) {
  $.fn.repaymentProfile = function(config) {
    var defaultConfig = {
      durationAsYearsAndMonths: true,
      editableFixedTermDuration: true,
      updateMaturityDate: false
    }
    var config = $.extend(defaultConfig, config)

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
      var originalRepaymentValueMonths = repaymentDuration.data("original-value-months")

      toggleFieldVisibility()

      repaymentProfile.on("change", "input", toggleFieldVisibility)
      totalAmount.on("keyup", calculateDuration)
      fixedRepaymentAmountInput.on("keyup", calculateDuration)

      if (config.updateMaturityDate) {
        calculateMaturityDate()

        repaymentProfile.on("change", calculateMaturityDate)
        totalAmount.on("keyup", calculateMaturityDate)
        fixedRepaymentAmountInput.on("keyup", calculateMaturityDate)
      }

      function toggleFieldVisibility() {
        var selectedRepaymentProfile = repaymentProfile.find(":checked").val()

        if (selectedRepaymentProfile == "fixed_term") {
          fixedRepaymentAmount.val("").slideUp()
          repaymentDuration.slideDown()

          if (config.editableFixedTermDuration) {
            repaymentDurationYears.prop("disabled", false)
            repaymentDurationMonths.prop("disabled", false)
          }

          if (originalRepaymentValueMonths) {
            repaymentDurationMonths.val(originalRepaymentValueMonths)
          }

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

        if (config.durationAsYearsAndMonths) {
          years = Math.floor(totalMonths / 12)
          months = totalMonths % 12

          repaymentDurationYears.val(years)
          repaymentDurationMonths.val(months)
        } else {
          repaymentDuration.find("input").val(totalMonths)
        }
      }

      function calculateMaturityDate() {
        var maturityDate = parentElement.find("[data-repayment-profile-maturity-date]")
        var initialDrawDate = Date.parse(maturityDate.data("initial-draw-date"))

        var termMonthsSoFar = maturityDate.data("loan-term-months-so-far") * 1
        var newLoanTermMonths = repaymentDurationMonths.val() * 1
        var totalAdditionalMonths = termMonthsSoFar + newLoanTermMonths

        var newMaturityDate = initialDrawDate.add(totalAdditionalMonths).months()

        maturityDate.val(newMaturityDate.toLocaleDateString("en-GB"))
      }
    })
  }
})(jQuery)
