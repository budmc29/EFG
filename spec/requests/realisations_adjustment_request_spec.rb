require 'rails_helper'

describe 'making a realisation adjustment' do
  let(:current_user) { FactoryGirl.create(:cfe_user) }
  before { login_as(current_user, scope: :user) }

  let(:loan) { FactoryGirl.create(:loan, :realised) }
  let!(:realisation) { FactoryGirl.create(:loan_realisation, realised_loan: loan, realised_amount: Money.new(10_000_00)) }

  it do
    visit loan_path(loan)

    make_realisation_adjustment(
      amount: '1000.00',
      date: '19/09/2014',
      notes: 'Joe Bloggs informed us that this needed updating.',
      post_claim_limit: false
    )

    make_realisation_adjustment(
      amount: '2000.00',
      date: '19/09/2014',
      notes: '',
      post_claim_limit: true
    )

    click_link 'Loan Details'
    expect(page).to have_detail_row('Cumulative Value of All Pre-Claim Limit Realisations', '£10,000.00')
    expect(page).to have_detail_row('Cumulative Value of All Pre-Claim Limit Realisation Adjustments', '£1,000.00')
    expect(page).to have_detail_row('Cumulative Value of All Post-Claim Limit Realisation Adjustments', '£2,000.00')
    expect(page).to have_detail_row('Cumulative Value of All Realisations', '£7,000.00')

    realisation_adjustment = loan.realisation_adjustments.first!
    expect(realisation_adjustment.notes).to eql('Joe Bloggs informed us that this needed updating.')
  end

  it "does not continue with invalid values" do
    visit new_loan_realisation_adjustment_path(loan)

    expect {
      click_button 'Submit'
    }.to_not change(RealisationAdjustment, :count)
  end

  private
    def make_realisation_adjustment(opts)
      click_link 'Make a Realisation Adjustment'
      fill_in 'Amount', with: opts.fetch(:amount)
      fill_in 'Date', with: opts.fetch(:date)
      fill_in 'Notes', with: opts.fetch(:notes)
      check('Post claim limit') if opts.fetch(:post_claim_limit)
      click_button 'Submit'
    end
end
