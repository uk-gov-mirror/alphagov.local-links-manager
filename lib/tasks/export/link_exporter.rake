require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/export/links_exporter"

require "aws-sdk-s3"

namespace :export do
  namespace :links do
    desc "Export links to CSV"
    task "all": :environment do
      Rails.logger.info("Starting link exporter")
      LocalLinksManager::Export::LinksExporter.export_links
      Rails.logger.info("Link export to CSV completed")
    rescue StandardError => e
      Rails.logger.error("Error while running link exporter\n#{e}")
      raise e
    end

    # This task duplicates functionality in `export:links:all`, except uploads
    # the file to S3 instead of storing it locally. This task is to be used by
    # the cronjob in Kubernetes environments instead.
    desc "Export links to CSV and upload to S3"
    task "s3": :environment do
      filename = "links_to_services_provided_by_local_authorities.csv"

      bucket = ENV["AWS_S3_ASSET_BUCKET_NAME"]
      key = "data/local-links-manager/#{filename}"

      s3 = Aws::S3::Client.new

      StringIO.open do |body|
        LocalLinksManager::Export::LinksExporter.new.export(body)

        s3.put_object({ body: body.string, bucket:, key: })
      end
    end
  end
end
