require 'spec_helper'

describe User do
  it "requires passwords to be suitably strong" do
    user = FactoryGirl.build(:user, :password => "aaaaaa")
    user.valid?.should == true
    user.save!

    # REVIEW: slightly hokey - we don't validate the password for new records. Not sure if we want to revisit that?
    user.first_name = user.last_name
    user.valid?.should == false
    user.errors[:password].should == [I18n.t('errors.messages.weak_password')]
  end
end