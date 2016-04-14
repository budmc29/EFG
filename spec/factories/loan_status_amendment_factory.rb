FactoryGirl.define do
  factory :loan_status_amendment do
    status_amendment_type LoanStatusAmendment::ELIGIBILITY

    initialize_with {
      loan = FactoryGirl.create(:loan, :guaranteed)
      new(loan)
    }
  end
end
