require 'test_helper'

class NodesControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  def test_get_index
    Node.root.descendants.delete_all
    test_node = Node.create :slug => "foo"
    test_node.move_to_child_of Node.root
    login_as :quentin
    get :index
    assert_response :success
  end
  
  def test_new
    login_as :quentin
    get :new
    assert_response :success
  end
  
  def test_create
    login_as :quentin
    post :create, :node => {:slug => 'foobar'}, :parent_id => Node.root.id
    assert_redirected_to edit_node_path(Node.last)
  end
  
  def test_editing_a_node
    login_as :quentin
    
    node = Node.find_by_unique_name("fourth_child")
    node.pages.create
    node.draft = node.pages.last
    node.save
    
    assert_equal 1, node.pages.length
    
    draft = node.find_or_create_draft( User.first )
    draft.title = "Hello"
    draft.body = "World"
    draft.save
    node.publish_draft!
    
    get :edit, :id => node.id
    assert_response :success
    assert_select("#page_title[value=Hello]")
    assert_select("#page_body", "World")
    
    node.reload
    assert_equal 2, node.pages.length
    assert_equal "Hello", node.find_or_create_draft( User.first ).title
    assert_equal "World", node.find_or_create_draft( User.first ).body
  end
  
  def test_update_a_draft
    test_node = Node.create! :slug => "test_node"
    test_node.move_to_child_of Node.root
    
    login_as :quentin
    put :update, :id => test_node.id, :page => {:title => "Hello", :body => "There"}
    
    assert_equal "Hello", test_node.draft.title
    assert_equal "There", test_node.draft.body
  end
  
  def test_update_a_draft_with_changing_the_template
    test_node = Node.create! :slug => "test_node"
    test_node.move_to_child_of Node.root
    
    login_as :quentin
    put :update, {
      :id => test_node.id, 
      :page => {
        :title => "Hello", 
        :body => "There",
        :template_name => "Foobar"
      }
    }
    
    test_node.reload
    assert_equal "Hello", test_node.draft.title
    assert_equal "There", test_node.draft.body
    assert_equal "Foobar", test_node.draft.template_name
  end
end
