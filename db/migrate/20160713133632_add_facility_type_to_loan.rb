class AddFacilityTypeToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :facility_type, :string

    execute("UPDATE loans SET facility_type = 'business_term'")

    change_column_null :loans, :facility_type, false
  end
end
