(function($) {
  $.fn.loanEntryForm = function() {
    return this.each(function(_, element) {
      var loanEntryForm = $(element)
      var stateAidCalculationButton = loanEntryForm.find('.control-group.state_aid input[type=submit]')
      var repaymentFrequencySelect = loanEntryForm.find('#loan_entry_repayment_frequency_id')

      var focusRepaymentFrequency = function() {
        repaymentFrequencySelect.parents('.control-group').addClass('warning')
        repaymentFrequencySelect.focus()
      }

      var popover = stateAidCalculationButton.popover({
        html: true,
        title: 'Repayment Frequency Required',
        content: 'Unable to calculate State Aid until a <a href="#">repayment frequency</a> has been selected for the loan.',
        placement: 'top',
        trigger: 'manual'
      })

      popover.data('popover').tip().on('click', 'a', function(evt) {
        evt.preventDefault()
        focusRepaymentFrequency()
      })

      stateAidCalculationButton.click(function(evt) {
        if(!repaymentFrequencySelect.val()) {
          evt.preventDefault()
          stateAidCalculationButton.popover('show')
        }
      })

      repaymentFrequencySelect.change(function(evt) {
        if(repaymentFrequencySelect.val()) {
          stateAidCalculationButton.popover('hide')
        }
      })
    })
  }
})(jQuery)

$(document).ready(function() {
  $('.form-loan-entry').loanEntryForm()
  $('.repayment-profile').repaymentProfile()
})
