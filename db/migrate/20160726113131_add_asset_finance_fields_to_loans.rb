class AddAssetFinanceFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :deposit_amount, :integer, limit: 8
    add_column :loans, :end_of_finance_payment_amount, :integer, limit: 8
    add_column :loans, :agreement_type, :string
  end
end
