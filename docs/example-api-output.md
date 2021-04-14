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
