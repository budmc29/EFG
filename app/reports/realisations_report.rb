class RealisationsReport
  attr_reader :realised_on_start_date, :realised_on_end_date, :lender_ids

  def initialize(realised_on_start_date, realised_on_end_date, lender_ids)
    @realised_on_start_date = realised_on_start_date
    @realised_on_end_date = realised_on_end_date
    @lender_ids = lender_ids
  end

  def realisations
    @realisations ||= LoanRealisation
      .joins(:realised_loan => :lender)
      .where(realised_on: realised_on_start_date..realised_on_end_date,
            'loans.lender_id' => lender_ids)
      .select('loan_realisations.*, loans.reference AS loan_reference, lenders.name AS lender_name')
  end
end
