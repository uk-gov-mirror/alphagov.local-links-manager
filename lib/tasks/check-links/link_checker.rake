require 'local-links-manager/distributed_lock'
require 'local-links-manager/check_links/link_status_requester'

desc "Check all links for enabled services"
task "check-links": :environment do
  service_desc = "Local Links Manager link checker rake task"
  LocalLinksManager::DistributedLock.new("check-links").lock(
    lock_obtained: ->() {
      begin
        Rails.logger.info("Lock obtained, starting link checker")
        Services.icinga_check(service_desc, true, "Lock obtained, starting link checker")
        LocalLinksManager::CheckLinks::LinkStatusRequester.new.call
        Rails.logger.info("Link checker completed")
        # Flag nagios that this server's instance succeeded to stop lingering failures
        Services.icinga_check(service_desc, true, "Success")
      rescue StandardError => e
        Rails.logger.error("Error while running link checker\n#{e}")
        Services.icinga_check(service_desc, false, e.to_s)
        raise e
      end
    },
    lock_not_obtained: ->() {
      Rails.logger.info("Unable to lock")
      Services.icinga_check(service_desc, true, "Unable to lock")
    }
  )
end

namespace :"check-links" do
  desc "Check links for a single local authority"
  task :local_authority, [:authority_slug] => :environment do |_, args|
    checker = LocalLinksManager::CheckLinks::LinkStatusRequester.new
    checker.check_authority_urls(args[:authority_slug])
  end
end
