require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  def setup
    Page.delete_all
    @cal_node = Node.create :slug => "calendar"
    @cal_node.move_to_child_of Node.root
    @draft          = @cal_node.find_or_create_draft User.first
    @draft.title    = "99C3"
    @draft.abstract = "The 99th Chaos Comunication Congress"
    @draft.body     = "Its totally freakin awesome"
    @draft.save
    @cal_node.publish_draft!
    @cal_node.head.reload
  end
  
  test 'verfy setup data' do 
    assert_not_nil @cal_node
    assert_not_nil @cal_node.head
  end
  
  test 'creating an event with malformed rrule raises exception' do
    assert_raise(ArgumentError) do
      Event.create!(
        :start_time   => "2009-01-01T15:23:42".to_time,
        :end_time     => "2009-01-01T20:05:23".to_time,
        :url          => "http://events.ccc.de/congress/2082",
        :latitude     => 52.525308,
        :longitude    => 13.378944,
        :rrule        => "FOOBAR",
        :allday       => false,
        :custom_rrule => false,
        :node_id      => @cal_node.id
      )
    end
  end
  
  test 'create day event for node with one occurrence' do
    assert_not_nil event = Event.create!(
      :start_time   => "2009-01-01T15:23:42".to_time,
      :end_time     => "2009-01-01T20:05:23".to_time,
      :url          => "http://events.ccc.de/congress/2082",
      :latitude     => 52.525308,
      :longitude    => 13.378944,
      :rrule        => nil,
      :allday       => false,
      :custom_rrule => false,
      :node_id      => @cal_node.id
    )
    
    assert_equal 1, Occurrence.count
    assert_equal event.start_time, Occurrence.first.start_time
    assert_equal event.end_time, Occurrence.first.end_time
    assert_equal @cal_node.head.title, Occurrence.first.summary
  end
  
  test 'create day event with weekly reoccurrence and checking data' do
    assert_not_nil event = Event.create!(
      :start_time   => "2009-01-01T15:23:42".to_time,
      :end_time     => "2009-01-01T20:05:23".to_time,
      :url          => "http://events.ccc.de/congress/2082",
      :latitude     => 52.525308,
      :longitude    => 13.378944,
      :rrule        => "FREQ=WEEKLY;INTERVAL=1",
      :allday       => false,
      :custom_rrule => false,
      :node_id      => @cal_node.id
    )
    
    assert_not_nil scoped_occurrences = event.occurrences_in_range(
      "2009-01-01".to_time, "2009-12-31".to_time
    )
    
    assert_equal 52, scoped_occurrences.length
    
    assert_equal "2009-12-24T15:23:42".to_time, scoped_occurrences[51].start_time
    assert_equal "2009-12-24T20:05:23".to_time, scoped_occurrences[51].end_time
    assert_equal "99C3", scoped_occurrences[51].summary
    assert_equal @cal_node.event, scoped_occurrences[51].event
    assert_equal @cal_node, scoped_occurrences[51].node
    
    assert_equal "2009-03-19T15:23:42".to_time, scoped_occurrences[11].start_time
    assert_equal "2009-03-19T20:05:23".to_time, scoped_occurrences[11].end_time
    assert_equal "99C3", scoped_occurrences[11].summary
    assert_equal @cal_node.event, scoped_occurrences[11].event
    assert_equal @cal_node, scoped_occurrences[11].node
    
    assert_equal "2009-01-01T15:23:42".to_time, scoped_occurrences[0].start_time
    assert_equal "2009-01-01T20:05:23".to_time, scoped_occurrences[0].end_time
    assert_equal "99C3", scoped_occurrences[0].summary
    assert_equal @cal_node.event, scoped_occurrences[11].event
    assert_equal @cal_node, scoped_occurrences[11].node
  end
  
  test 'create chaosradio event with custom rrule and interval' do
    assert_not_nil event = Event.create!(
      :start_time   => "2009-01-28T21:00:00".to_time,
      :end_time     => "2009-01-28T23:00:00".to_time,
      :url          => "http://chaosradio.ccc.de",
      :latitude     => 52.525308,
      :longitude    => 13.378944,
      :rrule        => "FREQ=MONTHLY;INTERVAL=1;BYDAY=-1WE",
      :allday       => false,
      :custom_rrule => true,
      :node_id      => @cal_node.id
    )
    
    assert_not_nil scoped_occurrences = event.occurrences_in_range(
      "2009-01-01".to_time, "2009-12-31".to_time 
    )
    
    assert_equal 12, scoped_occurrences.length
    
    expected_days = [28, 25, 25, 29, 27, 24, 29, 26, 30, 28, 25, 30]
    chaosradio_days = scoped_occurrences.map {|x| x.start_time.day}
    assert_equal expected_days, chaosradio_days
  end
end