require_relative "../../../app/lib/local-links-manager/distributed_lock"
require_relative "../../../app/lib/local-links-manager/import/local_authorities_importer"

namespace :import do
  namespace :local_authorities do
    desc "Import all local authority properties"
    task import_all: :environment do
      Rake::Task["import:local_authorities:import_authorities"].invoke
    end

    desc "Import local authority names, codes and tiers from MapIt"
    task import_authorities: :environment do
      service_desc = "Import local authorities into local-links-manager"
      response = LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
      Services.icinga_check(service_desc, response.successful?.to_s, response.message)
    end
  end
end
