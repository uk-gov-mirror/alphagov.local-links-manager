# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'
set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :rake, 'cd :path && /usr/local/bin/govuk_setenv local-links-manager bundle exec rake :task :output'

every :day, at: '2am' do
  rake 'check-links'
end

# Run the rake task to import all services and interactions into Local Links Manager on the 1st of each month
every :month, on: '1st' do
  rake 'import:service_interactions:import_all'
end

# Run the rake task to export data to CSV for data.gov.uk.
every :day, at: '3am' do
  rake 'export:links:all'
end

# Run the rake task to import Google analytics for local transactions.
every :day, at: '5am' do
  rake 'import:analytics'
end

