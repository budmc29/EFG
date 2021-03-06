require 'rails_helper'

describe 'lender dashboard' do
  shared_examples 'dashboard' do
    context "with not drawn loan alerts" do
      let(:start_date) { (6.months.ago - 10.days).to_date }

      let!(:overdue_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 5.weekdays_from(start_date)
        )
      }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 11.weekdays_from(start_date)
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 21.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 42.weekdays_from(start_date)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 60.weekdays_from(start_date)
        )
      }

      it "should display overdue, high, medium and low priority loan alerts" do
        visit root_path

        expect(page).to have_css "#not_drawn_loan_alerts a.overdue-priority .total-loans", text: "1"
        expect(page).to have_css "#not_drawn_loan_alerts a.high-priority .total-loans", text: "1"
        expect(page).to have_css "#not_drawn_loan_alerts a.medium-priority .total-loans", text: "1"
        expect(page).to have_css "#not_drawn_loan_alerts a.low-priority .total-loans", text: "1"

        find("#not_drawn_loan_alerts a.overdue-priority").click
        expect(page).to have_content("(1 loan)")
        expect(page).to have_content(overdue_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_drawn_loan_alerts a.high-priority").click
        expect(page).to have_content("(1 loan)")
        expect(page).to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(overdue_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_drawn_loan_alerts a.medium-priority").click
        expect(page).to have_content("(1 loan)")
        expect(page).to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(overdue_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_drawn_loan_alerts a.low-priority").click
        expect(page).to have_content("(1 loan)")
        expect(page).to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(overdue_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
      end

      it "allows navigating to different loan alerts groups" do
        visit root_path
        find("#not_drawn_loan_alerts a.overdue-priority").click
        expect(page).to have_css(".overdue.btn.btn-info")

        click_on("High Priority Alerts")
        expect(page).to have_css(".high.btn.btn-info")

        click_on("Medium Priority Alerts")
        expect(page).to have_css(".medium.btn.btn-info")

        click_on("Low Priority Alerts")
        expect(page).to have_css(".low.btn.btn-info")

        click_on("All Loan Alerts")
        expect(page).to have_content("(4 loans)")
      end
    end

    context "not demanded loan alerts" do
      let(:start_date) { 365.days.ago.to_date }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: 5.weekdays_from(start_date)
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :legacy_sflg,
          lender: lender,
          borrower_demanded_on: 19.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: 42.weekdays_from(start_date)
        )
      }

      # EFG loans are excluded from this loan alert
      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          lender: lender,
          borrower_demanded_on: start_date
        )
      }

      let!(:loan_not_in_alerts2) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: start_date - 1.day
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        expect(page).to have_css "#not_demanded_loan_alerts a.high-priority .total-loans", text: "1"
        expect(page).to have_css "#not_demanded_loan_alerts a.medium-priority .total-loans", text: "1"
        expect(page).to have_css "#not_demanded_loan_alerts a.low-priority .total-loans", text: "1"

        find("#not_demanded_loan_alerts a.high-priority").click
        expect(page).to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
        expect(page).not_to have_content(loan_not_in_alerts2.reference)

        visit root_path

        find("#not_demanded_loan_alerts a.medium-priority").click
        expect(page).to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
        expect(page).not_to have_content(loan_not_in_alerts2.reference)

        visit root_path

        find("#not_demanded_loan_alerts a.low-priority").click
        expect(page).to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
        expect(page).not_to have_content(loan_not_in_alerts2.reference)
      end
    end

    context "not progressed loan alerts" do
      let(:start_date) { 6.months.ago.to_date }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :eligible,
          lender: lender,
          updated_at: start_date
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :completed,
          lender: lender,
          updated_at: 11.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :incomplete,
          lender: lender,
          updated_at: 30.weekdays_from(start_date)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :incomplete,
          lender: lender,
          updated_at: 60.weekdays_from(start_date)
        )
      }

      it "should display high, medium and low priority loan alerts" do
        skip "Removed due to unexplained failure in the Dev VM / CI environments"
        visit root_path

        expect(page).to have_css("#not_progressed_loan_alerts a.high-priority .total-loans", text: "1"), page.body
        expect(page).to have_css("#not_progressed_loan_alerts a.medium-priority .total-loans", text: "1"), page.body
        expect(page).to have_css("#not_progressed_loan_alerts a.low-priority .total-loans", text: "1"), page.body

        find("#not_progressed_loan_alerts a.high-priority").click
        expect(page).to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_progressed_loan_alerts a.medium-priority").click
        expect(page).to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_progressed_loan_alerts a.low-priority").click
        expect(page).to have_content(low_priority_loan.reference)
        expect(page).not_to have_content(medium_priority_loan.reference)
        expect(page).not_to have_content(high_priority_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
      end
    end

    context "not closed loan alerts" do
      let!(:high_priority_efg_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :efg,
          lender: lender,
          maturity_date: 3.months.ago
        )
      }

      let!(:high_priority_legacy_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :sflg,
          lender: lender,
          maturity_date: 6.months.ago
        )
      }

      let!(:medium_priority_efg_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :efg,
          lender: lender,
          maturity_date: 11.weekdays_from(3.months.ago)
        )
      }

      let!(:medium_priority_legacy_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :sflg,
          lender: lender,
          maturity_date: 11.weekdays_from(6.months.ago)
        )
      }

      let!(:low_priority_efg_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :efg,
          lender: lender,
          maturity_date: 31.weekdays_from(3.months.ago)
        )
      }

      let!(:low_priority_legacy_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :legacy_sflg,
          lender: lender,
          maturity_date: 31.weekdays_from(6.months.ago)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :efg,
          lender: lender,
          maturity_date: 61.weekdays_from(3.months.ago)
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        expect(page).to have_css "#not_closed_loan_alerts a.high-priority .total-loans", text: "2"
        expect(page).to have_css "#not_closed_loan_alerts a.medium-priority .total-loans", text: "2"
        expect(page).to have_css "#not_closed_loan_alerts a.low-priority .total-loans", text: "2"

        find("#not_closed_loan_alerts a.high-priority").click
        expect(page).to have_content(high_priority_efg_loan.reference)
        expect(page).to have_content(high_priority_legacy_loan.reference)
        expect(page).not_to have_content(medium_priority_efg_loan.reference)
        expect(page).not_to have_content(medium_priority_legacy_loan.reference)
        expect(page).not_to have_content(low_priority_efg_loan.reference)
        expect(page).not_to have_content(low_priority_legacy_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_closed_loan_alerts a.medium-priority").click
        expect(page).not_to have_content(high_priority_efg_loan.reference)
        expect(page).not_to have_content(high_priority_legacy_loan.reference)
        expect(page).to have_content(medium_priority_efg_loan.reference)
        expect(page).to have_content(medium_priority_legacy_loan.reference)
        expect(page).not_to have_content(low_priority_efg_loan.reference)
        expect(page).not_to have_content(low_priority_legacy_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_closed_loan_alerts a.low-priority").click
        expect(page).not_to have_content(high_priority_efg_loan.reference)
        expect(page).not_to have_content(high_priority_legacy_loan.reference)
        expect(page).not_to have_content(medium_priority_efg_loan.reference)
        expect(page).not_to have_content(medium_priority_legacy_loan.reference)
        expect(page).to have_content(low_priority_efg_loan.reference)
        expect(page).to have_content(low_priority_legacy_loan.reference)
        expect(page).not_to have_content(loan_not_in_alerts.reference)
      end
    end
  end

  context 'user logging in for the first time' do
    let(:user) { FactoryGirl.create(:cfe_user) }

    before { login_as(user, scope: :user) }

    it 'should show correct welcome message' do
      visit root_path
      expect(page).to have_content "Welcome #{user.first_name}"
    end
  end

  context 'user logging in for the second time' do
    let(:user) { FactoryGirl.create(:cfe_user, sign_in_count: 2) }

    before { login_as(user, scope: :user) }

    it 'should show correct welcome message' do
      visit root_path
      expect(page).to have_content "Welcome back, #{user.first_name}"
    end
  end

  context 'CfeUser' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:user) { FactoryGirl.create(:cfe_user) }

    before { login_as(user, scope: :user) }

    it_behaves_like 'dashboard'
  end

  context 'LenderUser' do
    let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }
    let(:user) { FactoryGirl.create(:lender_user, lender: lender) }

    before { login_as(user, scope: :user) }

    it_behaves_like 'dashboard'

    context "with LendingLimits" do
      let(:lending_limit1) { lender.lending_limits.first }
      let(:lending_limit2) { FactoryGirl.create(:lending_limit, lender: lender, allocation: 3000000) }

      let!(:loan1) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          lender: lender,
          lending_limit: lending_limit1,
          amount: 250000
        )
      }

      let!(:loan2) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          lender: lender,
          lending_limit: lending_limit2,
          amount: 800000
        )
      }

      it "should display LendingLimit summary" do
        visit root_path

        within '.dashboard-widgets.primary' do
          expect(page).to have_content(lending_limit1.name)
          expect(page).to have_content('Allocation: £1,000,000')
          expect(page).to have_content('Usage: £250,000')
          expect(page).to have_content('Utilisation: 25.00%')

          expect(page).to have_content(lending_limit2.name)
          expect(page).to have_content('Allocation: £3,000,000')
          expect(page).to have_content('Usage: £800,000')
          expect(page).to have_content('Utilisation: 26.67%')
        end
      end
    end

    context "with Claim Limits" do
      before do
        all_phases = Phase.all.map do |phase|
          calculator_class = "Phase#{phase.id}ClaimLimitCalculator".constantize

          calculator = double(
            calculator_class,
            total_amount: Money.new(1_000_000_00),
            amount_remaining: Money.new(500_000_00),
            percentage_remaining: 50,
            pre_claim_realisations_amount: Money.new(0),
            settled_amount: Money.new(500_000_00),
            phase: phase)

          allow(calculator_class).to receive(:new).and_return(calculator)

          rules = double("Rules", claim_limit_calculator: calculator_class)

          allow(phase).to receive(:rules).and_return(rules)

          phase
        end

        allow(Phase).to receive(:all).and_return(all_phases)
      end

      it "displays claim limit stats" do
        visit root_path

        within(claim_limit_widgets) do
          expect(page).to have_content('Phase 1')
          expect(page).to have_content('Claim Limit: £1,000,000')
          expect(page).to have_content('Amount Remaining: £500,000')
          expect(page).to have_content('Percentage Remaining: 50%')
        end
      end

      it "displays a claim limit for each phase" do
        visit root_path

        within(claim_limit_widgets) do
          Phase.all.each do |phase|
            expect(page).to have_content(phase.name)
          end
        end
      end
    end
  end

  def claim_limit_widgets
    find(".dashboard-widgets.secondary")
  end
end
