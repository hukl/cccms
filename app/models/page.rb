require 'xml'

class Page < ActiveRecord::Base

  PUBLIC_TEMPLATE_PATH = File.join(%w(custom page_templates public))
  FULL_PUBLIC_TEMPLATE_PATH = File.join(RAILS_ROOT, 'app', 'views', PUBLIC_TEMPLATE_PATH)

  # named scopes

  named_scope(
    :drafts,
    :joins => :node,
    :include => [:translations],
    :conditions => ["nodes.draft_id = pages.id"]
  )

  named_scope(
    :heads,
    :joins => :node,
    :include => [:translations],
    :conditions => ["nodes.head_id = pages.id"]
  )

  # Mixins and Plugins
  acts_as_taggable
  acts_as_list :column => :revision, :scope => :node_id

  translates :title, :abstract, :body # Globalize2

  # Associations
  belongs_to :node
  belongs_to :user
  belongs_to :editor, :class_name => "User"
  has_many   :related_assets
  has_many   :assets, :through => :related_assets, :order => "position ASC"

  # Filter
  before_create :set_page_title
  before_create :set_template
  before_save   :rewrite_links_in_body

  # Security
  attr_accessible :title, :abstract, :body, :template_name, :published_at, :user_id

  # Class Methods

  # This method is most likely called from the ContentHelper.render_collection
  # method which aggregates pages into a collection, based on parameters it
  # recieves. This method then calls Page.aggregate with these parameters.
  # The Page.aggregate method comes with a defaults hash. These options are
  # partially or entirely overwritten by the options hash. Afterwards the merged
  # parameters are used to query the DB for Pages matching these parameters.
  # The aggregation only takes published pages into account.
  def self.aggregate options, page=1

    defaults = {
      :tags             => "",
      :limit            => 25,
      :order_by         => "pages.id",
      :order_direction  => "ASC"
    }

    options = defaults.merge options

    Page.heads.paginate(
      find_options_for_find_tagged_with(
        options[:tags].gsub(/\s/, ","), :match_all => true
      ).merge(
        :page     => page,
        :per_page => options[:limit],
        :order    => "#{options[:order_by]} #{options[:order_direction]}"
      )
    )
  end

  def self.custom_templates
    files = Dir.entries(FULL_PUBLIC_TEMPLATE_PATH).select do |x|
      x if x.gsub!(".html.erb", "")
    end
  end

  def self.untranslated(options = {:locale => :de})
    PageTranslation.all.group_by(&:page_id).select do |k,v|
      v.size == 1 && v.map{|x| x.locale}.include?(options[:locale])
    end
  end

  # Returns only those pages that have outdated translations. See
  # outdated_translations? for more information.
  # Takes :locale => <locale> and :delta_time => 12.hours as options
  def self.find_with_outdated_translations options = {}
    Page.all(:include => :translations).select do |page|
      page.outdated_translations? options
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
    "/#{node.unique_name}"
  end

  def clone_attributes_from page
    return nil unless page

    self.reload

    # Clone untranslated attributes
    self.tag_list         = page.tag_list
    self.template_name  ||= page.template_name
    self.published_at     = page.published_at

    # Getting rid of the auto-generated empty translations
    self.translations.delete_all

    # Clone translated attributes
    page.translations.each do |translation|
      self.translations.create!(translation.attributes)
    end

    # Clone asset references
    self.assets = page.assets

    self.save
  end

  def public?
    published_at.nil? ? true : published_at < Time.now
  end

  # Returns true if a page has translations where one of them is significantly
  # older than the other.
  # Takes the I18n.default locale and a second :locale to test if the
  # translations for the given locales exist and if their updated_at attributes
  # have a delta time that is greater than the specified :delta_time
  def outdated_translations? options = {}

    default_options = {
      :locale => :en,
      :delta_time => 23.hours
    }

    options = default_options.merge options

    translations = self.translations

    default = *(translations.select {|x| x.locale == I18n.default_locale})
    custom  = *(translations.select {|x| x.locale == options[:locale]})

    if translations.size > 1 && default && custom
      difference = (default.updated_at - custom.updated_at).to_i.abs
      return (options[:delta_time].to_i.abs < difference)
    else
      return false
    end
  end

  def update_assets image_ids

    transaction do
      self.related_assets.delete_all

      if image_ids
        image_ids.each_with_index do |id, index|
          asset = Asset.find(id)
          self.related_assets.create!(:asset_id => asset.id, :position => index+1)
        end
      end
    end

  end

  private

    def set_page_title
      if title.nil?
        title = "Untitled"
      end
    end

    def set_template
      if node && node.update?
        self.template_name = "update"
      end
    end

    def rewrite_links_in_body
      begin
        if self.body
          tmp_body    = "<div>#{self.body}</div>"
          xml_string  = XML::Parser.string( tmp_body )
          xml_doc     = xml_string.parse
          links       = xml_doc.find("//a[not(starts-with(@href, 'http://'))]")
          locales     = I18n.available_locales.reject {|l| l == :root}

          if xml_doc.find("//p/aggregate")[0]
            aggregate_tags   = xml_doc.find("//aggregate")
            aggregate_tags[0].parent.replace_with aggregate_tags[0]
          end

          links.each do |link|
            unless locales.include? link[:href].slice(1,2).to_sym
              unless link[:href] =~ /sytem\/uploads/
                link[:href] = link[:href].sub(/^\//, "/#{I18n.locale}/")
              end
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