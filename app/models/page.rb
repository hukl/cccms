class Page < ActiveRecord::Base
  
  belongs_to :node

  acts_as_taggable  
  acts_as_list :column => :revision, :scope => :node_id
  
  # This method is most likely called from the ContentHelper.render_collection
  # method which aggregates pages into a collection, based on parameters it 
  # recieves. This method then calls Page.aggregate with these parameters.
  # The Page.aggregate method comes with a defaults hash. These options are
  # partially or entirely overwritten by the options hash. Afterwards the merged
  # parameters are used to query the DB for Pages matching these parameters.
  def self.aggregate options
    
    defaults = {
      :flags            => "",
      :limit            => 20,
      :order_by         => "id",
      :order_direction  => "ASC"
    }
    
    options = defaults.merge options
    
    pages = Page.find_tagged_with(
      options[:flags].gsub(/\s/, ", "),
      :match_all => true,
      :order => "#{options[:order_by]} #{options[:order_direction]}")
  end
end