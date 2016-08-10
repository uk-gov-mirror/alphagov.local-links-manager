# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'
set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :rake, 'cd :path && /usr/local/bin/govuk_setenv local-links-manager bundle exec rake :task :output'

every :day, at: '2am' do
  rake 'check-links'
end

# Run the rake task to import all links to service interactions for local authorities into Local Links Manager every day
every :day, at: '1am' do
  rake 'import:links:import_all'
end

# Run the rake task to import all services and interactions into Local Links Manager on the 1st of each month
every :month, on: '1st' do
  rake 'import:service_interactions:import_all'
end

# Run the rake task to import homepage URLs for local authorities into Local Links Manager every day
every :day, at: '12:30am' do
  rake 'import:local_authorities:add_urls'
end

# Run the rake task to export data to CSV for data.gov.uk.
every :day, at: '3am' do
  rake 'export:links:all'
end
