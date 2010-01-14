ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def create_node_with_published_page
    node = create_node_with_draft
    draft = node.draft
    draft.title = "Test"
    draft.abstract = "Test"
    draft.body = "Test"
    draft.user = users(:quentin)
    node.publish_draft!
    node
  end
  
  def create_node_with_draft
    Node.root.children.create :slug => "test_node"
  end
end
