class AddFinanceFacilityAmountToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :finance_facility_amount, :integer, limit: 8
  end
end
