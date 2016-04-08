require "rails_helper"

describe EfgRecoveryCalculator do
  context "with linked and non-linked securities" do
    it "calculates the realisations attributable amount" do
      loan = FactoryGirl.build(
        :loan, :settled,
        amount: Money.new(100_000_00),
        dti_demand_outstanding: Money.new(100_000_00),
        dti_amount_claimed: Money.new(0))

      recovery = setup_recovery(
        loan: loan,
        outstanding_prior_non_efg_debt: Money.new(300_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(100_000_00),
        non_linked_security_proceeds: Money.new(200_000_00),
        linked_security_proceeds: Money.new(50_000_00),
      )
      calculator = described_class.new(recovery)

      expect(calculator.realisations_attributable).to eq(Money.new(50_000_00))
    end

    it "calculates the amount due to DTI" do
      loan = FactoryGirl.build(
        :loan, :settled,
        amount: Money.new(100_000_00),
        dti_demand_outstanding: Money.new(100_000_00),
        dti_amount_claimed: Money.new(0))

      recovery = setup_recovery(
        loan: loan,
        outstanding_prior_non_efg_debt: Money.new(300_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(100_000_00),
        non_linked_security_proceeds: Money.new(200_000_00),
        linked_security_proceeds: Money.new(50_000_00),
      )
      calculator = described_class.new(recovery)

      expect(calculator.amount_due_to_dti).to eq(Money.new(0))
    end
  end

  context "with no linked security proceeds" do
    it "calculates the realisations attributable amount" do
      recovery = setup_recovery(
        outstanding_prior_non_efg_debt: Money.new(2_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(0),
        non_linked_security_proceeds: Money.new(1_000_00),
        linked_security_proceeds: Money.new(0),
      )
      calculator = described_class.new(recovery)

      expect(calculator.realisations_attributable).to eq(Money.new(0))
    end

    it "calculates the amount due to DTI" do
      recovery = setup_recovery(
        outstanding_prior_non_efg_debt: Money.new(2_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(0),
        non_linked_security_proceeds: Money.new(1_000_00),
        linked_security_proceeds: Money.new(0),
      )
      calculator = described_class.new(recovery)

      expect(calculator.amount_due_to_dti).to eq(Money.new(0))
    end
  end

  context "with remaining non-linked securities" do
    it "reduces the realisations attributable relative to non-EFG debt" do
      loan = FactoryGirl.build(
        :loan, :settled,
        amount: Money.new(100_000_00),
        dti_demand_outstanding: Money.new(100_000_00),
        dti_amount_claimed: Money.new(0))

      recovery = setup_recovery(
        loan: loan,
        outstanding_prior_non_efg_debt: Money.new(300_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(100_000_00),
        non_linked_security_proceeds: Money.new(325_000_00),
        linked_security_proceeds: Money.new(50_000_00),
      )
      calculator = described_class.new(recovery)

      expect(calculator.realisations_attributable).to eq(Money.new(58_333_33))
    end

    it "reduces the amount due to DTI relative to non-EFG debt" do
      loan = FactoryGirl.build(
        :loan, :settled,
        amount: Money.new(100_000_00),
        dti_demand_outstanding: Money.new(100_000_00),
        dti_amount_claimed: Money.new(0))

      recovery = setup_recovery(
        loan: loan,
        outstanding_prior_non_efg_debt: Money.new(300_000_00),
        outstanding_subsequent_non_efg_debt: Money.new(100_000_00),
        non_linked_security_proceeds: Money.new(325_000_00),
        linked_security_proceeds: Money.new(50_000_00),
      )
      calculator = described_class.new(recovery)

      expect(calculator.amount_due_to_dti).to eq(Money.new(6_250_00))
    end
  end

  def setup_recovery(opts = {})
    loan = opts[:loan]
    outstanding_prior_non_efg_debt = opts.fetch(:outstanding_prior_non_efg_debt)
    outstanding_subsequent_non_efg_debt = opts.fetch(
      :outstanding_subsequent_non_efg_debt)
    non_linked_security_proceeds = opts.fetch(:non_linked_security_proceeds)
    linked_security_proceeds = opts.fetch(:linked_security_proceeds)

    loan ||= FactoryGirl.build(
      :loan, :settled,
      amount: Money.new(50_000_00),
      dti_demand_outstanding: Money.new(25_000_00),
      dti_amount_claimed: Money.new(18_750_00))

    FactoryGirl.build(
      :recovery,
      loan: loan,
      outstanding_prior_non_efg_debt: outstanding_prior_non_efg_debt,
      outstanding_subsequent_non_efg_debt: outstanding_subsequent_non_efg_debt,
      non_linked_security_proceeds: non_linked_security_proceeds,
      linked_security_proceeds: linked_security_proceeds)
  end
end
