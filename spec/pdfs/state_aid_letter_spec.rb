require 'rails_helper'

describe StateAidLetter do
  include_context "State Aid Letter Content" do  
    it_behaves_like "State Aid Letter PDF"
  end
end
