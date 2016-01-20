class ReplaceHtmlEntitiesInLoanIneligibilityReasons < ActiveRecord::Migration
  def up
    execute 'UPDATE loan_ineligibility_reasons SET reason = REPLACE(reason, "&pound;", "£") WHERE reason LIKE "%&pound;%"'
  end
end
