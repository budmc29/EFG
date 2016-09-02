class AllowLoansFieldsToBeNull < ActiveRecord::Migration
  def change
    change_column_null :loans, :amount, true
    change_column_null :loans, :repayment_duration, true
    change_column_null :loans, :sic_code, true
  end
end
