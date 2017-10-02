crumb :root do
  link "Local links", root_path
end

crumb :local_authorities do
  link "Local authorities", local_authorities_path
end

crumb :local_authority do |local_authority|
  link local_authority.name, local_authority_path(local_authority.slug)
  parent :local_authorities
end

crumb :services do
  link "Services", services_path
end

crumb :service do |service|
  link service.label, service_path(service)
  parent :services
end

crumb :links do |local_authority, service, interaction|
  link interaction.label, link_path(local_authority.slug, service.slug, interaction.slug)
  parent :service, service
end
