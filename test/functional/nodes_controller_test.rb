require 'test_helper'

class NodesControllerTest < ActionController::TestCase

  def test_get_index
    Node.root.descendants.delete_all
    test_node = Node.root.children.create :slug => "foo"
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
        :title => "Hello My Spaceboy"
      )
    end

    assert_response :redirect
    expected = "hello-my-spaceboy"
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

  test "editing a locked node raises LockedByAnotherUser Exception" do
    login_as :quentin

    node = create_node_with_draft
    node.lock_owner = User.last
    node.save

    assert node.locked?

    get :edit, :id => node.id
    assert_response :redirect
    assert @response.flash[:error] =~ /Page is locked by another user/
  end

  def test_update_a_draft
    test_node = Node.root.children.create! :slug => "test_node"

    login_as :quentin
    put :update, :id => test_node.id, :page => {:title => "Hello", :body => "There"}

    assert_equal "Hello", test_node.draft.title
    assert_equal "There", test_node.draft.body
  end

  def test_update_a_draft_with_changing_the_template
    test_node = Node.root.children.create! :slug => "test_node"

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

    test_node = Node.root.children.create! :slug => "test_node", :staged_slug => "peter_pan"

    put :publish, :id => test_node.id

    test_node.reload
    assert_equal "peter_pan", test_node.slug
    assert_equal "peter_pan", test_node.unique_name
  end

  test "publish draft with staged_slug with more levels of nodes" do
    login_as :quentin

    test_node = Node.root.children.create! :slug => "test_node", :staged_slug => "peter_pan"
    test_node2 = test_node.children.create! :slug => "test_node2"

    put :publish, :id => test_node.id

    test_node.reload; test_node2.reload
    assert_equal "peter_pan/test_node2", test_node2.unique_name
    assert_equal "peter_pan", test_node.unique_name
  end

  test "publish draft with staged_parent_id" do
    login_as :quentin

    parent = Node.root.children.create! :slug => "parent"
    test_node = Node.root.children.create! :slug => "test_node", :staged_parent_id => parent.id
    test_node2 = test_node.children.create! :slug => "test_node2"

    put :publish, :id => test_node.id

    test_node.reload; test_node2.reload
    assert_equal "parent/test_node", test_node.unique_name
    assert_equal "parent/test_node/test_node2", test_node2.unique_name
  end

  test "publish draft with staged_parent_id and staged_slug" do
    login_as :quentin

    parent = Node.root.children.create! :slug => "parent"

    test_node = Node.root.children.create!(
      :slug => "test_node",
      :staged_parent_id => parent.id,
      :staged_slug => "peter_pan"
    )

    test_node2 = test_node.children.create! :slug => "test_node2"

    put :publish, :id => test_node.id

    test_node.reload; test_node2.reload
    assert_equal "parent/peter_pan", test_node.unique_name
    assert_equal "parent/peter_pan/test_node2", test_node2.unique_name
  end

  test "show node with empty draft" do
    login_as :quentin
    assert_not_nil node = create_node_with_draft
    get :show, :id => node.id
    assert_response :success
  end

  test "show node with published draft" do
    login_as :quentin
    node = create_node_with_published_page
    get :show, :id => node.id
    assert_response :success
    assert_select "td", :text => "Test", :count =>  3
  end

  test "unlocking a locked node" do
    login_as :quentin
    node = create_node_with_published_page
    node.find_or_create_draft User.first

    assert node.locked?

    get :unlock, :id => node.id
    assert_response :redirect
    assert !node.reload.locked?
  end

  test "unlocking an already unlocked node" do
    login_as :quentin
    node = create_node_with_published_page

    get :unlock, :id => node.id
    assert_response :redirect
    assert_equal "Already unlocked", @response.flash[:notice]
  end

  test "updating a node by changing its parent" do
    Node.root.descendants.destroy_all
    login_as :quentin
    node = create_node_with_published_page
    node.find_or_create_draft User.first

    other_node = Node.root.children.create( :slug => "other" )

    node.staged_parent_id = other_node.id
    node.publish_draft!

    assert Node.valid?
  end

  test "editing the initial draft sets the author to current_user" do
    login_as :quentin
    Node.root.descendants.destroy_all
    node  = create_node_with_draft
    get :edit, :id => node.id
    assert_equal "quentin", node.draft.user.login
  end

  test "updating the author of a node with existing head" do
    login_as :quentin
    Node.root.descendants.destroy_all
    node  = create_node_with_published_page
    assert_equal "quentin", node.head.user.login
    node.find_or_create_draft users(:quentin)
    assert node.draft.valid?
    assert node.valid?

    put :update, :id => node.id, :page => {:user_id => users(:aaron).id}
    assert_response :redirect
    assert_equal "aaron", node.reload.draft.user.login
  end

  test "updating an existing page should not modify published_at" do
    login_as :quentin
    Node.root.descendants.destroy_all
    node  = create_node_with_published_page

    get :edit, :id => node.id
    assert_response :success

    put :publish, :id => node.id

    node.reload
    assert_equal node.pages[0].published_at, node.pages[1].published_at
  end

  test "updating an exisiting page should not alter the author" do
    login_as :aaron
    Node.root.descendants.destroy_all
    node  = create_node_with_published_page
    get :edit,    :id => node.id

    put :publish, :id => node.id

    node.reload
    assert_equal node.pages[0].user, node.pages[1].user
  end

  test "editor and author are the same on a new node" do
    login_as :quentin
    node = create_node_with_draft
    get :edit, :id => node.id

    node.reload
    assert_equal "quentin", node.draft.user.login
    assert_equal "quentin", node.draft.editor.login
  end

  test "creating new draft alters the editor but keeps the author" do
    node = create_node_with_published_page
    assert_equal "quentin", node.head.user.login

    login_as :aaron
    get :edit,  :id => node.id

    node.reload
    assert_equal "quentin", node.head.user.login
    assert_equal "aaron",   node.draft.editor.login
  end

  test "unlocking and relocking changes editor if done by another user" do
    node  = create_node_with_published_page
    draft = node.find_or_create_draft users(:quentin)
    assert_equal draft.user.login, draft.editor.login
    assert node.locked?
    node.unlock!

    login_as :aaron
    get :edit, :id => node.id

    node.reload
    assert_equal "quentin", node.draft.user.login
    assert_equal "aaron", node.draft.editor.login
  end
end
