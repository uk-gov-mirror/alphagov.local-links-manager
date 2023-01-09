require "redis"
require "gds_api/publishing_api"

module Services
  # TODO: icinga_check once local-links-manager is hosted on Kubernetes.
  def self.icinga_check(service_desc, code, message)
    notify_command = "/usr/local/bin/notify_passive_check".freeze
    if Rails.env.production? && File.exist?(notify_command)
      `#{notify_command} #{service_desc.shellescape} #{code.shellescape} #{message.shellescape}`
    end
  end
end
