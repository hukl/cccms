class Node < ActiveRecord::Base
  acts_as_nested_set
  
  # returns array with pages up to root excluding root
  def path_to_root
    parent.nil? && [slug] || parent.path_to_root.push(slug)
  end
  
  def update_unique_name
    path = self.path_to_root[1..-1]
    self.unique_name = path.join("/")
  end
end
