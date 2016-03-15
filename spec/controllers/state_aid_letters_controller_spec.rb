require "rails_helper"

describe StateAidLettersController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { sign_in(current_user) }

  describe "GET #new" do
    def dispatch
      get :new, loan_id: loan.id
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser Lender-scoped controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end

  describe "POST #create" do
    def dispatch
      post :create, loan_id: loan.id
    end

    it_behaves_like "PDF controller action"
    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser Lender-scoped controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end
end
