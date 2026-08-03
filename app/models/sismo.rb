class Sismo < ApplicationRecord
  has_many :reports, dependent: :destroy

  validates :title, :url, :place, :magType, :latitude, :longitude, presence: true
  validates :mag, inclusion: { in: -1.0..10.0 }
  validates :latitude, inclusion: { in: -90.0..90.0 }
  validates :longitude, inclusion: { in: -180.0..180.0 }
end
