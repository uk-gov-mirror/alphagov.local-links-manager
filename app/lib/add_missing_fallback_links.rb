require "csv"

CSV.foreach("lgsl_lgil_fallback_links.csv", headers: true) do |row|
  la_slug = row[0]
  service_slug = row[1]
  interaction_slug = row[2]
  link_url = row[3]

  link = Link.build(local_authority_slug: la_slug, service_slug: service_slug, interaction_slug: interaction_slug)
  link.url = link_url
  logger.info "Adding link for local authority #{la_slug}, service slug #{service_slug} and interaction slug #{interaction_slug}: #{link_url}."
  link.save!
end
