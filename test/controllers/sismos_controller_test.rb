require 'test_helper'

class SismosControllerTest < ActionDispatch::IntegrationTest
  # ── Basic endpoint ─────────────────────────────────────────────────
  test 'should get index' do
    get sismos_url
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?('data')
    assert json.key?('pagination')
  end

  test 'index returns all sismos when no filters applied' do
    get sismos_url
    json = JSON.parse(response.body)
    assert_equal Sismo.count, json['pagination']['total']
  end

  # ── mag_type filter ────────────────────────────────────────────────
  test 'filters by single mag_type' do
    get sismos_url, params: { filters: { mag_type: 'ml' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 2, json['data'].length
    json['data'].each do |sismo|
      assert_equal 'ml', sismo['attributes']['mag_type']
    end
  end

  test 'filters by multiple mag_types (comma-separated)' do
    get sismos_url, params: { filters: { mag_type: 'ml,mww' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 3, json['data'].length
    json['data'].each do |sismo|
      assert_includes %w[ml mww], sismo['attributes']['mag_type']
    end
  end

  test 'returns empty data for unknown mag_type' do
    get sismos_url, params: { filters: { mag_type: 'nonexistent' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_empty json['data']
    assert_equal 0, json['pagination']['total']
  end

  # ── Magnitude range filters ───────────────────────────────────────
  test 'filters by mag_min' do
    get sismos_url, params: { filters: { mag_min: '5.0' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 2, json['data'].length
    json['data'].each do |sismo|
      assert_operator sismo['attributes']['magnitude'], :>=, 5.0
    end
  end

  test 'filters by mag_max' do
    get sismos_url, params: { filters: { mag_max: '3.0' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 2, json['data'].length
    json['data'].each do |sismo|
      assert_operator sismo['attributes']['magnitude'], :<=, 3.0
    end
  end

  test 'filters by magnitude range (mag_min and mag_max combined)' do
    get sismos_url, params: { filters: { mag_min: '2.0', mag_max: '6.0' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 2, json['data'].length
    json['data'].each do |sismo|
      mag = sismo['attributes']['magnitude']
      assert_operator mag, :>=, 2.0
      assert_operator mag, :<=, 6.0
    end
  end

  test 'returns empty data when magnitude range excludes all records' do
    get sismos_url, params: { filters: { mag_min: '9.5', mag_max: '10.0' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_empty json['data']
  end

  test 'returns 400 bad request for malformed mag_min' do
    get sismos_url, params: { filters: { mag_min: 'abc' } }
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal 'Invalid value for filter: mag_min', json['error']
  end

  test 'returns 400 bad request for malformed mag_max' do
    get sismos_url, params: { filters: { mag_max: '1abc' } }
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal 'Invalid value for filter: mag_max', json['error']
  end

  # ── Stats endpoint ────────────────────────────────────────────────
  test 'should get stats with calculated metrics' do
    get stats_sismos_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 'stats', json['data']['id']
    assert_equal 'stats', json['data']['type']

    attrs = json['data']['attributes']
    assert_equal Sismo.count, attrs['total_sismos']
    assert_equal Sismo.where('created_at >= ?', 24.hours.ago).count, attrs['last_24h_count']
    assert_equal 1, attrs['tsunami_count']
    assert_equal 7.8, attrs['max_magnitude']['magnitude']
    assert attrs['by_mag_type'].key?('ml')
  end
end
