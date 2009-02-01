class Page < ActiveRecord::Base
  
  belongs_to :node
  
  acts_as_list :column => :revision, :scope => :node_id
  
  
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


named_scope :flagged_as, lambda { |flags| 
  conditions = {}
  flags.each do |flag|
    conditions[flag] = true
  end
  
  { :conditions => conditions }
}