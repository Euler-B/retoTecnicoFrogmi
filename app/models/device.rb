class Device < ApplicationRecord
  MAX_FCM_TOKEN_LENGTH = 255

  validates :fcm_token,
            presence: true,
            uniqueness: true,
            length: { maximum: MAX_FCM_TOKEN_LENGTH },
            format: { without: /\s/ }
  validates :platform, inclusion: { in: %w[web] }
end
