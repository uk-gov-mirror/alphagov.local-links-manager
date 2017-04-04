## Adding a new LGSL code

From time to time, we have requests to add new LGSL codes. For this,
you'll need to know the LGSL code, the description of the service and
the providing tier.

There is a [CSV
file](https://github.com/alphagov/publisher/blob/master/data/local_services.csv)
that contains the LGSL codes that are active on GOV.UK

To add a new LGSL code:
- Add the code itself in the first column in the CSV file.
- Add the description in the second column.
- Add the providing tier in the third column.

Providing tiers can be:
- `all`
- `county/unitary`
- `district/unitary`

Once your pull request has been merged the codes will become active overnight.
