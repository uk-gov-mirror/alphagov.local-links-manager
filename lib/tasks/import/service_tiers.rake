namespace :import do
  namespace :service_tiers do
    desc "Remove duplicate ServiceTier entries"
    task remove_duplicates: :environment do
      duplicates = []
      checked = []

      ServiceTier.all.each do |st|
        st_duplicate = ServiceTier.where(tier_id: st.tier_id, service_id: st.service_id).where.not(id: st.id)
        st_duplicate = st_duplicate.last

        if st_duplicate.present?
          checked_ids = checked.map(&:id)

          if checked_ids.exclude?(st_duplicate.id)
            duplicates << st_duplicate
          end
        end
        checked << st
      end

      puts "Removing #{duplicates.count} ServiceTier entries"

      duplicates.each do |st|
        print '.'
        st.destroy
      end
    end
  end
end
