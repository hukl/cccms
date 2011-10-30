class RelatedAsset < ActiveRecord::Base
  belongs_to :page
  belongs_to :asset

  acts_as_list :scope => :page_id

  default_scope :order => "position ASC"
end