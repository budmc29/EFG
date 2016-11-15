require "rails_helper"

describe SicCodesController do
  let(:sic_code) { create(:sic_code) }

  describe "#index" do
    def dispatch(params = {})
      get :index, params
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end

  describe "#new" do
    def dispatch(params = {})
      get :new, params
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end

  describe "#create" do
    def dispatch(params = {})
      post :create, params
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end

  describe "#edit" do
    def dispatch(params = {})
      get :edit, { id: sic_code.id }.merge(params)
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end

  describe "#update" do
    def dispatch(params = {})
      put :update, { id: sic_code.id }.merge(params)
    end

    it_behaves_like "AuditorUser-restricted controller"
    it_behaves_like "CfeUser-restricted controller"
    it_behaves_like "LenderAdmin-restricted controller"
    it_behaves_like "LenderUser-restricted controller"
    it_behaves_like "PremiumCollectorUser-restricted controller"
  end
end
