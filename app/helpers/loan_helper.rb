module LoanHelper

  def loan_title(title, loan)
    title << " for #{loan.reference}" if loan.reference.present?
    title
  end

  def loan_listing_title(state, scheme)
    title = state.titleize

    scheme_text = case scheme
    when 'efg'
      'EFG'
    when 'legacy_sflg'
      'Legacy SFLG'
    when 'sflg'
      'SFLG'
    end

    title << " (#{scheme_text})" if scheme_text
    title
  end

  def loan_business_name(loan)
    loan.business_name.present? ? loan.business_name : '<not assigned>'
  end

  def loan_summary(loan, &block)
    insert = block_given? ? capture(&block) : nil
    render('loans/summary', loan: loan, insert: insert)
  end

  def link_to_premium_schedule(loan)
    return unless current_user.can_view?(PremiumSchedule)

    path = loan.premium_schedule ? loan_premium_schedule_path(loan) : edit_loan_premium_schedule_path(loan)

    link_to('Generate Premium Schedule', path, class: 'btn btn-info')
  end

  def link_to_loan_entry(loan, options = {})
    if loan.created_from_transfer?
      path = new_loan_transferred_entry_path(loan)
      permission_class = TransferredLoanEntry
    else
      path = new_loan_entry_path(loan)
      permission_class = LoanEntry
    end

    link_to('Loan Entry', path, options) if current_user.can_create?(permission_class)
  end

  def for_loan_in_categories(loan, *loan_category_ids)
    yield if block_given? && loan_category_ids.include?(loan.loan_category_id)
  end

  def loan_state_history_includes?(loan, *states)
    (loan.state_history & states).size > 0
  end

  def loan_state_options(states)
    states.map { |state| [state.humanize, state] }.unshift(['All states', nil])
  end

  def loan_ineligible?(loan)
    [Loan::Rejected, Loan::Incomplete].include?(loan.state) && loan.ineligibility_reasons.present?
  end

  def loan_reason_options(reasons)
    reasons.map do |r| 
      array = [r.name, r.id] 
      if r.notice_text.present?
        array << { data: { content: r.notice_text, toggle: "popover" } }
      end
      array
    end
  end

end
