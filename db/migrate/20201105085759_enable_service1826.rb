class EnableService1826 < ActiveRecord::Migration[6.0]
  def up
    service = Service.find_by(lgsl_code: 1826)
    interaction = Interaction.find_by(lgil_code: 8)

    service.update!(enabled: true)
    ServiceTier.create_tiers([Tier.district, Tier.unitary, Tier.county], service)

    service_interaction = ServiceInteraction.find_by(service: service, interaction: interaction)

    if service_interaction
      service_interaction.update!(live: true)
    else
      raise "Service 1826 has not been imported from ESD"
    end
  end
end
