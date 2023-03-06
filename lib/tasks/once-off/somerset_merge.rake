namespace :once_off do
  desc "Set merged counties to inactive as of 1/Apr/2020, ensure parent_local_authority valid"
  task somerset_merge: :environment do
    slugs = %i[mendip somerset-west-taunton south-somerset sedgemoor]
    parent = LocalAuthority.find_by(slug: "somerset")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != parent
        puts("Warning: parent local authority for #{slug} is not as expected (somerset)")
        next
      end

      la.active_end_date = Time.parse("01-Apr-2023")
      la.active_note = "Merged into the unitary authority Somerset Council on 1 April 2023"
      la.succeeded_by_local_authority = parent
      la.save!
    end
  end
end
