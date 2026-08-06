# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGIN', 'http://localhost:5173')

    resource '/v1/*',
             headers: :any,
             methods: %i[get post delete options]
  end
end
