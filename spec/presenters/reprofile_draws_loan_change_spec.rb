require 'rails_helper'

describe ReprofileDrawsLoanChange do
  it_behaves_like 'LoanChangePresenter'

  describe '#initialize' do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }
    let(:presenter) { FactoryGirl.build(:reprofile_draws_loan_change, loan: loan) }

    context 'when the full amount has been drawn' do
      before do
        loan.initial_draw_change.update_column(:amount_drawn, loan.amount.cents)
      end

      it 'is not allowed' do
        expect {
          presenter
        }.to raise_error(ReprofileDrawsLoanChange::LoanAlreadyFullyDrawnError)
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, :with_premium_schedule, repayment_duration: 60) }
    let(:presenter) { FactoryGirl.build(:reprofile_draws_loan_change, created_by: user, loan: loan) }

    before do
      loan.initial_draw_change.update_column :date_of_change, Date.new(2010, 1)
    end

    it 'creates a LoanChange, a PremiumSchedule, and updates the loan' do
      Timecop.freeze(2013, 3, 1) do
        expect(presenter.save).to eq(true)
      end

      loan_change = loan.loan_changes.last!
      expect(loan_change.change_type).to eq(ChangeType::ReprofileDraws)
      expect(loan_change.created_by).to eq(user)

      loan.reload
      expect(loan.modified_by).to eq(user)

      premium_schedule = loan.premium_schedules.last!
      expect(premium_schedule.premium_cheque_month).to eq('04/2013')
      expect(premium_schedule.repayment_duration).to eq(21)
    end
  end
end
