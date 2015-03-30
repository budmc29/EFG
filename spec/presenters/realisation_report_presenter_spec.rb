require 'spec_helper'

describe RealisationReportPresenter do
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

  let(:loan1) { loan_realisation1.realised_loan }
  let(:loan2) { loan_realisation2.realised_loan }
  let(:loan3) { loan_realisation3.realised_loan }
  let(:loan4) { loan_realisation4.realised_loan }
  let(:loan5) { loan_realisation5.realised_loan }

  let(:lender1) { loan1.lender }
  let(:lender2) { loan2.lender }
  let(:lender3) { loan3.lender }
  let(:lender4) { loan4.lender }
  let(:lender5) { loan5.lender }

  let!(:cfe_user) { FactoryGirl.create(:cfe_user) }
  let!(:lender_user) { FactoryGirl.create(:lender_user, lender: lender1) }

  describe 'with valid options' do

    let(:report_options) {
      {
        lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
        realised_on_start_date: 2.days.ago,
        realised_on_end_date: Date.today
      }
    }

    context 'when user is cfe_user' do
      subject(:report_presenter) { RealisationReportPresenter.new(cfe_user, report_options) }

      its(:allowed_lenders) {
        should match_array(cfe_user.lenders << RealisationReportPresenter::ALL_LENDERS_OPTION)
      }

      its(:record_count) { should == 2 }

      its(:lenders) { should match_array([lender1, lender2, lender3, lender4]) }

      its(:lender_ids) { should match_array([lender1.id, lender2.id, lender3.id, lender4.id]) }

      its(:realisations) { should match_array([loan_realisation1, loan_realisation3]) }

      its(:to_csv) { should ==
%Q[Loan Reference,Date of Realisation,Lender Name,Pre / Post Claim Limit
#{loan_realisation1.realised_loan.reference},#{loan_realisation1.realised_on},#{lender1.name},pre
#{loan_realisation3.realised_loan.reference},#{loan_realisation3.realised_on},#{lender3.name},post
]
      }
    end

    context 'when user is lender_user' do
      subject(:report_presenter) { RealisationReportPresenter.new(lender_user, report_options) }

      its(:allowed_lenders) { should match_array([lender_user.lender]) }

      its(:record_count) { should == 1 }

      its(:lenders) { should match_array([lender_user.lender]) }

      its(:lender_ids) { should match_array([lender_user.lender.id]) }

      its(:realisations) { should match_array([loan_realisation1]) }

      its(:to_csv) { should ==
%Q[Loan Reference,Date of Realisation,Lender Name,Pre / Post Claim Limit
#{loan_realisation1.realised_loan.reference},#{loan_realisation1.realised_on},#{lender1.name},pre
]
      }
    end

  end

end