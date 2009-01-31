require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  
  def setup
    @root = Node.find(1)
    @first_child = Node.find(2)
  end
  
  def test_creation_of_unique_name
    node = Node.create :slug => 'child'
    node.move_to_child_of @root
    node.reload
    assert_equal 'child', node.unique_name
    
    node = Node.create :slug => 'deep_child'
    node.move_to_child_of @first_child
    node.reload
    assert_equal 'my_first_page/deep_child', node.unique_name
  end
  
  def test_retrieving_page_current
    
  end
  
  def test_retrieving_page_by_revision
    
  end
  
  def test_order_of_pages_by_revision
    one   = @first_child.pages.create :title => "one"
    two   = @first_child.pages.create :title => "two"
    three = @first_child.pages.create :title => "three"
    
    @first_child.pages.reload
    
    assert_equal [1,2,3], @first_child.pages.map { |x| x.revision }
  end
  
  def test_behavior_of_acts_as_list
    one   = @first_child.pages.create :title => "one"
    two   = @first_child.pages.create :title => "two"
    three = @first_child.pages.create :title => "three"
    
    assert_equal 1, one.revision
    assert_equal 2, two.revision
    assert_equal 3, three.revision
    
    assert_equal three, @first_child.pages.last
    
    assert one.move_to_bottom
    
    one.reload; two.reload; three.reload;
    
    assert_equal 3, one.revision
    assert_equal 1, two.revision
    assert_equal 2, three.revision
  end
end
