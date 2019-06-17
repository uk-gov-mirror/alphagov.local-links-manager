class ChangeTiers1788 < ActiveRecord::Migration[5.2]
  def up
    service = Service.find_by(lgsl_code: 1788)
    interaction = Interaction.find_by(lgil_code: 8)
    service_interaction = ServiceInteraction.find_by(service: service, interaction: interaction)

    # This service should be `county/unitary`
    ServiceTier.where(service: service, tier_id: Tier.district).destroy_all

    # Remove all links for the service and repopulate without the district authorities
    service_interaction.links.destroy_all
    LocalLinksManager::Import::MissingLinks.add
  end
end
