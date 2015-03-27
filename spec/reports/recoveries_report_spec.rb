require 'spec_helper'

describe RecoveriesReport do
  let!(:loan_realisation1) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_amount: Money.new(1_000_00),
                                                realised_on: 1.day.ago) }
  let!(:loan_realisation2) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_amount: Money.new(2_000_00),
                                                realised_on: 4.day.ago) }
  let!(:loan_realisation3) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_amount: Money.new(3_000_00),
                                                realised_on: 1.day.ago) }
  let!(:loan_realisation4) { FactoryGirl.create(:loan_realisation, :post,
                                                realised_amount: Money.new(4_000_00),
                                                realised_on: 3.day.ago) }
  let!(:loan_realisation5) { FactoryGirl.create(:loan_realisation, :pre,
                                                realised_amount: Money.new(4_000_00),
                                                realised_on: 1.day.ago) }

  let(:lender1) { loan_realisation1.realised_loan.lender }
  let(:lender2) { loan_realisation2.realised_loan.lender }
  let(:lender3) { loan_realisation3.realised_loan.lender }
  let(:lender4) { loan_realisation4.realised_loan.lender }
  let(:lender5) { loan_realisation5.realised_loan.lender }

  subject(:report) {
    RecoveriesReport.new(2.days.ago, Date.today, [lender1.id, lender2.id, lender3.id, lender4.id])
  }

  its(:realisations) { should match_array([loan_realisation1, loan_realisation3]) }

  its(:to_csv) { should ==
%Q[Loan Reference,Date of Realisation,Lender Name,Pre / Post Claim Limit
#{loan_realisation1.realised_loan.reference},#{loan_realisation1.realised_on},#{lender1.name},pre
#{loan_realisation3.realised_loan.reference},#{loan_realisation3.realised_on},#{lender3.name},post
]
  }


end
