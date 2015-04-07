require 'spec_helper'
require 'csv'

describe RecoveriesReportCsvExport do
  let!(:recovery1) { FactoryGirl.create(:recovery, :realised, recovered_on: 1.day.ago.to_date) }
  let!(:recovery2) { FactoryGirl.create(:recovery, :unrealised, recovered_on: 2.day.ago.to_date) }
  let(:loan1) { recovery1.loan }
  let(:loan2) { recovery2.loan }
  let(:lender1) { recovery1.loan.lender }
  let(:lender2) { recovery2.loan.lender }
  let(:report_recoveries) { RecoveriesReport.new(3.days.ago.to_date, Date.today, Lender.all).recoveries }

  subject(:export) { RecoveriesReportCsvExport.new(report_recoveries) }

  its(:fields) { should == [
      :lender_name,
      :loan_reference,
      :amount_due_to_dti,
      :recovered_on,
      :realised,
    ]
  }

  its(:generate) { should == %Q[Lender Name,Loan Reference,Amount,Recovered On,Realised?
#{lender1.name},#{loan1.reference},#{recovery1.amount_due_to_dti},#{recovery1.recovered_on},1
#{lender2.name},#{loan2.reference},#{recovery2.amount_due_to_dti},#{recovery2.recovered_on},0
] }

end