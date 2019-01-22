require 'test_helper'

class CloudbedsControllerTest < ActionDispatch::IntegrationTest
  test "should get oauth_callback" do
    get cloudbeds_oauth_callback_url
    assert_response :success
  end

end
