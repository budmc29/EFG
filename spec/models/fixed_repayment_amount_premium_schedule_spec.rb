require "rails_helper"

describe "Fixed Repayment Amount Premium Schedule" do
  it "generates correct schedule when there are no remaining months" do
    premium_schedule = FactoryGirl.build(
      :premium_schedule,
      repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
      fixed_repayment_amount: Money.new(1_200_00),
      initial_draw_amount: Money.new(12_000_00),
      repayment_duration: 12,
      legacy_premium_calculation: false,
    )

    expected_premiums = [
      Money.new(60_00),
      Money.new(42_00),
      Money.new(24_00),
      Money.new(6_00),
    ]

    expect(premium_schedule.premiums).to eq(expected_premiums)
  end

  it "generates correct schedule when there are remaining months" do
    premium_schedule = FactoryGirl.build(
      :premium_schedule,
      repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
      fixed_repayment_amount: Money.new(1_666_66),
      initial_draw_amount: Money.new(100_000_00),
      repayment_duration: 60,
      legacy_premium_calculation: false,
    )

    expected_premiums = [
      Money.new(500_00),
      Money.new(475_00),
      Money.new(450_00),
      Money.new(425_00),
      Money.new(400_00),
      Money.new(375_00),
      Money.new(350_00),
      Money.new(325_00),
      Money.new(300_00),
      Money.new(275_00),
      Money.new(250_00),
      Money.new(225_00),
      Money.new(200_00),
      Money.new(175_00),
      Money.new(150_00),
      Money.new(125_00),
      Money.new(100_00),
      Money.new(75_00),
      Money.new(50_00),
      Money.new(25_00),
    ]

    expect(premium_schedule.premiums).to eq(expected_premiums)
  end

  it "generates correct schedule when repayment frequency is six monthly" do
    premium_schedule = FactoryGirl.build(
      :premium_schedule,
      repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
      fixed_repayment_amount: Money.new(1_666_66),
      initial_draw_amount: Money.new(100_000_00),
      repayment_duration: 60,
      legacy_premium_calculation: false,
    )
    loan = premium_schedule.loan
    loan.repayment_frequency = RepaymentFrequency::SixMonthly

    expected_premiums = [
      Money.new(500_00),
      Money.new(500_00),
      Money.new(450_00),
      Money.new(450_00),
      Money.new(400_00),
      Money.new(400_00),
      Money.new(350_00),
      Money.new(350_00),
      Money.new(300_00),
      Money.new(300_00),
      Money.new(250_00),
      Money.new(250_00),
      Money.new(200_00),
      Money.new(200_00),
      Money.new(150_00),
      Money.new(150_00),
      Money.new(100_00),
      Money.new(100_00),
      Money.new(50_00),
      Money.new(50_00),
    ]

    expect(premium_schedule.premiums).to eq(expected_premiums)
  end
end
