require 'spec_helper'

describe LoanReportsController do

  describe "#new" do

    def dispatch
      get :new
    end

    context 'with lender user' do
      let(:current_user) { FactoryGirl.create(:lender_user) }

      before { sign_in(current_user) }

      it "should allow access" do
        dispatch
        response.should be_success
      end
    end

    context 'with cfe user' do
      let(:current_user) { FactoryGirl.create(:cfe_user) }

      before { sign_in(current_user) }

      it "should allow access" do
        dispatch
        response.should be_success
      end
    end

    context 'when not a cfe or lender user' do
      let(:current_user) { FactoryGirl.create(:premium_collector_user) }

      before { sign_in(current_user) }

      it "should not allow access" do
        expect {
          dispatch
        }.to raise_error(Canable::Transgression)
      end
    end

  end

  describe "#create" do

    let(:loan) { FactoryGirl.create(:loan, :eligible) }

    def dispatch(params = {})
      post :create, loan_report: params
    end

    context 'with lender user' do
      let(:lender) { loan.lender }

      let(:current_user) { FactoryGirl.create(:lender_user, lender: lender) }

      let(:loan2) { FactoryGirl.create(:loan, :eligible) }

      before { sign_in(current_user) }

      it "should allow access" do
        dispatch
        response.should be_success
      end

      it "should raise exception when trying to access loans belonging to a different lender" do
        expect {
          dispatch(lender_ids: [ loan.lender.id, loan2.lender.id ])
        }.to raise_error(LoanReport::LenderNotAllowed)
      end

      it "should set loan scheme to 'E' when current user's lender can only access EFG scheme loans" do
        lender.loan_scheme = Lender::EFG_SCHEME
        report = double(LoanReport, 'valid?' => false)

        LoanReport.
          should_receive(:new).
          with({ "loan_scheme" => Lender::EFG_SCHEME, "allowed_lender_ids" => [ lender.id ] }).
          and_return(report)

        dispatch(loan_scheme: 'S')
      end
    end

    context 'with cfe user' do
      let(:current_user) { FactoryGirl.create(:cfe_user) }

      before { sign_in(current_user) }

      it "should allow access" do
        dispatch
        response.should be_success
      end
    end

    context 'when not a cfe or lender user' do
      let(:current_user) { FactoryGirl.create(:premium_collector_user) }

      before { sign_in(current_user) }

      it "should not allow access" do
        expect {
          dispatch
        }.to raise_error(Canable::Transgression)
      end
    end

  end

end
