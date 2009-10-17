require 'test_helper'

class ContentControllerTest < ActionController::TestCase

  def setup
    @root = Node.find(1)
    @first_child = Node.find(2)
    @second_child = Node.find(3)
    
    @user1 = User.create :login => 'demo', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
    @user2 = User.create :login => 'show', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
  end

  def test_custom_page_route
    assert_recognizes({ :controller => 'content', :action => 'render_page', :locale => 'de', :page_path => ['foo', 'bar'] }, '/de/foo/bar')
    assert_recognizes({ :controller => 'content', :action => 'render_page', :locale => 'en', :page_path => ['home'] }, '/en/home')
  end
  
  def test_render_404_when_no_page_was_found
    get :render_page, :language => 'de', :page_path => ["wrong_path"]
    assert_response 404
  end
  
  def test_rendering_a_page
    assert Node.valid?
    assert_not_nil first_child = Node.find_by_slug("first_child")
    page = first_child.pages.create :title => "First Child"
    first_child.head = page
    first_child.save!
    
    get :render_page, :language => 'de', :page_path => ["first_child"]
    assert_response :success
    assert_equal "layouts/application", @response.layout
  end
  
  def test_page_containing_aggregator
    assert_not_nil Node.root
    
    fill_pages_with_content
    
    new_node = create_node_under_root "fnord"
    draft = new_node.find_or_create_draft @user1
    draft.body = '<aggregate tags="update" limit="20" />'
    draft.save
    new_node.publish_draft!
    
    get :render_page, :locale => 'de', :page_path => ["fnord"]
    assert_response :success
    
    assert_select("h2", "one")
    assert_select("h2", "two")
  end
  
  def test_page_containing_aggregator_with_custom_template
    fill_pages_with_content
    
    new_node = create_node_under_root "fnord"
    draft = new_node.find_or_create_draft @user1
    draft.body = '<aggregate tags="update" limit="20" partial="sidebar_title_only" />'
    draft.save
    new_node.publish_draft!
    
    get :render_page, :locale => 'de', :page_path => ["fnord"]
    assert_response :success
    
    assert_select(".sidebar_headline", "one")
    assert_select(".sidebar_headline", "two")
  end
  
  def test_nonexistant_custom_template_defaults_to_standard_template
    new_node = create_node_under_root "fnord"
    draft = new_node.find_or_create_draft @user1
    draft.template_name = "huchibu"
    draft.save
    new_node.publish_draft!
    
    get :render_page, :locale => 'de', :page_path => ["fnord"]
    assert_response :success
    assert_template "custom/page_templates/public/standard_template.html.erb"
  end
  
  def test_custom_template_no_date_and_author
    new_node = create_node_under_root "fnord"
    draft = new_node.find_or_create_draft @user1
    draft.template_name = "no_date_and_author"
    draft.save
    new_node.publish_draft!
    
    get :render_page, :locale => 'de', :page_path => ["fnord"]
    assert_response :success
    assert_template "custom/page_templates/public/no_date_and_author.html.erb"
  end
  
  protected
  
    def create_node_under_root slug
      node = Node.root.children.create! :slug => slug
      node
    end
  
    def fill_pages_with_content 
      d1 = @first_child.find_or_create_draft @user1
      d1.title = "one"
      d1.tag_list = "update"
      d1.save
      @first_child.publish_draft!

      d2 = @second_child.find_or_create_draft @user1
      d2.title = "two"
      d2.tag_list = "update"
      d2.save
      @second_child.publish_draft!
    end
end
