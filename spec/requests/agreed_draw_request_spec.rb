require 'spec_helper'

describe 'agreed draw' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, amount: Money.new(100_000_00), maturity_date: Date.new(2014, 12, 25), repayment_duration: 60) }

  context 'where loan is fully drawn' do
    before do
      FactoryGirl.create(:premium_schedule, :with_drawdowns, loan: loan)
      FactoryGirl.create(:loan_change, loan: loan, amount_drawn: Money.new(90_000_00), change_type: ChangeType::RecordAgreedDraw)
      expect(loan.amount_not_yet_drawn).to eq(0)
      visit loan_path(loan)
    end

    it 'does not include the reprofile draws option' do
      visit loan_path(loan)
      expect(page).not_to have_link('Record Agreed Draw')
    end
  end

  context 'where loan is NOT fully drawn' do
    before do
      expect(loan.amount_not_yet_drawn).to be > 0
      visit loan_path(loan)
      click_link 'Record Agreed Draw'
    end

    it do
      fill_in :date_of_change, '1/12/11'
      fill_in :amount_drawn, '12,345.67'
      click_button 'Submit'

      loan_change = loan.loan_changes.last!
      expect(loan_change.change_type).to eq(ChangeType::RecordAgreedDraw)
      expect(loan_change.date_of_change).to eq(Date.new(2011, 12, 1))
      expect(loan_change.amount_drawn).to eq(Money.new(12_345_67))

      loan.reload
      expect(loan.modified_by).to eq(current_user)
    end

    it 'does not continue with invalid values' do
      expect {
        click_button 'Submit'
      }.to change(LoanChange, :count).by(0)
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "agreed_draw_#{attribute}", with: value
    end
end
