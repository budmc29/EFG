if ENV['LENDER_SUPPORT_EMAIL'].blank?
  raise 'Required environment variable LENDER_SUPPORT_EMAIL is not set'
else
  EFG::Application.config.cfe_support_email= ENV['LENDER_SUPPORT_EMAIL']
end
