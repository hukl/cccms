class Permission < ActiveRecord::Base
  validates_presence_of :user_id, :node_id, :granted
  
  # Associations
  belongs_to :user
  belongs_to :node
  
  # Security
  attr_protected :user_id, :node_id, :granted # Allow no mass assignments
end
