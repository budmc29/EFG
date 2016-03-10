(function($) {
  $.fn.loanReportForm = function() {
    return this.each(function(_, element) {
      var form = $(element)
      var efgLoanType = form.find('#loan_report_loan_types_efg')
      var phaseInputs = form.find('.loan_report_phases')

      togglePhaseFields(efgLoanType, phaseInputs) // when page first loads

      efgLoanType.change(function() {
        togglePhaseFields(efgLoanType, phaseInputs)
      })

      function togglePhaseFields(efgLoanType, phaseInputs) {
        if (efgLoanType.is(':checked')) {
          phaseInputs.removeClass('hide')
        } else {
          phaseInputs.addClass('hide')
          phaseInputs.find('input:checkbox').prop('checked', false)
        }
      }
    })
  }
})(jQuery)

$(document).ready(function() {
  $('.loan-report').loanReportForm()
})
