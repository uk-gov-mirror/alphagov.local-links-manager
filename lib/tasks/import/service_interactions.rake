require 'local-links-manager/import/services_importer'
require 'local-links-manager/import/interactions_importer'
require 'local-links-manager/import/service_interactions_importer'

namespace :import do
  namespace :service_interactions do
    desc "Import ServiceInteractions and dependencies"
    task import_all: :environment do
      Rake::Task["import:service_interactions:import_services"].invoke
      Rake::Task["import:service_interactions:import_interactions"].invoke
      Rake::Task["import:service_interactions:import_service_interactions"].invoke
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
  end
end
