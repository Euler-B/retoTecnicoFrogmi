require 'test_helper'

class SismosControllerFiltersTest < ActionDispatch::IntegrationTest
  # ── Date range filters ────────────────────────────────────────────
  test 'filters by date_from' do
    get sismos_url, params: { filters: { date_from: 2.days.ago.iso8601 } }
    json = JSON.parse(response.body)

    assert_response :success
    assert json['data'].length < Sismo.count
    json['data'].each do |sismo|
      assert Time.parse(sismo['attributes']['time']) >= 2.days.ago.beginning_of_day
    end
  end

  test 'filters by date_to' do
    get sismos_url, params: { filters: { date_to: 5.days.ago.iso8601 } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 2, json['data'].length
    json['data'].each do |sismo|
      assert Time.parse(sismo['attributes']['time']) <= 5.days.ago.end_of_day
    end
  end

  test 'filters by date range (date_from and date_to combined)' do
    get sismos_url, params: { filters: { date_from: 5.days.ago.iso8601, date_to: Time.current.iso8601 } }
    json = JSON.parse(response.body)

    assert_response :success
    assert json['pagination']['total'] >= 1
  end

  test 'normalizes date-only date_to filter to end of day' do
    target_date = 1.day.ago.to_date.iso8601
    get sismos_url, params: { filters: { date_to: target_date } }
    json = JSON.parse(response.body)

    assert_response :success
    assert(json['data'].any? { |sismo| sismo['id'] == sismos(:two).id })
  end

  test 'supports date-only date_from filter' do
    target_date = 3.days.ago.to_date.iso8601
    get sismos_url, params: { filters: { date_from: target_date } }
    json = JSON.parse(response.body)

    assert_response :success
    json['data'].each do |sismo|
      assert Time.parse(sismo['attributes']['time']) >= 3.days.ago.beginning_of_day
    end
  end

  test 'returns 400 bad request for malformed date_from' do
    get sismos_url, params: { filters: { date_from: 'invalid-date' } }
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal 'Invalid date format for filter: date_from', json['error']
  end

  test 'returns 400 bad request for malformed date_to' do
    get sismos_url, params: { filters: { date_to: '2026-99-99' } }
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal 'Invalid date format for filter: date_to', json['error']
  end

  # ── Tsunami filter ────────────────────────────────────────────────
  test 'filters by tsunami true' do
    get sismos_url, params: { filters: { tsunami: 'true' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, json['data'].length
    json['data'].each do |sismo|
      assert_equal true, sismo['attributes']['tsunami']
    end
  end

  test 'filters by tsunami false' do
    get sismos_url, params: { filters: { tsunami: 'false' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 3, json['data'].length
    json['data'].each do |sismo|
      assert_equal false, sismo['attributes']['tsunami']
    end
  end

  test 'treats blank tsunami filter as absent' do
    get sismos_url, params: { filters: { tsunami: '' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal Sismo.count, json['pagination']['total']
  end

  test 'returns 400 bad request for invalid tsunami filter value' do
    get sismos_url, params: { filters: { tsunami: 'unsupported' } }
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal 'Invalid value for filter: tsunami', json['error']
  end

  # ── Combined filters ──────────────────────────────────────────────
  test 'applies multiple filters simultaneously' do
    get sismos_url, params: { filters: { mag_type: 'ml', mag_min: '1.0', tsunami: 'false' } }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, json['data'].length
    json['data'].each do |sismo|
      assert_equal 'ml', sismo['attributes']['mag_type']
      assert_operator sismo['attributes']['magnitude'], :>=, 1.0
      assert_equal false, sismo['attributes']['tsunami']
    end
  end

  # ── Pagination with filters ───────────────────────────────────────
  test 'pagination metadata is correct with filters' do
    get sismos_url, params: { filters: { mag_type: 'ml' }, page: 1, per_page: 1 }
    json = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, json['pagination']['current_page']
    assert_equal 1, json['pagination']['per_page']
    assert_equal 1, json['data'].length
  end

  # ── JSON envelope structure ────────────────────────────────────────
  test 'response follows the JSON envelope structure' do
    get sismos_url
    json = JSON.parse(response.body)

    first = json['data'].first
    assert first.key?('id')
    assert_equal 'feature', first['type']
    assert first.key?('attributes')
    assert first.key?('links')
    assert first['attributes'].key?('coordinates')
  end
end
