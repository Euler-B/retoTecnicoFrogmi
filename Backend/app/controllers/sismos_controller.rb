class SismosController < ApplicationController
  MAX_PER_PAGE = 1000
  def index
    filtered_sismos = filter_sismos

    paginated_sismos = filtered_sismos.paginate(page: params[:page], per_page: params[:per_page])

    paginated_sismos = paginated_sismos.per_page(MAX_PER_PAGE) if paginated_sismos.per_page > MAX_PER_PAGE

    serialized_sismos = serialize_sismos(paginated_sismos)

    render json: serialized_sismos
  end

  private

  def filter_sismos
    sismos = Sismo.all

    if params[:filters].present? && params[:filters][:mag_type].present?
      mag_types = params[:filters][:mag_type].split(',')
      sismos = sismos.where(magType: mag_types)
    end

    sismos
  end

  def serialize_sismos(sismos)
    serialized_sismos = sismos.map do |sismo|
      {
        id: sismo.id,
        type: "feature",
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
end
