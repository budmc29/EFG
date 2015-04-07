require 'spec_helper'

describe ClaimLimitCalculator do
  describe ".all_with_amount" do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:calculators) { ClaimLimitCalculator.all_with_amount([ lender ]) }

    before do
      FactoryGirl.create(:loan, :guaranteed, lender: lender)
    end

    it "returns array of claim limit calculators, excluding any with 0 amount" do
      calculators.size.should == 1
    end
  end

  describe "#cumulative_drawn_amount" do
    class ClaimLimitCalculatorSubclass < ClaimLimitCalculator
      def phase
        Phase.find(1)
      end
    end

    let(:calculator) { ClaimLimitCalculatorSubclass.new(lender) }
    let(:lender) { FactoryGirl.create(:lender) }
    let(:lending_limit) { FactoryGirl.create(:lending_limit, :phase_1, lender: lender) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: lender, lending_limit: lending_limit) }

    before do
      # We need to cater for types of LoanChange that shouldn't include an
      # amount_drawn because records already exist in the database from a time
      # before we sufficiently validated the data on the way in.
      FactoryGirl.create(:loan_change, :capital_repayment_holiday, amount_drawn: Money.new(10_00), loan: loan)
      FactoryGirl.create(:loan_change, :decrease_term, amount_drawn: Money.new(100_00), loan: loan)
      FactoryGirl.create(:loan_change, :extend_term, amount_drawn: Money.new(1_000_00), loan: loan)
      FactoryGirl.create(:loan_change, :lender_demand_satisfied, amount_drawn: Money.new(100_00), loan: loan)
      FactoryGirl.create(:loan_change, :lump_sum_repayment, amount_drawn: Money.new(10_000_00), loan: loan)
      FactoryGirl.create(:loan_change, :repayment_frequency, amount_drawn: Money.new(1_000_000_00), loan: loan)
      FactoryGirl.create(:loan_change, :reprofile_draws, amount_drawn: Money.new(100_000_00), loan: loan)
    end

    it "includes the drawn amounts for all relevant loan changes" do
      calculator.cumulative_drawn_amount.should eq(Money.new(1_111_110_00) + loan.initial_draw_change.amount_drawn)
    end
  end

  describe "#pre_claim_realisations_amount" do
    let(:calculator) { ClaimLimitCalculator.new(lender) }
    let(:lender) { FactoryGirl.create(:lender) }
    let(:lending_limit1) { FactoryGirl.create(:lending_limit, :phase_5, lender: lender) }
    let(:lending_limit2) { FactoryGirl.create(:lending_limit, :phase_5, lender: lender) }
    let(:loan1) { FactoryGirl.create(:loan, :realised, lender: lender, lending_limit: lending_limit1) }
    let(:loan2) { FactoryGirl.create(:loan, :realised, lender: lender, lending_limit: lending_limit2) }

    before do
      FactoryGirl.create(:loan_realisation, realised_loan: loan1, realised_amount: Money.new(10_00))
      FactoryGirl.create(:loan_realisation, realised_loan: loan1, realised_amount: Money.new(20_00))
      FactoryGirl.create(:loan_realisation, realised_loan: loan2, realised_amount: Money.new(50_00))

      calculator.stub(:phase).and_return(lending_limit1.phase)
    end

    it "sums the pre-claim realisations" do
      expect(calculator.pre_claim_realisations_amount).to eq(Money.new(80_00))
    end

    context "with realisation adjustments" do
      let(:lending_limit_from_another_phase) { FactoryGirl.create(:lending_limit, :phase_6, lender: lender) }
      let(:loan_from_another_phase) { FactoryGirl.create(:loan, :realised, lender: lender, lending_limit: lending_limit_from_another_phase) }

      before do
        FactoryGirl.create(:realisation_adjustment, loan: loan1, amount: Money.new(25_00))
        FactoryGirl.create(:realisation_adjustment, loan: loan_from_another_phase, amount: Money.new(25_00))
      end

      it "subtracts any realisation adjustments" do
        expect(calculator.pre_claim_realisations_amount).to eq(Money.new(55_00))
      end
    end

    context "with post-claim limit realisations" do
      before do
        FactoryGirl.create(:loan_realisation, :post, realised_loan: loan1, realised_amount: Money.new(5_00))
      end

      it "ignores post-claim limit realisations" do
        expect(calculator.pre_claim_realisations_amount).to eq(Money.new(80_00))
      end
    end
  end
end
