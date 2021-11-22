require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/import/local_authorities_importer"

namespace :import do
  namespace :local_authorities do
    desc "Import local authority names, codes and tiers from MapIt"
    task import_all: :environment do
      service_desc = "Import local authorities into local-links-manager"
      response = LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
      Services.icinga_check(service_desc, response.successful?.to_s, response.message)
    end
  end
end
