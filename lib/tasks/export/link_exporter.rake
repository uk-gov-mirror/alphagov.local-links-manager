require_relative "../../../app/lib/local_links_manager/export/links_exporter"

require "aws-sdk-s3"

namespace :export do
  namespace :links do
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
