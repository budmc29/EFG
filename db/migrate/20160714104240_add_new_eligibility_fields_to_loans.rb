class AddNewEligibilityFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :turnover_allowed, :boolean
    add_column :loans, :within_efg_limits, :boolean
    add_column :loans, :within_excluded_sector, :boolean
    add_column :loans, :within_restricted_sector, :boolean
    add_column :loans, :operating_outside_uk, :boolean
    add_column :loans, :received_other_state_aid, :boolean
  end
end
