namespace :once_off do
  desc "Set merged counties to inactive as of 1/Apr/2020, ensure parent_local_authority valid"
  task buckinghamshire_merge: :environment do
    slugs = %i[aylesbury-vale chiltern south-bucks wycombe]
    parent = LocalAuthority.find_by(slug: "buckinghamshire")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != parent
        puts("Warning: parent local authority for #{slug} is not as expected (buckinghamshire)")
        next
      end

      la.active_end_date = Time.parse("01-Apr-2020")
      la.active_note = "Merged into the unitary authority Buckinghamshire Council on 1 April 2020"
      la.save!
    end
  end
end
