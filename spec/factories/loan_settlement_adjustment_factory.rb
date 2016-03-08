FactoryGirl.define do
  factory :loan_settlement_adjustment do
    amount "100.00"
    date "26/03/16"
    association :created_by, factory: :cfe_user

    initialize_with do
      loan = build(:loan, :settled)
      new(loan, amount: amount, date: date)
    end
  end
end
