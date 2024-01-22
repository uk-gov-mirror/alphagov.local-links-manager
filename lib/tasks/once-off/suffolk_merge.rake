namespace :once_off do
  desc "Set merged districts to inactive as of 1/Apr/2019"
  task suffolk_merge: :environment do
    ws_slugs = %i[forest-heath st-edmundsbury]
    ws_parent = LocalAuthority.find_by(slug: "west-suffolk")

    ws_slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)

      la.active_end_date = Time.parse("01-Apr-2019")
      la.active_note = "Merged into the district council West Suffolk on 1 April 2019"
      la.succeeded_by_local_authority = ws_parent
      la.save!
    end

    es_slugs = %i[suffolk-coastal waveney]
    es_parent = LocalAuthority.find_by(slug: "east-suffolk")

    es_slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)

      la.active_end_date = Time.parse("01-Apr-2019")
      la.active_note = "Merged into the district council East Suffolk on 1 April 2019"
      la.succeeded_by_local_authority = es_parent
      la.save!
    end
  end
end
