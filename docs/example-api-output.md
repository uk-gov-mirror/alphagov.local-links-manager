## Example API output

**Endoint for local authorities**

`GET /api/local-authority`

This endpoint takes either an `authority_slug` or a `local_custodian_code` endpoint:

- `GET /api/local-authority?authority_slug=<authority_slug>`
- `GET /api/local-authority?local_custodian_code=<local_custodian_code>`

Returns a JSON array containing details for the local authority and (if appropriate), the county council that contains the district.

This example is for `GET /api/local-authority?authority_slug=rochford`
```
[
  {
    "name" => 'Rochford District Council',
    "homepage_url" => "http://rochford.example.com",
    "country_name" => "England",
    "tier" => "district",
    "slug" => "rochford"
  },
  {
    "name" => 'Essex County Council',
    "homepage_url" => "http://essex.example.com",
    "country_name" => "England",
    "tier" => "county",
    "slug" => "essex"
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
    "tier" => "unitary",
    "slug" => "camden"
  }
]
```

We do not require authentication for this request.

**Endpoint for local transactions links**

`GET /api/link?authority_slug=<authority_slug>&lgsl=<lgsl>&lgil=<lgil>`

Or:

`GET /api/link?local_custodian_code=<local_custodian_code>&lgsl=<lgsl>&lgil=<lgil>`

This takes parameters for Authority Slug or Local Custodian Code, as well as LGSL and (optionally) LGIL.

Returns JSON details for local authority and interaction or just local authority depending whether the LGIL parameter is passed in. If the LGIL is passed in we return the link for the LGIL if it exists. If not then only the local authority details are returned. If the LGIL is not passed in it returns the appropriate fallback link. If no appropriate link is found then once again we only return the local authority details.

```
{
  "local_authority" => {
    "name" => "Blackburn",
      "snac" => "00AG",
      "tier" => "unitary",
      "homepage_url" => "http://blackburn.example.com",
      "country_name" => "England",
      "slug" => "blackburn",
  },
    "local_interaction" => {
      "lgsl_code" => 2,
      "lgil_code" => 4,
      "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
    }
}
```

We do not require authentication for this request.
