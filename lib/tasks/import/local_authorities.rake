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
      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
    end

    desc "Add homepage URLs from local.direct.gov.uk to the list of authorities
     imported by running `import_authorities`"
    task add_urls: :environment do
      service_desc = "Check for blank homepage urls in local-links-manager"
      LocalLinksManager::DistributedLock.new('import-homepages').lock(
        lock_obtained: ->() {
          begin
            Rails.logger.info("Lock obtained, starting homepage url import.")
            Services.icinga_check(service_desc, true, "Lock obtained, starting job.")

            LocalLinksManager::Import::LocalAuthoritiesURLImporter.import_urls
            # Flags nagios that this servers instance succeeded to stop lingering failures
            LocalLinksManager::Import::LocalAuthoritiesURLImporter.alert_empty_urls(service_desc)

            Rails.logger.info("Homepage url import completed.")
            Services.icinga_check(service_desc, true, "Success")
          rescue StandardError => e
            Rails.logger.error("Error while running homepage url import\n#{e}")
            Services.icinga_check(service_desc, false, e.to_s)
            raise e
          end
        },
        lock_not_obtained: ->() {
          Rails.logger.info("Unable to lock")
          Services.icinga_check(service_desc, true, "Unable to lock")
        }
      )
    end
  end
end
