# Remove a service

From time to time, either a service (LGSL code) is no longer valid, required or has been removed from the [Electronic Service Delivery (ESD)](https://standards.esd.org.uk) system. When this happens, we need to remove the service from `local-links-manager` and `publisher`.

## Before you start

Before starting the process it is worth gethering a few key pieces of information:

* The Local Government Services List (LGSL) code of the service you are removing
* The URL or slug of the service
* The ESD URL of the service

## 1. Back-up the links

You may want to back-up the links created for the service before deleting the service.

First run the [`export:links:all`](../lib/tasks/export/link_exporter.rake) rake task (via the console or [`jenkins`](#links)) which exports all of the links for all services in `local-links-manager` to the following file `public/data/links_to_services_provided_by_local_authorities.csv`. If you're running this locally, note that this file is ignored by [`.gitignore`](../.gitignore).

```bash
bundle exec rake export:links:all
```

Then retrieve the newly created file using `scp-pull`...

```bash
gds govuk connect scp-pull -e [integration|staging|production] backend source_file destination_file
```

Apps on `backend` can be found in `/var/apps/APP-NAME`. So, our data file should be available at `/var/apps/local-links-manager/public/data/links_to_services_provided_by_local_authorities.csv`.

For example:

```bash
gds govuk connect scp-pull -e integration backend /var/apps/local-links-manager/public/data/links_to_services_provided_by_local_authorities.csv ~/Desktop
```

**Note**: Once stored in a secure location, please remember to delete the downloaded file from your local machine.

## 2. Unpublish or update the service in `publisher`

There are two options for maintaining the service going forward:

1. Update the format of the service so that it becomes a standard plain text page - without a start button and local lookup functionality. Then update the page content as appropriate.

2. Un-publish the service and - if desired - redirect the page.

Ask a content designer to carry out the required option.

## 3. Remove the LGSL code from `publisher`

`publisher` stores details about the serivce (LGSL code, name and providing tier) in [`data/local_services.csv`](https://github.com/alphagov/publisher/blob/main/data/local_services.csv). Remove the service from this file, create a pull request and get it approved and merged.

## 4. Remove the service from `local-links-manager`

`local-links-manager` has a `Service` model that stores details about the service, together with it's `Interaction` and providing tier(s). To remove the `Service` record, and all dependant records, run the [service:destroy](../lib/tasks/service.rake) rake task.

```bash
bundle exec rake service:destroy[LGSL_CODE]
```

## 5. Remove the service from `publisher`

We've [previously removed the LGSL code](#3-remove-the-lgsl-code-from-publisher) from `publisher`. Now we need to remove the service - and any other services not in the [`data/local_services.csv`](https://github.com/alphagov/publisher/blob/main/data/local_services.csv) file.

To do this run the [`local_transactions:remove_old_services`](https://github.com/alphagov/publisher/blob/main/lib/tasks/local_transactions.rake) rake task.

```bash
bundle exec rake local_transactions:remove_old_services
```

## 6. Remove the service from ESD

Ask your Delivery Manager to contact an ESD Project Manager and ask them to remove the service from ESD. This may take a while as it seems ESD is only updated sporadically, which is fine as there is no link between ESD and either `local-links-manager` or `publisher`.

## Links

* `local-links-manager`: [GitHub](https://github.com/alphagov/local-links-manager) | [integration](https://local-links-manager.integration.publishing.service.gov.uk/) | [staging](https://local-links-manager.staging.publishing.service.gov.uk/) | [production](https://local-links-manager.publishing.service.gov.uk/)

* `publisher`: [GitHub](https://github.com/alphagov/publisher) | [integration](https://publisher.integration.publishing.service.gov.uk/)  | [staging](https://publisher.staging.publishing.service.gov.uk/) | [production](https://publisher.publishing.service.gov.uk/)

* `jenkins`: [integration](https://deploy.integration.publishing.service.gov.uk/job/run-rake-task/build?delay=0sec) | [staging](https://deploy.blue.staging.govuk.digital/job/run-rake-task/build?delay=0sec) | [production](https://deploy.blue.production.govuk.digital/job/run-rake-task/build?delay=0sec)
