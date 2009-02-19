require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  
  def setup
    @root = Node.find(1)
    @first_child = Node.find(2)
    @second_child = Node.find(3)
    
    @user1 = User.create :login => 'demo', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
    @user2 = User.create :login => 'show', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
  end
  
  def test_created_nodes_have_an_empty_draft_and_no_head
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    
    assert !node.pages.empty?
    assert_equal 1, node.pages.length
    assert_not_nil node.draft
    assert_nil node.draft.user
    assert_nil node.head
  end
  
  def test_create_new_draft_of_published_page
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    
    assert node.publish_draft!
  end
  
  def test_find_or_create_draft_if_no_draft_exists
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    node.publish_draft!
    
    assert_not_nil node.find_or_create_draft( @user1 )
  end
  
  def test_find_or_create_draft_if_draft_exists_and_is_owned_by_user
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    node.publish_draft!
    
    node.find_or_create_draft @user1
    node.find_or_create_draft @user1
  end
  
  def test_exception_if_draft_exists_but_locked_by_another_user
    node = Node.create :slug => "third_child"
    node.move_to_child_of @root
    node.publish_draft!

    node.find_or_create_draft @user1

    assert_raise(RuntimeError) do
      node.find_or_create_draft @user2
    end
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
  
  def test_retrieving_page_current
    updates = Node.create(:slug => 'updates')
    updates.move_to_child_of @root

    year = Node.create(:slug => '2008')
    year.move_to_child_of updates

    foo = Node.create(:slug => 'foo')
    foo.move_to_child_of year

    assert_not_nil Node.find_by_unique_name('updates/2008/foo')

    # Note that there is already an initial, blank revision
    foo.pages.create :title => "Version 2"
    foo.pages.create :title => "Version 3"
    foo.pages.create :title => "Version 4"

    foo.head = foo.pages.last
    foo.save!

    page = Node.find_page("updates/2008/foo")
    assert_equal page, foo.pages.find_by_revision(4)
  end

  def test_retrieving_page_by_revision
    updates = Node.create(:slug => 'updates')
    updates.move_to_child_of @root

    year = Node.create(:slug => '2008')
    year.move_to_child_of updates

    foo = Node.create(:slug => 'foo')
    foo.move_to_child_of year

    assert_not_nil Node.find_by_unique_name('updates/2008/foo')

    # Note that there is already an initial, blank revision
    foo.pages.create :title => "Version 2"
    foo.pages.create :title => "Version 3"
    foo.pages.create :title => "Version 4"

    page = Node.find_page("updates/2008/foo", 2)
    assert_equal "Version 2", page.title
  end
end
