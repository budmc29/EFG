require 'rails_helper'

describe 'loan recovery' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  context 'EFG' do
    let(:loan) {
      FactoryGirl.create(:loan, :settled,
        dti_demand_outstanding: Money.new(100_000_00),
        dti_amount_claimed: Money.new(0),
        dti_interest: nil,
        settled_on: '1/5/12'
      )
    }

    [Loan::Settled, Loan::Recovered, Loan::Realised].each do |state|
      context "with state #{state}" do
        before do
          loan.update_attribute :state, state
        end

        it 'creates a loan recovery' do
          visit loan_path(loan)
          click_link 'Recovery Made'

          expect(page).to have_content("£100,000.00")
          expect(page).not_to have_button('Submit')

          expect {
            fill_in_valid_efg_recovery_details
            click_button 'Calculate'

            expect(page).to have_content("£58,333.33")
            expect(page).to have_content("£6,250.00")
          }.not_to change(Recovery, :count)

          expect {
            click_button 'Submit'
          }.to change(Recovery, :count).by(1)

          verify_recovery_and_loan

          expect(current_path).to eq(loan_path(loan))
        end
      end
    end

    context 'with invalid values' do
      it 'does not continue' do
        visit loan_path(loan)
        click_link 'Recovery Made'

        expect {
          fill_in_valid_efg_recovery_details
          click_button 'Calculate'
        }.not_to change(Recovery, :count)

        expect {
          # clear recovery values
          fill_in 'recovery_recovered_on', with: ''
          fill_in "recovery_outstanding_prior_non_efg_debt", with: ""
          fill_in "recovery_outstanding_subsequent_non_efg_debt", with: ""
          fill_in 'recovery_non_linked_security_proceeds', with: ''
          fill_in 'recovery_linked_security_proceeds', with: ''
          click_button 'Submit'
        }.not_to change(Recovery, :count)

        expect(current_path).to eq(loan_recoveries_path(loan))
      end
    end
  end

  context 'SFLG' do
    let(:loan) {
      FactoryGirl.create(:loan, :sflg, :settled,
        dti_amount_claimed: Money.new(75_000_68),
        dti_interest: Money.new(10_000_34),
        dti_demand_outstanding: Money.new(90_000_57),
        settled_on: '1/5/12'
      )
    }

    before do
      FactoryGirl.create(:recovery, loan: loan, amount_due_to_dti: Money.new(66_61))
      FactoryGirl.create(:recovery, loan: loan, amount_due_to_dti: Money.new(19_55))
    end

    it 'creates a loan recovery' do
      visit loan_path(loan)
      click_link 'Recovery Made'

      expect(page).to have_content('£100,000.91')
      expect(page).to have_content('£86.16')
      expect(page).not_to have_button('Submit')

      fill_in_valid_sflg_recovery_details

      expect {
        click_button 'Calculate'
      }.not_to change(Recovery, :count)

      expect(page).to have_content('£175.28')
      expect(page).to have_content('£976.28')

      expect {
        click_button 'Submit'
      }.to change(Recovery, :count).by(1)

      recovery = Recovery.last
      expect(recovery.loan).to eq(loan)
      expect(recovery.seq).to eq(2)
      expect(recovery.recovered_on).to eq(Date.current)
      expect(recovery.total_proceeds_recovered).to eq(Money.new(100_000_91))
      expect(recovery.total_liabilities_behind).to eq(Money.new(123_00))
      expect(recovery.total_liabilities_after_demand).to eq(Money.new(234_00))
      expect(recovery.additional_interest_accrued).to eq(Money.new(345_00))
      expect(recovery.additional_break_costs).to eq(Money.new(456_00))
      expect(recovery.amount_due_to_dti).to eq(Money.new(976_28))

      loan.reload
      expect(loan.state).to eq(Loan::Recovered)
      expect(loan.recovery_on).to eq(Date.current)
      expect(loan.modified_by).to eq(current_user)

      expect(current_path).to eq(loan_path(loan))
    end
  end

  context 'Legacy SFLG' do
    let(:loan) {
      FactoryGirl.create(:loan, :legacy_sflg, :settled,
        dti_amount_claimed: Money.new(3_375_00),
        dti_demand_outstanding: Money.new(4_400_00),
        dti_interest: Money.new(100_00),
        settled_on: '1/5/12'
      )
    }

    it 'creates a loan recovery' do
      visit loan_path(loan)
      click_link 'Recovery Made'

      expect(page).to have_content('£2,531.25')
      expect(page).not_to have_button('Submit')

      fill_in 'recovery_recovered_on', with: '1/5/12'
      fill_in 'recovery_total_liabilities_behind', with: '£123'
      fill_in 'recovery_total_liabilities_after_demand', with: '£234'
      fill_in 'recovery_additional_interest_accrued', with: '£345'
      fill_in 'recovery_additional_break_costs', with: '£456'

      expect {
        click_button 'Calculate'
      }.not_to change(Recovery, :count)

      expect(page).to have_content('£170.83')
      expect(page).to have_content('£971.83')

      expect {
        click_button 'Submit'
      }.to change(Recovery, :count).by(1)

      recovery = Recovery.last
      expect(recovery.loan).to eq(loan)
      expect(recovery.seq).to eq(0)
      expect(recovery.recovered_on).to eq(Date.new(2012, 5, 1))
      expect(recovery.total_proceeds_recovered).to eq(Money.new(2_531_25))
      expect(recovery.total_liabilities_behind).to eq(Money.new(123_00))
      expect(recovery.total_liabilities_after_demand).to eq(Money.new(234_00))
      expect(recovery.additional_interest_accrued).to eq(Money.new(345_00))
      expect(recovery.additional_break_costs).to eq(Money.new(456_00))
      expect(recovery.amount_due_to_dti).to eq(Money.new(971_83))

      loan.reload
      expect(loan.state).to eq(Loan::Recovered)
      expect(loan.recovery_on).to eq(Date.new(2012, 5, 1))
      expect(loan.modified_by).to eq(current_user)

      expect(current_path).to eq(loan_path(loan))
    end
  end

  private

  def verify_recovery_and_loan
    recovery = Recovery.last
    expect(recovery.loan).to eq(loan)
    expect(recovery.seq).to eq(0)
    expect(recovery.recovered_on).to eq(Date.current)

    loan.reload
    expect(loan.state).to eq(Loan::Recovered)
    expect(loan.recovery_on).to eq(Date.current)
    expect(loan.modified_by).to eq(current_user)
  end
end
