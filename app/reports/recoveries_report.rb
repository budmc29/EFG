require 'csv'

class RecoveriesReport

  attr_reader :recovered_on_start_date, :recovered_on_end_date, :lender_ids

  def initialize(recovered_on_start_date, recovered_on_end_date, lender_ids)
    @recovered_on_start_date = recovered_on_start_date
    @recovered_on_end_date = recovered_on_end_date
    @lender_ids = lender_ids
  end

  def recoveries
    @recoveries ||= Recovery
      .joins(:loan => :lender)
      .where(recovered_on: recovered_on_start_date..recovered_on_end_date,
            'loans.lender_id' => lender_ids)
      .select('recoveries.*, loans.reference AS loan_reference, lenders.name AS lender_name, realise_flag AS realised')
  end

end
