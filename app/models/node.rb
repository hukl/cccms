class Node < ActiveRecord::Base
  acts_as_nested_set
  
  has_many    :pages, :order => "revision ASC"
  belongs_to  :head,  :class_name => "Page",  :foreign_key => :head_id
  
  # Class methods
  
  
  # Returns a page for a given node. If no revision is supplied, it returns
  # the last / current one. If a specific revision number is supplied, the 
  # corresponding revision of that page is returned. Get the current / latest 
  # revision with -1. It raises an Argument error if the revision is not a 
  # Fixnum
  def self.find_page path, revision = -1
    unless revision.class == Fixnum
      raise ArgumentError, "revision must be a Fixnum" 
    end
    
    node = Node.find_by_unique_name(path)
        
    if node
      case revision
      when -1        
        return node.head
      else
        return node.pages.find_by_revision revision
      end
    end
    
    nil
  end
  
  # Instance Methods
  
  def draft
    
    # check if there is a page which has a nil :published_at column
    # if there is one - it is considered a draft else a new revision is 
    # created
    
    if draft = pages.find_by_published_at(nil)
      draft
    else
      # make a new fresh page with node reference
      draft = Page.new( :node_id => id)
    end
    
    draft
  end
  
  # returns an array with all parts of a unique_name rather than a string
  def unique_path
    unique_name.split("/") rescue unique_name
  end
  
  # returns array with pages up to root excluding root
  def path_to_root
    parent.nil? && [slug] || parent.path_to_root.push(slug)
  end
  
  def update_unique_name
    path = self.path_to_root[1..-1]
    self.unique_name = path.join("/")
    self.save
  end
end
