require 'test_helper'

class NodesControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  def test_get_index
    login_as :quentin
    get :index
    assert_response :success
  end
  
  def test_update_a_draft
    test_node = Node.create! :slug => "test_node"
    test_node.move_to_child_of Node.root
    
    login_as :quentin
    
    
  end
end
