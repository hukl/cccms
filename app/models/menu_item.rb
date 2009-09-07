class MenuItem < ActiveRecord::Base
  
  default_scope :conditions => {:type => "MenuItem"}
  
  translates    :title
  
  acts_as_list  :scope => :type
  
  before_save   :determine_type_id
  
  
  private
  
    def determine_type_id
      case self.class.name
        
      when "MenuItem"
        self.type_id = 1
      when "FeaturedArticle"
        self.type_id = 2
      end
    end
end


class FeaturedArticle < MenuItem
  default_scope :conditions => {:type => "FeaturedArticle"}
end