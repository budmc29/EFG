module RequestSpecHelpers

  def submit_sign_in_form(username, password)
    fill_in 'user_username', with: username
    fill_in 'user_password', with: password
    click_button 'Sign In'
  end

  def should_log_loan_state_change(loan, to_state, event_id, user)
    expect(loan.state_changes.count).to eq(1)
    state_change = loan.state_changes.last
    expect(state_change.state).to eq(to_state)
    expect(state_change.event).to eq(LoanEvent.find(event_id))
    expect(state_change.modified_by).to eq(user)
  end

  def fill_in_duration_input(attribute, years, months)
    fill_in "loan_eligibility_check_#{attribute}_years", with: years
    fill_in "loan_eligibility_check_#{attribute}_months", with: months
  end

  # Eligibility Check

  def fill_in_valid_eligibility_check_details(lender, sic_code)
    choose 'loan_eligibility_check_viable_proposition_true'
    choose 'loan_eligibility_check_would_you_lend_true'
    choose 'loan_eligibility_check_collateral_exhausted_true'
    choose 'loan_eligibility_check_not_insolvent_true'
    fill_in 'loan_eligibility_check_amount', with: '50000.89'
    select lender.lending_limits.first.name, from: 'loan_eligibility_check_lending_limit_id'
    choose "loan_eligibility_check_repayment_profile_fixed_term"
    fill_in_duration_input 'repayment_duration', 2, 6
    fill_in 'loan_eligibility_check_turnover', with: '1234567.89'
    fill_in 'loan_eligibility_check_trading_date', with: '31/1/2012'
    select_option_value sic_code.code, from: 'loan_eligibility_check_sic_code'
    select LoanCategory::TypeB.name, from: 'loan_eligibility_check_loan_category_id'
    select 'Start-up costs', from: 'loan_eligibility_check_reason_id' # Start-up costs
    choose 'loan_eligibility_check_previous_borrowing_true'
    choose 'loan_eligibility_check_private_residence_charge_required_false'
    choose 'loan_eligibility_check_personal_guarantee_required_false'
  end

  # Loan Entry

  def fill_in_valid_loan_entry_details(loan)
    choose 'loan_entry_declaration_signed_true'
    fill_in 'loan_entry_business_name', with: 'Widgets Ltd.'
    fill_in 'loan_entry_trading_name', with: 'Brilliant Widgets'
    fill_in 'loan_entry_company_registration', with: '0123456789'
    select LegalForm.find(1).name, from: 'loan_entry_legal_form_id' # Sole Trader
    fill_in 'loan_entry_postcode', with: 'N8 4HF'
    fill_in 'loan_entry_sortcode', with: '03-12-45'
    select RepaymentFrequency.find(3).name, from: 'loan_entry_repayment_frequency_id' # quarterly
    fill_in 'loan_entry_lender_reference', with: 'lenderref1'
    select LoanSecurityType.find(1).name, from: 'loan_entry_loan_security_types' # Residential property
    fill_in 'loan_entry_security_proportion', with: '20'
    fill_in 'loan_entry_generic1', with: 'Generic 1'
    fill_in 'loan_entry_generic2', with: 'Generic 2'
    fill_in 'loan_entry_generic3', with: 'Generic 3'
    fill_in 'loan_entry_generic4', with: 'Generic 4'
    fill_in 'loan_entry_generic5', with: 'Generic 5'
    choose 'loan_entry_interest_rate_type_id_1'
    fill_in 'loan_entry_interest_rate', with: '2.25'
    fill_in 'loan_entry_fees', with: '123.45'
  end

  def fill_in_valid_loan_entry_details_phase_6(loan)
    fill_in_valid_loan_entry_details(loan)
    click_button 'State Aid Calculation'
    check 'loan_entry_state_aid_is_valid'
  end

  alias :fill_in_valid_loan_entry_details_phase_7
        :fill_in_valid_loan_entry_details_phase_6

  alias :fill_in_valid_loan_entry_details_phase_8
        :fill_in_valid_loan_entry_details_phase_7

  def calculate_state_aid(loan)
    click_button 'State Aid Calculation'
  end

  # Offer Facility

  def fill_in_valid_loan_offer_details(loan)
    choose 'loan_offer_facility_letter_sent_true'
    fill_in 'loan_offer_facility_letter_date', with: Date.current.to_s(:screen)
  end

  # Loan Guarantee
  def fill_in_valid_loan_guarantee_details(fields = {})
    fields.reverse_merge!(initial_draw_date: Date.current.to_s(:screen))

    choose 'loan_guarantee_received_declaration_true'
    choose 'loan_guarantee_signed_direct_debit_received_true'
    choose 'loan_guarantee_first_pp_received_true'
    fill_in 'loan_guarantee_initial_draw_date', with: fields[:initial_draw_date]
  end

  # Loan Demand to Borrower
  def fill_in_valid_demand_to_borrower_details
    fill_in(
      "loan_demand_to_borrower_borrower_demand_outstanding",
      with: "9000"
    )
    fill_in 'loan_demand_to_borrower_amount_demanded', with: '10000'
    fill_in 'loan_demand_to_borrower_borrower_demanded_on', with: Date.current.to_s(:screen)
  end

  # Loan Recovery
  def fill_in_valid_efg_recovery_details
    fill_in 'recovery_recovered_on', with: Date.current.to_s(:screen)
    fill_in "recovery_outstanding_prior_non_efg_debt", with: "£300000.00"
    fill_in "recovery_outstanding_subsequent_non_efg_debt", with: "£100000.00"
    fill_in 'recovery_non_linked_security_proceeds', with: "325000.00"
    fill_in 'recovery_linked_security_proceeds', with: "£50,000"
  end

  def fill_in_valid_sflg_recovery_details
    fill_in 'recovery_recovered_on', with: Date.current.to_s(:screen)
    fill_in 'recovery_total_liabilities_behind', with: '£123'
    fill_in 'recovery_total_liabilities_after_demand', with: '£234'
    fill_in 'recovery_additional_interest_accrued', with: '£345'
    fill_in 'recovery_additional_break_costs', with: '£456'
  end

  # User Management
  def navigate_cfe_admin_to_lender_admins_for_lender(lender)
    visit root_path

    click_link 'Manage Lenders'

    within(:css, "tr#lender_#{lender.id}") do
      click_link 'Lender Admins'
    end
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelpers, type: :request
end
