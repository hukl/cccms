class Page < ActiveRecord::Base
  
  belongs_to :node

  acts_as_taggable  
  acts_as_list :column => :revision, :scope => :node_id

  # <aggregate 
  #   flags="update, pressemitteilung"
  #   limit="20"
  #   order_by="published_at"
  #   order_direction="DESC"
  # />
  def self.aggregate options
    
    defaults = {
      :flags            => "",
      :limit            => 20,
      :order_by         => "id",
      :order_direction  => "ASC"
    }
    
    options = defaults.merge options
    debugger
    pages = Page.find_tagged_with(options[:flags], :match_all => true)
  end
end