require 'rails_helper'

describe RevertDemandedLoansController do
  let(:loan) { FactoryGirl.create(:loan, :demanded) }

  describe '#create' do
    def dispatch
      post :create, loan_id: loan.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'rescue_from IncorrectLoanStateError controller'
  end
end
