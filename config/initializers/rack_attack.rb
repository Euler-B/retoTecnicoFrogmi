module Rack
  class Attack
    # Cache store for rate limit counters.
    # Uses RedisCacheStore if RACK_ATTACK_REDIS_URL or REDIS_URL is present.
    # Falls back gracefully to MemoryStore if Redis is not configured yet.
    redis_url = ENV['RACK_ATTACK_REDIS_URL'].presence || ENV['REDIS_URL'].presence

    Rack::Attack.cache.store = if redis_url
                                 ActiveSupport::Cache::RedisCacheStore.new(
                                   url: redis_url,
                                   namespace: 'rack_attack'
                                 )
                               elsif Rails.env.production?
                                 raise 'RACK_ATTACK_REDIS_URL or REDIS_URL is required in production'
                               else
                                 ActiveSupport::Cache::MemoryStore.new
                               end

    # 1. Throttle all requests by IP (60 req/min)
    throttle('req/ip', limit: 60, period: 1.minute) do |req|
      req.ip unless req.path.start_with?('/assets')
    end

    # 2. Throttle POST reports endpoint by IP (5 req/min) to prevent spam
    throttle('reports/ip', limit: 5, period: 1.minute) do |req|
      req.ip if req.path_info.match?(%r{\A/v1/sismos/\d+/reports(?:\.[^/]+)?\z}) && req.post?
    end

    # 3. Custom Response for Throttled Requests (HTTP 429)
    self.throttled_responder = lambda do |request|
      match_data = request.env['rack.attack.match_data'] || {}
      now = match_data[:epoch_time] || Time.now.to_i
      period = match_data[:period] || 60
      retry_after = period - (now % period)

      headers = {
        'Content-Type' => 'application/json; charset=utf-8',
        'Retry-After' => retry_after.to_s
      }

      body = {
        error: "Rate limit exceeded. Try again in #{retry_after} seconds."
      }.to_json

      [429, headers, [body]]
    end
  end
end
