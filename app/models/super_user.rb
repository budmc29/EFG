class SuperUser < User
  include SuperUserPermissions

  def lender
    nil
  end
end
