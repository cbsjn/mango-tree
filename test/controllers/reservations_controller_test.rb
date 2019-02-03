require 'test_helper'

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reservations_index_url
    assert_response :success
  end

  test "should get sync_invoice_to_quickbook" do
    get reservations_sync_invoice_to_quickbook_url
    assert_response :success
  end

end
