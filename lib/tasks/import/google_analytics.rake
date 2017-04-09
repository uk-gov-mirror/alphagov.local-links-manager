require 'local-links-manager/import/analytics_importer'

namespace :import do
  desc "Imports analytics so that links can be prioritised by usage"
  task google_analytics: :environment do
    service_desc = 'Import Google Analytics to Local Links Manager'
    response = LocalLinksManager::Import::AnalyticsImporter.import
    Services.icinga_check(service_desc, response.successful?, response.message)
    puts response.message
  end
end
