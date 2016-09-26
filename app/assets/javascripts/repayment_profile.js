(function($) {
  $.fn.repaymentProfile = function() {
    return this.each(function(_, element) {
      var form = $(element)

      var outstandingBalance = form.find("[data-repayment-profile-total-amount]")

      var repaymentProfile = form.find("[data-repayment-profile]")

      var fixedRepaymentAmount = form.find("[data-repayment-amount]").hide()
      var fixedRepaymentAmountInput = fixedRepaymentAmount.find("input")

      var repaymentDuration = form.find("[data-repayment-duration]")
      var repaymentDurationMonths = repaymentDuration.find("[data-duration-months]")
      var repaymentDurationYears = repaymentDuration.find("[data-duration-years]")

      var maturityDate = form.find("[data-repayment-profile-maturity-date]")

      toggleFieldVisibility()
      calculateDuration()
      calculateMaturityDate()

      repaymentProfile.on("change", "input", function() {
        toggleFieldVisibility()
        calculateDuration()
        calculateMaturityDate()
      })

      outstandingBalance.on("change keyup", function() {
        calculateDuration()
        calculateMaturityDate()
      })

      fixedRepaymentAmountInput.on("keyup", function() {
        calculateDuration()
        calculateMaturityDate()
      })

      repaymentDurationMonths.on("keyup", calculateMaturityDate)
      repaymentDurationYears.on("keyup", calculateMaturityDate)

      function fixedTermRepaymentProfile() {
        return repaymentProfile.find(":checked").val() == "fixed_term"
      }

      function fixedAmountRepaymentProfile() {
        return repaymentProfile.find(":checked").val() == "fixed_amount"
      }

      function toggleFieldVisibility() {
        if (fixedTermRepaymentProfile()) {
          fixedRepaymentAmount.slideUp()
          fixedRepaymentAmountInput.val("")

          repaymentDurationMonths.prop("disabled", false)
          repaymentDurationYears.prop("disabled", false)
        } else if (fixedAmountRepaymentProfile()) {
          fixedRepaymentAmount.slideDown()

          repaymentDurationMonths.val("").prop("disabled", true)
          repaymentDurationYears.val("").prop("disabled", true)
        } else {
          fixedRepaymentAmount.hide()
        }
      }

      function calculateDuration() {
        if (fixedTermRepaymentProfile()) return
        if (!outstandingBalance.val()) return
        if (!fixedRepaymentAmountInput.val()) return

        var totalMonths = Math.ceil(
          new Money(outstandingBalance.val()).toFloat() /
          new Money(fixedRepaymentAmountInput.val()).toFloat()
        )

        var years = Math.floor(totalMonths / 12)
        var months = totalMonths % 12

        repaymentDurationYears.val(years)
        repaymentDurationMonths.val(months)
      }

      function calculateMaturityDate() {
        if (maturityDate.length == 0) return

        var initialDrawDate = Date.parse(maturityDate.data("initial-draw-date"))
        var termMonthsSoFar = maturityDate.data("loan-term-months-so-far") * 1

        var remainingLoanTermTotalMonths = repaymentDurationYears.val() * 12 +
                                             repaymentDurationMonths.val() * 1

        var newMaturityDate = initialDrawDate.
          add(termMonthsSoFar + remainingLoanTermTotalMonths).months()

        maturityDate.val(newMaturityDate.toLocaleDateString("en-GB"))
      }
    })
  }
})(jQuery)
