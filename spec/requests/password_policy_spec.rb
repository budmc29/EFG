require 'spec_helper'

describe 'password policy' do

  describe 'expiry' do

    %w(
      auditor_user
      cfe_admin
      cfe_user
      lender_admin
      lender_user
      premium_collector_user
    ).each do |user_type|

      it "should be unable to login as a #{user_type.humanize} when the password has expired" do
        current_user = FactoryGirl.create(user_type)
        current_user.password_changed_at = current_user.password_changed_at - 91.days
        current_user.save!

        visit root_path
        submit_sign_in_form(current_user.username, current_user.password)
        page.should have_content('Your password is expired')
      end
    end
  end
end
