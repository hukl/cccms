class Permission < ActiveRecord::Base
  # Validations
  validates_presence_of   :user_id, :node_id, :granted
  validates_inclusion_of  :granted, :in => [true, false]

  # Associations
  belongs_to :user
  belongs_to :node

  # Named scopes
  named_scope :for_node, lambda { |node| { :conditions => ['node_id = ?', (node.is_a? Node ? node.id : node)] } }
  named_scope :for_user, lambda { |user| { :conditions => ['user_id = ?', (user.is_a? User ? user.id : user)] } }
end
