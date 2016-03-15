FactoryGirl.define do
  factory :loan_repay do
    repaid_on { Date.current }

    initialize_with {
      loan = FactoryGirl.create(:loan, :guaranteed)
      new(loan)
    }
  end
end
