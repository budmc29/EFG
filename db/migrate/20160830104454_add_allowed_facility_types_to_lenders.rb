class AddAllowedFacilityTypesToLenders < ActiveRecord::Migration
  def up
    add_column :lenders, :allowed_facility_types, :text

    # all existing lenders have Business Term facility type
    facility_types = ["business_term"].to_yaml
    execute("UPDATE lenders SET allowed_facility_types = '#{facility_types}'")
  end

  def down
    remove_column :lenders, :allowed_facility_types
  end
end
