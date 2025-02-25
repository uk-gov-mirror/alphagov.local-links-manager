require "csv"
require "aws-sdk-s3"

namespace :export do
  namespace :links do
    desc "Generate links status to CSV and upload to S3"
    task "status": :environment do
      filename1 = "all_links_status_count.csv"
      filename2 = "links_with_local_authority_service.csv"

      bucket = ENV["AWS_S3_ASSET_BUCKET_NAME"]
      key = "data/local-links-manager/#{filename2}"

      s3 = Aws::S3::Client.new

      CSV.open(filename1, "wb") do |csv|
        csv << %w[Status Problem_Summary Count Percentage]
        Link.group(:status, :problem_summary).count.each do |(status, problem_summary), count|
          percentage = (count.to_f * 100 / Link.count).round(2)
          csv << [status || "nil", problem_summary || "nil", count, percentage]
        end
      end

      CSV.open(filename2, "wb") do |csv|
        csv << ["Link", "Local Authority", "Service", "Status", "Problem Summary"]
        Link.joins(:local_authority, :service)
          .select("links.url AS link_url", "local_authorities.name AS local_authority_name", "services.label AS service_name", "links.status AS link_status", "links.problem_summary AS link_problem_summary")
          .each do |link|
            csv << [link.link_url, link.local_authority_name, link.service_name, link.link_status, link.link_problem_summary]
          end
      end

      s3.put_object({ body: File.read(filename2), bucket: bucket, key: key })
    end
  end
end
