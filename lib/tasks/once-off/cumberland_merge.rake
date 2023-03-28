namespace :once_off do
  desc "Set merged counties to inactive as of 1/Apr/2020, ensure parent_local_authority valid"
  task cumberland_merge: :environment do
    LocalAuthority.create!(name: "Cumberland Council", gss: "E06000063", local_custodian_code: "940", snac: "FAKE", slug: "cumberland", tier_id: Tier.unitary, homepage_url: "https://www.cumberland.gov.uk/")
    slugs = %i[allerdale carlisle copeland]
    successor = LocalAuthority.find_by(slug: "cumberland")
    parent = LocalAuthority.find_by(slug: "cumbria")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != parent
        puts("Warning: parent local authority for #{slug} is not as expected (cumbria)")
        next
      end

      la.active_end_date = Time.zone.parse("01-Apr-2023")
      la.active_note = "Merged into the unitary authority Cumberland Council on 1 April 2023"
      la.succeeded_by_local_authority = successor
      la.save!
    end

    LocalAuthority.create!(name: "Westmorland and Furness Council", gss: "E06000064", local_custodian_code: "935", snac: "FAKE2", slug: "westmorland-and-furness", tier_id: Tier.unitary, homepage_url: "https://www.westmorlandandfurness.gov.uk/")
    slugs = %i[barrow-in-furness eden south-lakeland]
    successor = LocalAuthority.find_by(slug: "westmorland-and-furness")
    parent = LocalAuthority.find_by(slug: "cumbria")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != parent
        puts("Warning: parent local authority for #{slug} is not as expected (cumbria)")
        next
      end

      la.active_end_date = Time.zone.parse("01-Apr-2023")
      la.active_note = "Merged into the unitary authority Westmorland and Furness Council on 1 April 2023"
      la.succeeded_by_local_authority = successor
      la.save!
    end

    successor = LocalAuthority.find_by(slug: "cumberland")

    la = LocalAuthority.find_by(slug: "cumbria")

    la.active_end_date = Time.zone.parse("01-Apr-2023")
    la.active_note = "Merged into the unitary authorities of Cumberland Council and Westmorland and Furness Council on 1 April 2023"
    la.succeeded_by_local_authority = successor
    la.save!
  end
end
