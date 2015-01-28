shared_examples_for "loan change" do
  context "loan with tranche drawdowns" do
    before do
      premium_schedule = loan.premium_schedules.last

      premium_schedule.second_draw_amount = Money.new(10_000_00)
      premium_schedule.second_draw_months = 6

      premium_schedule.third_draw_amount = Money.new(5_000_00)
      premium_schedule.third_draw_months = 12

      premium_schedule.fourth_draw_amount = Money.new(2_000_00)
      premium_schedule.fourth_draw_months = 24

      premium_schedule.save!
    end

    it "retains tranche drawdowns in new premium schedule" do
      dispatch

      loan.reload
      premium_schedule = loan.premium_schedules.last!
      expect(premium_schedule.second_draw_amount).to eq(Money.new(10_000_00))
      expect(premium_schedule.second_draw_months).to eq(6)
      expect(premium_schedule.third_draw_amount).to eq(Money.new(5_000_00))
      expect(premium_schedule.third_draw_months).to eq(12)
      expect(premium_schedule.fourth_draw_amount).to eq(Money.new(2_000_00))
      expect(premium_schedule.fourth_draw_months).to eq(24)
    end
  end
end
