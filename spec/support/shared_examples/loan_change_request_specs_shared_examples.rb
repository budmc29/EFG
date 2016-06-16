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
