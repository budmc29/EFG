require 'spec_helper'

describe UserMailer do

  describe "#new_account_notification" do
    before do
      @user = FactoryGirl.build(:user, reset_password_token: 'abc123')
      @email = UserMailer.new_account_notification(@user)
    end

    it "should be set to be delivered to the user's email address" do
      @email.to.should == [@user.email]
    end

    it "should contain user's first name" do
      @email.body.should include(@user.first_name)
    end

    it "should contain user's username" do
      @email.body.should include(@user.username)
    end

    it "should contain link to reset password page" do
      @email.body.should include("?reset_password_token=#{@user.reset_password_token}")
    end
    
    it "should contain a link back to the home page to resend the request" do
      @email.body.should include(%Q("#{root_url}"))
    end
    
    it "should have a from header" do
      @email.from.should == [ Devise.mailer_sender ]
    end
  end

end
