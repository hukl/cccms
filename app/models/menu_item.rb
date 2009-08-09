class MenuItem < ActiveRecord::Base
  
  translates :title
  
  acts_as_list
end
