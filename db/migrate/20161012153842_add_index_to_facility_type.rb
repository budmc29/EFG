class AddIndexToFacilityType < ActiveRecord::Migration
  def change
    add_index :loans, :facility_type
  end
end
