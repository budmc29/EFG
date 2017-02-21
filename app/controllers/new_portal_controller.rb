class NewPortalController < ApplicationController
  skip_before_filter :redirect_user_on_new_legal_agreement

  def show
  end
end
