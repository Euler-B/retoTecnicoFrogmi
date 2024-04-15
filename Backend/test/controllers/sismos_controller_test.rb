require "test_helper"

class SismosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sismos_index_url
    assert_response :success
  end
end
