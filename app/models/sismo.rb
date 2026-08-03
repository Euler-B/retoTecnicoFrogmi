class Sismo < ApplicationRecord
  has_many :reports, dependent: :destroy

  validates :title, :url, :place, :magType, :latitude, :longitude, presence: true
  validates :mag, inclusion: { in: -1.0..10.0 }
  validates :latitude, inclusion: { in: -90.0..90.0 }
  validates :longitude, inclusion: { in: -180.0..180.0 }

  # ── Filter scopes ──────────────────────────────────────────────────
  scope :by_mag_type, ->(types) { where(magType: types) }
  scope :by_mag_min, ->(min) { where('mag >= ?', Float(min)) }
  scope :by_mag_max, ->(max) { where('mag <= ?', Float(max)) }
  scope :by_date_from, ->(date) { where('created_at >= ?', date) }
  scope :by_date_to, ->(date) { where('created_at <= ?', date) }
  scope :by_tsunami, lambda { |val|
    tsunami = ActiveModel::Type::Boolean.new.cast(val)
    tsunami ? where(tsunami: true) : where(tsunami: [false, nil])
  }
end
