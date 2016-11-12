require "rails_helper"

describe "loan demand to borrower" do
  let(:current_lender) { create(:lender) }
  let(:current_user) { create(:lender_user, lender: current_lender) }
  let(:loan) { create(:loan, :guaranteed, lender: current_lender) }

  before do
    initial_draw_change = loan.initial_draw_change
    initial_draw_change.amount_drawn = loan.amount
    initial_draw_change.date_of_change = Date.new(2012)
    initial_draw_change.save!

    login_as(current_user, scope: :user)
  end

  it "updates loan" do
    visit loan_path(loan)
    click_link "Demand to Borrower"
    fill_in_valid_demand_to_borrower_details
    click_button "Submit"

    expect(page).to have_content("State: Lender demand")

    click_link "Loan Details"

    expect(page).to have_content("£10,000.00")
    expect(page).to have_content("£9,000.00")
    expect(page).to have_content(Date.current.to_s(:screen))
  end

  it "does not display previous demand to borrower details" do
    loan.update_attribute(:amount_demanded, 1234)

    visit loan_path(loan)
    click_link "Demand to Borrower"

    expect(amount_demanded_field_value).to be_blank
    expect(borrower_demand_outstanding_field_value).to be_blank
    expect(borrower_demanded_on_field_value).to be_blank
  end

  it "does not continue with invalid values" do
    visit loan_path(loan)
    click_link "Demand to Borrower"

    expect(loan.state).to eq(Loan::Guaranteed)
    expect do
      click_button "Submit"
      loan.reload
    end.to_not change(loan, :state)

    expect(current_path).to eq(loan_demand_to_borrower_path(loan))
  end

  def amount_demanded_field_value
    page.find("#loan_demand_to_borrower_amount_demanded").value
  end

  def borrower_demand_outstanding_field_value
    page.find("#loan_demand_to_borrower_borrower_demand_outstanding").value
  end

  def borrower_demanded_on_field_value
    page.find("#loan_demand_to_borrower_borrower_demanded_on").value
  end
end
