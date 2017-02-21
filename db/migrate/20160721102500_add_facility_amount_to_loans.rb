class AddFacilityAmountToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :facility_amount, :integer
  end
end
