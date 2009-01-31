class Node < ActiveRecord::Base
  acts_as_nested_set
  
  has_many :pages, :order => "revision ASC"
  
  # Class methods
  
  def self.find_page path, revision = :current
    
    node = Node.find_by_unique_name(path)
        
    if node
      
      case revision
      when :current        
        return node.pages.last 
      when /\d+/
        return node.pages.find_by_revision revision
      end
    end
    
    nil
  end
  
  # Instance Methods
  
  # returns array with pages up to root excluding root
  def path_to_root
    parent.nil? && [slug] || parent.path_to_root.push(slug)
  end
  
  def update_unique_name
    path = self.path_to_root[1..-1]
    self.unique_name = path.join("/")
  end
end
