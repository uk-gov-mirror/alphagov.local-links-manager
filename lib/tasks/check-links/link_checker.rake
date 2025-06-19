require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/check_links/link_status_requester"

desc "Check all links for enabled services"
task "check-links": :environment do
  LocalLinksManager::DistributedLock.new("check-links").lock(
    lock_obtained: lambda {
      begin
        Rails.logger.info("Lock obtained, starting link checker")
        LocalLinksManager::CheckLinks::LinkStatusRequester.new.call
        Rails.logger.info("Link checker completed")
      rescue StandardError => e
        Rails.logger.error("Error while running link checker\n#{e}")
        raise e
      end
    },
    lock_not_obtained: lambda {
      Rails.logger.info("Unable to lock")
    },
  )
end

namespace :"check-links" do
  desc "Check links & update link status for a single local authority"
  task :local_authority, [:authority_slug] => :environment do |_, args|
    checker = LocalLinksManager::CheckLinks::LinkStatusRequester.new
    checker.check_authority_urls(args[:authority_slug])
  end

  desc <<~DESC
    Check links & update link status for all active local authorities.
    This will run in the background as a queue of Sidekiq jobs.
    The jobs will take a long time to complete, even a few hours.
  DESC
  task all_local_authorities: :environment do
    checker = LocalLinksManager::CheckLinks::LinkStatusRequester.new
    LocalAuthority.active.find_each { |la| checker.check_authority_urls(la.slug) }
  end
end
