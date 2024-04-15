require 'httparty'
require 'json'

namespace :sismo do
  desc 'Fetch and persist sismo data'
  task fetch_data: :environment do
    url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson'
    response = HTTParty.get(url)
    data = JSON.parse(response.body)

    new_records = 0
    duplicate_records = 0
    invalid_records = 0

    data['features'].each do |feature|
      properties = feature['properties']
      geometry = feature['geometry']['coordinates']

      title = properties['title']
      existing_sismo = Sismo.find_by(title: title)

      if existing_sismo
        duplicate_records += 1
        puts "Registro duplicado: #{title}"
      else
        sismo = Sismo.new(
          title: title,
          url: properties['url'],
          place: properties['place'],
          magType: properties['magType'],
          mag: properties['mag'],
          tsunami: properties['tsunami'],
          external_id: feature['id'],
          latitude: geometry[1],
          longitude: geometry[0]
        )

        if sismo.valid?
          if sismo.save
            new_records += 1
          else
            puts "Error al guardar el registro: #{sismo.errors.full_messages}"
          end
        else
          if sismo.errors[:mag].include?("La magnitud del sismo debe estar entre -1.0 y 10.0")
            invalid_records += 1
          else
            duplicate_records += 1
            puts "Registro duplicado: #{sismo.title}"
          end
        end
      end
    end

    puts "Nuevos registros guardados: #{new_records}"
    puts "Registros duplicados omitidos: #{duplicate_records}"
    puts "Registros inválidos omitidos: #{invalid_records}"
    puts "Datos de los sismos obtenido, validados, y persistidos"
  end
end
