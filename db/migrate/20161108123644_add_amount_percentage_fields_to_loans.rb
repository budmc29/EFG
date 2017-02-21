class AddAmountPercentageFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :amount_percentage, :decimal, precision: 5, scale: 2
    add_column :loans, :override_amount_percentage, :boolean, default: false
  end
end
