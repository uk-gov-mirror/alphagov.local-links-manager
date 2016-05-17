FactoryGirl.define do
  factory :link do
    association :local_authority
    association :service_interaction
    url { "http://#{local_authority.slug}.example.com/#{service_interaction.service.slug}/#{service_interaction.interaction.label.parameterize}" }
  end
end
