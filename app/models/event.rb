# TODO Make a gem out of the c wrapper
require 'lib/chaos_calendar/ical_occurrences'

class Event < ActiveRecord::Base
  
  # Associations
  
  has_many    :occurrences
  belongs_to  :node
  
  # Callbacks
  
  after_save  :calculate_occurences
  
  private
    def calculate_occurences
      
      Occurrence.delete_all
      
      end_time = Time.now + 5.years
      
      Event.all.each do |event|
        write_occurrences event, start_time, end_time
      end
    end
    
    def write_occurrences event, start_time, end_time
      node     = event.node
      title    = node.head.title
      duration = event.end_time - event.start_time
      
      occurrences = Ical_occurrences::occurrences( 
        event.start_time.utc.iso8601, 
        end_time.utc.iso8601, 
        event.rrule
      )
      
      occurrences.each do |occurrence|
        Occurrence.create!(
          :summary    => title,
          :start_time => occurrence, 
          :end_time   => occurrence + duration,
          :event_id   => event.id,
          :node_id    => node.id
        )
      end
    end
end
