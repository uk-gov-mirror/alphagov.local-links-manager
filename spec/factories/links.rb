FactoryGirl.define do
  factory :link do
    association :local_authority
    association :service_interaction
    url { "http://#{local_authority.slug}.example.com/#{service_interaction.service.slug}/#{service_interaction.interaction.label.parameterize}" }
    status nil
    link_last_checked nil
  end

  factory :link_for_disabled_service, parent: :link do
    after(:create) do |link|
      link.service.update_attribute(:enabled, false)
    end
  end
end
