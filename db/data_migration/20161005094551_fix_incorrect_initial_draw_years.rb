# Validation has been added to ensure the initial draw year is set to a
# realistic value (i.e. within five years). However, a number of premium
# schedules exist with invalid values (e.g. 5009, 300514). This fixes those
# values by setting them to the year of the initial draw change, or if that
# does not exist, to the year the loan record was created.

PremiumSchedule.transaction do
  PremiumSchedule.where("initial_draw_year > 2021").each do |ps|
    initial_draw_change = ps.loan.initial_draw_change
    new_initial_draw_year = if initial_draw_change
                              initial_draw_change.date_of_change.year
                            else
                              ps.loan.created_at.year
                            end
    ps.update_column(:initial_draw_year, new_initial_draw_year)
    puts "Updated premium schedule #{ps.id}"
  end
end
