require 'test_helper'

class SismoTest < ActiveSupport::TestCase
  # ── Validations ────────────────────────────────────────────────────
  test 'valid sismo is valid' do
    sismo = sismos(:one)
    assert sismo.valid?
  end

  test 'requires title' do
    sismo = Sismo.new(url: 'http://example.com', place: 'Test', magType: 'ml', mag: 1.0, latitude: 0, longitude: 0)
    assert_not sismo.valid?
    assert_includes sismo.errors[:title], "can't be blank"
  end

  test 'rejects magnitude out of range' do
    sismo = sismos(:one)
    sismo.mag = 11.0
    assert_not sismo.valid?
  end

  test 'rejects latitude out of range' do
    sismo = sismos(:one)
    sismo.latitude = 95.0
    assert_not sismo.valid?
  end

  test 'rejects longitude out of range' do
    sismo = sismos(:one)
    sismo.longitude = 200.0
    assert_not sismo.valid?
  end

  # ── Scopes ─────────────────────────────────────────────────────────
  test 'by_mag_type returns matching records' do
    results = Sismo.by_mag_type(['ml'])
    assert(results.all? { |s| s.magType == 'ml' })
    assert_equal 2, results.count
  end

  test 'by_mag_type with multiple types' do
    results = Sismo.by_mag_type(%w[ml mww])
    assert(results.all? { |s| %w[ml mww].include?(s.magType) })
    assert_equal 3, results.count
  end

  test 'by_mag_min filters correctly' do
    results = Sismo.by_mag_min(5.0)
    assert(results.all? { |s| s.mag >= 5.0 })
    assert_equal 2, results.count
  end

  test 'by_mag_max filters correctly' do
    results = Sismo.by_mag_max(3.0)
    assert(results.all? { |s| s.mag <= 3.0 })
    assert_equal 2, results.count
  end

  test 'by_mag_min raises ArgumentError for malformed string' do
    assert_raises(ArgumentError) do
      Sismo.by_mag_min('abc').to_a
    end
  end

  test 'by_mag_max raises ArgumentError for malformed string' do
    assert_raises(ArgumentError) do
      Sismo.by_mag_max('1abc').to_a
    end
  end

  test 'by_mag_min and by_mag_max compose correctly' do
    results = Sismo.by_mag_min(2.0).by_mag_max(6.0)
    assert(results.all? { |s| s.mag.between?(2.0, 6.0) })
    assert_equal 2, results.count
  end

  test 'by_date_from filters correctly' do
    results = Sismo.by_date_from(2.days.ago)
    assert(results.all? { |s| s.created_at >= 2.days.ago })
    assert_equal 1, results.count
  end

  test 'by_date_to filters correctly' do
    results = Sismo.by_date_to(5.days.ago)
    assert(results.all? { |s| s.created_at <= 5.days.ago })
    assert_equal 2, results.count
  end

  test 'by_tsunami true returns only tsunami events' do
    results = Sismo.by_tsunami('true')
    assert(results.all?(&:tsunami?))
    assert_equal 1, results.count
  end

  test 'by_tsunami false returns non-tsunami events including nil tsunami' do
    sismo_nil = Sismo.create!(
      title: 'M 3.0 - Test NULL tsunami',
      url: 'https://example.com/test_null',
      place: 'Test Place',
      magType: 'ml',
      mag: 3.0,
      latitude: 0,
      longitude: 0,
      tsunami: nil
    )

    results = Sismo.by_tsunami('false')
    assert(results.none?(&:tsunami?))
    assert_includes results, sismo_nil
    assert_equal 4, results.count
  end

  # ── Association ────────────────────────────────────────────────────
  test 'has many reports' do
    sismo = sismos(:one)
    assert_respond_to sismo, :reports
  end

  test 'destroying sismo destroys associated reports' do
    sismo = sismos(:one)
    assert_difference('Report.count', -sismo.reports.count) do
      sismo.destroy
    end
  end
end
