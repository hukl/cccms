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
  validates_length_of     :slug, :within => 1..255,    :unless => "parent_id.nil?"
  validates_presence_of   :slug,                       :unless => "parent_id.nil?"
  validates_uniqueness_of :slug, :scope => :parent_id, :unless => "parent_id.nil?"
  validates_presence_of   :parent_id,                  :unless => "Node.root.nil?"

  validate :borders       # This should never ever happen.

  # Index for Fulltext Search
  define_index do
    indexes head.translations.title
    indexes slug
    indexes unique_name
    indexes head.translations.body
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
      draft.user    = current_user if draft.user.nil?
      draft.editor  = current_user
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
    empty_page        = self.pages.create!
    empty_page.user   = (self.head ? self.head.user : user)
    empty_page.editor = user
    empty_page.save

    empty_page.clone_attributes_from self.head

    self.draft = empty_page
    self.save
    self.draft.reload
  end

  def publish_draft!
    if self.draft
      self.head = self.draft
      self.head.published_at ||= Time.now
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
      self
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
    unique_name.split("/") rescue [unique_name]
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

  def locked?
    !self.lock_owner.nil?
  end

  def unlock!
    if self.lock_owner
      self.lock_owner = nil
      self.save
      self
    end
  end

  def title
    head ? head.title : draft.title
  end

  def update_unique_names?
    !children.empty? && !children.first.path_to_root.include?(self.slug)
  end

  def head?
    head_id
  end

  def update?
    unique_path.length == 3 && unique_path[0] == "updates"
  end

  # Returns immutable node id for all new nodes so that the atom feed entry ids
  # stay the same eventhough the slug or positions changes.
  # Can be removed after a year or so ;)
  def feed_id
    new_id_format_date = "2009-11-14".to_time
    self.created_at < new_id_format_date ? unique_path : id
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
      unless root?
        self.descendants.each do |descendant|
          descendant.update_unique_name
        end
      end
    end

    def borders
      if lft && rgt && (lft > rgt)
        errors.add("Fuck!. lft should never be smaller than rgt")
      end
    end
end

class LockedByAnotherUser < StandardError; end


