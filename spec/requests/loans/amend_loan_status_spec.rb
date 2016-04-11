require "rails_helper"

describe "Amend loan status" do
  it "on a guaranteed loan" do
    user = FactoryGirl.create(:cfe_user)
    loan = FactoryGirl.create(:loan, :guaranteed)

    login_as(user)
    visit loan_path(loan)
    click_on "Status Amendment"

    select "Administrative", from: :loan_status_amendment_status_amendment_type
    fill_in :loan_status_amendment_status_amendment_notes,
            with: "A mistake was made."
    click_on "Submit"

    expected_flash = I18n.t(
      "activemodel.loan_status_amendment.status_amended",
      amendment_type: "Administrative",
    )
    expect(page.current_path).to eql(loan_path(loan))
    expect(page).to have_content(expected_flash)
    expect(page).to have_content("Status Amendment: Administrative")
    expect(loan.reload.modified_by).to eql(user)
  end

  it "is not allowed on a loan that is not yet guaranteed" do
    user = FactoryGirl.create(:cfe_user)
    loan = FactoryGirl.create(:loan, :offered)

    login_as(user)
    visit loan_path(loan)
    expect(page).not_to have_content("Status Amendment")
  end

  it "change existing amendment" do
    user = FactoryGirl.create(:cfe_user)
    loan = FactoryGirl.create(
      :loan,
      :guaranteed,
      status_amendment_type: LoanStatusAmendment::ELIGIBILITY,
      status_amendment_notes: "A mistake was made.",
    )

    login_as(user)
    visit loan_path(loan)
    click_on "Status Amendment"

    expect(amendment_status_type_value).to eql("Eligibility")
    expect(amendment_status_notes_value).to eql("A mistake was made.")

    select "Other", from: :loan_status_amendment_status_amendment_type
    fill_in :loan_status_amendment_status_amendment_notes,
            with: "A new note"
    click_on "Submit"

    expected_flash = I18n.t(
      "activemodel.loan_status_amendment.status_amended",
      amendment_type: "Other",
    )
    expect(page.current_path).to eql(loan_path(loan))
    expect(page).to have_content(expected_flash)
  end

  def amendment_status_type_value
    find("#loan_status_amendment_status_amendment_type").value
  end

  def amendment_status_notes_value
    find("#loan_status_amendment_status_amendment_notes").value
  end
end
