require 'rails_helper'

describe 'Realisation report' do
  let(:lender1) { FactoryGirl.create(:lender, name: "Bank 1") }
  let(:lender2) { FactoryGirl.create(:lender, name: "Bank 3") }
  let(:lender3) { FactoryGirl.create(:lender, name: "Bank 2") }
  let(:lender4) { FactoryGirl.create(:lender, name: "Bank 4") }
  let(:lender5) { FactoryGirl.create(:lender, name: "Bank 5") }

  let(:loan1) do
    FactoryGirl.create(:loan, :settled, settled_on: 10.days.ago.to_date,
                                        lender: lender1)
  end

  let(:loan2) do
    FactoryGirl.create(:loan, :settled, settled_on: 11.days.ago.to_date,
                                        lender: lender2)
  end

  let(:loan3) do
    FactoryGirl.create(:loan, :settled, settled_on: 12.days.ago.to_date,
                                        lender: lender3)
  end

  let(:loan4) do
    FactoryGirl.create(:loan, :settled, settled_on: 13.days.ago.to_date,
                                        lender: lender4)
  end

  let(:loan5) do
    FactoryGirl.create(:loan, :settled, settled_on: 14.days.ago.to_date,
                                        lender: lender5)
  end

  let!(:realisation1) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_loan: loan1,
                                                realised_amount: Money.new(1_000_00),
                                                realised_on: 2.days.ago.to_date) }
  let!(:realisation1b) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_loan: loan1,
                                                realised_amount: Money.new(1_000_00),
                                                realised_on: 3.days.ago.to_date) }
  let!(:realisation1c) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_loan: loan1,
                                                realised_amount: Money.new(1_000_00),
                                                realised_on: Date.today) }
  let!(:realisation1d) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_loan: loan1,
                                                realised_amount: Money.new(1_000_00),
                                                realised_on: 5.days.ago.to_date) }
  let!(:realisation2) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_loan: loan2,
                                                realised_amount: Money.new(2_000_00),
                                                realised_on: 5.days.ago.to_date) }
  let!(:realisation3) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_loan: loan3,
                                                realised_amount: Money.new(3_000_00),
                                                realised_on: Date.today) }
  let!(:realisation4) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_loan: loan4,
                                                realised_amount: Money.new(4_000_00),
                                                realised_on: 2.days.ago.to_date) }
  let!(:realisation5) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_loan: loan5,
                                                realised_amount: Money.new(4_000_00),
                                                realised_on: 2.days.ago.to_date) }

  let(:report_start_date) { 4.days.ago.to_date.to_s(:screen) }
  let(:report_end_date) { 2.day.ago.to_date.to_s(:screen) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  context 'as a CFE user' do
    let(:current_user) { FactoryGirl.create(:cfe_user) }

    context 'when selecting particular lenders' do
      it 'outputs a CSV realisation report' do
        visit root_path
        click_link 'Generate Realisations Report'

        expect(page).to have_text 'Realisations Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select lender1.name, from: 'Which lenders would you like to see realisations for?'
        select lender2.name, from: 'Which lenders would you like to see realisations for?'
        select lender3.name, from: 'Which lenders would you like to see realisations for?'
        select lender4.name, from: 'Which lenders would you like to see realisations for?'
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 3 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"
        expect(page).to have_text "Lenders #{lender1.name}, #{lender3.name}, #{lender2.name}, #{lender4.name}"
        expect(page).not_to have_text lender5.name
        click_button 'Download Report'

        expect(page.response_headers['Content-Type']).to include('text/csv')
      end
    end

    context 'when selecting ALL lenders' do
      it 'outputs a CSV realisation report for all lenders' do
        all_lenders_list = Lender.order_by_name.map(&:name).join(", ")

        visit root_path
        click_link 'Generate Realisations Report'

        expect(page).to have_text 'Realisations Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select "All", from: 'Which lenders would you like to see realisations for?'
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 4 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"
        expect(page).to have_text "Lenders #{all_lenders_list}"
        click_button 'Download Report'

        expect(page.response_headers['Content-Type']).to include('text/csv')
      end
    end

    context 'when report criteria returns no results' do
      let(:report_start_date) { 10.days.ago.to_date.to_s(:screen) }
      let(:report_end_date) { 9.days.ago.to_date.to_s(:screen) }

      it 'a csv file cannot be downloaded' do
        visit root_path
        click_link 'Generate Realisations Report'

        expect(page).to have_text 'Realisations Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select lender1.name, from: 'Which lenders would you like to see realisations for?'
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 0 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"
        expect(page).to have_text "Lenders #{lender1.name}"

        expect(page).not_to have_button('Download Report')

        click_link 'Try again'
        expect(page).to have_text 'Realisations Report Criteria'
      end
    end

  end

  context 'as a lender user' do
    let(:current_user) { FactoryGirl.create(:lender_user, lender: lender1) }

    context 'with results' do
      let(:report_start_date) { 4.days.ago.to_date.to_s(:screen) }
      let(:report_end_date) { 1.days.ago.to_date.to_s(:screen) }

      it "outputs a CSV realisation report for the current user's lender" do
        visit root_path
        click_link 'Generate Realisations Report'

        expect(page).to have_text 'Realisations Report Criteria'
        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        expect(page).not_to have_text('Which lenders would you like to see realisations for?')

        click_button 'Submit'

        expect(page).to have_text 'Data extract found 2 rows'
        expect(page).not_to have_text 'Lenders'
        click_button 'Download Report'

        expect(page.response_headers['Content-Type']).to include('text/csv')
      end
    end

    context 'with no results' do
      let(:report_start_date) { 10.days.ago.to_date.to_s(:screen) }
      let(:report_end_date) { 9.days.ago.to_date.to_s(:screen) }

      it 'a csv file cannot be downloaded when report criteria returns no results' do
        visit root_path
        click_link 'Generate Realisations Report'

        expect(page).to have_text 'Realisations Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 0 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"

        expect(page).not_to have_button('Download Report')

        click_link 'Try again'
        expect(page).to have_text 'Realisations Report Criteria'
      end
    end
  end
end
