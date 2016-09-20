require "rails_helper"

describe RepaymentProfileLoanChange do
  describe "validations" do
    let(:presenter) { build(:repayment_profile_loan_change) }

    it "validates repayment profile" do
      expect(presenter).to validate_with(RepaymentProfileValidator)
    end

    it "must have remaining loan term when repaying to zero" do
      presenter.remaining_loan_term = nil
      expect(presenter).not_to be_valid
    end

    it "must change the repayment profile when fixed term (otherwise nothing
        will change by keeping that same profile)" do
      presenter.
        repayment_profile = PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE
      expect(presenter).not_to be_valid
    end

    it "when switching to fixed amount repayment profile, it does not allow
        the new loan term to exceed the loan's maximum term,
        including any months in the loan term that have already passed
        up to the next premium collection month" do
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(350_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
        repayment_duration: 120, # 10 years
        maturity_date: 10.years.from_now,
      )

      loan_initial_draw = loan.initial_draw_change
      # next premium cheque month is the 75 month of the term
      # leaving max allowed new term at 45 months
      loan_initial_draw.date_of_change = 73.months.ago
      loan_initial_draw.save!

      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        initial_draw_amount: Money.new(46_000_00),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        fixed_repayment_amount: Money.new(1_000_00), # 46 monthly repayments
        loan: loan,
      )

      expect(presenter).not_to be_valid
    end

    it "when switching to fixed term repayment profile, it does not allow
        the new loan term to exceed the loan's maximum term,
        including any months in the loan term that have already passed
        up to the next premium collection month" do
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(350_000_00),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        repayment_duration: 120, # 10 years
        maturity_date: 10.years.from_now,
      )

      loan_initial_draw = loan.initial_draw_change
      # next premium cheque month is the 75 month of the term
      # leaving max allowed new term at 45 months
      loan_initial_draw.date_of_change = 73.months.ago
      loan_initial_draw.save!

      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        initial_draw_amount: Money.new(46_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
        remaining_loan_term: { years: 3, months: 10 }, # 46 monthly repayments
        loan: loan,
      )

      expect(presenter).not_to be_valid
    end
  end

  describe "#save" do
    it "creates new loan change when changing from fixed term
        to fixed amount" do
      user = create(:lender_user)
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(40_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
      )

      loan_initial_draw = loan.initial_draw_change
      loan_initial_draw.date_of_change = 7.months.ago
      loan_initial_draw.save!

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
      # months so far at next premium cheque month + new remaining term
      expect(loan_change.repayment_duration).to eq(39)
    end

    it "creates new loan change when changing from fixed amount
        to fixed term" do
      user = create(:lender_user)
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(40_000_00),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        fixed_repayment_amount: Money.new(1_000_00),
      )

      loan_initial_draw = loan.initial_draw_change
      loan_initial_draw.date_of_change = 11.months.ago
      loan_initial_draw.save!

      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        initial_draw_amount: Money.new(30_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
        remaining_loan_term: { years: 2, months: 5 },
        created_by: user,
        loan: loan,
      )

      presenter.save

      loan_change = LoanChange.last
      expect(loan_change.date_of_change).to eq(Date.new(2013, 3, 1))
      expect(loan_change.repayment_profile).
        to eq(PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE)
      expect(loan_change.old_repayment_profile).
        to eq(PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE)
      expect(loan_change.fixed_repayment_amount).to eq(nil)
      expect(loan_change.old_fixed_repayment_amount).to eq(Money.new(1_000_00))
      # term months so far from next premium cheque date (12 months) +
      # specified remaining term (29 months)
      expect(loan_change.repayment_duration).to eq(41)
    end

    it "updates the loan" do
      user = create(:lender_user)
      loan = create(
        :loan,
        :guaranteed,
        :with_premium_schedule,
        amount: Money.new(40_000_00),
        repayment_profile: PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE,
      )

      loan_initial_draw = loan.initial_draw_change
      loan_initial_draw.date_of_change = 11.months.ago
      loan_initial_draw.save!

      presenter = build(
        :repayment_profile_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        repayment_profile: PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE,
        initial_draw_amount: Money.new(20_000_00),
        fixed_repayment_amount: Money.new(1_000_00), # 20 monthly repayments
        created_by: user,
        loan: loan,
      )

      presenter.save

      loan.reload
      expect(loan.repayment_profile).
        to eq(PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE)
      expect(loan.fixed_repayment_amount).to eq(Money.new(1_000_00))
      # term months so far from next premium cheque date (12 months) +
      # remaining term (20 months)
      expect(loan.repayment_duration.total_months).to eq(32)
    end
  end
end
