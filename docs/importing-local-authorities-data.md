# Importing Local Authorities data

Before running the import rake tasks make sure you have Mapit running locally and have imported data into it.

Import all local authorities:

`bundle exec rake import:local_authorities:import_all`

Then import services and interactions:

`bundle exec rake import:service_interactions:import_all`
