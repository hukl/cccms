require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  def setup
    @cal = <<-EOT
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Ensemble Independent//vPim 0.658//EN
CALSCALE:Gregorian
BEGIN:VEVENT
SUMMARY:Chaosradio
DTSTART:20080505T220000
LOCATION:FM 102,60 MHz
URL:http://www.fritz.de/frequenzen
RRULE:FREQ=MONTHLY;BYMONTH=1,2,3,4,5,6,7,8,9,10,11;BYDAY=-1WE;UNTIL=20091105T220000
CREATED:20021020T220000
DURATION:PT3H
END:VEVENT
END:VCALENDAR
    EOT
    
    @first_child = Node.find(2)
  end
  
  test 'saving serialized event' do
    assert event = Event.create!( :serialized_event => @cal )
  end
  
  test 'parsing calendar data' do
    event = Event.create!( :serialized_event => @cal )
    assert calendar = ChaosCalendar.new
    assert calendar.push( event.serialized_event, @first_child.id )
    assert_equal 1, calendar.calendar.length
    assert_equal "Chaosradio", calendar.calendar.to_a.first.first.summary
  end

  test 'checking occurrences logic' do
    event = Event.create!( :serialized_event => @cal )
    calendar = ChaosCalendar.new
    calendar.push( event.serialized_event, @first_child.id )

    all_occurrences = calendar.occurrences( "2009-03-22".to_datetime, "2010-01-10".to_datetime )
    assert_equal 8, all_occurrences.length

    assert_equal "2009-03-25".to_date, all_occurrences.first.dtstart.to_date
    assert_equal "2009-10-28".to_date, all_occurrences.last.dtstart.to_date
  end
  
end

__END__

opt_days  = 7

calendar = ChaosCalendar.new


calendar.push( cal, 25 )
t0 = Time.today
t1 = t0 + opt_days.days

all_occurrences = calendar.occurrences( t0, t1 )

all_occurrences.each do |o|
  e = o.event
  puts o.dtstart
  puts "#{e.summary}:"

  puts "  description=#{e.description}" if e.description
  puts "  comment=#{e.comments.first}"  if e.comments
  puts "  location=#{e.location}"       if e.location
  puts "  status=#{e.status}"           if e.status
  puts "  dtstart=#{e.dtstart}"         if e.dtstart
  puts "  duration=#{Vpim::Duration.new(e.duration).to_s}" if e.duration
end

