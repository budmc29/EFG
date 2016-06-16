require 'rails_helper'

describe 'Lump sum repayment loan change' do
  include LoanChangeSpecHelper

  before do
    loan.initial_draw_change.update_column(:date_of_change, Date.new(2009, 12, 25))

    premium_schedule = loan.premium_schedule
    premium_schedule.second_draw_amount = Money.new(5_000_00)
    premium_schedule.second_draw_months = 3
    premium_schedule.second_draw_amount = Money.new(4_000_00)
    premium_schedule.second_draw_months = 6
    premium_schedule.second_draw_amount = Money.new(2_000_00)
    premium_schedule.second_draw_months = 9
  end

  it do
    dispatch

    loan.reload

    loan_change = loan.loan_changes.last!
    expect(loan_change.change_type).to eq(ChangeType::LumpSumRepayment)
    expect(loan_change.date_of_change).to eq(Date.new(2011, 12, 1))
    expect(loan_change.lump_sum_repayment).to eq(Money.new(1_234_56))

    premium_schedule = loan.premium_schedules.last!
    expect(premium_schedule.premium_cheque_month).to eq('03/2012')
    expect(premium_schedule.repayment_duration).to eq(33)

    expect(premium_schedule.initial_draw_amount).to eq(Money.new(6_432_10))
    expect(premium_schedule.second_draw_amount).to be_nil
    expect(premium_schedule.second_draw_months).to be_nil
    expect(premium_schedule.third_draw_amount).to be_nil
    expect(premium_schedule.third_draw_months).to be_nil
    expect(premium_schedule.fourth_draw_amount).to be_nil
    expect(premium_schedule.fourth_draw_months).to be_nil

    expect(loan.maturity_date).to eq(Date.new(2014, 12, 25))
    expect(loan.modified_by).to eq(current_user)
  end

  private

  def dispatch
    visit loan_path(loan)
    click_link 'Change Amount or Terms'
    click_link 'Lump Sum Repayment'

    fill_in :date_of_change, '1/12/11'
    fill_in :lump_sum_repayment, '1234.56'
    fill_in :initial_draw_amount, '6,432.10'

    Timecop.freeze(2011, 12, 1) do
      click_button 'Submit'
    end
  end
end
