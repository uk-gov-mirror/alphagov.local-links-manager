# Local-links-manager

Admin interface for managing Local Authorities links including all their services and interactions.

This app maps RESTful URLs onto a persistence layer. It doesn't face public users.

## Nomenclature

- **SNAC** - Standard Names And Code - The old identifier code for locations. This is being phased out in favour of GSS codes.
- **GSS**  - Government Statistical Service - The new identifier code for locations.
- **LGSL** - Local Government Services List
- **LGIL** - Local Government Interactions List

Both LGSL and LGIL codes are used for the lookups for each Local Authority and its service interactions.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions][conventions].

You can use the [GOV.UK Docker environment][govuk-docker] to run the application and its tests with all the necessary dependencies. Follow the [usage instructions][docker-usage] to get started.

Running the bare application without any test data isn't very useful, you can replicate the app's Postgres database [using GOV.UK Docker][replicate-db].

**Use GOV.UK Docker to run any commands that follow.**

[conventions]: https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html
[govuk-docker]: https://github.com/alphagov/govuk-docker
[docker-usage]: https://github.com/alphagov/govuk-docker#usage
[replicate-db]: https://github.com/alphagov/govuk-docker/blob/master/docs/how-tos.md#how-to-replicate-data-locally

### Running the test suite

```
$ bundle exec rake
```

## Further documentation

- [Enable or create a service](/docs/enable-or-create-service.md)
- [Deleting a local transaction link](/docs/deleting-a-link.md)
- [Importing Local Authorities data](/docs/importing-local-authorities-data.md)
- [Exporting Local Authority links to services](/docs/exporting-local-authority-links.md)
- [Checking links](/docs/checking-links.md)

## Example API output

**Endoint for local authorities**

`GET /api/local-authority?authority_slug=<authority_slug>`

This takes parameters for Authority Slug.

Returns a JSON array containing details for the local authority and (if appropriate), the county council that contains the district.

This example is for `GET /api/local-authority?authority_slug=rochford`
```
[
  {
    "name" => 'Rochford District Council',
    "homepage_url" => "http://rochford.example.com",
    "country_name" => "England",
    "tier" => "district"
  },
  {
    "name" => 'Essex County Council',
    "homepage_url" => "http://essex.example.com",
    "country_name" => "England",
    "tier" => "county"
  }
]
```

This example is for `GET /api/local-authority?authority_slug=camden`
```
[
  {
    "name" => 'Camden Borough Council',
    "homepage_url" => "http://camden.example.com",
    "country_name" => "England",
    "tier" => "unitary"
  }
]
```

We do not require authentication for this request.

**Endpoint for local transactions links**

`GET /api/link?authority_slug=<authority_slug>&lgsl=<lgsl>&lgil=<lgil>`

This takes parameters for Authority Slug, LGSL and optionally LGIL.

Returns JSON details for local authority and interaction or just local authority depending whether the LGIL parameter is passed in. If the LGIL is passed in we return the link for the LGIL if it exists. If not then only the local authority details are returned. If the LGIL is not passed in it returns the appropriate fallback link. If no appropriate link is found then once again we only return the local authority details.

```
{
  "local_authority" => {
    "name" => "Blackburn",
      "snac" => "00AG",
      "tier" => "unitary",
      "homepage_url" => "http://blackburn.example.com",
      "country_name" => "England",
  },
    "local_interaction" => {
      "lgsl_code" => 2,
      "lgil_code" => 4,
      "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
    }
}
```

We do not require authentication for this request.

## Licence

[MIT License](LICENCE)
