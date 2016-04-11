require "rails_helper"

describe Phase6ClaimLimitCalculator do
  let(:lending_limit1) do
    FactoryGirl.create(:lending_limit, :phase_6, lender: lender)
  end

  let(:lending_limit2) do
    FactoryGirl.create(:lending_limit, :phase_6, lender: lender)
  end

  it_behaves_like "phase 6 claim limit calculator"

  describe "#total_amount" do
    it "does not include loans with excluded
        status amendments (Ineligible, Administrative)" do
      lender = FactoryGirl.create(:lender)

      lending_limit = FactoryGirl.create(
        :lending_limit,
        :phase_6,
        lender: lender,
      )

      _included_loan1 = FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        lending_limit: lending_limit,
        amount: Money.new(50_000_00),
        status_amendment_type: LoanStatusAmendment::LIABILITY,
      )

      _included_loan2 = FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        lending_limit: lending_limit,
        amount: Money.new(50_000_00),
        status_amendment_type: LoanStatusAmendment::OTHER,
      )

      _excluded_loan1 = FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        lending_limit: lending_limit,
        amount: Money.new(20_000_00),
        status_amendment_type: LoanStatusAmendment::ELIGIBILITY,
      )

      _excluded_loan2 = FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        lending_limit: lending_limit,
        amount: Money.new(20_000_00),
        status_amendment_type: LoanStatusAmendment::ADMINISTRATIVE,
      )

      [
        _included_loan1,
        _included_loan2,
        _excluded_loan1,
        _excluded_loan2,
      ].each do |loan|
        loan.initial_draw_change.update_attribute(:amount_drawn, loan.amount)
      end

      claim_limit = described_class.new(lender)

      # 75% of first eligible £100,000
      # £40,000 from excluded loans is not included in calculation
      expect(claim_limit.total_amount).to eq(Money.new(75_000_00))
    end
  end
end
