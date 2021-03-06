require 'rails_helper'

describe 'Lump sum repayment loan change' do
  include LoanChangeSpecHelper

  before do
    loan.initial_draw_change.update_column(:date_of_change, Date.new(2009, 12, 25))

    premium_schedule = loan.premium_schedule
    premium_schedule.initial_draw_year = 2010
    premium_schedule.second_draw_amount = Money.new(5_000_00)
    premium_schedule.second_draw_months = 3
    premium_schedule.third_draw_amount = Money.new(4_000_00)
    premium_schedule.third_draw_months = 6
    premium_schedule.fourth_draw_amount = Money.new(2_000_00)
    premium_schedule.fourth_draw_months = 9
    premium_schedule.repayment_profile =
      PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE
    premium_schedule.fixed_repayment_amount = Money.new(1_000_00)
    premium_schedule.save
  end

  it do
    open_lump_sum_repayment_form

    expect(page).to have_content("£5,000.00 in month 3")
    expect(page).to have_content("£4,000.00 in month 6")
    expect(page).to have_content("£2,000.00 in month 9")

    submit_loan_change_form

    loan.reload

    loan_change = loan.loan_changes.last!
    expect(loan_change.change_type).to eq(ChangeType::LumpSumRepayment)
    expect(loan_change.date_of_change).to eq(Date.new(2011, 12, 1))
    expect(loan_change.lump_sum_repayment).to eq(Money.new(1_234_56))

    premium_schedule = loan.premium_schedules.last!
    expect(premium_schedule.premium_cheque_month).to eq('03/2012')
    expect(premium_schedule.repayment_duration).to eq(33)

    expect(premium_schedule.calc_type).to eq(PremiumSchedule::RESCHEDULE_TYPE)
    expect(premium_schedule.repayment_profile).
      to eq(PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE)
    expect(premium_schedule.fixed_repayment_amount).to eq(Money.new(1_000_00))
    expect(premium_schedule.initial_draw_year).to eq(2010)
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

  def open_lump_sum_repayment_form
    visit loan_path(loan)
    click_link 'Change Amount or Terms'
    click_link 'Lump Sum Repayment'
  end

  def submit_loan_change_form
    fill_in :date_of_change, '1/12/11'
    fill_in :lump_sum_repayment, '1234.56'
    fill_in :initial_draw_amount, '6,432.10'

    Timecop.freeze(2011, 12, 1) do
      click_button 'Submit'
    end
  end
end
