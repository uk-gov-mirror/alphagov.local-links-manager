namespace :once_off do
  desc "Remove services, service_tiers, service_interactions and links for all services that aren't enabled"
  task remove_unused_services: :environment do
    services = Service.where(enabled: false)

    total_services = 0
    total_service_interactions = 0
    total_links = 0

    services.find_each do |service|
      puts("Deleting: #{service.label}")
      puts("   - #{service.service_interactions.count} service interactions")
      puts("   - #{service.links.count} links")
      total_services += 1
      total_service_interactions += service.service_interactions.count
      total_links += service.links.count

      service.service_interactions.each do |si|
        si.links.delete_all
      end
      service.service_interactions.delete_all
      service.delete
    end

    puts("Totals: ")
    puts("Services: #{total_services}")
    puts("Service Interactions: #{total_service_interactions}")
    puts("Links: #{total_links}")
  end
end
