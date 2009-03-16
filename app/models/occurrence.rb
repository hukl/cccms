# TODO Make a gem out of the c wrapper
require 'lib/chaos_calendar/ical_occurrences'

class Occurrence < ActiveRecord::Base
  
  # Associations
  
  belongs_to :node
  belongs_to :event
  
  # Class Methods
  
  def self.generate event
    self.delete_all(:event_id => event.id)
    
    node        = event.node
    summary     = node.head.title
    duration    = (event.end_time - event.start_time)
    occurrences = self.generate_dates(event)
    
    occurrences.each do |occurrence|
      self.create(
        :summary    => summary,
        :start_time => occurrence,
        :end_time   => (occurrence + duration),
        :node_id    => node.id,
        :event_id   => event.id
      )
    end
  end
  
  def self.generate_dates event
    
    if event.rrule
      Ical_occurrences::occurrences( 
        event.start_time.utc.iso8601, 
        (Time.now + 5.years).utc.iso8601, 
        event.rrule
      )
    else
      [event.start_time]
    end
      
  end
end
