# Importing Local Authorities data

Import all local authorities from `data/local-authorities.csv`:

`bundle exec rake import:local_authorities:import_all`

Then import services and interactions:

`bundle exec rake import:service_interactions:import_all`
