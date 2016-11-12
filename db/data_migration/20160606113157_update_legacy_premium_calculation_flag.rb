# PR #270 (https://git.io/FD25) duplicates premium schedules when making a loan
# change. This carries forward legacy_premium_calculation value of 1 for old
# schedules where it shouldn't (all new premium schedules should use the new
# premium schedule calculation).
#
# This restores all affected schedules since then to the correct value.
PremiumSchedule.connection.execute("
  UPDATE premium_schedules
  SET legacy_premium_calculation = 0
  WHERE created_at > '2016-04-01 00:00:00'")
