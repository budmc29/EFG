FactoryGirl.define do
  factory :agreed_draw do
    transient do
      association :loan, factory: [:loan, :guaranteed]
    end

    association :created_by, factory: :lender_user
    date_of_change Date.new
    amount_drawn Money.new(1_000_00)

    initialize_with do
      new(loan)
    end
  end
end
