require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  
  def setup
    @root = Node.find(1)
    @first_child = Node.find(2)
    @second_child = Node.find(3)
  end

  def test_creation_of_unique_name
    node = Node.create :slug => 'child'
    node.move_to_child_of @root
    node.reload
    assert_equal 'child', node.unique_name
    
    node = Node.create :slug => 'deep_child'
    node.move_to_child_of @first_child
    node.reload
    assert_equal 'first_child/deep_child', node.unique_name
  end
  
  def test_retrieving_page_current
    updates = Node.create(:slug => 'updates')
    updates.move_to_child_of @root
    
    year = Node.create(:slug => '2008')
    year.move_to_child_of updates
    
    foo = Node.create(:slug => 'foo')
    foo.move_to_child_of year
    
    assert_not_nil Node.find_by_unique_name('updates/2008/foo')
    
    foo.pages.create :title => "Version 1"
    foo.pages.create :title => "Version 2"
    foo.pages.create :title => "Version 3"
    
    foo.head = foo.pages.last
    foo.save!
    
    page = Node.find_page("updates/2008/foo")
    assert_equal page, foo.pages.find_by_revision(3)
  end
  
  def test_retrieving_page_by_revision
    updates = Node.create(:slug => 'updates')
    updates.move_to_child_of @root
    
    year = Node.create(:slug => '2008')
    year.move_to_child_of updates
    
    foo = Node.create(:slug => 'foo')
    foo.move_to_child_of year
    
    assert_not_nil Node.find_by_unique_name('updates/2008/foo')
    
    foo.pages.create :title => "Version 1"
    foo.pages.create :title => "Version 2"
    foo.pages.create :title => "Version 3"
    
    page = Node.find_page("updates/2008/foo", 2)
    assert_equal "Version 2", page.title
  end
  
  def test_order_of_pages_by_revision
    one   = @second_child.pages.create :title => "one"
    two   = @second_child.pages.create :title => "two"
    three = @second_child.pages.create :title => "three"
    
    @second_child.pages.reload
    
    assert_equal [1,2,3], @second_child.pages.map { |x| x.revision }
  end
  
  def test_behavior_of_acts_as_list
    one   = @second_child.pages.create :title => "one"
    two   = @second_child.pages.create :title => "two"
    three = @second_child.pages.create :title => "three"
    
    assert_equal 1, one.revision
    assert_equal 2, two.revision
    assert_equal 3, three.revision
    
    assert_equal three, @second_child.pages.last
    
    assert one.move_to_bottom
    
    one.reload; two.reload; three.reload;
    
    assert_equal 3, one.revision
    assert_equal 1, two.revision
    assert_equal 2, three.revision
  end
end
