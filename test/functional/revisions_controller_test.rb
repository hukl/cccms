require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  
  def setup
    Node.root.descendants.destroy_all
    @user = User.find_by_login("aaron")
    @node = Node.root.children.create!( :slug => "version_me" )
    
    draft = @node.draft
    draft.body = "first"
    @node.publish_draft!
    @node.find_or_create_draft @user
    draft = @node.draft
    draft.update_attributes(:body => "second")
    @node.publish_draft!
  end
  
  test "setup" do
    assert_equal 2, Node.count
    assert_equal 2, @node.pages.count
    assert_equal ["first", "second"], @node.pages.map {|p| p.body}
  end
  
  test "get list of revisions for a given node" do
    login_as :quentin
    get :index, :node_id => @node.id
    assert_response :success
    assert_select ".revision", 2
  end
  
  test "showing one revision" do
    login_as :quentin
    get :show, :node_id => @node.id, :id => @node.pages.last.id
    assert_response :success
    assert_select "strong", "Body"
    assert_select "td", {:count => 1, :text => "second"}
  end
  
  test "diffing two revisions" do
    login_as :quentin
    post(
      :diff,
      :node_id => @node.id,
      :start_revision => @node.pages.first.revision, 
      :end_revision => @node.pages.last.revision
    )
    assert_response :success
  end
  
  test "restoring a revision" do
    assert_equal "second", @node.head.body
    
    login_as :aaron
    put( :restore, :node_id => @node.id, :id => @node.pages.first.id )
    
    @node.reload
    assert_equal @node.head, @node.pages.first
    assert_equal "first", @node.head.reload.body
  end
end
