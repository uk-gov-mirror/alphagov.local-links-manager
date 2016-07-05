require 'local-links-manager/check_links/homepage_status_updater'
require 'local-links-manager/check_links/link_status_updater'
require 'local-links-manager/distributed_lock'

desc "Check links"
task "check-links": :environment do
  LocalLinksManager::DistributedLock.new('check-links').lock do
    LocalLinksManager::CheckLinks::HomepageStatusUpdater.new.update
    LocalLinksManager::CheckLinks::LinkStatusUpdater.new.update
  end
end
