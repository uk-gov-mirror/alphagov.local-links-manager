# Permissions

## Named Permissions

- `GDS Editor`: gives the user permission to do all actions in the app.

## Department Permissions

Other permissions are based on the organisation_slug of the current user. If a user does not have the `GDS Editor` permission they will be able to:

- visit the Services page `/services`, which will only show services where the current user's organisation slug is contained in the service's organisation_slugs array.
- visit the specific service pages of those services
- download a csv of links for those services
- download a csv of new links for those services
- edit links in those services.

The organisation slugs array is editable only by people with the `GDS Editor` permission.
