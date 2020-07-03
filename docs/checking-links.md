# Checking Links

`bundle exec rake check-links`

This long running rake task performs a `GET` request using [a timeout and a redirect limit](https://github.com/alphagov/local-links-manager/blob/master/lib/local-links-manager/check_links/link_checker.rb#L4L5) against each active link.  It stores the HTTP status code of the result (or the error condition that it encountered).  The status is shown in the UI to help identify links that need to be fixed.

A digest of the results is available for interaction links at:

https://local-links-manager.publishing.service.gov.uk/check_links_status.csv

and for homepages at:

https://local-links-manager.publishing.service.gov.uk/check_homepage_links_status.csv

The output resembles the following:

|      status       | count |
| ----------------- | ----- |
|    Invalid URI    |   231 |
| Connection failed |   524 |
|        500        |    26 |
|        200        | 36599 |
| Too many redirects|     4 |
|        503        |   110 |
|   Timeout Error   |   194 |
|        401        |     6 |
|        410        |    72 |
|        404        |  2518 |
|     SSL Error     |    69 |
|        403        |   229 |
