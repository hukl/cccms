require 'vpim/repo'

class Occurrence
  def initialize start, event, node
    @dtstart = start
    @event = event
    @node = node
  end
  attr_reader :dtstart, :event, :node
end

class ChaosCalendar
  def initialize
    @calendar = {}
  end

  def push cal, node
    Vpim::Icalendar.decode( cal ).each { |c| c.events.each { |e| @calendar[e] = node } }
  end

  def occurrences start_time, end_time
    occurr = []
    @calendar.each { |e, node|
      if e.occurs_in?( start_time, end_time )
        e.occurences( end_time ) { |t|
          occurr << Occurrence.new(t,e,node) if (t + (e.duration || 0)) >= start_time
        }
      end
    }

    return occurr.sort { |lhs, rhs| lhs.dtstart <=> rhs.dtstart }
  end

end
