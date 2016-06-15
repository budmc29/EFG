# Database records in various tables that existed prior to migrating to this
# app had their `created_at` and `updated_at` set to 0000-00-00 00:00:00.
#
# When the extractor runs it converts these datetime to the current datetime
# (i.e. the time the extractor runs). This causes problems when working with the
# data locally, like when querying data by creation date.
#
# This sets the zeroed out values to midnight of the morning when this app was
# first deployed to production.
PRE_LAUNCH_DATETIME = "2012-10-20 00:00:00"

tables = %w(admin_audits data_corrections ded_codes demand_to_borrowers invoices
            lending_limits loan_ineligibility_reasons loan_modifications
            loan_securities loan_state_changes premium_schedules user_audits)

tables.each do |table|
  ActiveRecord::Base.connection.execute(
    "UPDATE #{table}
     SET created_at = '#{PRE_LAUNCH_DATETIME}'
     WHERE created_at = '0000-00-00 00:00:00'"
  )

  ActiveRecord::Base.connection.execute(
    "UPDATE #{table}
     SET updated_at = '#{PRE_LAUNCH_DATETIME}'
     WHERE updated_at = '0000-00-00 00:00:00'"
  )
end
