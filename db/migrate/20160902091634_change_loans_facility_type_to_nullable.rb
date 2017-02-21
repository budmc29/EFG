class ChangeLoansFacilityTypeToNullable < ActiveRecord::Migration
  def change
    change_column_null :loans, :facility_type, true
  end
end
