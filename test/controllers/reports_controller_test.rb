require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sismo = sismos(:one)
  end

  test 'should create report with valid felt and intensity' do
    assert_difference('Report.count', 1) do
      post sismo_reports_url(@sismo), params: { felt: true, intensity: 'moderate' }, as: :json
    end
    assert_response :created

    json = JSON.parse(response.body)
    assert_equal 'report', json['data']['type']
    assert_equal 'moderate', json['data']['attributes']['intensity']
    assert_equal @sismo.id, json['data']['attributes']['sismo_id']
  end

  test 'should not create report with invalid intensity' do
    assert_no_difference('Report.count') do
      post sismo_reports_url(@sismo), params: { felt: true, intensity: 'catastrophic' }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'should return not found for missing sismo' do
    assert_no_difference('Report.count') do
      post sismo_reports_url(sismo_id: 99_999), params: { felt: true, intensity: 'weak' }, as: :json
    end
    assert_response :not_found
  end
end
