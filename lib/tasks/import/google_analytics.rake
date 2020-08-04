require_relative "../../../app/lib/local-links-manager/import/analytics_importer"

namespace :import do
  desc "Imports analytics so that links can be prioritised by usage"
  task google_analytics: :environment do
    service_desc = "Import Google Analytics to Local Links Manager"
    LocalLinksManager::DistributedLock.new("analytics-import").lock(
      lock_obtained: lambda {
        begin
          response = LocalLinksManager::Import::AnalyticsImporter.import
          Services.icinga_check(service_desc, response.successful?.to_s, response.message)
        rescue StandardError => e
          Services.icinga_check(service_desc, "false", e.to_s)
          raise e
        end
      },
      lock_not_obtained: lambda {
        Services.icinga_check(service_desc, "true", "Unable to lock")
      },
    )
  end
end
