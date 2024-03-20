namespace :once_off do
  desc "Publish external links to all active council homepages so they appear in search"
  task publish_external_content_items: :environment do
    LocalAuthority.active.find_each do |la|
      LocalAuthorityExternalContentPublisher.publish(la)
    end
  end
end
