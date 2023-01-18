require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/export/links_exporter"

require "aws-sdk-s3"

namespace :export do
  namespace :links do
    desc "Export links to CSV"
    task "all": :environment do
      service_desc = "Export links to CSV from local-links-manager"
      begin
        Rails.logger.info("Starting link exporter")
        Services.icinga_check(service_desc, "true", "Starting link exporter")

        file_path = "/data/links_to_services_provided_by_local_authorities.csv"
        bucket = ENV["AWS_S3_ASSET_BUCKET_NAME"]
        key = Rails.application.config.assets.prefix.delete_prefix("/") + file_path

        s3 = Aws::S3::Client.new

        StringIO.open do |body|
          LocalLinksManager::Export::LinksExporter.new.export(body)

          body.rewind
          s3.put_object({ body:, bucket:, key: })
        end

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
