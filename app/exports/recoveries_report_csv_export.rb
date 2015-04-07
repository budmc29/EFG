class RecoveriesReportCsvExport < BaseCsvExport

  def fields
    [
      :lender_name,
      :loan_reference,
      :amount_due_to_dti,
      :recovered_on,
      :realised,
    ]
  end

  private

  def translation_scope
    'csv_headers.recoveries_report'
  end

end