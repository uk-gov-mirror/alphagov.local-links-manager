require "local-links-manager/export/analytics_exporter"

namespace :export do
  namespace :google_analytics do
    desc "Export bad links status to Google Analytics"
    task "bad_links": :environment do
      if ENV["RUN_LINK_GA_EXPORT"].present? && ENV["RUN_LINK_GA_EXPORT"] == "true"
        service_desc = "Export bad links status to Google Analytics"
        LocalLinksManager::DistributedLock.new("bad-links-analytics-export").lock(
          lock_obtained: lambda {
            begin
              Rails.logger.info("Starting link exporter")
              Services.icinga_check(service_desc, "true", "Exporting list of bad links to Google Analytics")

              LocalLinksManager::Export::AnalyticsExporter.export

              Rails.logger.info("Bad links export to GA has completed")
              Services.icinga_check(service_desc, "true", "Success")
            rescue StandardError => e
              Rails.logger.error("Error while running link exporter\n#{e}")
              Services.icinga_check(service_desc, "false", e.to_s)
              raise e
            end
          },
          lock_not_obtained: lambda {
            Services.icinga_check(service_desc, "true", "Unable to lock")
          },
        )
      end
    end
  end
end
