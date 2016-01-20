require 'spec_helper'

feature "a user resetting their password" do
  before { ActionMailer::Base.deliveries.clear }

  specify "mails them a reset link, reset's their password and logs them in" do
    user = FactoryGirl.create(:lender_user, username: 'batman', first_name: 'Bruce', last_name: 'Wayne')

    visit new_user_password_path
    page.should have_content('Reset Your Password')

    fill_in 'user[username]', with: 'batman'
    click_button 'Send Reset Instructions'

    ActionMailer::Base.deliveries.size.should == 1

    reset_password_email = ActionMailer::Base.deliveries.last
    reset_password_uris = URI.extract(reset_password_email.body.to_s, ['http'])
    reset_password_uri = URI.parse(reset_password_uris.first)

    visit reset_password_uri.request_uri

    page.should have_content('Set Your Password')

    fill_in 'user[password]', with: 'bounds2540{uprightly'
    fill_in 'user[password_confirmation]', with: 'bounds2540{uprightly'
    click_button 'Change Password'

    page.should_not have_content('Reset password token is invalid')
    page.should have_content('Welcome Bruce')
  end
end
