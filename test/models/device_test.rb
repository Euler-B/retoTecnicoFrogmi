require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  test 'requires a unique FCM token' do
    device = Device.new(fcm_token: 'token-1')
    assert device.save!

    duplicate = Device.new(fcm_token: 'token-1')
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:fcm_token], 'has already been taken'
  end

  test 'defaults to the web platform' do
    assert_equal 'web', Device.new(fcm_token: 'token-1').platform
  end

  test 'only accepts the web platform' do
    device = Device.new(fcm_token: 'token-1', platform: 'ios')

    assert_not device.valid?
    assert_includes device.errors[:platform], 'is not included in the list'
  end

  test 'rejects invalid FCM tokens containing whitespace, control characters, or exceeding maximum length' do
    invalid_tokens = [
      'token with space',
      "token\nwith\nnewline",
      "token\rwith\rreturn",
      "token\twith\ttab",
      'a' * (Device::MAX_FCM_TOKEN_LENGTH + 1)
    ]

    invalid_tokens.each do |invalid_token|
      device = Device.new(fcm_token: invalid_token)
      assert_not device.valid?, "Expected device with token #{invalid_token.inspect} to be invalid"
      assert_not_empty device.errors[:fcm_token]
    end
  end
end
