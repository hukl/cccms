require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  def setup
    @user1 = User.create :login => 'demo', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
    @user2 = User.create :login => 'show', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
  end
  
  def test_aggregation
    # Create two nodes and move them beneath the root node
    n1 = Node.root.children.create! :slug => "one"
    n2 = Node.root.children.create! :slug => "two"
    
    # get the drafts and assign a user to it
    assert_not_nil d1 = n1.find_or_create_draft( @user1 )
    assert_not_nil d3 = n2.find_or_create_draft( @user1 )
    
    # tag and double publish so we have 4 pages tagged with "update"
    d1.tag_list = "update"
    d1.save
    n1.publish_draft!
  
    d2 = n1.find_or_create_draft @user1
    n1.publish_draft!
    
    
    d3.tag_list = "update, pressemitteilung"
    d3.save
    n2.publish_draft!
  
    d4 = n2.find_or_create_draft @user1
    n2.publish_draft!
    
    # Set up two options hashes for the assertions
    options1 = {
      :tags => "update"
    }
    
    options2 = {
      :tags => "update, pressemitteilung"
    }
    
    assert_equal 2, Page.aggregate( options1 ).length
    assert_equal 1, Page.aggregate( options2 ).length
    assert_equal 4, Page.find_tagged_with( "update" ).length
    assert_equal [d2.id, d4.id], Page.aggregate( options1 ).map {|x| x.id}
  end
  
  def test_before_save_rewrite_links_in_body
    n = Node.root.children.create :slug => "link_test"
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save!
    
    assert_equal after, d.body
  end
  
  def test_before_save_rewrite_links_in_body_if_no_locale_prefix_present
    n = Node.root.children.create :slug => "link_test"
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save
    
    assert_equal after, d.body
  end
  
  def test_before_save_rewrite_links_skips_on_external_links
    n = Node.root.children.create :slug => "link_test"
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"http://www.ccc.de/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"http://www.ccc.de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save
    
    assert_equal after, d.body
  end
  
  def test_find_with_outdated_translations
    Node.delete_all
    Page.delete_all
    I18n.locale = :de
    
    assert_not_nil page = Page.create!( :title => "Hallo" )
    page.reload
    assert_equal 2, page.globalize_translations.size
    assert_equal [], Page.find_with_outdated_translations
    
    I18n.locale = :en
    page.title = "Hello"
    page.save
    
    assert_equal 3, page.globalize_translations.size
    assert_equal 0, Page.find_with_outdated_translations.size
    
    english = *page.globalize_translations.select {|x| x.locale == :en}
    PageTranslation.record_timestamps = false
    english.update_attributes(:updated_at => (Time.now+25.hours))    
    PageTranslation.record_timestamps = true
    assert_equal 1, Page.find_with_outdated_translations.count
    
    I18n.locale = :de
    page2 = Page.create!( :title => "Hallo2" )
    I18n.locale = :en
    page2.title = "Hello2"
    page2.save!
    
    assert_equal 0, Page.find_with_outdated_translations(:delta_time => 23.days).count
    assert_equal 1, Page.find_with_outdated_translations(:delta_time => 23.minutes).count
    assert_equal 2, Page.count
  end
end
