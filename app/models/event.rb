class Event < ActiveRecord::Base
  
  # Associations
  
  has_many    :occurrences
  belongs_to  :node
  
  # Callbacks
  
  after_save  :generate_occurences
  
  # Instance Methods
  
  def occurrences_in_range start_time, end_time
    self.occurrences.find(
      :all, :conditions => [
        "start_time > ? AND end_time < ?", 
        start_time, end_time
      ]
    )
  end
  
  private
    def generate_occurences
      Occurrence.generate self
    end
end
