FactoryGirl.define do
  factory :settlement_adjustment do
    created_by factory: :cfe_user
    amount Money.new(100_00)
    date { Date.current }
    loan factory: [:loan, :settled]
  end
end
