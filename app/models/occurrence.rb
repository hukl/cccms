# TODO Make a gem out of the c wrapper
require 'chaos_calendar'

class Occurrence < ActiveRecord::Base
  
  # Associations
  
  belongs_to :node
  belongs_to :event
  
  # Class Methods
  
  def self.find_in_range start_time, end_time
    find(
      :all,
      :include => :node, 
      :conditions => [
        "start_time > ? AND end_time < ?", start_time, end_time 
      ]
    )
  end
  
  def self.find_next
    find(
      :all,
      :limit => 1,
      :include => :node,
      :conditions => ["start_time > ?", Time.now]
    )
  end
  
  # Deletes all Occurrences which belong to the given event. Afterwards a few
  # variables are set to save repetitive queries. The occurrences of the given
  # event are then calculated and created.
  def self.generate event
    self.delete_all(:event_id => event.id)
    
    node        = event.node
    duration    = (event.end_time - event.start_time)
    occurrences = self.generate_dates(event)
    
    occurrences.each do |occurrence|
      self.create(
        :start_time => occurrence,
        :end_time   => (occurrence + duration),
        :node_id    => node.id,
        :event_id   => event.id
      )
    end
  end
  
  # Calculates the start_time of all occurrences for a given event if a proper
  # RRule is provided. An ArgumentError is thrown from within the libical
  # wrapper if the RRule is malformed. If the rrule attribute of an event is
  # nil, it simply returns the event start_time as only occurrence.
  # Return value is always an array of Time objects.
  def self.generate_dates event
    if event.rrule && !event.rrule.empty?
      ChaosCalendar::occurrences( 
        event.start_time, 
        (Time.now + 5.years), 
        event.rrule
      )
    else
      [event.start_time]
    end
      
  end
  
  
  # Instance Methods
  
  def summary
    node.head.title
  end
  
end
