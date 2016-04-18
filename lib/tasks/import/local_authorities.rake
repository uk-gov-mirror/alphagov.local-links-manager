require 'local-links-manager/import/local_authorities_importer'
require 'local-links-manager/import/local_authorities_slug_importer'

namespace :import do
  namespace :local_authorities do
    desc "Import all local authority properties"
    task import_all: :environment do
      Rake::Task["import:local_authorities:import_authorities"].invoke
      Rake::Task["import:local_authorities:add_slugs"].invoke
    end

    desc "Import local authority names, codes and tiers from MapIt"
    task import_authorities: :environment do
      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
    end

    desc "Add slugs from authorities.json to the list of authorities imported
    by running `import_authorities`"
    task add_slugs: :environment do
      LocalLinksManager::Import::LocalAuthoritiesSlugImporter.import_slugs
    end
  end
end
