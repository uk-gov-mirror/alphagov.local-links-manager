require 'local-links-manager/check_links/homepage_status_updater'
require 'local-links-manager/check_links/link_status_updater'
require 'local-links-manager/distributed_lock'

desc "Check links"
task "check-links": :environment do
  service_desc = "Local Links Manager link checker rake task"
  LocalLinksManager::DistributedLock.new('check-links').lock(
    lock_obtained: ->() {
      begin
        LocalLinksManager::CheckLinks::HomepageStatusUpdater.new.update
        LocalLinksManager::CheckLinks::LinkStatusUpdater.new.update
        # Flag nagios that this servers instance succeeded to stop lingering failures
        Services.icinga_check(service_desc, true, "Success")
      rescue StandardError => e
        Services.icinga_check(service_desc, false, e.to_s)
        raise e
      end
    },
    lock_not_obtained: ->() {
      Services.icinga_check(service_desc, true, "Unable to lock")
    }
  )
end
