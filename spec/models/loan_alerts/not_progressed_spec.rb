require "rails_helper"

describe LoanAlerts::NotProgressed do
  it "groups medium priority alerts correctly" do
    start_date = 6.months.ago
    lender = FactoryGirl.create(:lender)

    approaching_high_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 10.weekdays_from(start_date))

    newly_medium_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 29.weekdays_from(start_date))

    mid_range_medium_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 19.weekdays_from(start_date))

    _excluded_low_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 30.weekdays_from(start_date))

    _excluded_high_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 9.weekdays_from(start_date))

    expected_ids = [approaching_high_priority_loan,
                    mid_range_medium_priority_loan,
                    newly_medium_priority_loan].map(&:id)

    alert = described_class.new(lender)
    group = alert.group(:medium)

    expect(group.map(&:id)).to eq(expected_ids)
  end

  it "groups low priority alerts correctly" do
    start_date = 6.months.ago
    lender = FactoryGirl.create(:lender)

    approaching_medium_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 31.weekdays_from(start_date))

    newly_low_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 59.weekdays_from(start_date))

    mid_range_low_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 42.weekdays_from(start_date))

    _excluded_medium_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 29.weekdays_from(start_date))

    _excluded_out_of_bounds_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 61.weekdays_from(start_date))

    expected_ids = [approaching_medium_priority_loan,
                    mid_range_low_priority_loan,
                    newly_low_priority_loan].map(&:id)

    alert = described_class.new(lender)
    group = alert.group(:low)

    expect(group.map(&:id)).to eq(expected_ids)
  end

  it "groups high priority alerts correctly" do
    start_date = 6.months.ago
    lender = FactoryGirl.create(:lender)

    approaching_deadline_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 1.weekdays_from(start_date))

    newly_high_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 9.weekdays_from(start_date))

    mid_range_high_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 5.weekdays_from(start_date))

    _excluded_medium_priority_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: 29.weekdays_from(start_date))

    _excluded_past_deadline_loan = FactoryGirl.create(
      :loan, :eligible,
      lender: lender,
      updated_at: start_date - 1.day)

    expected_ids = [approaching_deadline_loan,
                    mid_range_high_priority_loan,
                    newly_high_priority_loan].map(&:id)

    alert = described_class.new(lender)
    group = alert.group(:high)

    expect(group.map(&:id)).to eq(expected_ids)
  end
end
