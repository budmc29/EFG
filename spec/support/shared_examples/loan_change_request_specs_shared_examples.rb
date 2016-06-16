shared_examples_for "loan change on loan with capital repayment holiday" do
  context "loan with capital repayment holiday" do
    before do
      premium_schedule = loan.premium_schedules.last
      premium_schedule.initial_capital_repayment_holiday = 6
      premium_schedule.save!
    end

    it "removes capital repayment holiday duration in new premium schedule" do
      dispatch

      loan.reload
      premium_schedule = loan.premium_schedules.last!
      expect(premium_schedule.initial_capital_repayment_holiday).to eq(0)
    end
  end
end

shared_examples_for "loan change on loan with no premium schedule" do
  context "loan has no premium schedule" do
    before do
      loan.premium_schedules.destroy_all
      expect(loan.premium_schedules).to be_empty
    end

    it "creates a new premium schedule based on the loan change data" do
      dispatch

      loan.reload
      expect(loan.premium_schedules.count).to eq(1)
    end
  end
end
