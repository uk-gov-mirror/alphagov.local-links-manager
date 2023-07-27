# Local Authority Changes

Local Links Manager is set up to edit links, and editing other aspects of Local Authorities is not really supported by the front end. Fortunately these changes do not happen often, but when they do they tend to happen in batches.

## To change a Local Authority's details

The URL can be changed in the UI, but if you need to change the slug and/or authority name, you'll have to log on to the app-console to do it.

## To mark a Local Authority as superseded

Sometimes local authorities are merged (this tends to be borough/city/district councils getting rolled up into their county council, which then becomes a unitary authority). In this case, you should create a rake task that does the following:

- Update the county council from a tier 2 (county) to a tier 3 (unitary) council (or create a new unitary council if repurposing the previous one is likely to cause problems).
- For each of the councils being merged:
  - Set the active_end_date property to the date on which it will be (or aws, if you're doing this in retrospect) merged into the unitary authority.
  - Set the active_note property with a text description of the merge.
  - Set the succeeded_by_local_authority property to point to the new unitary council.
  - (Only after the council has been merged) Download the links CSV file and attach it to the card describing the change.
  - (Only after the council has been merged) Delete all the Link items attached to the council so that the link checker will not attempt to check them, and they will not appear in the broken links report.

Note that new Local Authorities do not have SNAC codes, only GSS codes.

