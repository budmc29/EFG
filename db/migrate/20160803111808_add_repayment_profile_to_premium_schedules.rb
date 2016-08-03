class AddRepaymentProfileToPremiumSchedules < ActiveRecord::Migration
  def up
    add_column :premium_schedules, :repayment_profile, :string
    add_column :premium_schedules, :fixed_repayment_amount, :integer, limit: 8

    execute("UPDATE premium_schedules SET repayment_profile = 'fixed_term'")
  end

  def down
    remove_column :premium_schedules, :repayment_profile
    remove_column :premium_schedules, :fixed_repayment_amount
  end
end
