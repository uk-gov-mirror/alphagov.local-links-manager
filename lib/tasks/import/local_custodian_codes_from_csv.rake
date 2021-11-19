namespace :import do
  desc "Imports local custodian codes from CSV file"
  task :local_custodian_codes, %i[filename] => :environment do |_t, args|
    LocalLinksManager::Import::LocalCustodianCodesImporter.new.import_from_csv(args[:filename])
  end
end
