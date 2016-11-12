class AddRepaymentProfileFieldToLoanModifications < ActiveRecord::Migration
  def change
    add_column :loan_modifications, :repayment_profile, :string
    add_column :loan_modifications, :old_repayment_profile, :string

    add_column :loan_modifications, :fixed_repayment_amount, :integer, limit: 8
    add_column :loan_modifications, :old_fixed_repayment_amount, :integer,
               limit: 8
  end
end
