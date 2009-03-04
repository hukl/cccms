class Page < ActiveRecord::Base
  
  PUBLIC_TEMPLATE_PATH = File.join(%w(custom page_templates public))
  FULL_PUBLIC_TEMPLATE_PATH = File.join(RAILS_ROOT, 'app', 'views', PUBLIC_TEMPLATE_PATH)
  
  # Mixins and Plugins
  acts_as_taggable  
  acts_as_list :column => :revision, :scope => :node_id
  
  translates :title, :abstract, :body # Globalize2
  
  # Associations
  belongs_to :node
  belongs_to :user
  
  # Security
  attr_accessible :title, :abstract, :body, :template_name
  
  # Class Methods
  
  # This method is most likely called from the ContentHelper.render_collection
  # method which aggregates pages into a collection, based on parameters it 
  # recieves. This method then calls Page.aggregate with these parameters.
  # The Page.aggregate method comes with a defaults hash. These options are
  # partially or entirely overwritten by the options hash. Afterwards the merged
  # parameters are used to query the DB for Pages matching these parameters.
  # The aggregation only takes published pages into account.
  def self.aggregate options
    
    defaults = {
      :tags             => "",
      :limit            => 20,
      :order_by         => "pages.id",
      :order_direction  => "ASC"
    }
    
    options = defaults.merge options
    
    pages = Page.find_all_tagged_with(
      options[:tags].gsub(/\s/, ", "), 
      :match_all => true,
      :order => "#{options[:order_by]} #{options[:order_direction]}",
      :include => :node, 
      :conditions => ["nodes.head_id = pages.id"],
      :limit => options[:limit]
    )
    
  end
  
  def self.custom_templates
    files = Dir.entries(FULL_PUBLIC_TEMPLATE_PATH).select do |x| 
      x if x.gsub!(".html.erb", "")
    end
  end
  
  # Instance Methods
  
  def clone_attributes_from page
    return nil unless page
  
    self.tag_list = page.tag_list.join(", ")
    
    locale_before = I18n.locale
    
    I18n.available_locales.each do |l|
      next if l == :root
      I18n.locale = l
      self.title    = page.title
      self.abstract = page.abstract
      self.body     = page.body
    end
  
    I18n.locale = locale_before
  end

  def public_template_path
    File.join(PUBLIC_TEMPLATE_PATH, template_name)
  end
  
  def full_public_template_path
    File.join(FULL_PUBLIC_TEMPLATE_PATH, template_name)
  end
  
  def template_exists?
    File.exists? "#{full_public_template_path}.html.erb"
  end
  
  def valid_template
    
    if template_name && template_exists?
      public_template_path
    else
      File.join(PUBLIC_TEMPLATE_PATH, 'standard_template')
    end    
  end
  
  def clone_attributes_from page
    return nil unless page
  
    self.tag_list = page.tag_list.join(", ")
    self.template_name = page.template_name
    
    locale_before = I18n.locale
    
    I18n.available_locales.each do |l|
      next if l == :root
      I18n.locale = l
      self.title    = page.title
      self.abstract = page.abstract
      self.body     = page.body
    end
  
    I18n.locale = locale_before
  end
end