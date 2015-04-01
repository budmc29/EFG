require 'rails_helper'

describe 'Recoveries report' do
  let!(:loan1) { FactoryGirl.create(:loan, :settled, settled_on: 10.days.ago.to_date )}
  let!(:loan2) { FactoryGirl.create(:loan, :settled, settled_on: 11.days.ago.to_date )}
  let!(:loan3) { FactoryGirl.create(:loan, :settled, settled_on: 12.days.ago.to_date )}
  let!(:loan4) { FactoryGirl.create(:loan, :settled, settled_on: 13.days.ago.to_date )}
  let!(:loan5) { FactoryGirl.create(:loan, :settled, settled_on: 14.days.ago.to_date )}

  let!(:recovery1) { FactoryGirl.create(:recovery, :realised, loan: loan1, recovered_on: 2.day.ago.to_date) }
  let!(:recovery1b) { FactoryGirl.create(:recovery, :realised, loan: loan1, recovered_on: 3.day.ago.to_date) }
  let!(:recovery1c) { FactoryGirl.create(:recovery, :realised, loan: loan1, recovered_on: Date.today) }
  let!(:recovery1d) { FactoryGirl.create(:recovery, :realised, loan: loan1, recovered_on: 5.day.ago.to_date) }
  let!(:recovery2) { FactoryGirl.create(:recovery, :realised, loan: loan2, recovered_on: 5.day.ago.to_date) }
  let!(:recovery3) { FactoryGirl.create(:recovery, :unrealised, loan: loan3, recovered_on: Date.today) }
  let!(:recovery4) { FactoryGirl.create(:recovery, :realised, loan: loan4, recovered_on: 2.day.ago.to_date) }
  let!(:recovery5) { FactoryGirl.create(:recovery, :unrealised, loan: loan5, recovered_on: 2.day.ago.to_date) }

  let(:lender1) { loan1.lender }
  let(:lender2) { loan2.lender }
  let(:lender3) { loan3.lender }
  let(:lender4) { loan4.lender }
  let(:lender5) { loan5.lender }

  let(:report_start_date) { 4.days.ago.to_date.to_s }
  let(:report_end_date) { 2.day.ago.to_date.to_s }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  context 'as an CFE user' do
    let!(:current_user) { FactoryGirl.create(:cfe_user) }

    context 'when selecting particular lenders' do
      it 'outputs a CSV realisation report' do
        report_start_date = 4.days.ago.to_date.to_s
        report_end_date = 2.day.ago.to_date.to_s

        visit root_path
        click_link 'Generate Recoveries Report'

        expect(page).to have_text 'Recoveries Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select "#{lender1.name}", from: 'Which lenders would you like to see recoveries for?'
        select "#{lender2.name}", from: 'Which lenders would you like to see recoveries for?'
        select "#{lender3.name}", from: 'Which lenders would you like to see recoveries for?'
        select "#{lender4.name}", from: 'Which lenders would you like to see recoveries for?'
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 3 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"
        expect(page).to have_text "Lenders #{lender1.name}, #{lender2.name}, #{lender3.name}, #{lender4.name}"
        expect(page).not_to have_text lender5.name
        click_button 'Download Report'

        expect(page.response_headers['Content-Type']).to include('text/csv')
      end
    end

    context 'when selecting ALL lenders' do
      it 'outputs a CSV realisation report for all lenders' do
        report_start_date = 4.days.ago.to_date.to_s
        report_end_date = 2.day.ago.to_date.to_s
        all_lenders_list = Lender.all.map(&:name).join(', ')

        visit root_path
        click_link 'Generate Recoveries Report'

        expect(page).to have_text 'Recoveries Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select "All", from: 'Which lenders would you like to see recoveries for?'
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
      it 'a csv file cannot be downloaded' do
        report_start_date = 10.days.ago.to_date.to_s
        report_end_date = 9.days.ago.to_date.to_s

        visit root_path
        click_link 'Generate Recoveries Report'

        expect(page).to have_text 'Recoveries Report Criteria'
        click_button 'Submit' # submit with invalid form data
        expect(page).to have_text "can't be blank"

        fill_in 'What is the start date for your report?', with: report_start_date
        fill_in 'What is the end date for your report?', with: report_end_date
        select "#{lender1.name}", from: 'Which lenders would you like to see recoveries for?'
        click_button 'Submit'

        expect(page).to have_text 'Data extract found 0 rows'
        expect(page).to have_text "Report Start Date #{report_start_date}"
        expect(page).to have_text "Report End Date #{report_end_date}"
        expect(page).to have_text "Lenders #{lender1.name}"

        expect(page).not_to have_button('Download Report')

        click_link 'Try again'
        expect(page).to have_text 'Recoveries Report Criteria'
      end
    end

  end

  context 'as an lender user' do
    let!(:current_user) { FactoryGirl.create(:lender_user, lender: lender1) }

    it "outputs a CSV realisation report for the current user's lender" do
      visit root_path
      click_link 'Generate Recoveries Report'

      expect(page).to have_text 'Recoveries Report Criteria'
      fill_in 'What is the start date for your report?', with: 4.days.ago.to_date.to_s
      fill_in 'What is the end date for your report?', with: 1.day.ago.to_date.to_s
      expect(page).not_to have_text('Which lenders would you like to see recoveries for?')

      click_button 'Submit'

      expect(page).to have_text 'Data extract found 2 rows'
      expect(page).not_to have_text 'Lenders'
      click_button 'Download Report'

      expect(page.response_headers['Content-Type']).to include('text/csv')
    end

    it 'a csv file cannot be downloaded when report criteria returns no results' do
      report_start_date = 10.days.ago.to_date.to_s
      report_end_date = 9.days.ago.to_date.to_s

      visit root_path
      click_link 'Generate Recoveries Report'

      expect(page).to have_text 'Recoveries Report Criteria'
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
      expect(page).to have_text 'Recoveries Report Criteria'
    end
  end

end
