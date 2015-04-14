class RecoveriesReportCsvExport < BaseCsvExport

  def fields
    [
      :lender_name,
      :loan_reference,
      :amount_due_to_dti,
      :recovered_on,
      :realise_flag,
    ]
  end

  private

  def formats
    @formats ||= {
      FalseClass => 'not realised',
      TrueClass => 'realised'
    }
  end

  def translation_scope
    'csv_headers.recoveries_report'
  end

end
