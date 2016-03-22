require "rails_helper"

describe Phase7ClaimLimitCalculator do
  let(:lending_limit1) do
    FactoryGirl.create(:lending_limit, :phase_7, lender: lender)
  end

  let(:lending_limit2) do
    FactoryGirl.create(:lending_limit, :phase_7, lender: lender)
  end

  it_behaves_like "phase 6 claim limit calculator"
end
