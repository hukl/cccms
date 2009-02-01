class Page < ActiveRecord::Base
  
  belongs_to :node
  has_and_belongs_to_many :flags
  
  acts_as_list :column => :revision, :scope => :node_id
  
  named_scope :with_flags, lambda {|flag_names| 
    if (flags = Flag.find_all_by_name(flag_names)).empty?
      {}
    else
      {:include => :flags, :conditions => ['flags_pages.flag_id IN (?)', flags.map(&:id)] }
    end
  }
  
  
  
  # <aggregate 
  #   flags="updates pressemitteilungen"
  #   path="updates/2009"
  #   limit="20"
  #   order_by="published_at"
  #   order_direction="DESC"
  # />
  def self.aggregate options
    
    defaults = {
      :flags            => "",
      :path             => "",
      :limit            => 20,
      :order_by         => "id",
      :order_direction  => "ASC"
    }
    
    options = defaults.merge options
    
    pages = Page.all(
      :limit => options[:limit],
      :order => "#{options[:order_by]} #{options[:order_direction]}"
    )
  end
end