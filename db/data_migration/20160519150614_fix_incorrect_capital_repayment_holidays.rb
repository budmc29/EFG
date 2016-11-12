# Fix incorrect capital repayment holiday in premium schedules
# affected by bug fixed in 909b94
PremiumSchedule.where(id: [52848, 52984, 52985, 52972, 52970, 53105, 52902]).
  update_all(initial_capital_repayment_holiday: 0)
