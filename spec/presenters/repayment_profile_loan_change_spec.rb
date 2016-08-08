require "rails_helper"

describe RepaymentProfileLoanChange do
  describe "validations" do
    let(:presenter) { build(:repayment_profile_loan_change) }

    it "validates repayment profile" do
      expect(presenter).to validate_with(RepaymentProfileValidator)
    end

    it "must change the repayment profile when fixed term (otherwise nothing
        will change by keeping that same profile)" do
      presenter.
        repayment_profile = PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE
      expect(presenter).not_to be_valid
    end
  end

  describe "#save" do
    it "creates new loan change" do
      user = create(:lender_user)
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(40_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
      )
      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        initial_draw_amount: Money.new(30_000_00),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        fixed_repayment_amount: Money.new(1_000_00),
        created_by: user,
        loan: loan,
      )

      presenter.save

      loan_change = LoanChange.last
      expect(loan_change.date_of_change).to eq(Date.new(2013, 3, 1))
      expect(loan_change.repayment_profile).
        to eq(PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE)
      expect(loan_change.old_repayment_profile).
        to eq(PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE)
      expect(loan_change.fixed_repayment_amount).to eq(Money.new(1_000_00))
      expect(loan_change.old_fixed_repayment_amount).to eq(nil)
      expect(loan_change.repayment_duration).to eq(30)
    end

    it "updates the loan" do
      user = create(:lender_user)
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
      )
      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        fixed_repayment_amount: Money.new(1_000_00),
        created_by: user,
        loan: loan,
      )

      presenter.save

      loan.reload
      expect(loan.repayment_profile).
        to eq(PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE)
      expect(loan.fixed_repayment_amount).to eq(Money.new(1_000_00))
    end
  end
end
