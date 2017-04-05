# Deleting a local transaction link

Occasionally we may need to urgently delete a link prevent it being shown as
the result for its local authority on a local transaction page on GOV.UK (such
 as [https://www.gov.uk/pay-council-tax/lambeth](https://www.gov.uk/pay-council-tax/lambeth)).

Links to local government are editable using [Local Links Manager](https://local-links-manager.publishing.service.gov.uk),
 however this does not yet provide an easy way to find and edit URLs in bulk.

Assuming you know the link you want to delete and the page it appears on, in a
`local-links-manager` Rails console:


1.  Construct a variable using the bad URL to use in a `LIKE` query in the following
    steps:

        domain_pattern = '%horrible.domain.com%'

1.  Find all affected links:

        Link.where('url LIKE ?', domain_pattern).count

1.  Find the LGSL codes and local authority slugs for each of these local
    interactions. This will help with finding the URLs to cache-bust after
    you've deleted them:

        lgsl_codes = Link.where('url LIKE ?', domain_pattern).map{ |l| l.service.lgsl_code}.uniq

        la_slugs = Link.where('url LIKE ?', domain_pattern).map{|l| l.local_authority.slug}.uniq

1.  Delete all affected links. (If a link does not exist, there's a fallback
    process culminating in the local authority homepage):

        Link.where('url LIKE ?', domain_pattern).delete_all

1.  It's possible that the same domain has been used for a local authority
    homepage, so check them too:

        LocalAuthority.where('homepage_url LIKE ?', domain_pattern).count

1.  If there are any here, set the `homepage_url` to `nil`.  (It's better if
     you can set it to a real URL, but we can do that through the UI as part
     of a clean up if necessary)

        LocalAuthority.where('homepage_url LIKE ?', domain_pattern).update_all(homepage_url: nil)

1.  Frontend should now no longer be serving the bad links, but the pages
    containing them may be cached. You'll need to get a **Publisher** Rails
    console to find the `artefact-slugs` for the local transactions which use the LGSL codes for the links you've deleted (substituting the values into the array in this query):

        LocalTransactionEdition.where(state: "published").in(:lgsl_code => [ <LGSL codes> ] ).each do |lte|
          print "LGSL code: #{lte.lgsl_code}    Slug: #{lte.slug}\n"
        end

1.  Combine the artefact and local authority slugs to build the paths to
    cache-bust - they're in this form:

        /<artefact-slug>/<local-authority-slug>

    for example

        /pay-council-tax/lambeth

1.  Flush the caches for the affected URLs.
    (Wildcard purging would make this easier, by allowing us to purge all paths
    under a local transaction rather than having to do each local authority page
    individually.)

1.  Now you're done.
