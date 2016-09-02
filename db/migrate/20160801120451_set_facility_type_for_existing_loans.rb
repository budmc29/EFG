class SetFacilityTypeForExistingLoans < ActiveRecord::Migration
  def change
    # Type E loans
    execute("
      UPDATE loans
         SET facility_type = 'revolving_credit'
       WHERE loan_category_id = 5
    ")

    # Type F loans
    execute("
      UPDATE loans
         SET facility_type = 'invoice_finance'
       WHERE loan_category_id = 6
    ")
  end
end
