require 'digest/sha1'

class User < ActiveRecord::Base
  # Mixins and Plugins
  include Authentication
  include Authentication::ByPassword

  # Associations
  has_many :permissions

  # Validations
  validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => Authentication.login_regex,
                            :message => Authentication.bad_login_message

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => Authentication.email_regex,
                            :message => Authentication.bad_email_message

  attr_accessible :login, :email, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password. Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # TODO: Do we really want to have downcase logins only?
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
end
