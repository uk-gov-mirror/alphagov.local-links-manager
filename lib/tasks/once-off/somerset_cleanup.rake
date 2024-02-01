namespace :once_off do
  desc "Point 2019 retired somerset districts to their successor"
  task somerset_cleanup: :environment do
    slugs = %i[taunton-deane west-somerset]
    parent = LocalAuthority.find_by(slug: "somerset-west-taunton")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)

      la.active_end_date = Time.parse("01-Apr-2019")
      la.active_note = "Merged into the district authority Somerset West and Taunton District Council on 1 April 2019"
      la.succeeded_by_local_authority = parent
      la.save!
    end
  end
end
