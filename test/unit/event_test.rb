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
end