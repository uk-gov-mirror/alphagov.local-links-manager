require 'local-links-manager/import/links_importer'

namespace :import do
  namespace :links do
    desc "Import local authority links for service (lgsl) and interaction (lgil) combinations from local DirectGov"
    task import_all: :environment do
      LocalLinksManager::Import::LinksImporter.import
    end
  end
end
