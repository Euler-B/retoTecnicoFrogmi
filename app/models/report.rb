class Report < ApplicationRecord
  belongs_to :sismo

  # "Did You Feel It?"-style structured intensity scale, based on the
  # USGS DYFI scheme. Deliberately a closed set of options (no free text)
  # to avoid spam/abuse on a public, unauthenticated endpoint.
  INTENSITY_LEVELS = %w[not_felt weak light moderate strong severe].freeze

  validates :felt, inclusion: { in: [true, false] }
  validates :intensity, inclusion: { in: INTENSITY_LEVELS }
end
