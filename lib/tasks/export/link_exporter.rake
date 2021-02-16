require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/export/links_exporter"

def clean(text)
  text = text.join(" ") if text.is_a?(Array)
  text.gsub('"', "").gsub(",", "") unless text.nil?
end

namespace :export do
  namespace :links do
    desc "Export links to CSV"
    task "all": :environment do
      service_desc = "Export links to CSV from local-links-manager"
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

    desc "Export all links into a given CSV file"
    task :csv, %i[filename] => [:environment] do |_, args|
      file = File.open(args.filename, "w")
      file.puts "url,status,errors,warnings,summary,fix"

      Link.where.not(url: nil).each do |link|
        errors = clean(link.link_errors)
        warnings = clean(link.link_warnings)
        summary = clean(link.problem_summary)
        fix = clean(link.suggested_fix)

        file.puts "#{link.url},#{link.status},#{errors},#{warnings},#{summary},#{fix}"
      end

      file.close
    end
  end
end
