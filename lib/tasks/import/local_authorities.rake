require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/import/local_authorities_importer"

namespace :import do
  namespace :local_authorities do
    desc "Import local authority names, codes and tiers from CSV"
    task import_all: :environment do
      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_csv(File.expand_path("../../../data/local-authorities.csv", File.dirname(__FILE__)))
    end
  end
end
