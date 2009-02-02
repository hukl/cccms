# Alternativ queries for the named_scope with one or two inner joins. 
# Loading the Flags themselves would be another query. 
# Could be faster on larger data sets.
#
# Single Join:
#
# Page.find(
#   :all, 
#   :joins => 'JOIN flags_pages on pages.id = flags_pages.page_id', 
#   :include => :flags, 
#   :conditions => ['flags_pages.flag_id IN (?)', [1,2]]
# )
# Two inner joins:
#
# Page.find(
#   :all, 
#   :joins => :flags_pages, 
#   :conditions => ['flags_pages.flag_id IN (?)', [1,2]]
# )
#
# Page.find_by_sql("select p.* from pages p JOIN flags_pages f on p.id = f.page_id where (f.flag_id IN (1,2))")

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
    
    pages = Page.with_flags(options[:flags].split(/\s/)).all(
      :limit => options[:limit],
      :order => "#{options[:order_by]} #{options[:order_direction]}"
    )
  end
end