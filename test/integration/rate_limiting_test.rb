require 'test_helper'

class RateLimitingTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.cache.store.clear
  end

  test 'allows requests under the rate limit' do
    get sismos_url
    assert_response :success
  end

  test 'returns 429 too many requests when general rate limit is exceeded' do
    travel_to Time.utc(2026, 8, 4, 12, 0, 0) do
      60.times do
        get sismos_url
        assert_response :success
      end

      get sismos_url
      assert_response :too_many_requests

      json = JSON.parse(response.body)
      assert json.key?('error')
      assert_includes json['error'], 'Rate limit exceeded'
      assert response.headers.key?('Retry-After')
    end
  end

  test 'returns 429 when POST report rate limit is exceeded' do
    sismo = sismos(:one)

    travel_to Time.utc(2026, 8, 4, 12, 0, 0) do
      5.times do
        post sismo_reports_url(sismo), params: { felt: true, intensity: 'moderate' }, as: :json
        assert_response :created
      end

      post sismo_reports_url(sismo), params: { felt: true, intensity: 'moderate' }, as: :json
      assert_response :too_many_requests

      json = JSON.parse(response.body)
      assert json.key?('error')
      assert_includes json['error'], 'Rate limit exceeded'
    end
  end

  test 'returns 429 when POST report rate limit is exceeded on format-suffixed path' do
    sismo = sismos(:one)

    travel_to Time.utc(2026, 8, 4, 12, 0, 0) do
      5.times do
        post "#{sismo_reports_path(sismo)}.json", params: { felt: true, intensity: 'moderate' }, as: :json
        assert_response :created
      end

      post "#{sismo_reports_path(sismo)}.json", params: { felt: true, intensity: 'moderate' }, as: :json
      assert_response :too_many_requests

      json = JSON.parse(response.body)
      assert json.key?('error')
      assert_includes json['error'], 'Rate limit exceeded'
    end
  end

  test 'returns 429 when POST device rate limit is exceeded' do
    travel_to Time.utc(2026, 8, 4, 12, 0, 0) do
      5.times do |index|
        post devices_url, params: { fcm_token: "token-#{index}" }, as: :json
        assert_response :success
      end

      post devices_url, params: { fcm_token: 'token-5' }, as: :json
      assert_response :too_many_requests
    end
  end
end
