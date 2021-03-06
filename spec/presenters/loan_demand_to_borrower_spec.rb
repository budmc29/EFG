require 'rails_helper'

describe LoanDemandToBorrower do
  describe 'validations' do
    let(:loan_demand_to_borrower) { FactoryGirl.build(:loan_demand_to_borrower) }
    let(:loan) { loan_demand_to_borrower.loan }

    before do
      loan.save!

      FactoryGirl.create(:initial_draw_change,
        amount_drawn: Money.new(5_000_00),
        date_of_change: Date.new(2012, 1, 2),
        loan: loan
      )
    end

    it 'should have a valid factory' do
      expect(loan_demand_to_borrower).to be_valid
    end

    it 'should be invalid without a borrower demanded date' do
      loan_demand_to_borrower.borrower_demanded_on = ''
      expect(loan_demand_to_borrower).not_to be_valid
    end

    it 'should be invalid without amount_demanded' do
      loan_demand_to_borrower.amount_demanded = ''
      expect(loan_demand_to_borrower).not_to be_valid
    end

    it "must have an outstanding facility amount" do
      loan_demand_to_borrower.borrower_demand_outstanding = nil
      expect(loan_demand_to_borrower).not_to be_valid
    end

    it 'cannot have a borrower_demanded_on before the loan initial draw date' do
      loan_demand_to_borrower.borrower_demanded_on = Date.new(2012, 1, 1)
      expect(loan_demand_to_borrower).not_to be_valid
    end

    it 'requires borrower_demanded_on to not be in the future' do
      loan_demand_to_borrower.borrower_demanded_on = 1.day.from_now
      expect(loan_demand_to_borrower).not_to be_valid

      loan_demand_to_borrower.borrower_demanded_on = Date.current
      expect(loan_demand_to_borrower).to be_valid
    end

    it "must have an outstanding balance less than or equal to
        the demanded amount" do
      loan_demand_to_borrower.borrower_demand_outstanding = Money.new(10_001_00)
      loan_demand_to_borrower.amount_demanded = Money.new(10_000_00)
      expect(loan_demand_to_borrower).not_to be_valid

      loan_demand_to_borrower.borrower_demand_outstanding = Money.new(10_000_00)
      loan_demand_to_borrower.amount_demanded = Money.new(10_000_00)
      expect(loan_demand_to_borrower).to be_valid
    end
  end

  describe '#save' do
    let(:loan_demand_to_borrower) {
      FactoryGirl.build(:loan_demand_to_borrower,
        amount_demanded: '£10,000',
        borrower_demanded_on: '5/6/07',
        borrower_demand_outstanding: "£9,000"
      )
    }
    let(:loan) { loan_demand_to_borrower.loan }

    before do
      loan.save!

      FactoryGirl.create(:initial_draw_change,
        amount_drawn: Money.new(5_000_00),
        date_of_change: Date.new(2007),
        loan: loan
      )
    end

    it 'creates a corresponding DemandToBorrower' do
      expect {
        expect(loan_demand_to_borrower.save).to eq(true)
      }.to change(DemandToBorrower, :count).by(1)

      demand_to_borrower = DemandToBorrower.last!
      expect(demand_to_borrower.loan).to eq(loan)
      expect(demand_to_borrower.date_of_demand).to eq(Date.new(2007, 6, 5))
      expect(demand_to_borrower.demanded_amount).to eq(Money.new(10_000_00))
      expect(demand_to_borrower.outstanding_facility_amount).
        to eq(Money.new(9_000_00))
    end

    it "updates the loan" do
      loan_demand_to_borrower.save
      loan.reload

      expect(loan.amount_demanded).to eq(Money.new(10_000_00))
      expect(loan.borrower_demanded_on).to eq(Date.new(2007, 6, 5))
      expect(loan.borrower_demand_outstanding).to eq(Money.new(9_000_00))
    end
  end
end
