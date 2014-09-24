require 'rails_helper'

describe 'Lump sum repayment loan change' do
  include LoanChangeSpecHelper

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, amount: Money.new(100_000_00), maturity_date: Date.new(2014, 12, 25), repayment_duration: 60, repayment_frequency_id: RepaymentFrequency::Quarterly.id) }

  before do
    loan.initial_draw_change.update_column(:date_of_change, Date.new(2009, 12, 25))

    visit loan_path(loan)
    click_link 'Change Amount or Terms'
    click_link 'Lump Sum Repayment'
  end

  it do
    fill_in :date_of_change, '1/12/11'
    fill_in :lump_sum_repayment, '1234.56'
    fill_in :initial_draw_amount, '65,432.10'

    Timecop.freeze(2011, 12, 1) do
      click_button 'Submit'
    end

    loan_change = loan.loan_changes.last!
    expect(loan_change.change_type).to eq(ChangeType::LumpSumRepayment)
    expect(loan_change.date_of_change).to eq(Date.new(2011, 12, 1))
    expect(loan_change.lump_sum_repayment).to eq(Money.new(1_234_56))

    premium_schedule = loan.premium_schedules.last!
    expect(premium_schedule.initial_draw_amount).to eq(Money.new(65_432_10))
    expect(premium_schedule.premium_cheque_month).to eq('03/2012')
    expect(premium_schedule.repayment_duration).to eq(33)

    loan.reload
    expect(loan.maturity_date).to eq(Date.new(2014, 12, 25))
    expect(loan.modified_by).to eq(current_user)
  end
end
