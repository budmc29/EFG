class AddRevolvingCreditFacilityAmountToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :revolving_credit_facility_amount, :integer, limit: 8
  end
end
