require "rails_helper"

describe StatusAmendmentsController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe "#new" do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
    it_behaves_like "rescue_from IncorrectLoanStateError controller" do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
      let(:loan_state) { Loan::Eligible }
    end
  end

  describe "#create" do
    def dispatch(params = {})
      post :create, {
        loan_id: loan.id, loan_status_amendment: {} }.merge(params)
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
    it_behaves_like "rescue_from IncorrectLoanStateError controller" do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
      let(:loan_state) { Loan::Eligible }
    end
  end
end
