//= require accounting

(function ($) {
  $.fn.invoiceSelectableRows = function () {
    var dataAttribute = 'data-selected'
    var rowInputSelector = 'input[type=checkbox]'

    return $(this).each(function (idx, tableElement) {
      var table = $(tableElement)

      var toggleSelected = function(rowElement) {
        var row = $(rowElement)
        var checked = row.find(rowInputSelector).is(':checked');

        if(checked) {
          row.attr(dataAttribute, 'true')
        } else {
          row.removeAttr(dataAttribute)
        }

        table.trigger('rowSelect', row)
      }

      setTimeout(function() {
        table.find('tr').each(function(idx, row) {
          toggleSelected(row)
        })
        table.trigger('rowSelectionChange')
      })

      table.on('change', rowInputSelector, function () {
        var row = $(this).parents('tr');
        toggleSelected(row)
        table.trigger('rowSelectionChange')
      })
    })
  }

  $.fn.invoiceTotal = function (filter) {
    var selector
    if(filter) {
      selector = $(filter, this)
    } else {
      selector = $(this)
    }

    var totalAmountSettled = 0;
    selector.find('[data-amount]').each(function(_, inputElement) {
      var input = $(inputElement);
      var amountSettledText = input.attr('data-amount') || input.val()
      var amountSettled = accounting.unformat(amountSettledText);
      totalAmountSettled = totalAmountSettled + amountSettled;
    });
    return totalAmountSettled
  }

  $.fn.invoiceSubTotal = function() {
    function setupSubTotal(table) {
      function render () {
        var subTotal = table.invoiceTotal('tbody tr[data-selected]')
        var formattedSubTotal = accounting.formatMoney(subTotal, '')

        table.find('[data-behaviour=subtotal] input').val(formattedSubTotal)

        var grandTotal = $('[data-behaviour=subtotal]').invoiceTotal()
        var formattedGrandTotal = accounting.formatMoney(grandTotal, '£')
        $('[data-behaviour=grand-total]').text(formattedGrandTotal)
      }

      table
        .bind('rowSelectionChange', render)
        .bind('recalculate', render)

      render()
    }

    return $(this).each(function (_, table) {
      setupSubTotal($(table))
    })
  }
})(jQuery);

$(document).ready(function() {

  function highlightRow(evt, rowElement) {
    var row = $(rowElement)
    row.toggleClass('info', !!row.attr('data-selected'))
  }

  $('[data-behaviour=invoice-received-table]')
    .invoiceSelectableRows()
    .invoiceSubTotal()
    .bind('rowSelect', highlightRow)

  $('[data-behaviour=invoice-received-table]')
    .on('blur', 'tbody input[type=text]', function() {
      $(this).parents('table').trigger('recalculate')
    })
});
