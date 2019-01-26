require 'test_helper'

class MappingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mappings_index_url
    assert_response :success
  end

  test "should get create" do
    get mappings_create_url
    assert_response :success
  end

  test "should get update" do
    get mappings_update_url
    assert_response :success
  end

  test "should get edit" do
    get mappings_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get mappings_destroy_url
    assert_response :success
  end

end
