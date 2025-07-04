class Account < ActiveRecord::Base

  def password=(str)
    write_attribute("password", str)
  end

  def password
    "********"
  end

  def self.authenticate(l, p)
    find_by_login_and_password(l, p)
  end
end