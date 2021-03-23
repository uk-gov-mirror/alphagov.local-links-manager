namespace :service do
  desc "Enable or create a service."
  task :enable, %i[lgsl lgil label slug] => [:environment] do |_, args|
    lgsl = args.lgsl
    # LGIL is deprecated concept, defaults to PROVIDING INFORMATION
    lgil = args.lgil || Interaction::PROVIDING_INFORMATION_LGIL

    # Provide a label and slug if creating a service that doesn't exist
    label = args.label
    slug = args.slug

    service = Service.find_by(lgsl_code: lgsl)

    if slug && label && service.nil?
      service = Service.create!(
        lgsl_code: lgsl,
        label: label,
        slug: slug,
      )
    end
    abort "Service [#{lgsl}] does not exist" unless service

    interaction = Interaction.find_by(lgil_code: lgil)
    abort "Interaction [#{lgil}] does not exist" unless interaction

    service.update!(enabled: true)

    # Creating all service tiers (check if your service requires all)
    ServiceTier.create_tiers([Tier.district, Tier.unitary, Tier.county], service)

    service_interaction = ServiceInteraction.find_or_create_by!(
      service: service,
      interaction: interaction,
    )
    abort "Service Interaction between [#{lgsl}] and [#{lgil}] does not exist" unless service_interaction

    service_interaction.update!(live: true)
  end

  desc "Destroys an existing Service and all dependant records"
  task :destroy, %w[lgsl_code] => :environment do |_, args|
    service = Service.find_by!(lgsl_code: args.lgsl_code)
    service.destroy!
  end
end
