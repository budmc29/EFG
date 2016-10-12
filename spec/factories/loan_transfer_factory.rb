FactoryGirl.define do
  factory :loan_transfer do
    amount 10_000_00
    new_amount 8_000_00
    reference "D54QT9C+01"
    declaration_signed true
    lender
    facility_letter_date "20/05/2011"

    initialize_with do
      loan = FactoryGirl.create(:loan, :guaranteed)
      new(loan)
    end
  end
end
