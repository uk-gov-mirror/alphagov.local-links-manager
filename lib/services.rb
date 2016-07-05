require 'redis'
require 'gds_api/mapit'

module Services
  def self.mapit
    @mapit ||= GdsApi::Mapit.new(
      Plek.new.find('mapit'),
      disable_cache: Rails.env.test?
    )
  end

  def self.redis
    @redis ||= begin
      redis_config = {
        host: ENV["REDIS_HOST"] || "127.0.0.1",
        port: ENV["REDIS_PORT"] || 6379,
        namespace: "local-links-manager",
      }

      Redis.new(redis_config)
    end
  end
end
