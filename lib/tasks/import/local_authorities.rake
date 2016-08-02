require 'local-links-manager/distributed_lock'
require 'local-links-manager/import/local_authorities_importer'
require 'local-links-manager/import/local_authorities_url_importer'

namespace :import do
  namespace :local_authorities do
    desc "Import all local authority properties"
    task import_all: :environment do
      Rake::Task["import:local_authorities:import_authorities"].invoke
      Rake::Task["import:local_authorities:add_urls"].invoke
    end

    desc "Import local authority names, codes and tiers from MapIt"
    task import_authorities: :environment do
      service_desc = "Import local authorities into local-links-manager"
      response = LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
      Services.icinga_check(service_desc, response.successful?, response.message)
    end

    desc "Add homepage URLs from local.direct.gov.uk to the list of authorities
     imported by running `import_authorities`"
    task add_urls: :environment do
      service_desc = "Check for blank homepage urls in local-links-manager"
      LocalLinksManager::DistributedLock.new('import-homepages').lock(
        lock_obtained: ->() {
          begin
            Services.icinga_check(service_desc, true, "Lock obtained, starting job.")

            response = LocalLinksManager::Import::LocalAuthoritiesURLImporter.import_urls
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
