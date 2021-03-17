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

  desc "Duplicates an existing Service"
  task :duplicate, %w[from_lgsl_code to_lgsl_code] => :environment do |_, args|
    old_service = Service.find_by!(lgsl_code: args.from_lgsl_code)

    ActiveRecord::Base.transaction do
      new_service = old_service.dup

      new_service.assign_attributes(
        lgsl_code: args.to_lgsl_code,
        label: "Transitioning #{old_service.label}",
        slug: "transitioning-#{old_service.slug}",
      )
      new_service.save!

      new_service.service_interactions = old_service.service_interactions.map do |si|
        si.dup.tap { |new_si| new_si.links = si.links.map(&:dup) }
      end

      new_service.service_tiers = old_service.service_tiers.map(&:dup)
    end
  end

  desc "Updates the label and slug of an existing Service"
  task :rename, %w[lgsl_code label slug] => :environment do |_, args|
    service = Service.find_by!(lgsl_code: args.lgsl_code)
    service.update!(label: args.label, slug: args.slug)
  end
end
