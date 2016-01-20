require 'spec_helper'

describe 'Update loan lending limit' do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:lender) { current_user.lender }

  let!(:new_lending_limit) { FactoryGirl.create(:lending_limit, name: 'New Limit', lender: lender) }

  let(:sic_code) { FactoryGirl.create(:sic_code, state_aid_threshold: 15000) }

  let(:loan) { FactoryGirl.create(:loan, :completed, :with_premium_schedule, lender: lender, sic_code: sic_code.code) }

  before { login_as(current_user, scope: :user) }

  before do
    visit loan_path(loan)
    click_link 'Change Lending Limit'
    select 'New Limit', from: :update_loan_lending_limit_new_lending_limit_id
    click_button 'Submit'
  end

  it "renders confirmation page with SIC state aid threshold" do
    page.should have_content('Lending Limit Updated')
    page.should have_content('is now more than €15,000')

    loan.reload.lending_limit.should == new_lending_limit
  end

  context 'when loan is invalid for new lending limit' do
    let!(:new_lending_limit) { FactoryGirl.create(:lending_limit, :phase_6, name: 'New Limit', lender: lender) }

    let(:loan) { FactoryGirl.create(:loan, :completed, lender: lender, amount: Money.new(1_200_000_01)) }

    it "redirects to loan entry form" do
      page.current_url.should == new_loan_entry_url(loan)
      page.should have_content(I18n.t('update_loan_lending_limit.loan_not_valid_for_lending_limit'))

      loan.reload.lending_limit.should == new_lending_limit
    end
  end

end
