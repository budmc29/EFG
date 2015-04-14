require 'spec_helper'
require 'csv'

describe RecoveriesReportCsvExport do
  let(:lender1) { FactoryGirl.create(:lender, name: "Lender 1") }
  let(:lender2) { FactoryGirl.create(:lender, name: "Lender 2") }

  let(:loan1) { FactoryGirl.create(:loan, :settled,
                  lender: lender1, reference: 'zyxwvu9876', settled_on: Date.new(2015, 3, 1) )}
  let(:loan2) { FactoryGirl.create(:loan, :settled,
                  lender: lender2, reference: 'abcde1234', settled_on: Date.new(2015, 3, 2) )}

  let!(:recovery1) { FactoryGirl.create(:recovery, :realised,
    loan: loan1, recovered_on: Date.new(2015,4,8), amount_due_to_dti: Money.new(345_89)) }
  let!(:recovery2) { FactoryGirl.create(:recovery, :unrealised,
    loan: loan2, recovered_on: Date.new(2015,4,7), amount_due_to_dti: Money.new(123_45)) }

  let(:user) { FactoryGirl.create(:cfe_user) }

  let(:report) {
    RecoveriesReport.new(user, {
      start_date: '6/4/2015',
      end_date: '9/4/2015',
      lender_ids: [lender1.id, lender2.id],
    })
  }

  subject(:export) { RecoveriesReportCsvExport.new(report.recoveries) }

  its(:generate) { should == %Q[Lender Name,Loan Reference,Amount,Recovered On,Realised?
Lender 1,zyxwvu9876,345.89,2015-04-08,realised
Lender 2,abcde1234,123.45,2015-04-07,not realised
] }

end
