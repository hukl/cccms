require 'xml'

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
  
  # Filter
  before_save :rewrite_links_in_body
  
  # Security
  attr_accessible :title, :abstract, :body, :template_name, :published_at
  
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
      :include => [:node, :globalize_translations], 
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
  
  def public_link
    "#{I18n.locale}/#{node.unique_name}"
  end
  
  def clone_attributes_from page
    return nil unless page
    
    self.reload
    
    # Clone untranslated attributes
    self.tag_list = page.tag_list.join(", ")
    self.template_name = page.template_name
    self.published_at = page.published_at
    
    # Getting rid of the auto-generated empty translations
    self.globalize_translations.delete_all
    
    # Clone translated attributes
    page.globalize_translations.each do |translation|
      self.globalize_translations.create!(translation.attributes)
    end
    
    self.save
  end
  
  def public?
    published_at.nil? ? true : published_at < Time.now 
  end
  
  private
    
    def rewrite_links_in_body
      begin
        if self.body
          tmp_body = "<div>#{self.body}</div>"
          xml_string = XML::Parser.string( tmp_body )
          xml_doc = xml_string.parse
          links = xml_doc.find("//a[not(starts-with(@href, 'http://'))]")
          
          locales = I18n.available_locales.reject {|l| l == :root}
          
          links.each do |link|
            unless locales.include? link[:href].slice(1,2).to_sym
              link[:href] = link[:href].sub(/^\//, "/#{I18n.locale}/")
            end
          end
          
          tmp_body = xml_doc.to_s.gsub(/(\n\<div\>|\<\/div\>\n)/, "")
          tmp_body.gsub!("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "")
          
          self.body = tmp_body
        end
      rescue
        nil
      end
    end
  
end