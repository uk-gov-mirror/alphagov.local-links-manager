# Permissions

## Named Permissions

- `signin`: as with other apps, this is the basic permission needed to access
  the app.
- `GDS Editor`: gives the user permission to do all actions in the app.

## Department Permissions

Other permissions are based on the organisation_slug of the current user. If a
user does not have the `GDS Editor` permission, they will be able to:

- visit the Services page `/services`. Only services with the current user's
  organisation slug in the service's organisation_slugs array will be visible.
- visit the specific service pages of those services
- download a csv of links for those services
- upload a csv including new links for those services
- edit links in those services.

The organisation slugs array is editable only by people with the `GDS Editor`
permission.
