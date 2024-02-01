namespace :once_off do
  desc "Set Northamptonshire county to inactive as of 1/Apr/2021"
  task northamptonshire_split: :environment do
    old_parent = LocalAuthority.find_by(slug: "northamptonshire")
    old_parent.active_end_date = Time.parse("01-Apr-2021")
    old_parent.active_note = "Split into the North Northamptonshire and West Northamptonshire unitary authorities on 1 April 2021"
    old_parent.save!

    slugs = %i[corby east-northamptonshire kettering wellingborough]
    parent = LocalAuthority.find_by(slug: "north-northamptonshire")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != old_parent
        puts("Warning: parent local authority for #{slug} is not as expected (northamptonshire)")
        next
      end

      la.active_end_date = Time.parse("01-Apr-2021")
      la.active_note = "Merged into the unitary authority North Northampshire on 1 April 2021"
      la.succeeded_by_local_authority = parent
      la.save!
    end

    slugs = %i[daventry northampton south-northamptonshire]
    parent = LocalAuthority.find_by(slug: "west-northamptonshire")

    slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)
      if la.parent_local_authority != old_parent
        puts("Warning: parent local authority for #{slug} is not as expected (northamptonshire)")
        next
      end

      la.active_end_date = Time.parse("01-Apr-2021")
      la.active_note = "Merged into the unitary authority West Northampshire on 1 April 2021"
      la.succeeded_by_local_authority = parent
      la.save!
    end
  end
end
