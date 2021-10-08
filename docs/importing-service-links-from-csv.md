# Importing Service Links from a CSV

`bundle exec rake import:service_links[lgsl_code lgil_code filename]` provides the ability to mass import local authority service links.

## Why?

This is useful in a situation where a new service is added nationally. Every local authority running the new service will have a page on their website to provide information about the service. Usually the url would be added for a service through the user interface.

### Data format

A CSV with the headings `slug` and `url` needs to be placed somewhere it can be read in by the script (accessed by the `filename` argument).

Example:

`test-data.csv`

```
slug,url
milton-keynes,http://www.milton-keynes.gov.uk/new-service
brighton-and-hove,http://www.brighton-hove.gov.uk/new-service
```

### Running the script

`govuk-docker-run bundle exec rake import:service_links[123,8,test-data.csv]`


To run on anything other than a local environment, the CSV needs to be added manually to the `/tmp` directory using `scp-push`. If there are multiple machine classes, the CSV will need to be added to the `/tmp` directory for each of them.

```
$ gds govuk connect scp-push --environment [integration|staging|integration] name-of-machine[:1|:2|:3] path/to/file.ext /tmp/
```
