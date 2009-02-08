require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  
  def setup
    @root = Node.find(1)
    @first_child = Node.find(2)
    @second_child = Node.find(3)
  end
  
  def test_created_nodes_have_an_empty_draft_and_no_head
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    
    assert !node.pages.empty?
    assert_equal 1, node.pages.length
    assert_not_nil node.draft
    assert_nil node.head
  end
  
  def test_create_new_draft_of_published_page
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    
    assert node.publish_draft!
    
    draft = node.draft
    
    assert_equal 2, node.pages.length
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
  
  def test_order_of_pages_by_revision
    # This test should make sure the order is the same on different db's

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
