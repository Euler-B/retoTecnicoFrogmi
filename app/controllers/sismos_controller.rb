class SismosController < ApplicationController
  MAX_PER_PAGE = 1000
  def index
    filtered_sismos = filter_sismos
    return if performed?

    paginated_sismos = filtered_sismos.paginate(page: params[:page], per_page: params[:per_page])

    paginated_sismos = paginated_sismos.per_page(MAX_PER_PAGE) if paginated_sismos.per_page > MAX_PER_PAGE

    serialized_sismos = serialize_sismos(paginated_sismos)

    render json: serialized_sismos
  end

  def stats
    stats_data = calculate_stats
    render json: serialize_stats(stats_data)
  end

  private

  def filter_sismos
    sismos = Sismo.all

    sismos = apply_mag_type_filter(sismos)
    sismos = apply_magnitude_range_filter(sismos)
    return unless sismos

    sismos = apply_date_range_filter(sismos)
    return unless sismos

    apply_tsunami_filter(sismos)
  end

  def apply_mag_type_filter(sismos)
    return sismos unless filter_param(:mag_type).present?

    mag_types = filter_param(:mag_type).split(',')
    sismos.by_mag_type(mag_types)
  end

  def apply_magnitude_range_filter(sismos)
    if filter_param(:mag_min).present?
      mag_min = parse_float_filter(filter_param(:mag_min))
      if mag_min.nil?
        render json: { error: 'Invalid value for filter: mag_min' }, status: :bad_request
        return nil
      end
      sismos = sismos.by_mag_min(mag_min)
    end

    if filter_param(:mag_max).present?
      mag_max = parse_float_filter(filter_param(:mag_max))
      if mag_max.nil?
        render json: { error: 'Invalid value for filter: mag_max' }, status: :bad_request
        return nil
      end
      sismos = sismos.by_mag_max(mag_max)
    end

    sismos
  end

  def parse_float_filter(value)
    return nil if value.blank?

    Float(value.to_s.strip)
  rescue ArgumentError, TypeError
    nil
  end

  def apply_date_range_filter(sismos)
    if filter_param(:date_from).present?
      date_from = parse_date_filter(filter_param(:date_from), is_date_to: false)
      unless date_from
        render json: { error: 'Invalid date format for filter: date_from' }, status: :bad_request
        return nil
      end
      sismos = sismos.by_date_from(date_from)
    end

    if filter_param(:date_to).present?
      date_to = parse_date_filter(filter_param(:date_to), is_date_to: true)
      unless date_to
        render json: { error: 'Invalid date format for filter: date_to' }, status: :bad_request
        return nil
      end
      sismos = sismos.by_date_to(date_to)
    end

    sismos
  end

  def parse_date_filter(value, is_date_to: false)
    return nil if value.blank?

    str = value.to_s.strip
    return parse_iso_date(str, is_date_to: is_date_to) if str.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    parse_datetime_string(str)
  end

  def parse_iso_date(str, is_date_to:)
    date = Date.iso8601(str)
    is_date_to ? date.in_time_zone.end_of_day : date.in_time_zone.beginning_of_day
  rescue StandardError
    nil
  end

  def parse_datetime_string(str)
    parsed = Time.zone.parse(str)
    return nil if parsed.nil? || parsed.year < 1000 || parsed.year > 9999

    parsed
  rescue StandardError
    nil
  end

  def apply_tsunami_filter(sismos)
    tsunami_param = filter_param(:tsunami)
    return sismos if tsunami_param.blank?

    tsunami_val = parse_boolean_filter(tsunami_param)
    if tsunami_val.nil?
      render json: { error: 'Invalid value for filter: tsunami' }, status: :bad_request
      return nil
    end

    sismos.by_tsunami(tsunami_val)
  end

  def parse_boolean_filter(value)
    str = value.to_s.strip.downcase
    return nil unless %w[true false 1 0 t f].include?(str)

    ActiveModel::Type::Boolean.new.cast(str)
  end

  def filter_param(key)
    filters = params[:filters]
    return nil unless filters.is_a?(ActionController::Parameters)

    filters[key]
  end

  def serialize_sismos(sismos)
    serialized_sismos = sismos.map do |sismo|
      {
        id: sismo.id,
        type: 'feature',
        attributes: {
          external_id: sismo.external_id,
          magnitude: sismo.mag,
          place: sismo.place,
          time: sismo.created_at.to_s,
          tsunami: sismo.tsunami?,
          mag_type: sismo.magType,
          title: sismo.title,
          coordinates: {
            longitude: sismo.longitude,
            latitude: sismo.latitude
          }
        },
        links: {
          external_url: sismo.url
        }
      }
    end

    {
      data: serialized_sismos,
      pagination: {
        current_page: sismos.current_page,
        total: sismos.total_entries,
        per_page: sismos.per_page
      }
    }
  end

  def calculate_stats
    max_sismo = Sismo.where.not(mag: nil).order(mag: :desc).first

    {
      total_sismos: Sismo.count,
      last_24h_count: Sismo.where('created_at >= ?', 24.hours.ago).count,
      tsunami_count: Sismo.by_tsunami('true').count,
      max_magnitude: serialize_max_magnitude(max_sismo),
      by_mag_type: Sismo.group(:magType).count
    }
  end

  def serialize_max_magnitude(sismo)
    return nil unless sismo

    {
      id: sismo.id,
      title: sismo.title,
      magnitude: sismo.mag,
      place: sismo.place,
      time: sismo.created_at.to_s
    }
  end

  def serialize_stats(stats_data)
    {
      data: {
        id: 'stats',
        type: 'stats',
        attributes: stats_data
      }
    }
  end
end
