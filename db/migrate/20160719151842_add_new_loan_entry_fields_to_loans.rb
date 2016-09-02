class AddNewLoanEntryFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :additional_security, :boolean
    add_column :loans, :additional_security_amount, :integer
    add_column :loans, :additional_security_included_in_guarantee, :boolean
    add_column :loans, :guarantee_will_amortise, :boolean
    add_column :loans, :security_classification, :string
  end
end
