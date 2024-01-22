namespace :once_off do
  desc "Set merged counties to inactive as of 1/Apr/2019, ensure parent_local_authority valid"
  task dorset_merge: :environment do
    bcp_slugs = %i[bournemouth christchurch poole]
    bcp_parent = LocalAuthority.find_by(slug: "bournemouth-christchurch-poole")

    bcp_slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)

      la.active_end_date = Time.parse("01-Apr-2019")
      la.active_note = "Merged into the unitary authority Bournemouth, Christchurch and Poole Council on 1 April 2019"
      la.succeeded_by_local_authority = bcp_parent
      la.save!
    end

    d_slugs = %i[east-dorset north-dorset purbeck west-dorset weymouth-and-portland]
    d_parent = LocalAuthority.find_by(slug: "dorset")

    d_slugs.each do |slug|
      la = LocalAuthority.find_by(slug:)

      la.active_end_date = Time.parse("01-Apr-2019")
      la.active_note = "Merged into the unitary authority Dorset Council on 1 April 2019"
      la.succeeded_by_local_authority = d_parent
      la.save!
    end
  end
end
