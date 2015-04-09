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

  def formats
    @formats ||= {
      Fixnum => ->(n){
        case n
        when 1 then "realised"
        when 0 then "not realised"
        end
      }
    }
  end

  def translation_scope
    'csv_headers.recoveries_report'
  end

end