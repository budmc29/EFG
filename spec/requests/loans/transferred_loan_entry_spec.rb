require "rails_helper"

describe "Transferred loan entry" do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) do
    FactoryGirl.create(:loan, :sflg, :transferred, lender: current_user.lender)
  end

  let!(:sub_lender) do
    FactoryGirl.create(:sub_lender, lender: loan.lender, name: "ACME sublender")
  end

  before(:each) do
    login_as(current_user, scope: :user)
    visit new_loan_transferred_entry_path(loan)
  end

  it "should transition transferred loan to completed" do
    choose "transferred_loan_entry_declaration_signed_true"
    fill_in "transferred_loan_entry_sortcode", with: "03-12-45"
    select "Quarterly", from: "transferred_loan_entry_repayment_frequency_id"
    fill_in "transferred_loan_entry_lender_reference", with: "lenderref1"
    fill_in "transferred_loan_entry_repayment_duration_years", with: 1
    fill_in "transferred_loan_entry_repayment_duration_months", with: 6
    select "ACME sublender", from: "Sub-lender"

    calculate_state_aid

    fill_in "transferred_loan_entry_generic1", with: "Generic 1"
    fill_in "transferred_loan_entry_generic2", with: "Generic 2"
    fill_in "transferred_loan_entry_generic3", with: "Generic 3"
    fill_in "transferred_loan_entry_generic4", with: "Generic 4"
    fill_in "transferred_loan_entry_generic5", with: "Generic 5"

    click_button "Submit"

    expect(current_path).to eq(loan_path(loan))

    loan.reload
    expect(loan.state).to eq(Loan::Completed)
    expect(loan.declaration_signed).to eql(true)
    expect(loan.sortcode).to eq("03-12-45")
    expect(loan.lender_reference).to eq("lenderref1")
    expect(loan.repayment_frequency_id).to eq(3)
    expect(loan.repayment_duration).to eq(MonthDuration.new(18))
    expect(loan.sub_lender).to eql("ACME sublender")
    expect(loan.generic1).to eq("Generic 1")
    expect(loan.generic2).to eq("Generic 2")
    expect(loan.generic3).to eq("Generic 3")
    expect(loan.generic4).to eq("Generic 4")
    expect(loan.generic5).to eq("Generic 5")
    expect(loan.premium_schedule).to be_present
    expect(loan.modified_by).to eq(current_user)

    should_log_loan_state_change(loan, Loan::Completed, 4, current_user)
  end

  it "does not continue with invalid values" do
    expect do
      click_button "Submit"
    end.not_to change(loan, :state)

    expect(page).to have_content "must be accepted"
    expect(page).to have_content "must be calculated"
    expect(page).to have_content "a sub-lender must be chosen"
  end

  def calculate_state_aid
    click_button "State Aid Calculation"
    fill_in "premium_schedule_initial_draw_year", with: "2016"
    fill_in "premium_schedule_initial_draw_amount",
            with: (loan.reload.amount - Money.new(1_000_00)).to_s
    click_button "Submit"
  end
end
