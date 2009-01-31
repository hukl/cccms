class Page < ActiveRecord::Base
  
  belongs_to :node
  
  acts_as_list :column => :revision, :scope => :node_id
  
end
