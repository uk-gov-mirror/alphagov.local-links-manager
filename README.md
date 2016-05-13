# Local-links-manager

Admin interface for managing Local Authorities links including all their services and interactions.

## Screenshots

## Live examples

- [Local Links Manager](https://local-links-manager.publishing.service.gov.uk)

## Nomenclature

- **SNAC** - Standard Names And Code - The old identifier code for locations. This is being phased out in favour of GSS codes.
- **GSS**  - Government Statistical Service - The new identifier code for locations.
- **LGSL** - Local Government Services List
- **LGIL** - Local Government Interactions List

Both LGSL and LGIL codes are used for the lookups for each Local Authority and its' service interactions.

## Technical documentation

This is a Ruby on Rails application that maps RESTful URLs onto a persistence
layer. It's only presented as an internal API and doesn't face public users.

### Dependencies

- [alphagov/other-repo]() - provides some downstream service

### Running the application

`./startup.sh`

### Running the test suite

`bundle exec rake`

### Developing Locally

If you are using the development vm before running any of the rake tasks below you will need to have [Mapit](https://github.com/alphagov/mapit) checked out locally.

You will also need to [import data from S3](https://github.com/alphagov/mapit/blob/master/import-db-from-s3.sh).

### Importing Local Authorities data

Before running the import rake tasks make sure you have Mapit running locally and have imported data into it.

Import all local authorities:

`bundle exec rake import:local_authorities:import_all`

Then import services and interactions:

`bundle exec rake import:service_interactions:import_all`

### Example API output (optional)

## Licence

[MIT License](LICENCE)
