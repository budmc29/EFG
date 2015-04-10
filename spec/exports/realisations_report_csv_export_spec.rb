require 'spec_helper'
require 'csv'

describe RealisationsReportCsvExport do
  let(:lender1) { FactoryGirl.create(:lender, name: 'Lender1') }
  let(:lender2) { FactoryGirl.create(:lender, name: 'Lender2') }
  let(:lending_limit1) { FactoryGirl.create(:lending_limit, lender: lender1, phase_id: 5) }
  let(:lending_limit2) { FactoryGirl.create(:lending_limit, lender: lender2, phase_id: 6) }
  let(:loan1) { FactoryGirl.create(:loan, :efg, :realised, lender: lender1, lending_limit: lending_limit1, reference: 'abc123') }
  let(:loan2) { FactoryGirl.create(:loan, :legacy_sflg, :realised, lender: lender2, lending_limit: lending_limit2, reference: 'xyz123') }
  let(:realisations) { report.realisations }
  let(:report) {
    RealisationsReport.new(user, {
      'end_date' => Date.new(2015, 4, 2),
      'lender_ids' => RealisationsReport::ALL_LENDERS_OPTION.id,
      'start_date' => Date.new(2015, 4, 1)
    })
  }
  let(:user) { FactoryGirl.create(:cfe_user) }

  let!(:realisation1) { FactoryGirl.create(:loan_realisation, :pre,  realised_amount: Money.new(101_00), realised_loan: loan1, realised_on: Date.new(2015,4,1)) }
  let!(:realisation2) { FactoryGirl.create(:loan_realisation, :post, realised_amount: Money.new(202_99), realised_loan: loan2, realised_on: Date.new(2015,4,2)) }

  subject { RealisationsReportCsvExport.new(realisations) }

  its(:generate) { should == 'Lender Name,Loan Reference,Loan Scheme,Loan Phase,Realised On,Realised Amount,Post Claim Limit?
Lender1,abc123,EFG,5,2015-04-01,101.00,pre
Lender2,xyz123,Legacy,6,2015-04-02,202.99,post
' }
end
