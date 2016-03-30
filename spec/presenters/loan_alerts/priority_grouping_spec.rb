require "rails_helper"

describe LoanAlerts::PriorityGrouping do
  describe "for Not Drawn alert" do
    let(:start_date) { alert.start_date }

    let!(:lender) { FactoryGirl.create(:lender) }

    let!(:overdue_priority_loan) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: start_date)
    end

    let!(:high_priority_loan) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: 10.weekdays_from(start_date))
    end

    let!(:medium_priority_loan1) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: 21.weekdays_from(start_date))
    end

    let!(:medium_priority_loan2) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: 39.weekdays_from(start_date))
    end

    let!(:low_priority_loan1) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: 40.weekdays_from(start_date))
    end

    let!(:low_priority_loan2) do
      FactoryGirl.create(
        :loan,
        :offered,
        lender: lender,
        facility_letter_date: 59.weekdays_from(start_date))
    end

    let(:alert) do
      LoanAlerts::NotDrawn.new(lender)
    end

    let(:priority_grouping) do
      LoanAlerts::PriorityGrouping.new(alert)
    end

    describe "#alerts_grouped_by_priority" do
      it "returns groups in the expected order" do
        group_names = priority_grouping.alerts_grouped_by_priority.
          map(&:priority)

        expect(group_names).to eq([:overdue, :high, :medium, :low])
      end

      it "includes the correct loans in the first group" do
        first_group = priority_grouping.alerts_grouped_by_priority.first
        expect(first_group.total_loans).to eq(1)
      end

      it "includes the correct loans in the second group" do
        second_group = priority_grouping.alerts_grouped_by_priority.second
        expect(second_group.total_loans).to eq(1)
      end

      it "includes the correct loans in the third group" do
        third_group = priority_grouping.alerts_grouped_by_priority.third
        expect(third_group.total_loans).to eq(2)
      end

      it "includes the correct loans in the fourth group" do
        fourth_group = priority_grouping.alerts_grouped_by_priority.fourth
        expect(fourth_group.total_loans).to eq(2)
      end
    end

    context "for not demanded alert" do
      it "returns groups in the expected order" do
        alert = LoanAlerts::NotDemanded.new(lender)
        priority_grouping = LoanAlerts::PriorityGrouping.new(alert)
        group_names = priority_grouping.alerts_grouped_by_priority.
          map(&:priority)

        expect(group_names).to eq([:high, :medium, :low])
      end
    end
  end
end
