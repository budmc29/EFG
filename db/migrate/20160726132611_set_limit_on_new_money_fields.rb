class SetLimitOnNewMoneyFields < ActiveRecord::Migration
  def change
    change_column :loans, :facility_amount, :integer, limit: 8
    change_column :loans, :additional_security_amount, :integer, limit: 8
  end
end
