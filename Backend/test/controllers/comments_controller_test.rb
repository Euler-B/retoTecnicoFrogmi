require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sismo = sismos(:one)
  end

  test 'should create comment with valid body' do
    assert_difference('Comment.count', 1) do
      post sismo_comments_url(@sismo), params: { body: 'Great resource!' }, as: :json
    end
    assert_response :created

    json = JSON.parse(response.body)
    assert_equal 'comment', json['data']['type']
    assert_equal 'Great resource!', json['data']['attributes']['body']
    assert_equal @sismo.id, json['data']['attributes']['sismo_id']
  end

  test 'should not create comment with empty body' do
    assert_no_difference('Comment.count') do
      post sismo_comments_url(@sismo), params: { body: '' }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'should return not found for missing sismo' do
    assert_no_difference('Comment.count') do
      post sismo_comments_url(sismo_id: 99_999), params: { body: 'test' }, as: :json
    end
    assert_response :not_found
  end
end
