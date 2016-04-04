//= require accounting

(function ($) {
  $.fn.recoveriesSelectableRows = function () {
    return $(this).each(function() {
      var table = $(this)

      table.on('change', 'input[type=radio]', function () {
        var row = $(this).parents('tr:first')

        row.attr('data-post-claim', this.value)

        table.trigger('rowSelect', row)
        table.trigger('rowSelectionChange')
      })
    })
  }

  $.fn.recoveriesTotal = function (filter) {
    var selector
    if(filter) {
      selector = $(filter, this)
    } else {
      selector = $(this)
    }

    var totalAmount = 0;
    selector.find('[data-amount]').each(function(_, inputElement) {
      var input = $(inputElement);
      var amountText = input.attr('data-amount') || input.val();
      var amount = accounting.unformat(amountText);
      totalAmount += amount;
    });
    return totalAmount
  }

  $.fn.recoveriesCalculateTotals = function() {
    function setupBehaviour(table) {
      function renderTotals () {
        // calculate subtotals for this table
        var preSubTotal = table.recoveriesTotal('tbody tr[data-post-claim=no]')
        var formattedPreSubTotal = accounting.formatMoney(preSubTotal, '£')
        table.find('[data-behaviour=preSubTotal] td').text(formattedPreSubTotal)

        var postSubTotal = table.recoveriesTotal('tbody tr[data-post-claim=yes]')
        var formattedPostSubTotal = accounting.formatMoney(postSubTotal, '£')
        table.find('[data-behaviour=postSubTotal] td').text(formattedPostSubTotal)

        var subTotal = preSubTotal + postSubTotal
        var formattedSubTotal = accounting.formatMoney(subTotal, '£')
        table.find('[data-behaviour=subtotal] td').text(formattedSubTotal)

        // recalculate the grand totals for all tables
        var preTotal = $('table tbody tr[data-post-claim=no]').recoveriesTotal()
        var formattedPreTotal = accounting.formatMoney(preTotal, '£')
        $('[data-behaviour=pre-total]').text(formattedPreTotal)

        var postTotal = $('table tbody tr[data-post-claim=yes]').recoveriesTotal()
        var formattedPostTotal = accounting.formatMoney(postTotal, '£')
        $('[data-behaviour=post-total]').text(formattedPostTotal)

        var grandTotal = preTotal + postTotal
        var formattedGrandTotal = accounting.formatMoney(grandTotal, '£')
        $('[data-behaviour=grand-total]').text(formattedGrandTotal)
      }

      table
        .bind('rowSelectionChange', renderTotals)
        .bind('recalculate', renderTotals)

      renderTotals()
    }

    return $(this).each(function (_, table) {
      setupBehaviour($(table))
    })
  }
})(jQuery);

$(document).ready(function() {

  function highlightRow(evt, rowElement) {
    $(rowElement).addClass('info')
  }

  $('[data-behaviour=recoveries-statement-table]')
    .recoveriesSelectableRows()
    .recoveriesCalculateTotals()
    .bind('rowSelect', highlightRow)

});
