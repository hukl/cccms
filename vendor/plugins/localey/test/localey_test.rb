require 'test_helper'

class LocaleyTest < ActiveSupport::TestCase
  
  def setup
    @app = Localey.new Object.new
    @env = {}
    I18n.locale = :en
    I18n.available_locales = [:de, :en, :"en-US", :fr]
  end
  
  test "filtering a basic url with a simple locale" do
    set_path_info_and_filter( "/de/foo/bar" )
    assert_equal "/foo/bar", @env['PATH_INFO']
    assert_equal :de, I18n.locale
  end
  
  test "filtering a basic url with an extended locale" do
    set_path_info_and_filter( "/en-US/foo/bar" )
    assert_equal "/foo/bar", @env['PATH_INFO']
    assert_equal :"en-US", I18n.locale
  end
  
  test "urls without a locale should be ignored" do
    set_path_info_and_filter( "/foo/bar" )
    assert_equal "/foo/bar", @env['PATH_INFO']
    assert_equal :en, I18n.locale
  end
  
  test "filtering root path should do nothing" do
    set_path_info_and_filter( "/" )
    assert_equal "/", @env['PATH_INFO']
    assert_equal :en, I18n.locale
  end
  
  def set_path_info_and_filter path
    @env['PATH_INFO'] = path
    @app.filter_locale( @env )
  end

end
