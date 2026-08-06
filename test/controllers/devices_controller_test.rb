require 'test_helper'

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_token = 'test-admin-token'
    ENV['ADMIN_TOKEN'] = @admin_token
  end

  teardown do
    ENV.delete('ADMIN_TOKEN')
  end

  test 'creates a device publicly and does not duplicate its token' do
    assert_difference('Device.count', 1) do
      post devices_url, params: { fcm_token: 'token-1' }, as: :json
    end
    assert_response :created

    post devices_url, params: { fcm_token: 'token-1' }, as: :json
    assert_response :success
    assert_equal 1, Device.where(fcm_token: 'token-1').count
  end

  test 'rejects invalid devices' do
    post devices_url, params: { fcm_token: '' }, as: :json

    assert_response :unprocessable_entity
  end

  test 'requires the admin token to list devices' do
    get devices_url
    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized' }, JSON.parse(response.body))

    get devices_url, headers: { 'X-Admin-Token' => @admin_token }
    assert_response :success
    assert_includes response.headers['Cache-Control'], 'no-store'
    assert_equal({ 'data' => [] }, JSON.parse(response.body))
  end

  test 'requires the admin token to destroy a device' do
    device = Device.create!(fcm_token: 'token-1')

    delete device_url(device)
    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized' }, JSON.parse(response.body))

    delete device_url(device), headers: { 'X-Admin-Token' => @admin_token }
    assert_response :no_content
    assert_not Device.exists?(device.id)
  end

  test 'rejects unauthorized requests with mismatched token length or invalid token' do
    get devices_url, headers: { 'X-Admin-Token' => 'short' }
    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized' }, JSON.parse(response.body))

    get devices_url, headers: { 'X-Admin-Token' => 'wrong-admin-token' }
    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized' }, JSON.parse(response.body))
  end

  test 'fails closed when ADMIN_TOKEN is not configured' do
    ENV.delete('ADMIN_TOKEN')

    get devices_url, headers: { 'X-Admin-Token' => 'test-admin-token' }

    assert_response :unauthorized
    assert_equal({ 'error' => 'Unauthorized' }, JSON.parse(response.body))
  end

  test 'rescues ActiveRecord::RecordNotUnique on concurrent device creation' do
    existing = Device.create!(fcm_token: 'token-concurrent')

    begin
      Device.define_method(:save) { raise ActiveRecord::RecordNotUnique }
      post devices_url, params: { fcm_token: 'token-concurrent' }, as: :json
    ensure
      Device.remove_method(:save)
    end

    assert_response :ok
    assert_equal({ 'data' => { 'id' => existing.id, 'type' => 'device' } }, JSON.parse(response.body))
  end

  test 'supports CORS preflight for DELETE requests' do
    device = Device.create!(fcm_token: 'token-cors')
    origin = ENV.fetch('ALLOWED_ORIGIN', 'http://localhost:5173')

    process :options, device_url(device), headers: {
      'Origin' => origin,
      'Access-Control-Request-Method' => 'DELETE'
    }

    assert_response :success
    assert_includes response.headers['Access-Control-Allow-Methods'], 'DELETE'
  end
end
