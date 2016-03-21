FactoryGirl.define do
  factory :lending_limit do
    lender
    phase_id 5
    active true
    allocation 1000000
    allocation_type_id LendingLimitType::Annual.id
    sequence(:name) { |n| "lending limit #{n}" }
    starts_on 1.month.ago
    ends_on { |lending_limit| lending_limit.starts_on.advance(years: 1) }

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :phase_1 do
      phase_id 1
    end

    trait :phase_5 do
      phase_id 5
    end

    trait :phase_6 do
      phase_id 6
    end

    trait :phase_7 do
      phase_id 7
    end

    trait :phase_8 do
      phase_id 8
    end
  end
end
