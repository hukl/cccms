class Event < ActiveRecord::Base
  
  # Associations
  
  has_many    :occurrences
  belongs_to  :node
  
  # Callbacks
  
  after_save  :generate_occurences
  
  private
    def generate_occurences
      Occurrence.generate self
    end
end
