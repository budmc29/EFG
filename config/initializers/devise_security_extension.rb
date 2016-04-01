# We're still using attr_accessible instead of strong parameters
# Allow devise_security_extension to mass assign OldPassword
# otherwise comparing new password with old password doesn't work
# OldPassword.send(:attr_accessible, :encrypted_password, :password_salt)
