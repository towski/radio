require File.dirname(__FILE__) + '/../test_helper'
require 'seeder_controller'

# Re-raise errors caught by the controller.
class SeederController; def rescue_action(e) raise e end; end

class SeederControllerTest < Test::Unit::TestCase
  def setup
    @controller = SeederController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
