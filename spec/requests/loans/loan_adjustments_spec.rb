require "rails_helper"

describe "Loan adjustments" do
  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let(:another_user) do
    FactoryGirl.create(
      :cfe_user,
      first_name: "David",
      last_name: "Bowman",
    )
  end

  let!(:loan) { FactoryGirl.create(:loan, :realised) }

  context "when loan has adjustments" do
    let!(:realisation_adjustment_post_claim) do
      FactoryGirl.create(
        :realisation_adjustment,
        amount: Money.new(400_00),
        date: Date.parse("25/03/2016"),
        notes: "Human error",
        loan: loan,
        created_by: another_user,
        post_claim_limit: true,
      )
    end

    let!(:realisation_adjustment_pre_claim) do
      FactoryGirl.create(
        :realisation_adjustment,
        amount: Money.new(200_00),
        date: Date.parse("23/03/2016"),
        notes: "Another human error",
        loan: loan,
        created_by: another_user,
        post_claim_limit: false,
      )
    end

    let!(:settlement_adjustment) do
      FactoryGirl.create(
        :settlement_adjustment,
        amount: Money.new(800_00),
        date: Date.parse("28/03/2016"),
        notes: "Hal 9000 error",
        loan: loan,
        created_by: another_user,
      )
    end

    before do
      login_as(current_user)
    end

    it "lists all adjustments, ordered by adjusted date" do
      visit loan_path(loan)
      click_on "View Adjustments"

      within adjustment_rows[0] do
        expect(page).to have_content("23/03/2016")
        expect(type_cell).to have_content(/\ARealisation\z/)
        expect(page).to have_content("£200.00")
        expect(page).to have_content("David Bowman")
        expect(page).to have_content("Pre Claim Limit")
        expect(notes_cell).to have_content("Another human error")
      end

      within adjustment_rows[1] do
        expect(page).to have_content("25/03/2016")
        expect(type_cell).to have_content(/\ARealisation\z/)
        expect(page).to have_content("£400.00")
        expect(page).to have_content("David Bowman")
        expect(page).to have_content("Post Claim Limit")
        expect(notes_cell).to have_content("Human error")
      end

      within adjustment_rows[2] do
        expect(page).to have_content("28/03/2016")
        expect(type_cell).to have_content(/\ASettlement\z/)
        expect(page).to have_content("£800.00")
        expect(page).to have_content("David Bowman")
        expect(page).not_to have_content("Post Claim Limit")
        expect(page).not_to have_content("Pre Claim Limit")
        expect(notes_cell).to have_content("Hal 9000 error")
      end
    end
  end

  context "when loan has no adjustment" do
    it "list of adjustments cannot be navigated to" do
      visit loan_path(loan)
      expect(page).not_to have_content("View Adjustments")
    end
  end

  def adjustment_rows
    all(".adjustment-table__row")
  end

  def type_cell
    page.find(".adjustment-table__cell--type")
  end

  def notes_cell
    page.find(".adjustment-table__cell--notes")
  end
end
