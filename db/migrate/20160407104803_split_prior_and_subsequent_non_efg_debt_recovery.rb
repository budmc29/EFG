class SplitPriorAndSubsequentNonEfgDebtRecovery < ActiveRecord::Migration
  def change
    rename_column(:recoveries,
                  :outstanding_non_efg_debt,
                  :outstanding_prior_non_efg_debt)

    add_column(:recoveries,
               :outstanding_subsequent_non_efg_debt,
               :integer)
  end
end
