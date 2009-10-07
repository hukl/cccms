require 'test_helper'

class NodesControllerTest < ActionController::TestCase

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
  
  test "create generic node with parent_id provided" do
    login_as :quentin
    assert_difference "Node.count", +1  do
      post( 
        :create, 
        :kind => "generic", 
        :parent_id => Node.root.id,
        :title => "Hello Spaceboy"
      )
    end
    
    assert_response :redirect
    assert_equal "hello-spaceboy", Node.last.slug
    assert_equal Node.last.parent_id, Node.root.id
    assert_equal 1, Node.last.level
  end
  
  test "create update node" do
    login_as :quentin
    #difference of three because "updates" and "2009" node get created as well
    assert_difference "Node.count", +3  do
      post( 
        :create,
        :kind => "update",
        :title => "Hello Spaceboy"
      )
    end
    
    assert_response :redirect
    expected = "updates/#{Time.now.year.to_s}/hello-spaceboy"
    assert_equal expected, Node.last.unique_name
    assert_equal 3, Node.last.level
  end
  
  test "create top level node" do
    login_as :quentin
    
    assert_difference "Node.count", +1  do
      post( 
        :create,
        :kind => "top_level",
        :title => "Hello Spaceboy"
      )
    end
    
    assert_response :redirect
    expected = "hello-spaceboy"
    assert_equal expected, Node.last.unique_name
    assert_equal 1, Node.last.level
  end
  
  test "creating a top_level node without a title should not work" do
    login_as :quentin
    
    assert_no_difference "Node.count" do
      post(:create, :kind => "top_level")
    end
  end
  
  test "creating a generic node without a parent_id should not work" do
    login_as :quentin
    
    assert_no_difference "Node.count" do
      post(:create, :kind => "generic")
    end
  end
  
  test "editing a node" do
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
  
  
  test "publish draft with staged_slug unqueal slug" do
    login_as :quentin
    
    test_node = Node.create! :slug => "test_node", :staged_slug => "peter_pan"
    test_node.move_to_child_of Node.root
    
    put :publish, :id => test_node.id
    
    test_node.reload
    assert_equal "peter_pan", test_node.slug
    assert_equal "peter_pan", test_node.unique_name
  end
  
  test "publish draft with staged_slug with more levels of nodes" do
    login_as :quentin
    
    test_node = Node.create! :slug => "test_node", :staged_slug => "peter_pan"
    test_node.move_to_child_of Node.root
    test_node2 = Node.create! :slug => "test_node2"
    test_node2.move_to_child_of test_node

    put :publish, :id => test_node.id
    
    test_node.reload; test_node2.reload
    assert_equal "peter_pan/test_node2", test_node2.unique_name
    assert_equal "peter_pan", test_node.unique_name
  end
  
  test "publish draft with staged_parent_id" do
    login_as :quentin
    
    parent = Node.create! :slug => "parent"
    parent.move_to_child_of Node.root
    test_node = Node.create! :slug => "test_node", :staged_parent_id => parent.id
    test_node.move_to_child_of Node.root
    test_node2 = Node.create! :slug => "test_node2"
    test_node2.move_to_child_of test_node
    
    put :publish, :id => test_node.id
    
    test_node.reload; test_node2.reload
    assert_equal "parent/test_node", test_node.unique_name
    assert_equal "parent/test_node/test_node2", test_node2.unique_name
  end
  
  test "publish draft with staged_parent_id and staged_slug" do
    login_as :quentin
    
    parent = Node.create! :slug => "parent"
    parent.move_to_child_of Node.root
    
    test_node = Node.create!(
      :slug => "test_node", 
      :staged_parent_id => parent.id,
      :staged_slug => "peter_pan"
    )
    test_node.move_to_child_of Node.root
    
    test_node2 = Node.create! :slug => "test_node2"
    test_node2.move_to_child_of test_node
    
    put :publish, :id => test_node.id
    
    test_node.reload; test_node2.reload
    assert_equal "parent/peter_pan", test_node.unique_name
    assert_equal "parent/peter_pan/test_node2", test_node2.unique_name
  end
  
end
