class LoanReportCsvRow
  def initialize(row, loan_security_types)
    @row = row
    @loan_security_types = loan_security_types
  end

  def to_a
    [
      row['reference'],
      LegalForm.find_by_id(row['legal_form_id']).try(:name),
      row['postcode'],
      Money.new(row['turnover'] || 0).to_s,
      row['trading_date'].try(:strftime, '%d-%m-%Y'),
      row['sic_code'],
      row['sic_desc'],
      row['sic_parent_desc'],
      LoanReason.find_by_id(row['reason_id']).try(:name),
      Money.new(row['amount'] || 0).to_s,
      row.guarantee_rate.to_s,
      row.premium_rate.to_s,
      row['lending_limit_name'],
      row['lender_organisation_reference_code'],
      LoanStateFormatter.humanize(row['state']),
      row['repayment_duration'],
      RepaymentFrequency.find_by_id(row['repayment_frequency_id']).try(:name),
      row['maturity_date'].try(:strftime, '%d-%m-%Y'),
      row['generic1'],
      row['generic2'],
      row['generic3'],
      row['generic4'],
      row['generic5'],
      CancelReason.find_by_id(row['cancelled_reason_id']).try(:name),
      row['cancelled_comment'],
      row['cancelled_on'].try(:strftime, '%d-%m-%Y'),
      row['facility_letter_date'].try(:strftime, '%d-%m-%Y'),
      row['initial_draw_amount'] ? Money.new(row['initial_draw_amount']).to_s : '',
      row['initial_draw_date'].try(:strftime, '%d-%m-%Y'),
      row['borrower_demanded_on'].try(:strftime, '%d-%m-%Y'),
      Money.new(row['amount_demanded'] || 0).to_s,
      row['repaid_on'].try(:strftime, '%d-%m-%Y'),
      row['no_claim_on'].try(:strftime, '%d-%m-%Y'),
      row['dti_demanded_on'].try(:strftime, '%d-%m-%Y'),
      Money.new(row['dti_demand_outstanding'] || 0).to_s,
      Money.new(row['dti_amount_claimed'] || 0).to_s,
      Money.new(row['dti_interest'] || 0).to_s,
      row['ded_code_group_description'],
      row['ded_code_category_description'],
      row['ded_code_code_description'],
      row['ded_code_code'],
      row['dti_reason'],
      Money.new(row['dti_break_costs'] || 0).to_s,
      row['last_recovery_on'] ? row['last_recovery_on'].strftime('%d-%m-%Y') : '',
      Money.new(row['total_recoveries'] || 0).to_s,
      row['last_realisation_at'] ? row['last_realisation_at'].try(:in_time_zone).strftime('%d-%m-%Y') : '',
      Money.new(row['total_loan_realisations'] || 0).to_s,
      Money.new(row['total_amount_drawn'] || 0).to_s,
      Money.new(row['total_lump_sum_repayment'] || 0).to_s,
      row['created_by_username'],
      row['created_at'].try(:in_time_zone).try(:strftime, "%d-%m-%Y %I:%M %p"),
      row['modified_by_username'],
      row['updated_at'].try(:in_time_zone).try(:strftime, '%d-%m-%Y'),
      row['remove_guarantee_on'].try(:strftime, '%d-%m-%Y'),
      Money.new(row['remove_guarantee_outstanding_amount'] || 0).to_s,
      row['remove_guarantee_reason'],
      Money.new(row['state_aid'] || 0).to_s, # if SIC is notified aid output 'not applicable'
      row['settled_on'].try(:strftime, '%d-%m-%Y'),
      row['invoice_reference'],
      LoanCategory.find_by_id(row['loan_category_id']).try(:name),
      LoanSubCategory.find_by_id(row['loan_sub_category_id']).try(:name),
      InterestRateType.find_by_id(row['interest_rate_type_id']).try(:name),
      row['interest_rate'],
      Money.new(row['fees'] || 0).to_s,
      boolean_as_text(row['private_residence_charge_required']),
      boolean_as_text(row['personal_guarantee_required']),
      row['security_proportion'],
      Money.new(row['current_refinanced_amount'] || 0).to_s,
      Money.new(row['final_refinanced_amount'] || 0).to_s,
      row['original_overdraft_proportion'],
      loan_security_types.collect(&:name).join(' / '),
      row['refinance_security_proportion'],
      Money.new(row['overdraft_limit'] || 0).to_s,
      boolean_as_text(row['overdraft_maintained']),
      Money.new(row['invoice_discount_limit'] || 0).to_s,
      row['invoice_prepayment_coverage_percentage'],
      row['invoice_prepayment_topup_percentage'],
      row['lender_reference'],
      Money.new(row['settled_amount'] || 0).to_s,
      Money.new(row['cumulative_pre_claim_limit_realised_amount'] || 0).to_s,
      Money.new(row['cumulative_post_claim_limit_realised_amount'] || 0).to_s,
      Money.new(row["cumulative_pre_claim_realisation_adjustments"] || 0).to_s,
      Money.new(row["cumulative_settlement_adjustments"] || 0).to_s,
      scheme_name(row['loan_scheme'], row['loan_source']),
      phase_name(row['lending_limit_phase_id']),
      row['sub_lender'],
      row["status_amendment_type"],
      row["status_amendment_notes"],
      row["repayment_profile"].try(:humanize),
      row["fixed_repayment_amount"] ? Money.new(row["fixed_repayment_amount"]).to_s : nil,
    ]
  end

  private

  attr_reader :row, :loan_security_types

  def boolean_as_text(bool)
    bool ? 'Yes' : 'No'
  end

  def scheme_name(scheme, source)
    LoanTypes.find(scheme, source).name
  end

  def phase_name(phase_id)
    Phase.find_by_id(phase_id).try(:name)
  end
end
