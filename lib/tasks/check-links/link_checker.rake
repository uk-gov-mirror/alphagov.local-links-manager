require 'local-links-manager/distributed_lock'
require 'local-links-manager/check_links/link_status_requester'

desc "Check links"
task "check-links": :environment do
  service_desc = "Local Links Manager link checker rake task"
  begin
    Rails.logger.info("Starting link checker")
    Services.icinga_check(service_desc, true, "Starting link checker")
    LocalLinksManager::CheckLinks::LinkStatusRequester.new.call

    Rails.logger.info("Link checker completed")
    # Flag nagios that this server's instance succeeded to stop lingering failures
    Services.icinga_check(service_desc, true, "Success")
  rescue StandardError => e
    Rails.logger.error("Error while running link checker\n#{e}")
    Services.icinga_check(service_desc, false, e.to_s)
    raise e
  end
end
