require 'rails_helper'

describe LumpSumRepaymentLoanChange do
  it_behaves_like 'LoanChangePresenter' do
    let(:presenter_factory_options) {
      { initial_draw_amount: Money.new(1_000_00) }
    }
  end

  describe 'validations' do
    describe '#lump_sum_repayment' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, :with_premium_schedule, amount: Money.new(15_000_00)) }
      let(:presenter) { FactoryGirl.build(:lump_sum_repayment_loan_change, loan: loan) }

      it 'is required' do
        presenter.lump_sum_repayment = nil
        expect(presenter).not_to be_valid
      end

      it 'must be greater than zero' do
        presenter.lump_sum_repayment = Money.new(0)
        expect(presenter).not_to be_valid
      end

      it 'must not be greater than the cumulative_drawn_amount (including previous repayments)' do
        allow(loan).to receive(:cumulative_drawn_amount).and_return(Money.new(6_000_00))
        allow(loan).to receive(:cumulative_lump_sum_amount).and_return(Money.new(1_000_00))

        presenter.lump_sum_repayment = Money.new(5_000_01)
        presenter.initial_draw_amount = Money.new(0)
        expect(presenter).not_to be_valid

        presenter.lump_sum_repayment = Money.new(4_000_00)
        presenter.initial_draw_amount = Money.new(500_00)
        expect(presenter).to be_valid
      end
    end

    describe "#initial_draw_amount" do
      it "cannot exceed the amount remaining on the loan, after all lump sum repayments" do
        loan = FactoryGirl.create(
          :loan,
          :guaranteed,
          :with_premium_schedule,
          amount: Money.new(15_000_00)
        )
        presenter = FactoryGirl.build(
          :lump_sum_repayment_loan_change,
          loan: loan
        )

        allow(loan).to receive(:cumulative_drawn_amount).
          and_return(Money.new(9_000_00))

        allow(loan).to receive(:cumulative_lump_sum_amount).
          and_return(Money.new(1_000_00))

        presenter.lump_sum_repayment = Money.new(5_000_00)

        presenter.initial_draw_amount = Money.new(4000_00)
        expect(presenter).not_to be_valid

        presenter.initial_draw_amount = Money.new(3000_00)
        expect(presenter).to be_valid
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, :with_premium_schedule, repayment_duration: 60) }
    let(:presenter) {
      FactoryGirl.build(
        :lump_sum_repayment_loan_change,
        date_of_change: Date.new(2013, 3, 1),
        created_by: user,
        loan: loan) }

    context 'success' do
      before do
        loan.initial_draw_change.update_column :date_of_change, Date.new(2013, 2)
        loan.premium_schedule.update_column(:legacy_premium_calculation, true)

        presenter.initial_draw_amount = Money.new(500_00)
      end

      it 'creates a LoanChange, a PremiumSchedule, and updates the loan' do
        Timecop.freeze(2013, 3, 1) do
          expect(presenter.save).to eq(true)
        end

        loan_change = loan.loan_changes.last!
        expect(loan_change.change_type).to eq(ChangeType::LumpSumRepayment)
        expect(loan_change.lump_sum_repayment).to eq(Money.new(1_000_00))
        expect(loan_change.created_by).to eq(user)

        loan.reload
        expect(loan.modified_by).to eq(user)
        expect(loan.cumulative_lump_sum_amount).to eq(Money.new(1_000_00))

        premium_schedule = loan.premium_schedules.last!
        expect(premium_schedule.premium_cheque_month).to eq('05/2013')
        expect(premium_schedule.repayment_duration).to eq(57)
      end

      it "updates the legacy premium schedule calculation to false" do
        current_premium_schedule = loan.reload.premium_schedules.last
        expect(current_premium_schedule.legacy_premium_calculation).to eq(true)

        Timecop.freeze(2013, 3, 1) do
          presenter.save
        end

        new_premium_schedule = loan.reload.premium_schedule
        expect(new_premium_schedule.legacy_premium_calculation).to eq(false)
      end
    end

    context 'failure' do
      it 'does not update loan' do
        presenter.lump_sum_repayment = nil
        expect(presenter.save).to eq(false)

        loan.reload
        expect(loan.modified_by).not_to eq(user)
      end
    end
  end
end
