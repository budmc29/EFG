class RealisationsReportCsvExport < BaseCsvExport

  def fields
    [
      :lender_name,
      :loan_reference,
      :scheme,
      :loan_phase,
      :realised_on,
      :realised_amount,
      :post_claim_limit
    ]
  end

  private

  def formats
    @formats ||= {
      FalseClass => 'pre',
      TrueClass => 'post'
    }
  end

  def translation_scope
    'csv_headers.realisations_report'
  end

end
