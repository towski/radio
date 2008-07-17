require File.dirname(__FILE__) + '/../test_helper'
require 'library_controller'

# Re-raise errors caught by the controller.
class LibraryController; def rescue_action(e) raise e end; end

class LibraryControllerTest < Test::Unit::TestCase
  def setup
    @controller = LibraryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_update
    get :update_library
  end
end
