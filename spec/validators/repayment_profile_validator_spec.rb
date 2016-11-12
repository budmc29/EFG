require "rails_helper"

describe RepaymentProfileValidator do
  class RepaymentProfileValidatorExample
    include ActiveModel::Validations
    validates_with RepaymentProfileValidator

    attr_accessor :repayment_profile, :fixed_repayment_amount
  end

  let(:record) { RepaymentProfileValidatorExample.new }

  it "must have a repayment profile" do
    record.repayment_profile = nil
    expect(record).not_to be_valid
  end

  it "must have an allowed repayment profile" do
    record.repayment_profile = "foo"
    expect(record).not_to be_valid
  end

  it "must have a fixed repayment amount when repayment profile is
      fixed amount" do
    record.
      repayment_profile = PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE
    record.fixed_repayment_amount = nil
    expect(record).not_to be_valid
  end
end
