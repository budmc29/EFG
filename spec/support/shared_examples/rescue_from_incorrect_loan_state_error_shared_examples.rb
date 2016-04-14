shared_examples_for 'rescue_from IncorrectLoanStateError controller' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  let(:loan_state) { "incorrect state" }

  before do
    loan.update_attribute(:state, loan_state)
    sign_in(current_user)
  end

  it "should redirect to the loan" do
    dispatch
    expect(response).to redirect_to(loan_path(loan))
  end
end
