class AddWithinExcludedSubSectorToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :within_excluded_sub_sector, :boolean
  end
end
