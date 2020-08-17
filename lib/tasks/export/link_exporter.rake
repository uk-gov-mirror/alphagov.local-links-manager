require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/export/links_exporter"

namespace :export do
  namespace :links do
    desc "Export links to CSV"
    task "all": :environment do
      service_desc = "Export links to CSV from local_links_manager"
      begin
        Rails.logger.info("Starting link exporter")
        Services.icinga_check(service_desc, "true", "Starting link exporter")

        LocalLinksManager::Export::LinksExporter.export_links
        Rails.logger.info("Link export to CSV completed")
        Services.icinga_check(service_desc, "true", "Success")
      rescue StandardError => e
        Rails.logger.error("Error while running link exporter\n#{e}")
        Services.icinga_check(service_desc, "false", e.to_s)
        raise e
      end
    end
  end
end
