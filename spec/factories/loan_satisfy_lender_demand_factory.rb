FactoryGirl.define do
  factory :loan_satisfy_lender_demand do
    transient do
      association :loan, factory: [:loan, :lender_demand]
    end

    association :modified_by, factory: :lender_user
    date_of_change Date.current

    initialize_with do
      new(loan)
    end
  end
end
