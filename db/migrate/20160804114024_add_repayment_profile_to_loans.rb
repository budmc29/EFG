class AddRepaymentProfileToLoans < ActiveRecord::Migration
  def up
    add_column :loans, :repayment_profile, :string
    add_column :loans, :fixed_repayment_amount, :integer, limit: 8

    execute("
       UPDATE loans
          SET repayment_profile = 'fixed_term'
        WHERE state NOT IN ('eligible', 'rejected', 'incomplete')
    ")
  end

  def down
    remove_column :loans, :repayment_profile
    remove_column :loans, :fixed_repayment_amount
  end
end
