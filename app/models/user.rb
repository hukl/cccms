require 'digest/sha1'

class User < ActiveRecord::Base
  # Mixins and Plugins
  include Authentication
  include Authentication::ByPassword

  # Associations
  has_many :permissions

  # Validations
  validates_presence_of     :login
  validates_length_of       :login, :within => 1..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => Authentication.login_regex,
                            :message => Authentication.bad_login_message

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => Authentication.email_regex,
                            :message => Authentication.bad_email_message

  attr_accessible :login, :email, :password, :password_confirmation, :admin

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
  
  # Permission stuff
  
  def grant(node)
    set_permission(true, node)
  end
  
  def revoke(node)
    set_permission(false, node)
  end

  def inherit(node)    
    permission = self.permissions.for_node(node).first
    permission.destroy if permission
  end
  
  def get_permission_for(node)
    permissions = {}
    self.permissions.for_node(node).each do |permission|
      permissions[permission.identifier.to_sym] = permission.granted
    end
    permissions
  end
  
  # Checks for permission on the node and if necessary ascends the
  # nodetree until permission is found or returns false if it is not found 
  # at all.
  def has_permission?(node)
    node_permission = self.permissions.for_node(node)
    return node_permission unless node_permission.nil?

    node.ancestors.reverse.each do |p|
      local_permission = self.get_permissions_for(p)[identifier]
      unless local_permission.nil?
        return local_permission
      end
    end
    
    return false
  end
  
    private
    
    def set_permission(granted, node)    
      permission = self.permissions.for_node(node).first
      if permission
        permission.granted = granted
      else
        self.permissions.create!( :node       => node, 
                                  :granted    => granted )
      end
    end
end
