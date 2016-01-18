# encoding: utf-8

require 'spec_helper'

describe 'loan change' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, amount: Money.new(100_000_00), maturity_date: Date.new(2014, 12, 25), repayment_duration: 60, repayment_frequency_id: RepaymentFrequency::Quarterly.id) }

  before do
    loan.initial_draw_change.update_column(:date_of_change, Date.new(2009, 12, 25))
  end

  context 'lump_sum_repayment' do
    before do
      visit_loan_changes
      click_link 'Lump Sum Repayment'
    end

    it 'works' do
      fill_in :date_of_change, '1/12/11'
      fill_in :lump_sum_repayment, '1234.56'
      fill_in :initial_draw_amount, '65,432.10'

      Timecop.freeze(2011, 12, 1) do
        click_button 'Submit'
      end

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::LumpSumRepayment
      loan_change.date_of_change.should == Date.new(2011, 12, 1)
      loan_change.lump_sum_repayment.should == Money.new(1_234_56)

      premium_schedule = loan.premium_schedules.last!
      premium_schedule.initial_draw_amount.should == Money.new(65_432_10)
      premium_schedule.premium_cheque_month.should == '03/2012'
      premium_schedule.repayment_duration.should == 33

      loan.reload
      loan.maturity_date.should == Date.new(2014, 12, 25)
      loan.modified_by.should == current_user
    end
  end

  context 'repayment_duration' do
    def dispatch
      visit_loan_changes
      click_link 'Extend or Reduce Loan Term'
      fill_in :date_of_change, '11/9/10'
      fill_in :added_months, '3'
      fill_in :initial_draw_amount, '65,432.10'
    end

    context 'phase 5' do
      it 'works' do
        dispatch

        Timecop.freeze(2010, 9, 1) do
          click_button 'Submit'
        end

        loan_change = loan.loan_changes.last!
        loan_change.change_type.should == ChangeType::ExtendTerm
        loan_change.date_of_change.should == Date.new(2010, 9, 11)
        loan_change.old_repayment_duration.should == 60
        loan_change.repayment_duration.should == 63

        premium_schedule = loan.premium_schedules.last!
        premium_schedule.initial_draw_amount.should == Money.new(65_432_10)
        premium_schedule.premium_cheque_month.should == '12/2010'
        premium_schedule.repayment_duration.should == 51

        loan.reload
        loan.modified_by.should == current_user
        loan.repayment_duration.total_months.should == 63
        loan.maturity_date.should == Date.new(2015, 3, 25)
      end
    end

    context 'phase 6' do
      before do
        loan.lending_limit.update_attribute(:phase_id, 6)
      end

      context 'when loan amount is invalid' do
        before do
          loan.update_attribute(:amount, Money.new(750_000_00))
        end

        it 'displays error message explaining why loan amount is invalid' do
          dispatch

          Timecop.freeze(2010, 9, 1) do
            click_button 'Submit'
          end

          page.should have_content(I18n.t('validators.phase6_amount.amount.invalid'))
        end
      end

      context 'when new loan repayment duration is invalid' do
        before do
          loan.update_attribute(:loan_category_id, LoanCategory::TypeE.id)
        end

        it 'displays error message explaining why loan term cannot be extended' do
          dispatch

          Timecop.freeze(2010, 9, 1) do
            click_button 'Submit'
          end

          page.should have_content(I18n.t('validators.repayment_duration.repayment_duration.invalid'))
        end
      end
    end
  end

  context 'repayment_frequency' do
    around do |example|
      Timecop.freeze(2010, 9, 1) do
        example.run
      end
    end

    it 'works' do
      visit_loan_changes
      click_link 'Repayment Frequency'

      fill_in :date_of_change, '11/9/10'
      fill_in :initial_draw_amount, '65,432.10'

      select :repayment_frequency_id, RepaymentFrequency::Monthly.name

      click_button 'Submit'

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::RepaymentFrequency
      loan_change.date_of_change.should == Date.new(2010, 9, 11)
      loan_change.repayment_frequency_id.should == RepaymentFrequency::Monthly.id
      loan_change.old_repayment_frequency_id.should == RepaymentFrequency::Quarterly.id

      premium_schedule = loan.premium_schedules.last!
      premium_schedule.initial_draw_amount.should == Money.new(65_432_10)
      premium_schedule.premium_cheque_month.should == '12/2010'
      premium_schedule.repayment_duration.should == 48

      loan.reload
      loan.modified_by.should == current_user
      loan.repayment_frequency_id.should == RepaymentFrequency::Monthly.id

      click_link 'Loan Changes'
      click_link 'Repayment frequency'

      page.should have_content('Monthly')
      page.should have_content('Quarterly')
    end
  end

  context 'reprofile_draws' do
    before do
      visit_loan_changes
      click_link 'Reprofile Draws'
    end

    it 'works' do
      fill_in :date_of_change, '11/9/10'
      fill_in :initial_draw_amount, '65,432.10'
      fill_in :initial_capital_repayment_holiday, '3'
      fill_in :second_draw_amount, '5,000.00'
      fill_in :second_draw_months, '6'
      fill_in :third_draw_amount, '5,000.00'
      fill_in :third_draw_months, '12'
      fill_in :fourth_draw_amount, '5,000.00'
      fill_in :fourth_draw_months, '18'

      Timecop.freeze(2010, 9, 1) do
        click_button 'Submit'
      end

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::ReprofileDraws
      loan_change.date_of_change.should == Date.new(2010, 9, 11)

      premium_schedule = loan.premium_schedules.last!
      premium_schedule.initial_draw_amount.should == Money.new(65_432_10)
      premium_schedule.premium_cheque_month.should == '12/2010'
      premium_schedule.repayment_duration.should == 48
      premium_schedule.initial_capital_repayment_holiday.should == 3
      premium_schedule.second_draw_amount.should == Money.new(5_000_00)
      premium_schedule.second_draw_months.should == 6
      premium_schedule.third_draw_amount.should == Money.new(5_000_00)
      premium_schedule.third_draw_months.should == 12
      premium_schedule.fourth_draw_amount.should == Money.new(5_000_00)
      premium_schedule.fourth_draw_months.should == 18

      loan.reload
      loan.modified_by.should == current_user
      loan.repayment_duration.total_months.should == 60
      loan.maturity_date.should == Date.new(2014, 12, 25)
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "loan_change_#{attribute}", with: value
    end

    def visit_loan_changes
      visit loan_path(loan)
      click_link 'Change Amount or Terms'
    end

    def select(attribute, value)
      page.select value, from: "loan_change_#{attribute}"
    end
end
