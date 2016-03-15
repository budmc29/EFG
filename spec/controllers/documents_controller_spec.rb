require 'rails_helper'

describe DocumentsController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { sign_in(current_user) }

  describe '#information_declaration' do
    def dispatch
      get :information_declaration, id: loan.id
    end

    it_behaves_like "PDF controller action"
    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#data_protection_declaration' do
    def dispatch
      get :data_protection_declaration, id: loan.id
    end

    it_behaves_like "PDF controller action"
    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
