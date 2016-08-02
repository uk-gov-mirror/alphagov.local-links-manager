require 'local-links-manager/distributed_lock'
require 'local-links-manager/import/links_importer'

namespace :import do
  namespace :links do
    desc "Import local authority links for service (lgsl) and interaction (lgil) combinations from local DirectGov"
    task import_all: :environment do
      service_desc = 'Import links to service interactions for local authorities into local-links-manager'
      LocalLinksManager::DistributedLock.new('links-import').lock(
        lock_obtained: ->() {
          begin
            response = LocalLinksManager::Import::LinksImporter.import
            Services.icinga_check(service_desc, response.successful?, response.message)
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
