class EnableService1788 < ActiveRecord::Migration[5.2]
  def up
    service = Service.find_by(lgsl_code: 1788)
    interaction = Interaction.find_by(lgil_code: 8)

    service.update!(enabled: true)
    ServiceTier.create_tiers([Tier.district, Tier.unitary, Tier.county], service)

    service_interaction = ServiceInteraction.find_by(service: service, interaction: interaction)

    if service_interaction
      service_interaction.update!(live: true)
      puts "Successfully enabled service 1788"
    else
      raise "Service 1788 has not been imported from ESD"
    end
  end
end
