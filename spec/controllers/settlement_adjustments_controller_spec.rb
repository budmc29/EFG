require "rails_helper"

describe SettlementAdjustmentsController do
  let(:loan) { FactoryGirl.create(:loan) }

  describe "GET new" do
    def dispatch
      get :new, loan_id: loan.id
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
    it_behaves_like "rescue_from IncorrectLoanStateError controller" do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
    end
  end

  describe "POST create" do
    def dispatch
      post :create, loan_id: loan.id
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
    it_behaves_like "rescue_from IncorrectLoanStateError controller" do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
    end
  end
end
