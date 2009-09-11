class Node < ActiveRecord::Base
  # Mixins and Plugins
  acts_as_nested_set
  
  # Associations
  has_many    :pages, :order => "revision ASC"
  belongs_to  :head,  :class_name => "Page",  :foreign_key => :head_id
  belongs_to  :draft, :class_name => "Page",  :foreign_key => :draft_id
  has_many    :permissions
  has_one     :event
  belongs_to  :lock_owner, :class_name => "User", :foreign_key => :locking_user_id
  
  # Callbacks
  after_create  :initialize_empty_page
  before_save   :check_for_changed_slug
  after_save    :update_unique_names_of_children
  
  # Validations
  validates_length_of :slug, :within => 1..255
  validates_presence_of   :slug
  validates_uniqueness_of :slug, :scope => :parent_id
  
  # Index for Fulltext Search
  define_index do
    indexes head.globalize_translations.title
    indexes slug
    indexes unique_name
  end
  
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
        return node.pages.find_by_revision( revision )
      end
    end
    
    nil
  end
  
  # Instance Methods
  
  def find_or_create_draft current_user
    if draft && self.lock_owner == current_user
      draft
    elsif draft && self.lock_owner.nil?
      lock_for! current_user
      draft.user = current_user
      draft.save
      draft
    elsif draft && self.lock_owner != current_user
      raise(
        LockedByAnotherUser, 
        "Page is locked by another user who is working on it! " \
        "Last modification: #{draft.updated_at.to_s(:db)}"
      )
    else
      lock_for! current_user
      create_new_draft current_user
    end
  end
  
  def create_new_draft user
    empty_page = self.pages.create!
    empty_page.user = user
    empty_page.save
    
    empty_page.clone_attributes_from self.head
    
    self.draft = empty_page
    self.save
    self.draft.reload
  end
  
  def publish_draft!
    if self.draft
      self.head = self.draft
      self.head.save!
      self.draft = nil
      
      if staged_slug && (staged_slug != slug)
        self.slug = staged_slug
      end
      
      if staged_parent_id && (staged_parent_id != parent_id)
        self.parent_id = staged_parent_id
      end
      
      self.save!
      self.unlock!
    else
      nil
    end
  end
  
  def restore_revision! revision
    if page = self.pages.find_by_revision(revision)
      self.head = page
      self.save
    else
      nil
    end
  end
  
  # returns an array with all parts of a unique_name rather than a string
  def unique_path
    unique_name.split("/") rescue unique_name
  end
  
  # returns array with pages up to root excluding root
  def path_to_root
    parent.nil? ? [slug] : parent.path_to_root.push(slug)
  end
  
  def current_unique_name
    path = path_to_root[1..-1] # excluding root
    self.unique_name = path.join("/")
  end
  
  def update_unique_name  
    current_unique_name
    self.save
  end
  
  def unlock!
    self.lock_owner = nil
    self.save
  end
  
  def title
    head ? head.title : draft.title
  end
  
  protected
    def lock_for! current_user
      self.lock_owner = current_user
      self.save
    end
  
    # Creates an empty page and associates it to the given node. This means
    # freshly created node has an empty draft. A user can create nodes as he
    # wants to which will not appear on the public page until the author edits
    # that draft and publishes it.
    def initialize_empty_page
      if self.pages.empty?
        self.draft = self.pages.create!
        self.save
      end
    end
    
    def check_for_changed_slug
      if parent and changed.include? "slug"
        self.unique_name = current_unique_name
      end
    end
    
    # Watch out recursion ahead! update_unique_name itself triggers this 
    # after_save callback which invokes update_unique_name on its children.
    # Hopefully until no childrens occur
    def update_unique_names_of_children
      self.descendants.each do |descendant| 
        descendant.update_unique_name
      end
    end
end

class LockedByAnotherUser < StandardError; end


