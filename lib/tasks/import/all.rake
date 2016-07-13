namespace :import do
  desc "Runs all the imports required to set up a functioning database - in the right order"
  task all: :environment do
    Rake::Task["import:local_authorities:import_all"].invoke
    Rake::Task["import:service_interactions:import_all"].invoke
    Rake::Task["import:links:import_all"].invoke
  end
end
