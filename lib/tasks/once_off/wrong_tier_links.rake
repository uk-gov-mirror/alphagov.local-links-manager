namespace :once_off do
  desc "Delete links that are for services at the wrong tier for the referenced authority"
  task delete_wrong_tier_links: :environment do
    wrong_tier_links = Link.enabled_links.all.reject do |link|
      link.service.tiers.include?(link.local_authority.tier)
    end

    wrong_tier_links.delete_all
  end
end
