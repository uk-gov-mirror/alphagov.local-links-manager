require 'local-links-manager/check_links/homepage_status_updater'
require 'local-links-manager/check_links/link_status_updater'

desc "Check links"
task "check-links": :environment do
  LocalLinksManager::CheckLinks::HomepageStatusUpdater.new.update
  LocalLinksManager::CheckLinks::LinkStatusUpdater.new.update
end
