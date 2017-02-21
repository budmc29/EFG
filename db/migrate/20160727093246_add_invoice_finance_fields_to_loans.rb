class AddInvoiceFinanceFieldsToLoans < ActiveRecord::Migration
  def change
    rename_column :loans, :debtor_book_coverage,
                  :invoice_prepayment_coverage_percentage
    rename_column :loans, :debtor_book_topup,
                  :invoice_prepayment_topup_percentage

    add_column :loans, :invoice_book_debt_amount, :integer, limit: 8
    add_column :loans, :invoice_prepayment_topup_amount, :integer, limit: 8
  end
end
