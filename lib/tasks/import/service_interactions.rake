require 'local-links-manager/import/services_importer'
require 'local-links-manager/import/interactions_importer'
require 'local-links-manager/import/service_interactions_importer'
require 'local-links-manager/import/services_tier_importer'
require 'local-links-manager/import/enabled_service_checker'

namespace :import do
  namespace :service_interactions do
    desc "Import ServiceInteractions and dependencies"
    task import_all: :environment do
      service_desc = 'Import services and interactions into local-links-manager'
      LocalLinksManager::DistributedLock.new('check-links').lock(
        lock_obtained: ->() {
          begin
            Rake::Task["import:service_interactions:import_services"].invoke
            Rake::Task["import:service_interactions:import_interactions"].invoke
            Rake::Task["import:service_interactions:import_service_interactions"].invoke
            Rake::Task["import:service_interactions:add_service_tiers"].invoke
            Rake::Task["import:service_interactions:enable_services"].invoke
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

    desc "Import Services from standards.esd.org.uk"
    task import_services: :environment do
      LocalLinksManager::Import::ServicesImporter.import
    end

    desc "Import Interactions from standards.esd.org.uk"
    task import_interactions: :environment do
      LocalLinksManager::Import::InteractionsImporter.import
    end

    desc "Import ServicesInteractions from standards.esd.org.uk"
    task import_service_interactions: :environment do
      LocalLinksManager::Import::ServiceInteractionsImporter.import
    end

    desc "Add tiers from local_services.csv in publisher to the list of Services imported by `import_services`"
    task add_service_tiers: :environment do
      LocalLinksManager::Import::ServicesTierImporter.import
    end

    desc "Enable services used on Gov.uk"
    task enable_services: :environment do
      LocalLinksManager::Import::EnabledServiceChecker.enable
    end
  end
end
