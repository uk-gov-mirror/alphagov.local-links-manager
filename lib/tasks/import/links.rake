require 'local-links-manager/import/links_importer'

namespace :import do
  namespace :links do
    desc "Import local authority links for service (lgsl) and interaction (lgil) combinations from local DirectGov"
    task import_all: :environment do
      service_desc = 'Import links to service interactions for local authorities into local-links-manager'
      LocalLinksManager::DistributedLock.new('check-links').lock(
        lock_obtained: ->() {
          begin
            LocalLinksManager::Import::LinksImporter.import
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
  end
end
