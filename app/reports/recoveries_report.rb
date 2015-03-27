require 'csv'

class RecoveriesReport

  attr_reader :recovered_on_start_date, :recovered_on_end_date, :lender_ids

  def initialize(recovered_on_start_date, recovered_on_end_date, lender_ids)
    @recovered_on_start_date = recovered_on_start_date
    @recovered_on_end_date = recovered_on_end_date
    @lender_ids = lender_ids
  end

  def realisations
    @realisations ||= LoanRealisation
      .where(realised_on: recovered_on_start_date..recovered_on_end_date)
      .joins(:realised_loan)
      .where('loans.lender_id' => lender_ids)
  end

  def to_csv
    CSV.generate do |csv|
      csv << ['Loan Reference', 'Date of Realisation', 'Lender Name', 'Pre / Post Claim Limit']
      realisations.each do |r|
        csv << [
          r.realised_loan.reference,
          r.realised_on,
          r.realised_loan.lender.name,
          r.post_claim_limit ? 'post' : 'pre'
        ]
      end
    end
  end

end
