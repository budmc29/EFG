require "rails_helper"

describe AdjustmentsController do
  let(:loan) { FactoryGirl.create(:loan) }

  describe "GET index" do
    def dispatch
      get :index, loan_id: loan.id
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeAdmin-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end
end
