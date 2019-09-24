require "redis"
require "gds_api/mapit"
require "gds_api/publishing_api_v2"

module Services
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

  def self.mapit
    @mapit ||= GdsApi.mapit(disable_cache: Rails.env.test?)
  end

  def self.publishing_api
    @publishing_api ||= GdsApi.publishing_api_v2
  end

  def self.icinga_check(service_desc, code, message)
    if Rails.env.production?
      `/usr/local/bin/notify_passive_check #{service_desc.shellescape} #{code.shellescape} #{message.shellescape}`
    end
  end
end
