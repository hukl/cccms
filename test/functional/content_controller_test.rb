require 'test_helper'

class ContentControllerTest < ActionController::TestCase

  def test_custom_page_route
    assert_recognizes({ :controller => 'content', :action => 'render_page', :language => 'de', :pagepath => ['foo', 'bar'] }, '/de/foo/bar')
    assert_recognizes({ :controller => 'content', :action => 'render_page', :language => 'en', :pagepath => ['home'] }, '/en/home')
  end
  
  # def test_rendering_a_page
  #   Page.destroy_all
  #   load_atp 'content_controller'
  #   Page.all.each {|x| x.update_unique_name; x.save}
  #   assert Page.valid?
  #   assert_not_nil Page.find_by_title("short name yo")
  #   get :render_page, :language => 'de', :pagepath => ["shortname","barfoo"]
  #   assert_response :success
  #   assert_template 'wtp_eins'
  #   assert_equal "page_templates/layouts/screen", @response.layout
  # end
end
