class AddOutstandingFacilityAmountToDemandToBorrowers < ActiveRecord::Migration
  def change
    add_column :demand_to_borrowers, :outstanding_facility_amount,
               :integer, limit: 8
  end
end
