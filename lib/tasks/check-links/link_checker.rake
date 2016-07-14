require 'local-links-manager/check_links/homepage_status_updater'
require 'local-links-manager/check_links/link_status_updater'

desc "Check links"
task "check-links": :environment do
  service_desc = "Local Links Manager link checker rake task"
  LocalLinksManager::DistributedLock.new('check-links').lock(
    lock_obtained: ->() {
      begin
        Rails.logger.info("Lock obtained, starting link checker")
        Services.icinga_check(service_desc, true, "Lock obtained, starting link checker")

        LocalLinksManager::CheckLinks::HomepageStatusUpdater.new.update
        LocalLinksManager::CheckLinks::LinkStatusUpdater.new.update

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
