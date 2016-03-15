require "rails_helper"

describe "Generating state aid letter" do
  it "can set borrower's name and address, with date of letter" do
    loan = create_guaranteed_loan
    lender_user = create_lender_user(loan.lender)

    login_as(lender_user)
    navigate_to_state_aid_letter_form(loan)
    fill_in :state_aid_letter_details_applicant_name, with: "Joe Bloggs"
    fill_in :state_aid_letter_details_applicant_address1, with: "123 My Street"
    fill_in :state_aid_letter_details_applicant_address2, with: "My Borough"
    fill_in :state_aid_letter_details_applicant_address3, with: "My Town"
    fill_in :state_aid_letter_details_applicant_address4, with: "My County"
    fill_in :state_aid_letter_details_applicant_postcode, with: "AB1 4CD"
    fill_in :state_aid_letter_details_letter_date, with: "23/03/2016"
    click_on "Generate State Aid Letter"

    expected_path = loan_state_aid_letters_path(loan, format: :pdf)
    expect(current_path).to eql(expected_path)
  end

  it "without borrower and date details" do
    loan = create_guaranteed_loan
    lender_user = create_lender_user(loan.lender)

    login_as(lender_user)
    navigate_to_state_aid_letter_form(loan)
    click_on "Generate State Aid Letter"

    expected_path = loan_state_aid_letters_path(loan, format: :pdf)
    expect(current_path).to eql(expected_path)
  end

  def create_guaranteed_loan
    FactoryGirl.create(:loan, :completed, :guaranteed)
  end

  def create_lender_user(lender)
    FactoryGirl.create(:lender_user, lender: lender)
  end

  def navigate_to_state_aid_letter_form(loan)
    visit(loan_path(loan))
    click_on "Generate State Aid Letter"
  end
end
